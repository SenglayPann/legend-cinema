import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../models/fnb_model.dart';
import '../models/showtime_model.dart';
import '../../presentation/state/seat_selection_state.dart';
import 'fnb_order_service.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FnbOrderService _fnbOrderService = FnbOrderService();

  /// Fetch all bookings for a specific showtime
  Future<List<BookingModel>> getBookingsByShowtime(String showtimeId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('showtimeId', isEqualTo: showtimeId)
          .where('bookingStatus', whereIn: ['confirmed', 'pending'])
          .get();

      return snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching bookings: $e");
      return [];
    }
  }

  /// Get all booked seat IDs for a showtime
  Future<Set<String>> getBookedSeatIds(String showtimeId) async {
    final bookings = await getBookingsByShowtime(showtimeId);
    final bookedSeats = <String>{};

    for (var booking in bookings) {
      for (var seat in booking.seats) {
        bookedSeats.add(seat.seatNumber);
      }
    }

    return bookedSeats;
  }

  /// Create a new booking with optional FnB order
  /// This is the main method to use for the checkout flow
  Future<BookingResult> createBookingWithFnb({
    required String userId,
    required String userEmail,
    required String userName,
    required ShowtimeModel showtime,
    required List<Seat> selectedSeats,
    required Map<String, int> seatPrices, // seatId -> price
    required double seatsTotal,
    required Map<String, FnbModel> fnbItems,
    required Map<String, int> fnbQuantities,
    required double fnbTotal,
    required String paymentMethod,
    required String paymentStatus, // 'paid', 'pending'
  }) async {
    try {
      // Generate booking code
      final bookingCode = _generateBookingCode();
      final now = Timestamp.now();
      final expiresAt = Timestamp.fromDate(
        DateTime.now().add(const Duration(hours: 24)),
      );

      String? fnbOrderId;

      // Create FnB order if there are items
      if (fnbItems.isNotEmpty && fnbQuantities.isNotEmpty) {
        final fnbOrderItems = fnbQuantities.entries.map((entry) {
          final item = fnbItems[entry.key]!;
          return FnbOrderItem.fromFnbModel(item, entry.value);
        }).toList();

        fnbOrderId = await _fnbOrderService.createFnbOrder(
          userId: userId,
          cinemaId: showtime.cinemaId,
          cinemaName: showtime.cinemaName,
          items: fnbOrderItems,
          totalAmount: fnbTotal,
        );
      }

      // Create booking seats
      final bookingSeats = selectedSeats.map((seat) {
        return BookingSeat(
          seatNumber: seat.label,
          row: seat.row,
          col: seat.column,
          type: seat.type.name,
          price: _getSeatPrice(seat.type, seatPrices),
        );
      }).toList();

      // Create booking
      final booking = BookingModel(
        id: '', // Will be set by Firestore
        userId: userId,
        userEmail: userEmail,
        userName: userName,
        showtimeId: showtime.id,
        movieId: showtime.movieId,
        movieTitle: showtime.movieTitle,
        cinemaId: showtime.cinemaId,
        cinemaName: showtime.cinemaName,
        hallId: showtime.hallId,
        hallNumber: showtime.hallNumber,
        showDateTime: showtime.showDateTime,
        showDate: showtime.showDate,
        showTime: showtime.showTime,
        seats: bookingSeats,
        seatCount: selectedSeats.length,
        fnbOrderId: fnbOrderId,
        seatsTotal: seatsTotal,
        fnbTotal: fnbTotal,
        totalAmount: seatsTotal + fnbTotal,
        bookingStatus: 'confirmed',
        paymentStatus: paymentStatus,
        paymentMethod: paymentMethod,
        bookingCode: bookingCode,
        qrCode: bookingCode, // Can be enhanced with actual QR data
        createdAt: now,
        updatedAt: now,
        expiresAt: expiresAt,
      );

      // Save booking to Firestore
      final docRef = await _firestore
          .collection('bookings')
          .add(booking.toMap());
      final bookingId = docRef.id;

      // Link FnB order to booking if exists
      if (fnbOrderId != null) {
        await _fnbOrderService.linkFnbOrderToBooking(fnbOrderId, bookingId);
      }

      // Add booked seats to showtime's booked seats collection
      await _addBookedSeatsToShowtime(
        showtime.id,
        selectedSeats.map((s) => s.label).toList(),
        bookingId,
      );

      return BookingResult(
        success: true,
        bookingId: bookingId,
        bookingCode: bookingCode,
        fnbOrderId: fnbOrderId,
      );
    } catch (e) {
      print("Error creating booking: $e");
      return BookingResult(success: false, error: e.toString());
    }
  }

  /// Add booked seats to showtime document for quick lookup
  Future<void> _addBookedSeatsToShowtime(
    String showtimeId,
    List<String> seatLabels,
    String bookingId,
  ) async {
    try {
      // Option 1: Add to a subcollection
      final batch = _firestore.batch();
      for (var seatLabel in seatLabels) {
        final seatRef = _firestore
            .collection('showtimes')
            .doc(showtimeId)
            .collection('booked_seats')
            .doc(seatLabel);
        batch.set(seatRef, {
          'bookingId': bookingId,
          'bookedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      print("Error adding booked seats to showtime: $e");
    }
  }

  /// Generate a unique booking code
  String _generateBookingCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    final timestamp = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(7);
    final randomPart = List.generate(
      4,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
    return 'LC$timestamp$randomPart';
  }

  double _getSeatPrice(SeatType type, Map<String, int> seatPrices) {
    switch (type) {
      case SeatType.regular:
        return (seatPrices['regular'] ?? 5).toDouble();
      case SeatType.vip:
        return (seatPrices['vip'] ?? 8).toDouble();
      case SeatType.twin:
        return (seatPrices['twin'] ?? 15).toDouble();
    }
  }

  /// Update booking payment status
  Future<bool> updatePaymentStatus(String bookingId, String status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'paymentStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print("Error updating payment status: $e");
      return false;
    }
  }

  /// Cancel a booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'bookingStatus': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print("Error cancelling booking: $e");
      return false;
    }
  }

  /// Get user's bookings
  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      print('snapshot.docs: ${snapshot.docs}');

      return snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching user bookings: $e");
      return [];
    }
  }
}

/// Result of booking creation
class BookingResult {
  final bool success;
  final String? bookingId;
  final String? bookingCode;
  final String? fnbOrderId;
  final String? error;

  BookingResult({
    required this.success,
    this.bookingId,
    this.bookingCode,
    this.fnbOrderId,
    this.error,
  });
}

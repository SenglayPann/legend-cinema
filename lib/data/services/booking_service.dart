import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  /// Create a new booking
  Future<String?> createBooking(BookingModel booking) async {
    try {
      final docRef = await _firestore
          .collection('bookings')
          .add(booking.toMap());
      return docRef.id;
    } catch (e) {
      print("Error creating booking: $e");
      return null;
    }
  }
}

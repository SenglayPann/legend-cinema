import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fnb_order_model.dart';
// Removed unused fnb_model import

/// Service for managing FnB orders in Firestore
class FnbOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new FnB order
  /// Returns the document ID of the created order
  Future<String?> createFnbOrder({
    required String userId,
    required String cinemaId,
    required String cinemaName,
    required List<FnbOrderItem> items,
    required double totalAmount,
    String? bookingId,
  }) async {
    try {
      final docRef = await _firestore.collection('fnb_orders').add({
        'userId': userId,
        'bookingId': bookingId,
        'cinemaId': cinemaId,
        'cinemaName': cinemaName,
        'items': items.map((e) => e.toMap()).toList(),
        'totalAmount': totalAmount,
        'status': 'pending', // pending, preparing, ready, collected
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Error creating FnB order: $e');
      return null;
    }
  }

  /// Update FnB order with booking ID after booking is created
  Future<bool> linkFnbOrderToBooking(
    String fnbOrderId,
    String bookingId,
  ) async {
    try {
      await _firestore.collection('fnb_orders').doc(fnbOrderId).update({
        'bookingId': bookingId,
      });
      return true;
    } catch (e) {
      print('Error linking FnB order to booking: $e');
      return false;
    }
  }

  /// Update FnB order status
  Future<bool> updateFnbOrderStatus(String fnbOrderId, String status) async {
    try {
      await _firestore.collection('fnb_orders').doc(fnbOrderId).update({
        'status': status,
      });
      return true;
    } catch (e) {
      print('Error updating FnB order status: $e');
      return false;
    }
  }

  /// Get standalone FnB orders (not attached to any booking) for a user
  Future<List<FnbOrderModel>> getUserStandaloneFnbOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('fnb_orders')
          .where('userId', isEqualTo: userId)
          // Ideally we would check for bookingId == null, but Firestore queries on null can be tricky if the field is missing.
          // However, we explicitly save it as null if not present in createFnbOrder (actually we just omit it or save null).
          // Let's filter client-side if needed, but 'bookingId' == null usually works if field exists and is null.
          // Or just fetch all and filter client side since user won't have millions of orders.
          .get();

      final orders = snapshot.docs
          .map((doc) => FnbOrderModel.fromMap(doc.data(), doc.id))
          .where((order) => order.bookingId == null || order.bookingId!.isEmpty)
          .toList();

      // Sort by creation date descending
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return orders;
    } catch (e) {
      print('Error fetching user FnB orders: $e');
      return [];
    }
  }
}

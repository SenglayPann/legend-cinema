import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fnb_model.dart';

/// Model for an FnB item with quantity in an order
class FnbOrderItem {
  final String fnbId;
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;

  FnbOrderItem({
    required this.fnbId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });

  factory FnbOrderItem.fromFnbModel(FnbModel model, int quantity) {
    return FnbOrderItem(
      fnbId: model.id,
      name: model.name,
      price: model.price,
      imageUrl: model.imageUrl,
      quantity: quantity,
    );
  }

  Map<String, dynamic> toMap() => {
    'fnbId': fnbId,
    'name': name,
    'price': price,
    'imageUrl': imageUrl,
    'quantity': quantity,
  };

  factory FnbOrderItem.fromMap(Map<String, dynamic> data) {
    return FnbOrderItem(
      fnbId: data['fnbId'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      quantity: data['quantity'] ?? 1,
    );
  }

  double get totalPrice => price * quantity;
}

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
}

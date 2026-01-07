import 'package:cloud_firestore/cloud_firestore.dart';
import 'fnb_model.dart';

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

  Map<String, dynamic> toMap() => {
    'fnbId': fnbId,
    'name': name,
    'price': price,
    'imageUrl': imageUrl,
    'quantity': quantity,
  };

  factory FnbOrderItem.fromMap(Map<String, dynamic> data) {
    return FnbOrderItem(
      fnbId: data['fnbId'] ?? data['id'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      quantity: data['quantity'] ?? 1,
    );
  }

  factory FnbOrderItem.fromFnbModel(FnbModel model, int quantity) {
    return FnbOrderItem(
      fnbId: model.id,
      name: model.name,
      price: model.price,
      imageUrl: model.imageUrl,
      quantity: quantity,
    );
  }

  double get totalPrice => price * quantity;
}

class FnbOrderModel {
  final String id;
  final String userId;
  final String? bookingId;
  final String cinemaId;
  final String cinemaName;
  final List<FnbOrderItem> items;
  final double totalAmount;
  final String status;
  final Timestamp createdAt;

  FnbOrderModel({
    required this.id,
    required this.userId,
    this.bookingId,
    required this.cinemaId,
    required this.cinemaName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  factory FnbOrderModel.fromMap(Map<String, dynamic> data, String id) {
    return FnbOrderModel(
      id: id,
      userId: data['userId'] ?? '',
      bookingId: data['bookingId'],
      cinemaId: data['cinemaId'] ?? '',
      cinemaName: data['cinemaName'] ?? '',
      items: (data['items'] as List<dynamic>? ?? [])
          .map((e) => FnbOrderItem.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bookingId': bookingId,
      'cinemaId': cinemaId,
      'cinemaName': cinemaName,
      'items': items.map((e) => e.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt,
    };
  }
}

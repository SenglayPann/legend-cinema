import 'package:cloud_firestore/cloud_firestore.dart';

class FnbOrderModel {
  final String id;
  final String userId;
  final String? bookingId;
  final String cinemaId;
  final String cinemaName;
  final List<FnbOrderItem> items;
  final double totalAmount;
  final String orderStatus; // 'pending' | 'completed' | 'cancelled'
  final String orderCode;
  final Timestamp createdAt;

  FnbOrderModel({
    required this.id,
    required this.userId,
    this.bookingId,
    required this.cinemaId,
    required this.cinemaName,
    required this.items,
    required this.totalAmount,
    required this.orderStatus,
    required this.orderCode,
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
      orderStatus: data['orderStatus'] ?? '',
      orderCode: data['orderCode'] ?? '',
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
      'orderStatus': orderStatus,
      'orderCode': orderCode,
      'createdAt': createdAt,
    };
  }
}

class FnbOrderItem {
  final String fnbId;
  final String name;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  FnbOrderItem({
    required this.fnbId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory FnbOrderItem.fromMap(Map<String, dynamic> data) {
    return FnbOrderItem(
      fnbId: data['fnbId'] ?? '',
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 0,
      unitPrice: (data['unitPrice'] ?? 0).toDouble(),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fnbId': fnbId,
      'name': name,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
    };
  }
}

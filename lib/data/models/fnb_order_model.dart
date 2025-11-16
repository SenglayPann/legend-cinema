import 'package:cloud_firestore/cloud_firestore.dart';
import './fnb_model.dart';

class FnbOrderModel {
  final String id;
  final String userId;
  final String? bookingId;
  final String cinemaId;
  final String cinemaName;
  final List<FnbModel> items;
  final double totalAmount;
  final Timestamp createdAt;

  FnbOrderModel({
    required this.id,
    required this.userId,
    this.bookingId,
    required this.cinemaId,
    required this.cinemaName,
    required this.items,
    required this.totalAmount,
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
          .map((e) => FnbModel.fromMap(Map<String, dynamic>.from(e), e['id'] ?? ''))
          .toList(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
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
      'createdAt': createdAt,
    };
  }
}


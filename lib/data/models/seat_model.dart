import 'package:cloud_firestore/cloud_firestore.dart';

class SeatModel {
  final String id;
  final String seatNumber;
  final String row;
  final int column;
  final String type;
  final String status;
  final double price;
  final String? reservedBy;
  final Timestamp? reservedAt;
  final Timestamp? reservationExpiry;

  SeatModel({
    required this.id,
    required this.seatNumber,
    required this.row,
    required this.column,
    required this.type,
    required this.status,
    required this.price,
    this.reservedBy,
    this.reservedAt,
    this.reservationExpiry,
  });

  factory SeatModel.fromMap(Map<String, dynamic> data, String id) {
    return SeatModel(
      id: id,
      seatNumber: data['seatNumber'] ?? '',
      row: data['row'] ?? '',
      column: data['column'] ?? 0,
      type: data['type'] ?? '',
      status: data['status'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      reservedBy: data['reservedBy'],
      reservedAt: data['reservedAt'],
      reservationExpiry: data['reservationExpiry'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'seatNumber': seatNumber,
      'row': row,
      'column': column,
      'type': type,
      'status': status,
      'price': price,
      'reservedBy': reservedBy,
      'reservedAt': reservedAt,
      'reservationExpiry': reservationExpiry,
    };
  }
}

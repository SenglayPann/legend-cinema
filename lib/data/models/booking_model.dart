import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final String showtimeId;
  final String movieId;
  final String movieTitle;
  final String cinemaId;
  final String cinemaName;
  final String hallId;
  final int hallNumber;
  final Timestamp showDateTime;
  final String showDate;
  final String showTime;
  final List<BookingSeat> seats;
  final int seatCount;
  final String? fnbOrderId;
  final double seatsTotal;
  final double fnbTotal;
  final double totalAmount;
  final String bookingStatus;
  final String paymentStatus;
  final String paymentMethod;
  final String bookingCode;
  final String qrCode;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final Timestamp expiresAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.showtimeId,
    required this.movieId,
    required this.movieTitle,
    required this.cinemaId,
    required this.cinemaName,
    required this.hallId,
    required this.hallNumber,
    required this.showDateTime,
    required this.showDate,
    required this.showTime,
    required this.seats,
    required this.seatCount,
    this.fnbOrderId,
    required this.seatsTotal,
    required this.fnbTotal,
    required this.totalAmount,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.bookingCode,
    required this.qrCode,
    required this.createdAt,
    required this.updatedAt,
    required this.expiresAt,
  });

  factory BookingModel.fromMap(Map<String, dynamic> data, String id) {
    return BookingModel(
      id: id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userName: data['userName'] ?? '',
      showtimeId: data['showtimeId'] ?? '',
      movieId: data['movieId'] ?? '',
      movieTitle: data['movieTitle'] ?? '',
      cinemaId: data['cinemaId'] ?? '',
      cinemaName: data['cinemaName'] ?? '',
      hallId: data['hallId'] ?? '',
      hallNumber: data['hallNumber'] ?? 0,
      showDateTime: data['showDateTime'] ?? Timestamp.now(),
      showDate: data['showDate'] ?? '',
      showTime: data['showTime'] ?? '',
      seats: (data['seats'] as List<dynamic>? ?? [])
          .map((s) => BookingSeat.fromMap(Map<String, dynamic>.from(s)))
          .toList(),
      seatCount: data['seatCount'] ?? 0,
      fnbOrderId: data['fnbOrderId'],
      seatsTotal: (data['seatsTotal'] ?? 0).toDouble(),
      fnbTotal: (data['fnbTotal'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      bookingStatus: data['bookingStatus'] ?? '',
      paymentStatus: data['paymentStatus'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
      bookingCode: data['bookingCode'] ?? '',
      qrCode: data['qrCode'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      expiresAt: data['expiresAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'showtimeId': showtimeId,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'cinemaId': cinemaId,
      'cinemaName': cinemaName,
      'hallId': hallId,
      'hallNumber': hallNumber,
      'showDateTime': showDateTime,
      'showDate': showDate,
      'showTime': showTime,
      'seats': seats.map((s) => s.toMap()).toList(),
      'seatCount': seatCount,
      'fnbOrderId': fnbOrderId,
      'seatsTotal': seatsTotal,
      'fnbTotal': fnbTotal,
      'totalAmount': totalAmount,
      'bookingStatus': bookingStatus,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'bookingCode': bookingCode,
      'qrCode': qrCode,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'expiresAt': expiresAt,
    };
  }
}

class BookingSeat {
  final String seatNumber;
  final String row;
  final int col;
  final String type;
  final double price;

  BookingSeat({
    required this.seatNumber,
    required this.row,
    required this.col,
    required this.type,
    required this.price,
  });

  factory BookingSeat.fromMap(Map<String, dynamic> data) {
    return BookingSeat(
      seatNumber: data['seatNumber'] ?? '',
      row: data['row'] ?? '',
      col: data['col'] ?? '',
      type: data['type'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
    'seatNumber': seatNumber,
    'row': row,
    'col': col,
    'type': type,
    'price': price,
  };
}

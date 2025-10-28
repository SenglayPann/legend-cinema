import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String userName;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final Timestamp createdAt;
  final int bookingCount;

  UserModel({
    required this.id,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.createdAt,
    required this.bookingCount,
  });

  // Factory constructor for creating a UserModel from a Firestore document map
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      userName: data['name'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      bookingCount: data['bookingCount'] ?? 0,
    );
  }

  // Convert a UserModel instance to a Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'createdAt': createdAt,
      'bookingCount': bookingCount,
    };
  }

  // Convert a UserModel instance to a JSON-serializable map for Shared Preferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      // Convert Timestamp to ISO 8601 string for storage
      'createdAt': createdAt.toDate().toIso8601String(),
      'bookingCount': bookingCount,
    };
  }

  // Factory constructor for creating a UserModel from a JSON map from Shared Preferences
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      userName: json['userName'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      // Convert ISO 8601 string back to Timestamp
      createdAt: Timestamp.fromDate(DateTime.parse(json['createdAt'])),
      bookingCount: json['bookingCount'] ?? 0,
    );
  }
}

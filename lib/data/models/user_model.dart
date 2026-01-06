import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String userName;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final Timestamp createdAt;
  final Timestamp? dateOfBirth; // newly added
  final int bookingCount;

  UserModel({
    required this.id,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.createdAt,
    this.dateOfBirth,
    required this.bookingCount,
  });

  // Factory constructor for creating a UserModel from a Firestore document map
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    Timestamp parseTs(dynamic v) {
      if (v == null) return Timestamp.now();
      if (v is Timestamp) return v;
      if (v is DateTime) return Timestamp.fromDate(v);
      if (v is int) return Timestamp.fromMillisecondsSinceEpoch(v);
      if (v is String) {
        final dt = DateTime.tryParse(v);
        if (dt != null) return Timestamp.fromDate(dt);
      }
      return Timestamp.now();
    }

    Timestamp? parseNullableTs(dynamic v) {
      if (v == null) return null;
      if (v is Timestamp) return v;
      if (v is DateTime) return Timestamp.fromDate(v);
      if (v is int) return Timestamp.fromMillisecondsSinceEpoch(v);
      if (v is String) {
        final dt = DateTime.tryParse(v);
        if (dt != null) return Timestamp.fromDate(dt);
      }
      return null;
    }

    return UserModel(
      id: documentId,
      // accept either 'userName' or legacy 'name'
      userName: data['userName'] ?? data['name'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      createdAt: parseTs(data['createdAt']),
      dateOfBirth: parseNullableTs(data['dateOfBirth']),
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
      'dateOfBirth': dateOfBirth,
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
      'dateOfBirth': dateOfBirth?.toDate().toIso8601String(),
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
      dateOfBirth: json['dateOfBirth'] != null
          ? Timestamp.fromDate(DateTime.parse(json['dateOfBirth']))
          : null,
      bookingCount: json['bookingCount'] ?? 0,
    );
  }

  UserModel copyWith({
    String? id,
    String? userName,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    Timestamp? createdAt,
    Timestamp? dateOfBirth,
    int? bookingCount,
  }) {
    return UserModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bookingCount: bookingCount ?? this.bookingCount,
    );
  }
}

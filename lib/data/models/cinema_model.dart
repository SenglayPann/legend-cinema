import 'package:cloud_firestore/cloud_firestore.dart';

class CinemaModel {
  final String id;
  final String name;
  final GeoPoint location;
  final String address;
  final String city;
  final String openHour;
  final String closeHour;
  final List<String> facilities;
  final int hallCount;

  CinemaModel({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    required this.city,
    required this.openHour,
    required this.closeHour,
    required this.facilities,
    required this.hallCount,
  });

  factory CinemaModel.fromMap(Map<String, dynamic> data, String id) {
    return CinemaModel(
      id: id,
      name: data['name'] ?? '',
      location: data['location'] ?? const GeoPoint(0, 0),
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      openHour: data['openHour'] ?? '',
      closeHour: data['closeHour'] ?? '',
      facilities: List<String>.from(data['facilities'] ?? []),
      hallCount: data['hallCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'address': address,
      'city': city,
      'openHour': openHour,
      'closeHour': closeHour,
      'facilities': facilities,
      'hallCount': hallCount,
    };
  }
}

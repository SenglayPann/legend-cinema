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

  final String imageUrl;

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
    required this.imageUrl,
  });

  factory CinemaModel.fromMap(Map<String, dynamic> data, String id) {
    // Handle location which might be a Map in JSON or GeoPoint in Firestore
    GeoPoint location;
    if (data['location'] is Map) {
      final locMap = data['location'] as Map;
      location = GeoPoint(
        (locMap['lat'] as num).toDouble(),
        (locMap['lng'] as num).toDouble(),
      );
    } else if (data['location'] is GeoPoint) {
      location = data['location'];
    } else {
      location = const GeoPoint(0, 0);
    }

    return CinemaModel(
      id: id,
      name: data['name'] ?? '',
      location: location,
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      openHour: data['openHour'] ?? '',
      closeHour: data['closeHour'] ?? '',
      facilities: List<String>.from(data['facilities'] ?? []),
      hallCount: data['hallCount'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
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

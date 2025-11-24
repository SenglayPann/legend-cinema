import 'package:cloud_firestore/cloud_firestore.dart';

class ShowtimeModel {
  final String id;
  final String movieId;
  final String movieTitle;
  final String moviePosterUrl;
  final String cinemaId;
  final String cinemaName;
  final String hallId;
  final int hallNumber;
  final String screenType;
  final Timestamp showDateTime;
  final String showDate;
  final String showTime;
  final String endTime;
  final List<String> features;

  ShowtimeModel({
    required this.id,
    required this.movieId,
    required this.movieTitle,
    required this.moviePosterUrl,
    required this.cinemaId,
    required this.cinemaName,
    required this.hallId,
    required this.hallNumber,
    required this.screenType,
    required this.showDateTime,
    required this.showDate,
    required this.showTime,
    required this.endTime,
    required this.features,
  });

  factory ShowtimeModel.fromMap(Map<String, dynamic> data, String id) {
    return ShowtimeModel(
      id: id,
      movieId: data['movieId'] ?? '',
      movieTitle: data['movieTitle'] ?? '',
      moviePosterUrl: data['moviePosterUrl'] ?? '',
      cinemaId: data['cinemaId'] ?? '',
      cinemaName: data['cinemaName'] ?? '',
      hallId: data['hallId'] ?? '',
      hallNumber: data['hallNumber'] ?? 0,
      screenType: data['screenType'] ?? '',
      showDateTime: data['showDateTime'] ?? Timestamp.now(),
      showDate: data['showDate'] ?? '',
      showTime: data['showTime'] ?? '',
      endTime: data['endTime'] ?? '',
      features: List<String>.from(data['features'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'movieId': movieId,
      'movieTitle': movieTitle,
      'moviePosterUrl': moviePosterUrl,
      'cinemaId': cinemaId,
      'cinemaName': cinemaName,
      'hallId': hallId,
      'hallNumber': hallNumber,
      'screenType': screenType,
      'showDateTime': showDateTime,
      'showDate': showDate,
      'showTime': showTime,
      'endTime': endTime,
      'features': features,
    };
  }
}

class Pricing {
  final double regular;
  final double vip;
  final double goldClass;

  Pricing({required this.regular, required this.vip, required this.goldClass});

  factory Pricing.fromMap(Map<String, dynamic> data) {
    return Pricing(
      regular: (data['regular'] ?? 0).toDouble(),
      vip: (data['vip'] ?? 0).toDouble(),
      goldClass: (data['goldClass'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'regular': regular,
        'vip': vip,
        'goldClass': goldClass,
      };
}

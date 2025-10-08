import 'package:cloud_firestore/cloud_firestore.dart';

class MovieModel {
  final String id;
  final String title;
  final String titleLowercase;
  final List<String> genres;
  final int duration;
  final String rating;
  final String language;
  final List<String> subtitles;
  final String posterUrl;
  final String backdropUrl;
  final String trailerUrl;
  final String description;
  final Timestamp releaseDate;
  final String status;
  final int popularity;

  MovieModel({
    required this.id,
    required this.title,
    required this.titleLowercase,
    required this.genres,
    required this.duration,
    required this.rating,
    required this.language,
    required this.subtitles,
    required this.posterUrl,
    required this.backdropUrl,
    required this.trailerUrl,
    required this.description,
    required this.releaseDate,
    required this.status,
    required this.popularity,
  });

  factory MovieModel.fromMap(Map<String, dynamic> data, String id) {
    return MovieModel(
      id: id,
      title: data['title'] ?? '',
      titleLowercase: data['titleLowercase'] ?? '',
      genres: List<String>.from(data['genres'] ?? []),
      duration: data['duration'] ?? 0,
      rating: data['rating'] ?? '',
      language: data['language'] ?? '',
      subtitles: List<String>.from(data['subtitles'] ?? []),
      posterUrl: data['posterUrl'] ?? '',
      backdropUrl: data['backdropUrl'] ?? '',
      trailerUrl: data['trailerUrl'] ?? '',
      description: data['description'] ?? '',
      releaseDate: data['releaseDate'] ?? Timestamp.now(),
      status: data['status'] ?? '',
      popularity: data['popularity'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'titleLowercase': titleLowercase,
      'genres': genres,
      'duration': duration,
      'rating': rating,
      'language': language,
      'subtitles': subtitles,
      'posterUrl': posterUrl,
      'backdropUrl': backdropUrl,
      'trailerUrl': trailerUrl,
      'description': description,
      'releaseDate': releaseDate,
      'status': status,
      'popularity': popularity,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie_model.dart';

class MovieService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch Banners (Movies)
  Future<List<MovieModel>> getBanners() async {
    try {
      // Fetch movies that are flagged as banners, or just fetch some movies
      // For now, we'll just fetch the first few movies from the 'movies' collection
      final snapshot = await _firestore.collection('movies').limit(5).get();
      return snapshot.docs
          .map((doc) => MovieModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching banners: $e");
      return [];
    }
  }

  // Fetch Cinemas
  Future<List<String>> getCinemaNames() async {
    try {
      final snapshot = await _firestore.collection('cinemas').get();
      List<String> names = ['All Cinemas'];
      names.addAll(snapshot.docs.map((doc) => doc['name'] as String));
      print("fetching cinemas: $names");
      return names;
    } catch (e) {
      print("Error fetching cinemas: $e");
      return ['All Cinemas'];
    }
  }

  // Fetch Now Showing Movies (only movies with at least one upcoming showtime)
  Future<List<MovieModel>> getNowShowingMovies() async {
    try {
      // First get all movies with status 'showing'
      final moviesSnapshot = await _firestore
          .collection('movies')
          .where('status', isEqualTo: 'showing')
          .get();

      final allMovies = moviesSnapshot.docs
          .map((doc) => MovieModel.fromMap(doc.data(), doc.id))
          .toList();

      // Filter to only movies that have at least one upcoming showtime
      final now = Timestamp.now();
      final moviesWithUpcomingShowtimes = <MovieModel>[];

      for (var movie in allMovies) {
        final showtimeSnapshot = await _firestore
            .collection('showtimes')
            .where('movieId', isEqualTo: movie.id)
            .where('showDateTime', isGreaterThanOrEqualTo: now)
            .limit(1) // We only need to check if at least one exists
            .get();

        if (showtimeSnapshot.docs.isNotEmpty) {
          moviesWithUpcomingShowtimes.add(movie);
        }
      }

      return moviesWithUpcomingShowtimes;
    } catch (e) {
      print("Error fetching now showing movies: $e");
      return [];
    }
  }

  // Fetch Coming Soon Movies
  Future<List<MovieModel>> getComingSoonMovies() async {
    try {
      final snapshot = await _firestore
          .collection('movies')
          .where('status', isEqualTo: 'upcoming')
          .get();

      return snapshot.docs
          .map((doc) => MovieModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching coming soon movies: $e");
      return [];
    }
  }

  // Fetch Movie by ID
  Future<MovieModel?> getMovieById(String id) async {
    try {
      final doc = await _firestore.collection('movies').doc(id).get();
      if (doc.exists) {
        return MovieModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print("Error fetching movie by id: $e");
      return null;
    }
  }
}

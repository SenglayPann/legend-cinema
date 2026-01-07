import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie_model.dart';
import '../models/showtime_model.dart';

class MovieService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch Banners (Movies)
  Future<List<MovieModel>> getBanners() async {
    try {
      // Reuse getNowShowingMovies to ensure banners are watchable
      // We can limit the number of banners if needed, e.g., top 5
      final nowShowing = await getNowShowingMovies();
      return nowShowing;
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

  // Fetch Showtimes for a Movie
  Future<List<ShowtimeModel>> getShowtimes(String movieId) async {
    try {
      final now = Timestamp.now();
      final snapshot = await _firestore
          .collection('showtimes')
          .where('movieId', isEqualTo: movieId)
          .where('showDateTime', isGreaterThanOrEqualTo: now)
          .get();

      return snapshot.docs
          .map((doc) => ShowtimeModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching showtimes: $e");
      return [];
    }
  }
}

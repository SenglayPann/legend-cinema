import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/showtime_model.dart';

class ShowtimeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ShowtimeModel>> getShowtimesForMovie(String movieId) async {
    try {
      final now = Timestamp.now();
      final snapshot = await _firestore
          .collection('showtimes')
          .where('movieId', isEqualTo: movieId)
          .where('showDateTime', isGreaterThanOrEqualTo: now)
          .orderBy('showDateTime')
          .get();

      print("--------->Showtimes snapshot: $snapshot");
      return snapshot.docs
          .map((doc) => ShowtimeModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching showtimes: $e");
      return [];
    }
  }
}

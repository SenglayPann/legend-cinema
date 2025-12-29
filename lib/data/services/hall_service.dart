import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hall_model.dart';

class HallService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch a specific hall by its ID
  Future<HallModel?> getHallById(String hallId) async {
    try {
      final doc = await _firestore.collection('halls').doc(hallId).get();
      if (doc.exists && doc.data() != null) {
        return HallModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print("Error fetching hall: $e");
      return null;
    }
  }

  /// Fetch all halls for a specific cinema
  Future<List<HallModel>> getHallsByCinema(String cinemaId) async {
    try {
      final snapshot = await _firestore
          .collection('halls')
          .where('cinemaId', isEqualTo: cinemaId)
          .get();
      return snapshot.docs
          .map((doc) => HallModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching halls: $e");
      return [];
    }
  }
}

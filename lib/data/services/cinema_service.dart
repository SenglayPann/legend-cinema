import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cinema_model.dart';

class CinemaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch Cinemas
  Future<List<CinemaModel>> getCinemas() async {
    try {
      final snapshot = await _firestore.collection('cinemas').get();
      return snapshot.docs
          .map((doc) => CinemaModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching cinemas: $e");
      // Fallback mock data
      return [];
    }
  }
}

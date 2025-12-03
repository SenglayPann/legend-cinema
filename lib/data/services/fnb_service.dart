import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fnb_model.dart';

class FnbService {
  final CollectionReference _fnbCollection = FirebaseFirestore.instance
      .collection('fnb');

  Future<List<FnbModel>> getFnbItems() async {
    try {
      final querySnapshot = await _fnbCollection.get();
      return querySnapshot.docs.map((doc) {
        return FnbModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print("Error fetching F&B items: $e");
      return [];
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/offer_model.dart';

class OfferService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<OfferModel>> getOffers() async {
    try {
      final snapshot = await _firestore.collection('offers').get();
      print("Offers fetched successfully: ${snapshot.docs.length}");
      return snapshot.docs
          .map((doc) => OfferModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching offers: $e");
      return [];
    }
  }
}

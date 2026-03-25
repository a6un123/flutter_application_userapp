import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_userapp/data/models/productmodel/productmodel.dart';

class ProductRepository {
  final _db = FirebaseFirestore.instance;
  final String _collection = 'products';

  // Stream all products in real-time from Firestore
  Stream<List<Productmodel>> getProducts() {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => Productmodel.fromFirestore(doc)).toList(),
        );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_userapp/data/models/usermodel/usermodel.dart';

class UserRepository {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // Stream current user in real-time
  Stream<UserModel?> streamCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);
    return _db
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // Update profile — name + phone
  Future<void> updateProfile({
    required String uid,
    required String name,
    String phone = '',
  }) async {
    await _db.collection('users').doc(uid).update({
      'name': name,
      'phone': phone,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _auth.currentUser?.updateDisplayName(name);
  }
}

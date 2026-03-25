import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── LOGIN ──────────────────────────────────────────────
  Future<User?> login({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    return credential.user;
  }

  // ── REGISTER USER ──────────────────────────────────────
  Future<User?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    final user = credential.user;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });
      await user.updateDisplayName(name.trim());
    }
    return user;
  }

  // ── REGISTER ADMIN ─────────────────────────────────────
  Future<User?> registerAdmin({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    final user = credential.user;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });
      await user.updateDisplayName(name.trim());
    }
    return user;
  }

  // ── GET USER ROLE ──────────────────────────────────────
  Future<String> getUserRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['role'] ?? 'user';
  }

  // ── LOGOUT ─────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
  }
}

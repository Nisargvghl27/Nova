import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------- SIGN UP ----------------
  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user != null) {
        await _createUserDocument(user);
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // ---------------- LOGIN ----------------
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      rethrow;
    }
  }

  // ---------------- LOGOUT ----------------
  Future<void> logout() async {
    try {
      // This triggers the StreamBuilder in main.dart automatically
      await _auth.signOut();
    } catch (e) {
      print("Logout Error: $e");
      rethrow;
    }
  }

  // ---------------- CREATE USER DOC ----------------
  Future<void> _createUserDocument(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);

    await userRef.set({
      'uid': user.uid,
      'email': user.email,
      'name': user.email!.split('@')[0],
      'createdAt': FieldValue.serverTimestamp(),
      'totalBalance': 0.0,
      'totalIncome': 0.0,
      'totalExpense': 0.0,
    });
  }

  User? get currentUser => _auth.currentUser;
}
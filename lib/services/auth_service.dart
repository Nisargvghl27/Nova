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
        // 🔹 Create Firestore user document
        await _createUserDocument(user);

        // 🔹 Send email verification (EMAIL OTP LINK)
        await user.sendEmailVerification();

        // 🔹 IMPORTANT: logout until email is verified
        await _auth.signOut();
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
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

      final user = cred.user;

      if (user == null) {
        throw Exception("Login failed");
      }

      // 🔄 Refresh user state
      await user.reload();
      final refreshedUser = _auth.currentUser!;

      // 🔒 Block unverified users
      if (!refreshedUser.emailVerified) {
        await _auth.signOut();
        throw Exception("Please verify your email before logging in.");
      }

      return refreshedUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // ---------------- RESEND VERIFICATION EMAIL ----------------
  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // ---------------- LOGOUT ----------------
  Future<void> logout() async {
    try {
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

  // ---------------- CURRENT USER ----------------
  User? get currentUser => _auth.currentUser;
}

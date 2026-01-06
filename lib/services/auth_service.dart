import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  // ================= CURRENT USER =================
  User? get currentUser => _auth.currentUser;

  // ================= SIGN UP (EMAIL) =================
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
        await _createUserIfNotExists(user);
        await user.sendEmailVerification();
        await _auth.signOut(); // force verify first
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Signup failed");
    }
  }

  // ================= LOGIN (EMAIL) =================
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
      if (user == null) throw Exception("Login failed");

      await user.reload();
      final refreshedUser = _auth.currentUser!;

      if (!refreshedUser.emailVerified) {
        await _auth.signOut();
        throw Exception("Please verify your email before logging in.");
      }

      return refreshedUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Login failed");
    }
  }

  // ================= GOOGLE SIGN IN =================
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn();

      if (googleUser == null) return null; // cancelled

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _auth.signInWithCredential(credential);

      final user = userCredential.user;

      if (user != null) {
        await _createUserIfNotExists(user);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Google sign-in failed");
    }
  }

  // ================= UPDATE PROFILE =================
  Future<void> updateProfile({required String name}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("No user logged in");

      await user.updateDisplayName(name);

      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await user.reload();
    } catch (e) {
      throw Exception("Profile update failed: $e");
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw Exception("Logout failed");
    }
  }

  // ================= RESEND EMAIL VERIFICATION =================
  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // ================= CREATE USER (SAFE) =================
  Future<void> _createUserIfNotExists(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      await userRef.set({
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName ?? user.email!.split('@')[0],
        'photoUrl': user.photoURL,
        'biometric': false,

        // Wallet defaults
        'totalBalance': 0.0,
        'totalIncome': 0.0,
        'totalExpense': 0.0,

        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}

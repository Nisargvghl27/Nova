import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  // ================= CURRENT USER =================
  User? get currentUser => _auth.currentUser;

  // ================= SIGN UP =================
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
        await user.sendEmailVerification();
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Signup failed");
    }
  }

  // ================= LOGIN =================
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
      throw Exception(e.message);
    }
  }

  Future<void> updateProfile({
    required String name,
    String? phone,
    String? bio,
    String? location,
    String? dob,
    String? profession,
    String? username,
    double? savingsGoal,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("No user logged in");

      await user.updateDisplayName(name);

      final Map<String, dynamic> data = {
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (phone != null) data['phone'] = phone;
      if (bio != null) data['bio'] = bio;
      if (location != null) data['location'] = location;
      if (dob != null) data['dob'] = dob;
      if (profession != null) data['profession'] = profession;
      if (username != null) data['username'] = username;
      if (savingsGoal != null) data['savingsGoal'] = savingsGoal;

      await _firestore.collection('users').doc(user.uid).set(data, SetOptions(merge: true));

      await user.reload();
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // ---------------- CHANGE PASSWORD ----------------
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("No user logged in");
      if (user.email == null) throw Exception("User email not found");

      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Current password is incorrect.');
      } else if (e.code == 'weak-password') {
        throw Exception('New password is too weak.');
      } else if (e.code == 'requires-recent-login') {
        throw Exception('Please log out and log in again to change password.');
      }
      throw Exception(e.message ?? 'Password update failed');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ---------------- SAVE IMAGE AS BASE64 ----------------
  Future<void> saveProfileImageAsBase64(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final bytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(bytes);

      await _firestore.collection('users').doc(user.uid).update({
        'base64Photo': base64Image,
        'photoUrl': null, 
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }

  // ---------------- DELETE PROFILE IMAGE ----------------
  Future<void> deleteProfileImage() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'base64Photo': FieldValue.delete(),
        'photoUrl': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  // ---------------- LOGOUT ----------------
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
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
      'name': user.displayName ?? user.email!.split('@')[0],
      'createdAt': FieldValue.serverTimestamp(),
      'totalBalance': 0.0,
      'totalIncome': 0.0,
      'totalExpense': 0.0,
      'phone': '',
      'bio': '',
      'location': '',
      'profession': '',
      'username': '',
      'dob': '',
      'savingsGoal': 0.0,
    });
  }

  // ---------------- GOOGLE SIGN IN ----------------
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          await _createUserDocument(user);
        }
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }
  
  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }
}
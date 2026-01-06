// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn(
//     scopes: ['email'],
//   );


//   // ================= CURRENT USER =================
//   User? get currentUser => _auth.currentUser;

//   // ================= SIGN UP (EMAIL) =================
//   Future<User?> signUp({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final cred = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       final user = cred.user;

//       if (user != null) {
//         await _createUserDocument(user);
//         await user.sendEmailVerification();
//         await _auth.signOut();
//       }

//       return user;
//     } on FirebaseAuthException catch (e) {
//       throw Exception(e.message ?? "Signup failed");
//     }
//   }

//   // ================= LOGIN (EMAIL) =================
//   Future<User?> login({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final cred = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       final user = cred.user;
//       if (user == null) throw Exception("Login failed");

//       await user.reload();
//       final refreshedUser = _auth.currentUser!;

//       if (!refreshedUser.emailVerified) {
//         await _auth.signOut();
//         throw Exception("Please verify your email before logging in.");
//       }

//       return refreshedUser;
//     } on FirebaseAuthException catch (e) {
//       throw Exception(e.message);
//     }
//   }

//   // ---------------- UPDATE PROFILE (NEW) ----------------
//   Future<void> updateProfile({required String name}) async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) throw Exception("No user logged in");

//       // 1. Update Firebase Auth Display Name
//       await user.updateDisplayName(name);
      
//       // 2. Update Firestore User Document
//       await _firestore.collection('users').doc(user.uid).update({
//         'name': name,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
      
//       // 3. Reload user to refresh local state
//       await user.reload();
//     } catch (e) {
//       throw Exception('Failed to update profile: $e');
//     }
//   }

//   // ---------------- RESEND VERIFICATION EMAIL ----------------
//   Future<void> resendVerificationEmail() async {
//     final user = _auth.currentUser;
//     if (user != null && !user.emailVerified) {
//       await user.sendEmailVerification();
//     }
//   }

//   // ---------------- LOGOUT ----------------
//   Future<void> logout() async {
//     try {
//       await _auth.signOut();
//     } catch (e) {
//       print("Logout Error: $e");
//       rethrow;
//     }
//   }

//   // ---------------- CREATE USER DOC ----------------
//   Future<void> _createUserDocument(User user) async {
//     final userRef = _firestore.collection('users').doc(user.uid);

//     await userRef.set({
//       'uid': user.uid,
//       'email': user.email,
//       'name': user.email!.split('@')[0],
//       'createdAt': FieldValue.serverTimestamp(),
//       'totalBalance': 0.0,
//       'totalIncome': 0.0,
//       'totalExpense': 0.0,
//     });
//   }

//   // ---------------- GOOGLE SIGN IN ----------------
//   Future<User?> signInWithGoogle() async {
//     try {
//       final GoogleSignIn googleSignIn = GoogleSignIn();
//       final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

//       if (googleUser == null) {
//         return null;
//       }

//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;

//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       final userCredential = await _auth.signInWithCredential(credential);
//       final user = userCredential.user;

//       if (user != null) {
//         final doc =
//             await _firestore.collection('users').doc(user.uid).get();

//         if (!doc.exists) {
//           await _createUserDocument(user);
//         }
//       }

//       return user;
//     } on FirebaseAuthException catch (e) {
//       throw Exception(e.message);
//     }
//   }

//   // ---------------- CURRENT USER ----------------
//   User? get currentUser => _auth.currentUser;
// }

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
        await _createUserDocument(user);
        await user.sendEmailVerification();
        await _auth.signOut();
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
      throw Exception(e.message);
    }
  }

  // ---------------- UPDATE PROFILE (NEW) ----------------
  Future<void> updateProfile({required String name}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("No user logged in");

      // 1. Update Firebase Auth Display Name
      await user.updateDisplayName(name);

      // 2. Update Firestore User Document
      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 3. Reload user to refresh local state
      await user.reload();
    } catch (e) {
      throw Exception('Failed to update profile: $e');
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

  // ---------------- GOOGLE SIGN IN ----------------
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Fixed: Removed duplicate variable declaration here
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final doc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!doc.exists) {
          await _createUserDocument(user);
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }
}
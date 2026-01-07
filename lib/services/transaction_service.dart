// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/transaction_model.dart';

// class TransactionService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   String get _uid {
//     final user = _auth.currentUser;
//     if (user == null) {
//       throw Exception("User not logged in");
//     }
//     return user.uid;
//   }

//   // 🔹 Helper: Get Current User Email
//   String? get _currentUserEmail => _auth.currentUser?.email;

//   CollectionReference<Map<String, dynamic>> get _txRef =>
//       _firestore.collection('users').doc(_uid).collection('transactions');

//   DocumentReference<Map<String, dynamic>> get _userRef =>
//       _firestore.collection('users').doc(_uid);

//   // ==========================================
//   // 🔹 CORE: RECALCULATE STATS (The Dynamic Fix)
//   // ==========================================
//   Future<void> _recalculateUserStats() async {
//     try {
//       // 1. Get all active transactions (not deleted)
//       final snapshot = await _txRef.where('isDeleted', isEqualTo: false).get();

//       double income = 0;
//       double expense = 0;

//       for (var doc in snapshot.docs) {
//         final data = doc.data();
//         final double amount = (data['amount'] as num).toDouble();
//         final String type = data['type']; // 'credit' or 'debit'

//         if (type == 'credit') {
//           income += amount;
//         } else {
//           expense += amount;
//         }
//       }

//       final balance = income - expense;

//       // 2. Update the main User Document in Firestore
//       await _userRef.update({
//         'totalIncome': income,
//         'totalExpense': expense,
//         'totalBalance': balance,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
      
//     } catch (e) {
//       print("Error recalculating stats: $e");
//     }
//   }

//   // ---------------- EXISTING METHODS (Updated) ----------------

//   // 隼 CHECK DUPLICATE
//   Future<bool> _exists(TransactionModel tx) async {
//     final snapshot = await _txRef
//         .where('fingerprint', isEqualTo: tx.fingerprint)
//         .limit(1)
//         .get();
//     return snapshot.docs.isNotEmpty;
//   }

//   // 隼 ADD TRANSACTION
//   Future<void> addTransaction(TransactionModel tx) async {
//     final isDuplicate = await _exists(tx);
//     if (isDuplicate) return;
    
//     await _txRef.add(tx.toMap());
    
//     // 🔄 Update Stats
//     await _recalculateUserStats();
//   }

//   // 🔹 SOFT DELETE
//   Future<void> deleteTransaction(String txId) async {
//     await _txRef.doc(txId).update({'isDeleted': true});
    
//     // 🔄 Update Stats
//     await _recalculateUserStats();
//   }

//   // 🔹 RESTORE
//   Future<void> restoreTransaction(String txId) async {
//     await _txRef.doc(txId).update({'isDeleted': false});
    
//     // 🔄 Update Stats
//     await _recalculateUserStats();
//   }

//   // 🔹 PERMANENT DELETE
//   Future<void> deletePermanently(String txId) async {
//     await _txRef.doc(txId).delete();
    
//     // 🔄 Update Stats
//     await _recalculateUserStats();
//   }

//   // 隼 UPDATE
//   Future<void> updateTransaction(
//     String txId,
//     Map<String, dynamic> data,
//   ) async {
//     await _txRef.doc(txId).update(data);
    
//     // 🔄 Update Stats
//     await _recalculateUserStats();
//   }

//   // 隼 STREAM
//   Stream<List<TransactionModel>> transactionsStream() {
//     return _txRef
//         .orderBy('date', descending: true)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs
//           .map((doc) => TransactionModel.fromMap(doc.id, doc.data()))
//           .toList();
//     });
//   }
  
//   // 隼 BATCH IMPORT (CSV/SMS)
//   Future<void> addTransactionsBatch(List<TransactionModel> txs) async {
//     final batch = FirebaseFirestore.instance.batch();
//     for (final tx in txs) {
//       final docRef = _txRef.doc();
//       batch.set(docRef, tx.toMap());
//     }
//     await batch.commit();
    
//     // 🔄 Update Stats
//     await _recalculateUserStats();
//   }

//   // ---------------- WALLET METHODS ----------------

//   // 2. 🔹 TOP UP WALLET
//   Future<void> topUpWallet(double amount) async {
//     final tx = TransactionModel(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       title: 'Wallet Top Up',
//       amount: amount,
//       date: DateTime.now(),
//       category: 'Income', 
//       type: 'credit',
//       source: 'manual',
//       note: 'Self Top Up',
//       createdAt: Timestamp.now(),
//     );
//     await addTransaction(tx); // This already calls recalculate
//   }

//   // 3. 🔹 SEND MONEY (Transfer)
//   Future<void> sendMoney({required String receiverEmail, required double amount}) async {
//     final senderEmail = _currentUserEmail;
//     if (senderEmail == null) throw Exception("You are not logged in");
//     if (senderEmail == receiverEmail) throw Exception("Cannot send money to yourself");

//     // A. Find Receiver
//     final userQuery = await _firestore
//         .collection('users')
//         .where('email', isEqualTo: receiverEmail)
//         .limit(1)
//         .get();

//     if (userQuery.docs.isEmpty) {
//       throw Exception("User with email $receiverEmail not found");
//     }

//     final receiverDoc = userQuery.docs.first;
//     final receiverUid = receiverDoc.id;

//     // B. Create Transaction IDs
//     final now = DateTime.now();
//     final senderTxId = now.millisecondsSinceEpoch.toString();
//     final receiverTxId = "${now.millisecondsSinceEpoch}_rec";

//     // C. Create Models
//     final senderTx = TransactionModel(
//       id: senderTxId,
//       title: 'Sent to $receiverEmail',
//       amount: amount,
//       date: now,
//       category: 'Others',
//       type: 'debit',
//       source: 'wallet',
//       note: 'Transfer to $receiverEmail',
//       createdAt: Timestamp.now(),
//     );

//     final receiverTx = TransactionModel(
//       id: receiverTxId,
//       title: 'Received from $senderEmail',
//       amount: amount,
//       date: now,
//       category: 'Income',
//       type: 'credit',
//       source: 'wallet',
//       note: 'Transfer from $senderEmail',
//       createdAt: Timestamp.now(),
//     );

//     // D. Perform Batch Write
//     final batch = _firestore.batch();

//     // 1. Add Tx to Sender
//     final senderTxRef = _txRef.doc(senderTxId);
//     batch.set(senderTxRef, senderTx.toMap());

//     // 2. Add Tx to Receiver
//     final receiverTxRef = _firestore
//         .collection('users')
//         .doc(receiverUid)
//         .collection('transactions')
//         .doc(receiverTxId);
//     batch.set(receiverTxRef, receiverTx.toMap());

//     // 3. Update Receiver Stats Directly (Atomic Increment)
//     // We do this so the receiver's DB updates immediately without them needing to open the app
//     final receiverUserRef = _firestore.collection('users').doc(receiverUid);
//     batch.update(receiverUserRef, {
//       'totalIncome': FieldValue.increment(amount),
//       'totalBalance': FieldValue.increment(amount),
//     });

//     await batch.commit();

//     // 4. Update Sender Stats (Recalculate to be safe)
//     await _recalculateUserStats();
//   }

//   // 4. 🔹 REQUEST MONEY
//   Future<void> requestMoney({required String fromEmail, required double amount}) async {
//     final senderEmail = _currentUserEmail;
//     if (senderEmail == null) return;
    
//     // Check if user exists
//     final userQuery = await _firestore
//         .collection('users')
//         .where('email', isEqualTo: fromEmail)
//         .limit(1)
//         .get();

//     if (userQuery.docs.isEmpty) {
//       throw Exception("User $fromEmail not found");
//     }
    
//     // Success (No DB write for requests in this version)
//     return;
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return user.uid;
  }

  String? get _currentUserEmail => _auth.currentUser?.email;

  CollectionReference<Map<String, dynamic>> get _txRef =>
      _firestore.collection('users').doc(_uid).collection('transactions');

  DocumentReference<Map<String, dynamic>> get _userRef =>
      _firestore.collection('users').doc(_uid);

  // ==========================================
  // 🔹 RECALCULATE STATS
  // ==========================================
  Future<void> recalculateUserStats() async {
    try {
      final snapshot = await _txRef.where('isDeleted', isEqualTo: false).get();
      double income = 0;
      double expense = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] is int) 
            ? (data['amount'] as int).toDouble() 
            : (data['amount'] as double? ?? 0.0);
        final String type = data['type'] ?? 'debit';

        if (type == 'credit') {
          income += amount;
        } else {
          expense += amount;
        }
      }

      await _userRef.update({
        'totalIncome': income,
        'totalExpense': expense,
        'totalBalance': income - expense,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (e.toString().contains('NOT_FOUND')) {
         await _userRef.set({
           'totalIncome': 0.0, 'totalExpense': 0.0, 'totalBalance': 0.0
         }, SetOptions(merge: true));
         await recalculateUserStats();
      }
    }
  }

  // ---------------- CRUD METHODS ----------------
  Future<void> addTransaction(TransactionModel tx) async {
    await _txRef.add(tx.toMap());
    await recalculateUserStats();
  }

  Future<void> deleteTransaction(String txId) async {
    await _txRef.doc(txId).update({'isDeleted': true});
    await recalculateUserStats();
  }

  Future<void> restoreTransaction(String txId) async {
    await _txRef.doc(txId).update({'isDeleted': false});
    await recalculateUserStats();
  }

  Future<void> deletePermanently(String txId) async {
    await _txRef.doc(txId).delete();
    await recalculateUserStats();
  }

  Future<void> updateTransaction(String txId, Map<String, dynamic> data) async {
    await _txRef.doc(txId).update(data);
    await recalculateUserStats();
  }

  Future<void> addTransactionsBatch(List<TransactionModel> txs) async {
    final batch = _firestore.batch();
    for (final tx in txs) {
      batch.set(_txRef.doc(), tx.toMap());
    }
    await batch.commit();
    await recalculateUserStats();
  }

  // ---------------- WALLET FEATURES ----------------

  Future<void> topUpWallet(double amount) async {
    final tx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Wallet Top Up',
      amount: amount,
      date: DateTime.now(),
      category: 'Income',
      type: 'credit',
      source: 'manual',
      note: 'Self Top Up',
      createdAt: Timestamp.now(),
    );
    await addTransaction(tx);
  }

  Future<void> sendMoney({required String receiverEmail, required double amount}) async {
    final senderEmail = _currentUserEmail;
    if (senderEmail == null) throw Exception("Not logged in");
    if (senderEmail == receiverEmail) throw Exception("Cannot send to self");

    // 1. Find Receiver
    final userQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: receiverEmail)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) throw Exception("User not found");

    final receiverUid = userQuery.docs.first.id;
    final now = DateTime.now();
    
    // 2. Create Transaction Records
    final senderTx = TransactionModel(
      id: now.millisecondsSinceEpoch.toString(),
      title: 'Sent to $receiverEmail',
      amount: amount,
      date: now,
      category: 'Others',
      type: 'debit',
      source: 'wallet',
      note: 'Transfer',
      createdAt: Timestamp.now(),
    );

    final receiverTx = TransactionModel(
      id: "${now.millisecondsSinceEpoch}_rec",
      title: 'Received from $senderEmail',
      amount: amount,
      date: now,
      category: 'Income',
      type: 'credit',
      source: 'wallet',
      note: 'Transfer',
      createdAt: Timestamp.now(),
    );

    // 3. Batch Write
    final batch = _firestore.batch();
    batch.set(_txRef.doc(senderTx.id), senderTx.toMap());
    
    final receiverRef = _firestore.collection('users').doc(receiverUid);
    batch.set(receiverRef.collection('transactions').doc(receiverTx.id), receiverTx.toMap());
    
    batch.update(receiverRef, {
      'totalIncome': FieldValue.increment(amount),
      'totalBalance': FieldValue.increment(amount),
    });

    await batch.commit();
    await recalculateUserStats();
  }

  // ---------------- REQUEST SYSTEM (NEW) ----------------

  // 1. Send Request
  Future<void> requestMoney({required String fromEmail, required double amount}) async {
    final senderEmail = _currentUserEmail;
    if (senderEmail == null) return;
    
    // Find the person we are asking money FROM
    final userQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: fromEmail)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) throw Exception("User $fromEmail not found");
    final targetUid = userQuery.docs.first.id;

    // Write to THEIR notifications
    await _firestore.collection('users').doc(targetUid).collection('notifications').add({
      'type': 'money_request',
      'fromEmail': senderEmail, // Who is asking (Me)
      'amount': amount,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 2. Get Notifications Stream
  Stream<QuerySnapshot> getNotificationsStream() {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 3. Handle Request (Accept/Decline)
  Future<void> handleRequest(String docId, bool accept, Map<String, dynamic> data) async {
    if (accept) {
      final String requesterEmail = data['fromEmail'];
      final double amount = (data['amount'] as num).toDouble();
      
      // Pay the money
      await sendMoney(receiverEmail: requesterEmail, amount: amount);
    }
    
    // Delete the notification after handling
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('notifications')
        .doc(docId)
        .delete();
  }

  // ---------------- STREAMS ----------------
  Stream<List<TransactionModel>> transactionsStream() {
    return _txRef.orderBy('date', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TransactionModel.fromMap(doc.id, doc.data())).toList();
    });
  }
}
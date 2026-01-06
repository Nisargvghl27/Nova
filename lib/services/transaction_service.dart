import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _txRef =>
      _firestore.collection('users').doc(_uid).collection('transactions');

  // 隼 CHECK DUPLICATE USING FINGERPRINT
  Future<bool> _exists(TransactionModel tx) async {
    final snapshot = await _txRef
        .where('fingerprint', isEqualTo: tx.fingerprint)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // 隼 ADD TRANSACTION
  Future<void> addTransaction(TransactionModel tx) async {
    final isDuplicate = await _exists(tx);
    if (isDuplicate) return;
    await _txRef.add(tx.toMap());
  }

  // 🔹 UPDATED: SOFT DELETE TRANSACTION
  Future<void> deleteTransaction(String txId) async {
    await _txRef.doc(txId).update({'isDeleted': true});
  }

  // 🔹 NEW: RESTORE TRANSACTION
  Future<void> restoreTransaction(String txId) async {
    await _txRef.doc(txId).update({'isDeleted': false});
  }

  // 🔹 NEW: PERMANENT DELETE
  Future<void> deletePermanently(String txId) async {
    await _txRef.doc(txId).delete();
  }

  // 隼 UPDATE TRANSACTION
  Future<void> updateTransaction(
    String txId,
    Map<String, dynamic> data,
  ) async {
    await _txRef.doc(txId).update(data);
  }

  // 隼 STREAM ALL TRANSACTIONS (Includes deleted ones, filtered in UI)
  Stream<List<TransactionModel>> transactionsStream() {
    return _txRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // 隼 ONE-TIME FETCH
  Future<List<TransactionModel>> fetchTransactions() async {
    final snapshot =
        await _txRef.orderBy('date', descending: true).get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromMap(doc.id, doc.data()))
        .toList();
  }
  
  // 隼 ADD BATCH
  Future<void> addTransactionsBatch(List<TransactionModel> txs) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final tx in txs) {
      final docRef = _txRef.doc();
      batch.set(docRef, tx.toMap());
    }
    await batch.commit();
  }
}
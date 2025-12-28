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

  // 🔹 CHECK DUPLICATE USING FINGERPRINT
  Future<bool> _exists(TransactionModel tx) async {
    final snapshot = await _txRef
        .where('fingerprint', isEqualTo: tx.fingerprint)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // 🔹 ADD TRANSACTION (WITH DUPLICATE PROTECTION)
  Future<void> addTransaction(TransactionModel tx) async {
    final isDuplicate = await _exists(tx);

    if (isDuplicate) {
      // silently skip duplicate
      return;
    }

    await _txRef.add(tx.toMap());
  }

  // 🔹 DELETE TRANSACTION
  Future<void> deleteTransaction(String txId) async {
    await _txRef.doc(txId).delete();
  }

  // 🔹 UPDATE TRANSACTION
  Future<void> updateTransaction(
    String txId,
    Map<String, dynamic> data,
  ) async {
    await _txRef.doc(txId).update(data);
  }

  // 🔹 STREAM ALL TRANSACTIONS (REAL-TIME)
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

  // 🔹 ONE-TIME FETCH (OPTIONAL)
  Future<List<TransactionModel>> fetchTransactions() async {
    final snapshot =
        await _txRef.orderBy('date', descending: true).get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromMap(doc.id, doc.data()))
        .toList();
  }
}

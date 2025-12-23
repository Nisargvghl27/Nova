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

  // 🔹 ADD TRANSACTION
  Future<void> addTransaction(TransactionModel tx) async {
    await _txRef.add(tx.toMap());
  }

  // 🔹 DELETE TRANSACTION
  Future<void> deleteTransaction(String txId) async {
    await _txRef.doc(txId).delete();
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
  // 🔹 UPDATE TRANSACTION
  Future<void> updateTransaction(
    String txId,
    Map<String, dynamic> data,
  ) async {
    await _txRef.doc(txId).update(data);
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

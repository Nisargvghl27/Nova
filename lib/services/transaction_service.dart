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
      'fromEmail': senderEmail,
      'amount': amount,
      'status': 'pending',
      'isRead': false, // 🔹 FIX: Added this field so the query finds it!
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

  // 3. Mark As Read 🔹 NEW METHOD
  Future<void> markNotificationsAsRead() async {
    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // 4. Handle Request (Accept/Decline)
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
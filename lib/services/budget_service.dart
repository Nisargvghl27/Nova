import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _budgetRef =>
      _firestore.collection('users').doc(_uid).collection('budgets');

  CollectionReference<Map<String, dynamic>> get _txRef =>
      _firestore.collection('users').doc(_uid).collection('transactions');

  // ---------------- SAVE BUDGET ----------------
  Future<void> setBudget(String category, double amount) async {
    await _budgetRef.doc(category).set({
      'category': category,
      'amount': amount,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------------- STREAM BUDGETS ----------------
  Stream<Map<String, double>> getBudgetsStream() {
    return _budgetRef.snapshots().map((snapshot) {
      final Map<String, double> budgets = {};
      for (var doc in snapshot.docs) {
        budgets[doc.id] = (doc.data()['amount'] as num).toDouble();
      }
      return budgets;
    });
  }

  // ---------------- PREDICTION LOGIC ----------------
  /// Calculates suggested budget using Weighted Average of last 3 months.
  /// Formula: (Month1(Recent) * 3 + Month2 * 2 + Month3 * 1) / 6
  Future<Map<String, double>> calculatePredictions() async {
    final now = DateTime.now();
    // Fetch last 90 days (approx 3 months)
    final ninetyDaysAgo = now.subtract(const Duration(days: 90));

    try {
      // 1. Fetch Transactions
      // We filter by date here. 'type' and 'isDeleted' are filtered in Dart 
      // to avoid needing complex Firestore composite indexes immediately.
      final snapshot = await _txRef
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(ninetyDaysAgo))
          .get();

      final transactions = snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.id, doc.data()))
          .where((tx) => tx.type == 'debit' && !tx.isDeleted)
          .toList();

      // 2. Group by Category and Month Index (0=Current/Recent, 1=Last, 2=Oldest)
      final Map<String, Map<int, double>> categoryMonthlyTotals = {};

      for (var tx in transactions) {
        // Calculate days difference to group into 30-day buckets
        final daysDiff = now.difference(tx.date).inDays;
        final monthIndex = (daysDiff / 30).floor(); 

        if (monthIndex > 2) continue; // Skip if older than 90 days

        categoryMonthlyTotals.putIfAbsent(tx.category, () => {0: 0.0, 1: 0.0, 2: 0.0});
        categoryMonthlyTotals[tx.category]![monthIndex] = 
            (categoryMonthlyTotals[tx.category]![monthIndex] ?? 0) + tx.amount;
      }

      // 3. Calculate Weighted Average
      final Map<String, double> predictions = {};

      categoryMonthlyTotals.forEach((category, months) {
        final recent = months[0] ?? 0; // Last 30 days (High weight)
        final mid = months[1] ?? 0;    // 30-60 days ago (Medium weight)
        final old = months[2] ?? 0;    // 60-90 days ago (Low weight)

        double prediction;
        
        // Edge Case: If user is new and only has recent data, don't drag average down with zeros
        if (mid == 0 && old == 0) {
          prediction = recent;
        } else if (old == 0) {
          // Only 2 months of data: (Recent * 2 + Mid * 1) / 3
          prediction = ((recent * 2) + (mid * 1)) / 3;
        } else {
          // Full 3 months Weighted Average
          prediction = ((recent * 3) + (mid * 2) + (old * 1)) / 6;
        }

        // Add a 5% buffer for safety and round to nearest 10
        prediction = prediction * 1.05;
        predictions[category] = (prediction / 10).ceil() * 10;
      });

      return predictions;
    } catch (e) {
      print("Prediction Error: $e");
      return {};
    }
  }
}
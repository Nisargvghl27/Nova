import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

/// 🔹 Global Provider
final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<TransactionModel>>(
  (ref) => TransactionNotifier(),
);

class TransactionNotifier
    extends StateNotifier<List<TransactionModel>> {
  TransactionNotifier() : super([]) {
    _loadFromHive();
    _syncFromFirestore();
  }

  final TransactionService _service = TransactionService();

  // ================= LOAD FROM HIVE =================
  void _loadFromHive() {
    final box = Hive.box<TransactionModel>('transactions');
    state = box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // ================= FIRESTORE SYNC =================
  void _syncFromFirestore() {
    _service.transactionsStream().listen((remoteTxs) async {
      final box = Hive.box<TransactionModel>('transactions');

      for (final tx in remoteTxs) {
        // 🔹 Dedup using fingerprint
        final exists = box.values.any(
          (local) => local.fingerprint == tx.fingerprint,
        );

        if (!exists) {
          await box.put(tx.id, tx);
        }
      }

      state = box.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  // ================= ADD =================
  Future<void> addTransaction(TransactionModel tx) async {
    final box = Hive.box<TransactionModel>('transactions');

    final exists = box.values.any(
      (t) => t.fingerprint == tx.fingerprint,
    );

    if (exists) return;

    await _service.addTransaction(tx);
    await box.put(tx.id, tx);

    state = box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // ================= UPDATE =================
  Future<void> updateTransaction(
    String id,
    Map<String, dynamic> data,
  ) async {
    final box = Hive.box<TransactionModel>('transactions');
    final tx = box.get(id);
    if (tx == null) return;

    final updated = tx.copyWith(
      title: data['title'],
      amount: data['amount'],
      category: data['category'],
      note: data['note'],
      type: data['type'],
    );

    await _service.updateTransaction(id, data);
    await box.put(id, updated);

    state = box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // ================= DELETE =================
  Future<void> deleteTransaction(String id) async {
    final box = Hive.box<TransactionModel>('transactions');

    await _service.deleteTransaction(id);
    await box.delete(id);

    state = box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}

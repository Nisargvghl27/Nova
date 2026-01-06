import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title; // Swiggy, Uber, Salary

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String category; // Food, Travel, Bills, Other

  @HiveField(5)
  final String type; // debit | credit

  @HiveField(6)
  final String source; // manual | csv | sms

  @HiveField(7)
  final String note; // optional

  /// ✅ Hive-safe (DO NOT use Timestamp in Hive)
  @HiveField(8)
  final DateTime createdAt;

  /// 🔹 Used for duplicate detection (CSV / SMS / Firestore sync)
  @HiveField(9)
  final String fingerprint;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    required this.source,
    required this.note,
    required this.createdAt,
    String? fingerprint,
  }) : fingerprint =
            fingerprint ??
            _generateFingerprint(
              date: date,
              amount: amount,
              title: title,
            );

  /// 🔹 Generate fingerprint (date + amount + title)
  static String _generateFingerprint({
    required DateTime date,
    required double amount,
    required String title,
  }) {
    return '${date.toIso8601String().substring(0, 10)}'
        '_${amount.toStringAsFixed(2)}'
        '_${title.toLowerCase().trim()}';
  }

  // ================= FIRESTORE → MODEL =================

  factory TransactionModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return TransactionModel(
      id: id,
      title: data['title'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      category: data['category'] ?? 'Other',
      type: data['type'] ?? 'debit',
      source: data['source'] ?? 'manual',
      note: data['note'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      fingerprint: data['fingerprint'],
    );
  }

  // ================= MODEL → FIRESTORE =================

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'category': category,
      'type': type,
      'source': source,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
      'fingerprint': fingerprint,
    };
  }

  // ================= COPY WITH (CRITICAL) =================

  TransactionModel copyWith({
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    String? type,
    String? source,
    String? note,
  }) {
    return TransactionModel(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      type: type ?? this.type,
      source: source ?? this.source,
      note: note ?? this.note,
      createdAt: createdAt,
      fingerprint: fingerprint, // ❗ NEVER regenerate
    );
  }
}

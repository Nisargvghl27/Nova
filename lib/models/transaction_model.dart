import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String title;        // Swiggy, Uber, Salary
  final double amount;
  final DateTime date;
  final String category;     // Food, Travel, Bills, Other
  final String type;         // debit | credit
  final String source;       // manual | csv | sms
  final String note;         // optional
  final Timestamp createdAt;
  final String fingerprint;
  final bool isDeleted;      // 🔹 NEW: Soft delete flag

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
    this.isDeleted = false,  // 🔹 Default to false
    String? fingerprint,
  }) : fingerprint = fingerprint ?? _generateFingerprint(
          date: date,
          amount: amount,
          title: title,
        );

  /// 🔹 Generate fingerprint
  static String _generateFingerprint({
    required DateTime date,
    required double amount,
    required String title,
  }) {
    return '${date.toIso8601String().substring(0, 10)}'
        '_${amount.toStringAsFixed(2)}'
        '_${title.toLowerCase().trim()}';
  }

  /// 🔹 Convert Firestore → Model
  factory TransactionModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return TransactionModel(
      id: id,
      title: data['title'] ?? 'Unknown',
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      category: data['category'] ?? 'Others',
      type: data['type'] ?? 'debit',
      source: data['source'] ?? 'manual',
      note: data['note'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      fingerprint: data['fingerprint'],
      isDeleted: data['isDeleted'] ?? false, // 🔹 Read isDeleted
    );
  }

  /// 🔹 Convert Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'category': category,
      'type': type,
      'source': source,
      'note': note,
      'createdAt': createdAt,
      'fingerprint': fingerprint,
      'isDeleted': isDeleted, // 🔹 Save isDeleted
    };
  }

  /// 🔹 CopyWith for Editing
  TransactionModel copyWith({
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    String? type,
    String? source,
    String? note,
    Timestamp? createdAt,
    String? id,
    bool? isDeleted, // 🔹 Allow updating isDeleted
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      type: type ?? this.type,
      source: source ?? this.source,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      // Pass null to fingerprint to force regeneration if key fields change
      fingerprint: null, 
    );
  }
}
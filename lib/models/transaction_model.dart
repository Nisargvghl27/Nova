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
  final String fingerprint; // 🔹 NEW

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
  }) : fingerprint = fingerprint ?? _generateFingerprint(
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

  /// 🔹 Convert Firestore → Model
  factory TransactionModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return TransactionModel(
      id: id,
      title: data['title'],
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      category: data['category'],
      type: data['type'],
      source: data['source'],
      note: data['note'] ?? '',
      createdAt: data['createdAt'],
      fingerprint: data['fingerprint'], // 🔹 READ FROM FIRESTORE
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
      'fingerprint': fingerprint, // 🔹 STORE IN FIRESTORE
    };
  }
}

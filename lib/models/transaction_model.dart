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
  });

  /// 🔹 Convert Firestore → Model
  factory TransactionModel.fromMap(String id, Map<String, dynamic> data) {
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
    };
  }
}

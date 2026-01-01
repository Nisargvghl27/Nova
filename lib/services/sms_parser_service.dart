import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';

class SmsParserService {
  /// 🔹 Parse multiple pasted SMS
  List<TransactionModel> parseBulkSms(String bulkText) {
    final lines = bulkText.split(RegExp(r'\n+'));
    final List<TransactionModel> transactions = [];

    for (final line in lines) {
      final tx = parse(line.trim());
      if (tx != null) transactions.add(tx);
    }

    return transactions;
  }

  /// 🔹 Parse single SMS
  TransactionModel? parse(String smsText) {
    final text = smsText.toLowerCase();

    // ❌ Ignore OTP / spam
    if (text.contains('otp') ||
        text.contains('verification') ||
        text.contains('password')) {
      return null;
    }

    // 💰 Amount
    final amountRegex =
        RegExp(r'(rs\.?|inr|₹)\s?([\d,]+\.?\d*)');
    final amountMatch = amountRegex.firstMatch(text);
    if (amountMatch == null) return null;

    final amount = double.tryParse(
      amountMatch.group(2)!.replaceAll(',', ''),
    );
    if (amount == null) return null;

    // 🔄 Debit / Credit
    final bool isDebit = text.contains('debit') ||
        text.contains('spent') ||
        text.contains('withdrawn');

    final bool isCredit = text.contains('credit') || text.contains('receive');

    if (!isDebit && !isCredit) return null;

    // 🏪 Merchant (supports: by / at / to)
    String merchant = 'Bank Transaction';

// Remove currency noise first
final cleanedText = text
    .replaceAll(RegExp(r'(rs\.?|inr|₹)\s?\d+'), '')
    .replaceAll(RegExp(r'\d+'), '');

// Strong merchant patterns (priority order)
final merchantPatterns = [
  RegExp(r'(?:at|to|for)\s+([a-zA-Z &._-]+)'),
  RegExp(r'(?:by)\s+([a-zA-Z &._-]+)'),
];

for (final pattern in merchantPatterns) {
  final match = pattern.firstMatch(cleanedText);
  if (match != null) {
    merchant = match.group(1)!
        .trim()
        .split(' ')
        .first; // single clean word
    break;
  }
}

// Final safety check
if (merchant.toLowerCase() == 'rs') {
  merchant = 'Bank Transaction';
}



    // 📅 Date (MULTI-FORMAT SAFE)
    DateTime date = DateTime.now();

    final dateRegex =
        RegExp(r'(\d{2}[-/]\d{2}[-/]\d{2,4})');
    final dateMatch = dateRegex.firstMatch(text);

    if (dateMatch != null) {
      final rawDate = dateMatch.group(1)!;

      final formats = [
        'dd-MM-yyyy',
        'dd/MM/yyyy',
        'dd-MM-yy',
        'dd/MM/yy',
      ];

      for (final format in formats) {
        try {
          date = DateFormat(format).parseStrict(rawDate);
          break;
        } catch (_) {}
      }
    }

    // 💳 Payment type
    String paymentType = 'Unknown';
    if (text.contains('upi')) paymentType = 'UPI';
    if (text.contains('card')) paymentType = 'Card';
    if (text.contains('atm')) paymentType = 'ATM';

    return TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _capitalize(merchant),
      amount: amount,
      date: date,
      category: 'Other', // ML later
      type: isDebit ? 'debit' : 'credit',
      source: 'sms',
      note: paymentType,
      createdAt: Timestamp.now(),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

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
    final originalText = smsText;
    final text = smsText.toLowerCase();

    // ❌ Ignore OTP / spam
    if (text.contains('otp') ||
        text.contains('verification') ||
        text.contains('password')) {
      return null;
    }

    // 💰 Amount (Rs / INR / ₹)
    final amountRegex =
        RegExp(r'(rs\.?|inr|₹)\s?([\d,]+\.?\d*)');
    final amountMatch = amountRegex.firstMatch(text);
    if (amountMatch == null) return null;

    final amount = double.tryParse(
      amountMatch.group(2)!.replaceAll(',', ''),
    );
    if (amount == null || amount <= 0) return null;

    // 🔄 Debit / Credit
    final bool isDebit = text.contains('debit') ||
        text.contains('spent') ||
        text.contains('withdrawn') ||
        text.contains('paid');

    final bool isCredit =
        text.contains('credit') || text.contains('received');

    if (!isDebit && !isCredit) return null;

    // 🏪 MERCHANT EXTRACTION (ROBUST)
    String merchant = _extractMerchant(originalText);

    // 📅 DATE (MULTI FORMAT SAFE)
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

    // 💳 Payment Method
    String paymentType = 'Unknown';
    if (text.contains('upi')) paymentType = 'UPI';
    else if (text.contains('card')) paymentType = 'Card';
    else if (text.contains('atm')) paymentType = 'ATM';

    // ⚠️ IMPORTANT:
    // DO NOT generate your own ID
    // Firestore will generate document ID

    return TransactionModel(
      id: '', // 🔥 MUST be empty (Firestore doc ID used later)
      title: merchant,
      amount: amount,
      date: date,
      category: 'Other', // ML later
      type: isDebit ? 'debit' : 'credit',
      source: 'sms',
      note: paymentType,
      createdAt: DateTime.now(),
    );
  }

  // ================= MERCHANT LOGIC =================

  String _extractMerchant(String text) {
    final lower = text.toLowerCase();

    // Remove amount and numbers
    String cleaned = lower
        .replaceAll(RegExp(r'(rs\.?|inr|₹)\s?[\d,]+\.?\d*'), '')
        .replaceAll(RegExp(r'\d+'), '');

    final patterns = [
      RegExp(r'(?:to|at|for)\s+([a-zA-Z][a-zA-Z &._-]{2,})'),
      RegExp(r'(?:by)\s+([a-zA-Z][a-zA-Z &._-]{2,})'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(cleaned);
      if (match != null) {
        final merchant = match.group(1)!.trim().split(' ').first;
        return _capitalize(merchant);
      }
    }

    return 'Bank Transaction';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

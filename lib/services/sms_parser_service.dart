import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import 'category_service.dart';

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

    // 💰 Amount (INR / Rs / ₹)
    final amountRegex = RegExp(
      r'(rs\.?|inr|₹)\s*([\d,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    );

    final amountMatch = amountRegex.firstMatch(text);
    if (amountMatch == null) return null;

    final amount = double.tryParse(
      amountMatch.group(2)!.replaceAll(',', ''),
    );
    if (amount == null) return null;

    // 🔄 Debit / Credit detection
    final debitKeywords = [
      'debit',
      'spent',
      'paid',
      'payment',
      'purchase',
      'withdrawn',
      'txn',
      'deducted',
    ];

    final creditKeywords = [
      'credit',
      'credited',
      'received',
      'refund',
      'cashback',
      'salary',
    ];

    final bool isDebit =
    debitKeywords.any((word) => text.contains(word));
    final bool isCredit =
    creditKeywords.any((word) => text.contains(word));

    // 🚨 If nothing detected → assume debit (real-world behavior)
    final bool finalIsDebit = isCredit ? false : true;

    // 🏪 Merchant Detection
    String merchant = 'Bank Transaction';

    final normalizedText = text
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final merchantPatterns = [
      RegExp(r'paid to\s+([a-zA-Z0-9 &._-]+)'),
      RegExp(r'spent at\s+([a-zA-Z0-9 &._-]+)'),
      RegExp(r'at\s+([a-zA-Z0-9 &._-]+)'),
      RegExp(r'to\s+([a-zA-Z0-9 &._-]+)'),
      RegExp(r'for\s+([a-zA-Z0-9 &._-]+)'),
    ];

    for (final pattern in merchantPatterns) {
      final match = pattern.firstMatch(normalizedText);
      if (match != null) {
        merchant = match.group(1)!.trim();
        break;
      }
    }

    // 🧹 Cleanup noise
    merchant = merchant
        .replaceAll(RegExp(r'\bvia\b.*'), '')
        .replaceAll(RegExp(r'\bupi\b.*'), '')
        .replaceAll(RegExp(r'\bcard\b.*'), '')
        .replaceAll(RegExp(r'\bref\b.*'), '')
        .replaceAll(RegExp(r'\bno\b.*'), '')
        .trim();

    // 📱 Recharge detection
    if (text.contains('recharge') ||
        text.contains('prepaid') ||
        text.contains('postpaid')) {
      merchant = 'Mobile Recharge';
    }

    if (merchant.isEmpty || merchant.length < 3) {
      merchant = 'Bank Transaction';
    }

    // 📅 Date detection
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

    // 🧠 Category detection
    final category = CategoryService.detectCategory(
      merchant: merchant,
      smsText: smsText,
      isDebit: finalIsDebit,
    );

    return TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _capitalize(merchant),
      amount: amount,
      date: date,
      category: category,
      type: finalIsDebit ? 'debit' : 'credit',
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

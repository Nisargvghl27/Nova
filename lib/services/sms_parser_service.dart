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
      if (line.trim().isEmpty) continue;
      final tx = parse(line.trim());
      if (tx != null) transactions.add(tx);
    }

    return transactions;
  }

  /// 🔹 Parse single SMS
  TransactionModel? parse(String smsText) {
    String text = smsText.toLowerCase().trim();

    // ❌ Ignore OTP / spam / irrelevant messages
    if (text.contains('otp') ||
        text.contains('verification') ||
        text.contains('code') ||
        text.contains('password') ||
        text.contains('requested') ||
        text.contains('fail') ||
        text.contains('declined')) {
      return null;
    }

    // 💰 1. Amount Detection
    // Matches: Rs. 500, INR 500, Rs 500.00, INR 5,000, ₹500
    final amountRegex = RegExp(
      r'(?:rs\.?|inr|₹)\s*([\d,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    );

    final amountMatch = amountRegex.firstMatch(text);
    if (amountMatch == null) return null;

    String cleanAmount = amountMatch.group(1)!.replaceAll(',', '');
    final amount = double.tryParse(cleanAmount);
    if (amount == null) return null;

    // 🔄 2. Debit / Credit Detection
    final debitKeywords = [
      'debit', 'spent', 'paid', 'sent', 'purchas', 'withdraw', 
      'deduct', 'payment', 'transfer to'
    ];
    final creditKeywords = [
      'credit', 'received', 'refund', 'cashback', 'deposited', 
      'added', 'salary', 'transfer from'
    ];

    bool isDebit = debitKeywords.any((w) => text.contains(w));
    bool isCredit = creditKeywords.any((w) => text.contains(w));

    if (!isDebit && !isCredit) {
      if (text.contains(' to ')) isDebit = true;
    }
    
    final bool finalIsDebit = isCredit ? false : true;

    // 🏪 3. Merchant / Description Detection
    String merchant = '';
    
    // Remove common identifiers that mess up extraction
    String cleanText = text
        .replaceAll(RegExp(r'a/c\s*x+\d+'), '') 
        .replaceAll(RegExp(r'ref:?\s*\w+'), '') 
        .replaceAll(RegExp(r'txn:?\s*\w+'), '') 
        .replaceAll(RegExp(r'info:?\s*.*'), '') 
        .replaceAll(RegExp(r'\s+'), ' ');

    final merchantPatterns = [
      RegExp(r'paid to\s+([a-zA-Z0-9 &._-]+?)(?:\s+(?:on|via|using|from)|$)'),
      RegExp(r'spent at\s+([a-zA-Z0-9 &._-]+?)(?:\s+(?:on|via|using|from)|$)'),
      RegExp(r'sent to\s+([a-zA-Z0-9 &._-]+?)(?:\s+(?:on|via|using|from)|$)'),
      RegExp(r'transfer to\s+([a-zA-Z0-9 &._-]+?)(?:\s+(?:on|via|using|from)|$)'),
      RegExp(r'debited\s+.*?\s+to\s+([a-zA-Z0-9 &._-]+?)(?:\s+(?:on|via|using|from)|$)'),
      RegExp(r'credited\s+.*?\s+from\s+([a-zA-Z0-9 &._-]+?)(?:\s+(?:on|via|using|from)|$)'),
      RegExp(r'\bat\s+([a-zA-Z0-9 &._-]+?)(?:\s+(?:on|via|using|from)|$)'),
    ];

    for (final pattern in merchantPatterns) {
      final match = pattern.firstMatch(cleanText);
      if (match != null) {
        merchant = match.group(1)!.trim();
        if (merchant.length > 2) break;
      }
    }

    if (merchant.isEmpty) {
        if (text.contains('recharge')) merchant = 'Mobile Recharge';
        else if (text.contains('bill')) merchant = 'Bill Payment';
        else merchant = 'Bank Transaction';
    }

    merchant = _cleanMerchantName(merchant);

    // 📅 4. Date Detection (FIXED)
    DateTime date = _parseDate(text);

    // 💳 5. Payment Source
    String paymentType = 'Unknown';
    if (text.contains('upi')) paymentType = 'UPI';
    else if (text.contains('card') || text.contains('debit card')) paymentType = 'Card';
    else if (text.contains('atm')) paymentType = 'ATM';
    else if (text.contains('netbanking') || text.contains('net banking')) paymentType = 'NetBanking';

    // 🧠 6. Category Detection
    final category = CategoryService.detectCategory(
      merchant: merchant,
      smsText: smsText,
      isDebit: finalIsDebit,
    );

    return TransactionModel(
      // Unique ID: Timestamp + Amount Hash
      id: DateTime.now().millisecondsSinceEpoch.toString() + (amount * 100).toStringAsFixed(0),
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

  // 🛠️ Robust Date Parser
  DateTime _parseDate(String text) {
    // 1. Numeric Pattern (DD-MM-YYYY or DD/MM/YYYY)
    // Matches: 06-12-2025, 6/12/25, 06.12.2025
    final numericRegex = RegExp(r'\b(\d{1,2})[\s/\-.,]+(\d{1,2})[\s/\-.,]+(\d{2,4})\b');
    final numMatch = numericRegex.firstMatch(text);
    if (numMatch != null) {
      String d = numMatch.group(1)!;
      String m = numMatch.group(2)!;
      String y = numMatch.group(3)!;
      return _buildDate(d, m, y);
    }

    // 2. Alphanumeric Pattern (DD-Mon-YYYY)
    // Matches: 12 Jan 2025, 12-Jan-2025, 12th Jan 25
    final alphaRegex = RegExp(r'\b(\d{1,2})(?:st|nd|rd|th)?[\s/\-.,]+([a-z]{3,})[\s/\-.,]+(\d{2,4})\b');
    final alphaMatch = alphaRegex.firstMatch(text);
    if (alphaMatch != null) {
      String d = alphaMatch.group(1)!;
      String m = alphaMatch.group(2)!;
      String y = alphaMatch.group(3)!;
      return _buildDate(d, m, y);
    }

    // 3. Reverse Alphanumeric Pattern (Mon DD YYYY)
    // Matches: Jan 12 2025, Jan 12th 2025
    final revAlphaRegex = RegExp(r'\b([a-z]{3,})[\s/\-.,]+(\d{1,2})(?:st|nd|rd|th)?[\s/\-.,]+(\d{2,4})\b');
    final revAlphaMatch = revAlphaRegex.firstMatch(text);
    if (revAlphaMatch != null) {
      String m = revAlphaMatch.group(1)!;
      String d = revAlphaMatch.group(2)!;
      String y = revAlphaMatch.group(3)!;
      return _buildDate(d, m, y);
    }

    // 4. ISO Pattern (YYYY-MM-DD)
    // Matches: 2025-12-06
    final isoRegex = RegExp(r'\b(\d{4})[\s/\-.,]+(\d{1,2})[\s/\-.,]+(\d{1,2})\b');
    final isoMatch = isoRegex.firstMatch(text);
    if (isoMatch != null) {
      String y = isoMatch.group(1)!;
      String m = isoMatch.group(2)!;
      String d = isoMatch.group(3)!;
      return _buildDate(d, m, y);
    }

    // Fallback: Return today
    return DateTime.now();
  }

  DateTime _buildDate(String d, String m, String y) {
    try {
      // 1. Fix Year (e.g., "23" -> "2023")
      if (y.length == 2) y = '20$y';

      // 2. Convert Month Name to Number (e.g., "jan" -> "01")
      if (RegExp(r'[a-z]').hasMatch(m)) {
        m = _monthNameToNumber(m);
      } else {
        // Numeric Month Logic
        int monthInt = int.tryParse(m) ?? 0;
        int dayInt = int.tryParse(d) ?? 0;

        // Auto-fix US Date Format (MM-DD-YYYY) if Month > 12
        // Example: 06-15-2025 (15th month is impossible, so it must be 15th Day)
        if (monthInt > 12 && dayInt <= 12) {
          String temp = d;
          d = m;
          m = temp;
        }
      }

      // 3. Pad Day and Month (e.g., "1" -> "01")
      if (d.length == 1) d = '0$d';
      if (m.length == 1) m = '0$m';

      // 4. Parse Strict ISO Format
      return DateTime.parse('$y-$m-$d');
    } catch (e) {
      return DateTime.now();
    }
  }

  String _cleanMerchantName(String name) {
     String n = name.toLowerCase();
     n = n.replaceAll(RegExp(r'\b(via|on|using|through|from)\b.*'), '');
     n = n.replaceAll(RegExp(r'\b(imps|neft|rtgs|upi|mmt|inb)\b'), '');
     return _capitalize(n.trim());
  }

  String _monthNameToNumber(String month) {
    const months = {
      'jan': '01', 'feb': '02', 'mar': '03', 'apr': '04', 'may': '05', 'jun': '06',
      'jul': '07', 'aug': '08', 'sep': '09', 'oct': '10', 'nov': '11', 'dec': '12'
    };
    final shortName = month.length >= 3 ? month.substring(0, 3) : month;
    return months[shortName] ?? '01';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
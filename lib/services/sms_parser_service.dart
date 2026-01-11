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

    // 💰 1. SMART AMOUNT DETECTION FIRST
    // (We detect amount first to confirm it's a transaction before filtering)
    RegExp amountRegex = RegExp(r'(?:rs\.?|inr|₹)\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false);
    var amountMatch = amountRegex.firstMatch(text);

    if (amountMatch == null) {
      final contextAmountRegex = RegExp(
        r'(?:debited|credited|sent|paid|withdraw|spent|amt|amount)\s+(?:by|of)?\s*?([\d,]+(?:\.\d{1,2})?)', 
        caseSensitive: false
      );
      amountMatch = contextAmountRegex.firstMatch(text);
    }

    // If no amount is found, it's not a transaction we care about
    if (amountMatch == null) return null;

    String cleanAmount = amountMatch.group(1)!.replaceAll(',', '');
    final amount = double.tryParse(cleanAmount);
    if (amount == null) return null;

    // ❌ 2. SMART SPAM FILTER
    // Only block "OTP" if the message DOES NOT contain transaction keywords
    bool isTransaction = text.contains('credited') || 
                         text.contains('debited') || 
                         text.contains('spent') || 
                         text.contains('sent') || 
                         text.contains('paid');

    if (!isTransaction) {
      if (text.contains('otp') || 
          text.contains('verification') || 
          text.contains('code') || 
          (text.contains('fail') && !text.contains('failure')) || 
          text.contains('declined')) {
        return null;
      }
    }

    // ==========================================
    // 🔄 3. DEBIT / CREDIT DETECTION
    // ==========================================
    final debitKeywords = ['debit', 'spent', 'paid', 'sent', 'purchas', 'withdraw', 'deduct', 'trf to', 'transfer to'];
    final creditKeywords = ['credit', 'received', 'refund', 'cashback', 'deposited', 'added', 'salary', 'transfer from'];

    bool isCredit = creditKeywords.any((w) => text.contains(w));
    bool isDebit = debitKeywords.any((w) => text.contains(w));

    // Fallback: "Paid to" usually means Debit
    if (!isDebit && !isCredit) {
      if (text.contains(' to ')) isDebit = true;
    }
    
    final bool finalIsDebit = isCredit ? false : true;

    // ==========================================
    // 🏪 4. ADVANCED MERCHANT EXTRACTION
    // ==========================================
    String merchant = '';

    String cleanText = text
        .replaceAll(RegExp(r'ref\s*(?:no|num)?[:\s-]*[a-z0-9]+'), ' ') 
        .replaceAll(RegExp(r'upi\s*ref\s*[:\s-]*[a-z0-9]+'), ' ') 
        .replaceAll(RegExp(r'call\s*[:\s-]*\d+'), ' ') 
        .replaceAll(RegExp(r'helpline\s*[:\s-]*\d+'), ' ') 
        .replaceAll(RegExp(r'if\s+not\s+u\?'), ' ') 
        .replaceAll(RegExp(r'dear\s+upi\s+user'), ' ') 
        .replaceAll(RegExp(r'never\s+share\s+.*'), ' ') // Remove security warnings at end
        .replaceAll(RegExp(r'a/c\s*[x0-9]+'), ' ') 
        .replaceAll(RegExp(r'info:?\s*.*'), ' ') 
        .replaceAll(RegExp(r'thru\s+[a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'via\s+[a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' '); 

    final merchantPatterns = [
      RegExp(r'(?:from|to)\s+([a-zA-Z0-9 .&_-]+)'), // Generic from/to
      RegExp(r'(?:trf|transfer|sent|paid|pay)\s+to\s+([a-zA-Z0-9 .&_-]+)'),
      RegExp(r'(?:spent|purchase|transxn)\s+(?:at|on)\s+([a-zA-Z0-9 .&_-]+)'),
      RegExp(r'(?:for|info)\s+([a-zA-Z0-9 .&_-]+)'),
      RegExp(r'^([a-zA-Z0-9 .&_-]+?)\s+(?:debited|credited)'),
    ];

    for (final pattern in merchantPatterns) {
      final match = pattern.firstMatch(cleanText);
      if (match != null) {
        String rawName = match.group(1)!;
        final stopWords = [' and ', ' on ', ' ref', ' date', ' bal', ' vpa', ' from ', ' using ', ' via '];
        int endIndex = rawName.length;
        
        for (var word in stopWords) {
          final idx = rawName.indexOf(word);
          if (idx != -1 && idx < endIndex) endIndex = idx;
        }
        
        merchant = rawName.substring(0, endIndex).trim();
        if (merchant.length > 2 && !RegExp(r'^\d+$').hasMatch(merchant)) break;
      }
    }

    if (merchant.isEmpty || merchant.length < 3) {
      if (text.contains('swiggy')) merchant = 'Swiggy';
      else if (text.contains('zomato')) merchant = 'Zomato';
      else if (text.contains('uber')) merchant = 'Uber';
      else if (text.contains('ola')) merchant = 'Ola';
      else if (text.contains('blinkit')) merchant = 'Blinkit';
      else if (text.contains('zepto')) merchant = 'Zepto';
      else if (text.contains('jio')) merchant = 'Jio';
      else if (text.contains('airtel')) merchant = 'Airtel';
      else if (text.contains('vi ')) merchant = 'Vi';
      else if (text.contains('netflix')) merchant = 'Netflix';
      else if (text.contains('amazon')) merchant = 'Amazon';
      else if (text.contains('flipkart')) merchant = 'Flipkart';
      else if (text.contains('recharge')) merchant = 'Mobile Recharge';
      else if (text.contains('bill')) merchant = 'Bill Payment';
      else if (text.contains('upi')) merchant = 'UPI Transfer';
      else merchant = 'Unknown Transaction';
    }

    merchant = _capitalize(merchant);

    // ==========================================
    // 🧠 5. CATEGORY DETECTION
    // ==========================================
    final category = CategoryService.detectCategory(
      merchant: merchant,
      smsText: text,
      isDebit: finalIsDebit,
    );

    // ==========================================
    // 📅 6. ADVANCED DATE PARSING
    // ==========================================
    DateTime date = _parseDate(text);

    return TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: merchant,
      amount: amount,
      date: date,
      category: category,
      type: finalIsDebit ? 'debit' : 'credit',
      source: 'sms',
      note: 'Auto-detected',
      createdAt: Timestamp.now(),
    );
  }

  /// 📅 Parses multiple date formats
  DateTime _parseDate(String text) {
    try {
      // Pattern 1: Continuous Digits "08112025" (DDMMYYYY)
      final continuousRegex = RegExp(r'\b(\d{2})(\d{2})(\d{4})\b');
      final continuousMatch = continuousRegex.firstMatch(text);
      if (continuousMatch != null) {
        return _buildDate(continuousMatch.group(1)!, continuousMatch.group(2)!, continuousMatch.group(3)!);
      }

      // Pattern 2: Compact Date "08Jan26" or "08Jan2026"
      final compactRegex = RegExp(r'\b(\d{2})([a-zA-Z]{3})(\d{2,4})\b');
      final compactMatch = compactRegex.firstMatch(text);
      if (compactMatch != null) {
        return _buildDate(compactMatch.group(1)!, compactMatch.group(2)!, compactMatch.group(3)!);
      }

      // Pattern 3: Standard Date "08-01-26" or "08/01/2026"
      final numericRegex = RegExp(r'\b(\d{1,2})[\s/\-.,]+(\d{1,2})[\s/\-.,]+(\d{2,4})\b');
      final numMatch = numericRegex.firstMatch(text);
      if (numMatch != null) {
        return _buildDate(numMatch.group(1)!, numMatch.group(2)!, numMatch.group(3)!);
      }

      // Pattern 4: Text Date "08 Jan 26"
      final textRegex = RegExp(r'\b(\d{1,2})[\s/\-.,]+([a-zA-Z]{3,})[\s/\-.,]+(\d{2,4})\b');
      final textMatch = textRegex.firstMatch(text);
      if (textMatch != null) {
        return _buildDate(textMatch.group(1)!, textMatch.group(2)!, textMatch.group(3)!);
      }
    } catch (e) {
      // Ignore errors
    }
    return DateTime.now();
  }

  DateTime _buildDate(String d, String m, String y) {
    try {
      // Fix 2-digit years (26 -> 2026)
      if (y.length == 2) y = '20$y';

      // Parse Month
      int month = 1;
      if (RegExp(r'^\d+$').hasMatch(m)) {
        month = int.parse(m);
      } else {
        month = _monthNameToNumber(m);
      }

      return DateTime(int.parse(y), month, int.parse(d));
    } catch (_) {
      return DateTime.now();
    }
  }

  int _monthNameToNumber(String m) {
    const months = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
      'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12
    };
    return months[m.toLowerCase().substring(0, 3)] ?? 1;
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : '').join(' ');
  }
}
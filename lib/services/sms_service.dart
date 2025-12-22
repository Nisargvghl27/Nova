import 'package:flutter/material.dart'; // REQUIRED for Icons and Colors
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/transaction_model.dart';

class SmsService {
  final SmsQuery _query = SmsQuery();

  Future<List<Transaction>> getBankTransactions() async {
    final status = await Permission.sms.request();
    if (!status.isGranted) return [];

    final List<SmsMessage> messages = await _query.querySms(
      kinds: [SmsQueryKind.inbox],
      // count: 500, // Optional: Limit count if app is slow
    );

    List<Transaction> transactions = [];

    for (final msg in messages) {
      final body = msg.body ?? '';
      final sender = msg.address ?? '';
      final text = body.toLowerCase();

      // 1. Check if Sender looks like a Bank (Not a mobile number)
      final isBankSender = RegExp(r'[a-zA-Z]').hasMatch(sender) || sender.length <= 6;
      if (!isBankSender) continue;

      // 2. Check for Transaction Words
      final hasTxnWord = RegExp(
        r'\b(debited|credited|spent|withdrawn|paid|dr\b|cr\b|upi|imps|neft)\b',
      ).hasMatch(text);
      if (!hasTxnWord) continue;

      // 3. Filter OTPs unless they explicitly say Debited/Credited
      if (text.contains('otp') &&
          !text.contains('debited') &&
          !text.contains('credited')) {
        continue;
      }

      // 4. Extract Amount
      final amountMatch = RegExp(
        r'(debited|credited|spent|paid|withdrawn)[^\d₹]{0,20}(rs\.?|₹|inr)?\s*(\d+(?:,\d+)*(?:\.\d+)?)',
        caseSensitive: false,
      ).firstMatch(text);

      if (amountMatch == null) continue;

      final amount = double.tryParse(amountMatch.group(3)!.replaceAll(',', '')) ?? 0;
      if (amount < 10) continue; // Ignore small amounts

      // 5. Spam Filter
      final isSpam = text.contains('loan') ||
          text.contains('approved') ||
          text.contains('offer') ||
          text.contains('apply') ||
          text.contains('limit');
      if (isSpam) continue;

      // 6. Expense vs Income
      final isIncome =
          amountMatch.group(1)!.toLowerCase().contains('credit') ||
          amountMatch.group(1)!.toLowerCase().contains('cr');

      final merchant = _extractMerchant(body, sender);
      final category = _detectCategory(body, merchant); // Detect category once

      transactions.add(
        Transaction(
          id: msg.id?.toString() ?? DateTime.now().toIso8601String(),
          amount: amount,
          date: msg.date ?? DateTime.now(),
          merchant: merchant,
          isExpense: !isIncome,
          category: category,
          title: merchant,
          // ✅ FIX: Added Icon and Color here
          icon: _getIconForCategory(category),
          color: _getColorForCategory(category),
        ),
      );
    }

    return transactions;
  }

  String _extractMerchant(String body, String sender) {
    final s = sender.toUpperCase();

    if (s.contains("HDFC")) return "HDFC Bank";
    if (s.contains("SBI")) return "SBI Bank";
    if (s.contains("ICICI")) return "ICICI Bank";
    if (s.contains("AXIS")) return "Axis Bank";
    if (s.contains("BOB")) return "Bank of Baroda";
    if (s.contains("KOTAK")) return "Kotak Bank";
    if (s.contains("YES")) return "Yes Bank";
    if (s.contains("IDFC")) return "IDFC Bank";
    if (s.contains("PAYTM")) return "Paytm";
    if (s.contains("GPAY") || s.contains("GOOGLE")) return "Google Pay";
    if (s.contains("PHONEPE")) return "PhonePe";
    if (s.contains("AMAZON")) return "Amazon";
    if (s.contains("FLIPKART")) return "Flipkart";

    final match = RegExp(
      r'(?:to|at|paid|via)\s+([A-Za-z0-9\.\-\s]+)',
      caseSensitive: false,
    ).firstMatch(body);

    if (match != null) {
      String res = match.group(1)!.trim();
      res = res.replaceAll(
        RegExp(r'(rs|inr|₹|success|txn|upi)', caseSensitive: false),
        '',
      );
      if (res.length > 25) res = res.substring(0, 25);
      return res;
    }

    return sender.contains('-') ? sender.split('-').last : 'Transaction';
  }

  String _detectCategory(String body, String merchant) {
    final text = "$body $merchant".toLowerCase();

    if (text.contains("zomato") || text.contains("swiggy")) return "Food";
    if (text.contains("uber") || text.contains("ola") || text.contains("fuel")) {
      return "Transport";
    }
    if (text.contains("recharge") ||
        text.contains("bill") ||
        text.contains("electricity")) {
      return "Bills";
    }
    if (text.contains("amazon") ||
        text.contains("flipkart") ||
        text.contains("shop")) {
      return "Shopping";
    }
    if (text.contains("upi")) return "UPI Transfer";

    return "General";
  }

  // ✅ FIX: Added Helper Functions for Icon and Color
  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Food': return Icons.fastfood_rounded;
      case 'Transport': return Icons.directions_car_rounded;
      case 'Shopping': return Icons.shopping_bag_rounded;
      case 'Bills': return Icons.receipt_long_rounded;
      case 'UPI Transfer': return Icons.qr_code_rounded;
      default: return Icons.account_balance_wallet_rounded;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Food': return Colors.orange;
      case 'Transport': return Colors.blue;
      case 'Shopping': return Colors.purple;
      case 'Bills': return Colors.indigo;
      case 'UPI Transfer': return Colors.teal;
      default: return Colors.grey;
    }
  }
}
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/transaction_model.dart';
import 'category_service.dart';

class CsvImportService {
  final _uuid = const Uuid();

  /// Pick CSV file
  Future<File?> pickCsvFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.single.path == null) {
        return null;
      }

      return File(result.files.single.path!);
    } catch (e) {
      debugPrint("Error picking file: $e");
      return null;
    }
  }

  /// Parse CSV → Transactions
  /// Supporting dynamic column detection for robustness
  Future<List<TransactionModel>> parseCsv(File file) async {
    try {
      final input = await file.readAsString();

      // Convert CSV to List of Lists
      final rows = const CsvToListConverter(
        shouldParseNumbers: false,
        eol: '\n', // Handle standard newlines
      ).convert(input);

      if (rows.length < 2) return [];

      // 1. Identify Headers (Normalize to lowercase for comparison)
      final headers = rows.first
          .map((e) => e.toString().toLowerCase().trim())
          .toList();

      // Find indices of key columns based on common synonyms
      final dateIdx = _findColumnIndex(headers, ['date', 'txn date', 'transaction date', 'dt', 'time']);
      final descIdx = _findColumnIndex(headers, ['description', 'particulars', 'narration', 'desc', 'details', 'title', 'text', 'remarks', 'merchant']);
      final amountIdx = _findColumnIndex(headers, ['amount', 'txn amount', 'value', 'inr', 'rs']);
      final debitIdx = _findColumnIndex(headers, ['debit', 'dr', 'withdrawal', 'outgoing']);
      final creditIdx = _findColumnIndex(headers, ['credit', 'cr', 'deposit', 'incoming', 'income']);
      final categoryIdx = _findColumnIndex(headers, ['category', 'tag', 'type']); // 'type' sometimes used for category
      final typeIdx = _findColumnIndex(headers, ['type', 'd/c', 'cr/dr', 'status']); // Explicit Type column

      final List<TransactionModel> transactions = [];

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        
        // Skip empty rows
        if (row.isEmpty || row.every((e) => e.toString().trim().isEmpty)) continue;

        // --- 1. Extract Description / Title ---
        String title = 'Unknown Transaction';
        if (descIdx != -1 && row.length > descIdx) {
          title = row[descIdx].toString().trim();
        } else if (headers.contains('text')) {
           // Fallback for previous simple format support
           final idx = headers.indexOf('text');
           if (row.length > idx) title = row[idx].toString().trim();
        }
        if (title.isEmpty) title = 'Imported Transaction';

        // --- 2. Extract Date ---
        DateTime date = DateTime.now();
        if (dateIdx != -1 && row.length > dateIdx) {
          final dateStr = row[dateIdx].toString().trim();
          date = _parseDate(dateStr) ?? DateTime.now();
        }

        // --- 3. Extract Amount & Type (Debit/Credit) ---
        double amount = 0.0;
        String type = 'debit'; // Default assumption

        // Strategy A: Explicit Debit and Credit Columns (Common in Bank Statements)
        if (debitIdx != -1 && creditIdx != -1 && row.length > debitIdx && row.length > creditIdx) {
           double dr = _parseAmount(row[debitIdx].toString());
           double cr = _parseAmount(row[creditIdx].toString());
           
           if (cr > 0) {
             amount = cr;
             type = 'credit';
           } else {
             amount = dr;
             type = 'debit';
           }
        }
        // Strategy B: Single Amount Column
        else if (amountIdx != -1 && row.length > amountIdx) {
           double rawAmount = _parseAmount(row[amountIdx].toString());
           
           // Check if there's an explicit type column (e.g., "Dr", "Cr", "Debit")
           if (typeIdx != -1 && row.length > typeIdx) {
             String typeStr = row[typeIdx].toString().toLowerCase();
             if (typeStr.contains('cr') || typeStr.contains('credit') || typeStr.contains('income') || typeStr.contains('deposit')) {
               type = 'credit';
             } else {
               type = 'debit';
             }
             amount = rawAmount.abs();
           } else {
             // Heuristic: Negative usually means debit, Positive means Credit (or sometimes Debit in Expense CSVs)
             if (rawAmount < 0) {
               type = 'debit';
               amount = rawAmount.abs();
             } else {
               // Positive amount: Check if title suggests income (e.g., 'Salary', 'Refund')
               if (_isIncomeTitle(title)) {
                 type = 'credit';
               } else {
                 type = 'debit'; // Default to expense
               }
               amount = rawAmount;
             }
           }
        } 
        // Strategy C: Legacy (Text-based extraction)
        else {
           // Try to extract from title using regex
           double? extracted = _extractAmountFromText(title);
           if (extracted != null) {
             amount = extracted;
             type = _isIncomeTitle(title) ? 'credit' : 'debit';
           }
        }

        if (amount <= 0) continue; // Skip invalid rows

        // --- 4. Extract or Detect Category ---
        String? category;
        if (categoryIdx != -1 && row.length > categoryIdx) {
          category = row[categoryIdx].toString().trim();
        }
        
        // Auto-categorize if missing or generic
        if (category == null || category.isEmpty || category.toLowerCase() == 'other' || category.toLowerCase() == 'general') {
          category = CategoryService.detectCategory(
            merchant: title,
            smsText: '',
            isDebit: type == 'debit',
          );
        }

        transactions.add(
          TransactionModel(
            id: _uuid.v4(), // Generate unique ID
            title: _capitalize(title),
            amount: amount,
            date: date,
            category: category ?? 'Others',
            type: type,
            source: 'csv',
            note: 'Imported via CSV',
            createdAt: Timestamp.now(),
          ),
        );
      }

      return transactions;
    } catch (e) {
      debugPrint('CSV Parse Error: $e');
      return [];
    }
  }

  // --- HELPERS ---

  int _findColumnIndex(List<String> headers, List<String> keywords) {
    for (int i = 0; i < headers.length; i++) {
      // Check if header contains any of the keywords
      if (keywords.any((k) => headers[i] == k || headers[i].contains(k))) {
        return i;
      }
    }
    return -1;
  }

  double _parseAmount(String text) {
    if (text.isEmpty) return 0.0;
    // Remove currency symbols (₹, $, Rs, etc) and commas
    String clean = text.replaceAll(RegExp(r'[^\d.-]'), ''); 
    return double.tryParse(clean) ?? 0.0;
  }

  DateTime? _parseDate(String text) {
    if (text.isEmpty) return null;
    
    // List of common date formats to try
    final formats = [
      'dd/MM/yyyy', 
      'dd-MM-yyyy', 
      'yyyy-MM-dd', 
      'MM/dd/yyyy',
      'd/M/yyyy',
      'd-M-yyyy',
      'dd MMM yyyy',
      'dd-MMM-yyyy',
    ];

    for (final f in formats) {
      try {
        return DateFormat(f).parse(text.trim());
      } catch (_) {
        // Continue to next format
      }
    }
    return null;
  }

  bool _isIncomeTitle(String title) {
    final lower = title.toLowerCase();
    return lower.contains('salary') || 
           lower.contains('credit') || 
           lower.contains('refund') || 
           lower.contains('deposit') ||
           lower.contains('interest') ||
           lower.contains('cashback');
  }

  double? _extractAmountFromText(String text) {
    final regex = RegExp(
      r'(rs\.?|inr|₹)?\s?(\d{1,6}(\.\d{1,2})?)',
      caseSensitive: false,
    );

    final match = regex.firstMatch(text);
    if (match == null) return null;

    return double.tryParse(match.group(2)!);
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
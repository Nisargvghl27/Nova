import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/transaction_model.dart';

class CsvImportService {
  final _uuid = const Uuid();

  /// Pick CSV file
  Future<File?> pickCsvFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.single.path == null) {
      return null;
    }

    return File(result.files.single.path!);
  }

  /// Parse CSV → Transactions
  Future<List<TransactionModel>> parseCsv(File file) async {
    final input = await file.readAsString();

    final rows = const CsvToListConverter(
      shouldParseNumbers: false,
    ).convert(input);

    if (rows.length < 2) return [];

    final headers = rows.first
        .map((e) => e.toString().toLowerCase().trim())
        .toList();

    final List<TransactionModel> transactions = [];

    for (int rowIndex = 1; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];

      try {
        if (row.every((e) => e.toString().trim().isEmpty)) continue;

        final Map<String, String> rowMap = {};
        for (int i = 0; i < headers.length && i < row.length; i++) {
          rowMap[headers[i]] = row[i].toString().trim();
        }

        // TEXT / TITLE
        final title = rowMap['text'] ?? 'Expense';

        // CATEGORY
        final category = rowMap['category'] ?? 'Other';

        // EXTRACT AMOUNT FROM TEXT
        final amount = _extractAmount(title);
        if (amount == null || amount <= 0) continue;

        transactions.add(
          TransactionModel(
            id: _uuid.v4(), // 🔥 UNIQUE ID FIX
            title: title,
            amount: amount,
            date: DateTime.now(),
            category: category,
            type: 'debit',
            source: 'csv',
            note: title,
            createdAt: Timestamp.now(),
          ),
        );
      } catch (e) {
        debugPrint('Skipped row $rowIndex: $e');
      }
    }

    return transactions;
  }

  /// Extract amount like ₹250 / Rs 250 / 250
  double? _extractAmount(String text) {
    final regex = RegExp(
      r'(rs\.?|inr|₹)?\s?(\d{1,6}(\.\d{1,2})?)',
      caseSensitive: false,
    );

    final match = regex.firstMatch(text);
    if (match == null) return null;

    return double.tryParse(match.group(2)!);
  }
}

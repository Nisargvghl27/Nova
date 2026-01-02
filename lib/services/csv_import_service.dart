import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';

class CsvImportService {
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

  /// Parse CSV → List<TransactionModel>
  Future<List<TransactionModel>> parseCsv(File file) async {
    final input = await file.readAsString();

    final rows = const CsvToListConverter(
      shouldParseNumbers: false,
    ).convert(input);

    if (rows.length < 2) return [];

    // Normalize headers
    final headers = rows.first
        .map((e) => e.toString().toLowerCase().trim())
        .toList();

    final dataRows = rows.skip(1);
    final List<TransactionModel> transactions = [];

    for (final row in dataRows) {
      try {
        if (row.every((e) => e.toString().trim().isEmpty)) {
          continue; // completely empty row
        }

        final Map<String, String> rowMap = {};
        for (int i = 0; i < headers.length && i < row.length; i++) {
          rowMap[headers[i]] = row[i].toString().trim();
        }

        // ---------------- AMOUNT (REQUIRED) ----------------
        final amountKey = CsvColumnMap.findKey(rowMap, 'amount');
        if (amountKey == null) continue;

        final rawAmount = rowMap[amountKey]!
            .replaceAll(RegExp(r'[^\d.-]'), '');

        final double? amount = double.tryParse(rawAmount);
        if (amount == null || amount == 0) continue;

        // ---------------- DATE (REQUIRED) ----------------
        final dateKey = CsvColumnMap.findKey(rowMap, 'date');
        if (dateKey == null) continue;

        final DateTime? date = _parseDate(rowMap[dateKey]!);
        if (date == null) continue;

        // ---------------- CATEGORY (REQUIRED) ----------------
        final categoryKey = CsvColumnMap.findKey(rowMap, 'category');
        if (categoryKey == null) continue;

        final String category = rowMap[categoryKey]!;
        if (category.isEmpty) continue;

        // ---------------- TITLE ----------------
        final titleKey = CsvColumnMap.findKey(rowMap, 'title');
        final String title =
            rowMap[titleKey] ?? category;

        // ---------------- TYPE ----------------
        final typeKey = CsvColumnMap.findKey(rowMap, 'type');
        final bool isDebit =
            amount < 0 ||
            (typeKey != null &&
                rowMap[typeKey]!
                    .toLowerCase()
                    .contains('debit'));

        transactions.add(
          TransactionModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
            amount: amount.abs(),
            date: date,
            category: category,
            type: isDebit ? 'debit' : 'credit',
            source: 'csv',
            note: title,
            createdAt: Timestamp.now(),
          ),
        );
      } catch (e) {
        debugPrint('CSV row skipped: $e');
      }
    }

    return transactions;
  }

  /// Try multiple date formats
  DateTime? _parseDate(String value) {
    final formats = [
      'yyyy-MM-dd',
      'dd-MM-yyyy',
      'dd/MM/yyyy',
      'dd/MM/yy',
      'MMM dd yyyy',
      'dd MMM yyyy',
    ];

    for (final format in formats) {
      try {
        return DateFormat(format).parse(value);
      } catch (_) {}
    }

    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
}

/// CSV column aliases
class CsvColumnMap {
  static const Map<String, List<String>> aliases = {
    'date': [
      'date',
      'transaction date',
      'txn date',
      'posted date',
    ],
    'title': [
      'description',
      'details',
      'note',
      'remarks',
      'narration',
    ],
    'amount': [
      'amount',
      'debit',
      'credit',
    ],
    'type': [
      'type',
      'dr/cr',
    ],
    'category': [
      'category',
      'expense type',
      'transaction category',
    ],
  };

  static String? findKey(
    Map<String, String> row,
    String logicalKey,
  ) {
    for (final alias in aliases[logicalKey]!) {
      for (final key in row.keys) {
        if (key.toLowerCase().trim() == alias) {
          return key;
        }
      }
    }
    return null;
  }
}

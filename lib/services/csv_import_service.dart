import 'dart:io';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

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

    final headers =
        rows.first.map((e) => e.toString()).toList();

    final dataRows = rows.skip(1);

    List<TransactionModel> transactions = [];

    for (final row in dataRows) {
      try {
        final Map<String, dynamic> rowMap = {};
        for (int i = 0; i < headers.length; i++) {
          rowMap[headers[i]] = row[i];
        }

        final dateKey =
            CsvColumnMap.findKey(rowMap, 'date');
        final titleKey =
            CsvColumnMap.findKey(rowMap, 'title');
        final amountKey =
            CsvColumnMap.findKey(rowMap, 'amount');
        final typeKey =
            CsvColumnMap.findKey(rowMap, 'type');

        if (dateKey == null || amountKey == null) {
          continue;
        }

        final rawAmount = rowMap[amountKey]
            .toString()
            .replaceAll(',', '')
            .trim();

        final amount = double.parse(rawAmount);

        final isDebit = amount < 0 ||
            (typeKey != null &&
                rowMap[typeKey]
                    .toString()
                    .toLowerCase()
                    .contains('debit'));

        transactions.add(
          TransactionModel(
            id: DateTime.now()
                .millisecondsSinceEpoch
                .toString(),
            title:
                rowMap[titleKey]?.toString() ?? 'Imported',
            amount: amount.abs(),
            date: DateTime.parse(rowMap[dateKey]),
            category: 'Other',
            type: isDebit ? 'debit' : 'credit',
            source: 'csv',
            note: '',
            createdAt: Timestamp.now(),
          ),
        );
      } catch (e) {
        debugPrint('CSV row skipped: $e');
      }
    }

    return transactions;
  }
}

/// 🔹 CSV COLUMN NORMALIZATION
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
  };

  static String? findKey(
      Map<String, dynamic> row, String logicalKey) {
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

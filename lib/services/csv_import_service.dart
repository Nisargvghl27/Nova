import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

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
    final csvString = await file.readAsString();

    final rows = const CsvToListConverter(
      shouldParseNumbers: false,
    ).convert(csvString);

    if (rows.isEmpty) return [];

    // Header row
    final headers = rows.first
        .map((e) => e.toString().toLowerCase().trim())
        .toList();

    final dataRows = rows.skip(1);

    List<TransactionModel> transactions = [];

    for (final row in dataRows) {
      try {
        final date = DateTime.parse(
          row[headers.indexOf('date')].toString(),
        );

        final title =
            row[headers.indexOf('description')].toString();

        final amount = double.parse(
          row[headers.indexOf('amount')].toString(),
        );

        final rawType =
            row[headers.indexOf('type')].toString().toLowerCase();

        final category =
            row[headers.indexOf('category')].toString();

        final type =
            rawType == 'credit' ? 'credit' : 'debit';

        transactions.add(
          TransactionModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
            amount: amount,
            date: date,
            category: category,
            type: type,
            source: 'csv',
            note: title,
            createdAt: Timestamp.now(),
          ),
        );
      } catch (e) {
        // Skip invalid row
        print('CSV row skipped: $e');
      }
    }

    return transactions;
  }
}

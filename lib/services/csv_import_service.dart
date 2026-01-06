// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:csv/csv.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/foundation.dart';
// import 'package:intl/intl.dart';
//
// import '../models/transaction_model.dart';
//
// class CsvImportService {
//   /// Pick CSV file
//   Future<File?> pickCsvFile() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['csv'],
//     );
//
//     if (result == null || result.files.single.path == null) {
//       return null;
//     }
//
//     return File(result.files.single.path!);
//   }
//
//   /// Parse CSV → List<TransactionModel>
//   Future<List<TransactionModel>> parseCsv(File file) async {
//     final input = await file.readAsString();
//
//     final rows = const CsvToListConverter(
//       shouldParseNumbers: false,
//     ).convert(input);
//
//     if (rows.length < 2) return [];
//
//     final headers = rows.first
//         .map((e) => e.toString().toLowerCase().trim())
//         .toList();
//
//     final dataRows = rows.skip(1);
//     final List<TransactionModel> transactions = [];
//
//     for (final row in dataRows) {
//       try {
//         if (row.every((e) => e.toString().trim().isEmpty)) continue;
//
//         final Map<String, String> rowMap = {};
//         for (int i = 0; i < headers.length && i < row.length; i++) {
//           rowMap[headers[i]] = row[i].toString().trim();
//         }
//
//         // ---------------- TEXT / TITLE ----------------
//         final textKey = CsvColumnMap.findKey(rowMap, 'text');
//         final title = rowMap[textKey] ?? 'Expense';
//
//         // ---------------- CATEGORY ----------------
//         final categoryKey = CsvColumnMap.findKey(rowMap, 'category');
//         final category = rowMap[categoryKey] ?? 'Other';
//
//         // ---------------- AMOUNT ----------------
//         double? amount;
//
//         final amountKey = CsvColumnMap.findKey(rowMap, 'amount');
//         if (amountKey != null) {
//           amount = double.tryParse(
//             rowMap[amountKey]!.replaceAll(RegExp(r'[^\d.-]'), ''),
//           );
//         }
//
//         // 🔥 Extract amount from text if not present
//         amount ??= _extractAmountFromText(title);
//
//         if (amount == null || amount == 0) continue;
//
//         // ---------------- DATE ----------------
//         DateTime date = DateTime.now();
//         final dateKey = CsvColumnMap.findKey(rowMap, 'date');
//         if (dateKey != null) {
//           date = _parseDate(rowMap[dateKey]!) ?? DateTime.now();
//         }
//
//         final isDebit = amount > 0;
//
//         transactions.add(
//           TransactionModel(
//             id: DateTime.now().millisecondsSinceEpoch.toString(),
//             title: title,
//             amount: amount.abs(),
//             date: date,
//             category: category,
//             type: isDebit ? 'debit' : 'credit',
//             source: 'csv',
//             note: title,
//             createdAt: Timestamp.now(),
//           ),
//         );
//       } catch (e) {
//         debugPrint('CSV row skipped: $e');
//       }
//     }
//
//     return transactions;
//   }
//
//   /// 🔍 Extract amount from text (₹250 / Rs 250 / 250)
//   double? _extractAmountFromText(String text) {
//     final regex = RegExp(
//       r'(rs\.?|inr|₹)?\s?(\d{1,6}(\.\d{1,2})?)',
//       caseSensitive: false,
//     );
//
//     final match = regex.firstMatch(text);
//     if (match == null) return null;
//
//     return double.tryParse(match.group(2)!);
//   }
//
//   /// Try multiple date formats
//   DateTime? _parseDate(String value) {
//     final formats = [
//       'yyyy-MM-dd',
//       'dd-MM-yyyy',
//       'dd/MM/yyyy',
//       'dd/MM/yy',
//       'MMM dd yyyy',
//       'dd MMM yyyy',
//     ];
//
//     for (final format in formats) {
//       try {
//         return DateFormat(format).parse(value);
//       } catch (_) {}
//     }
//
//     try {
//       return DateTime.parse(value);
//     } catch (_) {
//       return null;
//     }
//   }
// }
//
// /// CSV column aliases
// class CsvColumnMap {
//   static const Map<String, List<String>> aliases = {
//     'text': [
//       'text',
//       'description',
//       'details',
//       'note',
//       'remarks',
//       'narration',
//     ],
//     'date': [
//       'date',
//       'transaction date',
//       'txn date',
//     ],
//     'amount': [
//       'amount',
//       'debit',
//       'credit',
//     ],
//     'category': [
//       'category',
//       'expense type',
//       'transaction category',
//     ],
//   };
//
//   static String? findKey(
//       Map<String, String> row,
//       String logicalKey,
//       ) {
//     for (final alias in aliases[logicalKey]!) {
//       for (final key in row.keys) {
//         if (key.toLowerCase().trim() == alias) {
//           return key;
//         }
//       }
//     }
//     return null;
//   }
// }

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

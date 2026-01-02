// ================= CSV IMPORT DIALOG =================
import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../services/csv_import_service.dart';
import '../../services/transaction_service.dart';
class CsvImportDialog extends StatefulWidget {
  const CsvImportDialog();

  @override
  State<CsvImportDialog> createState() => _CsvImportDialogState();
}

class _CsvImportDialogState extends State<CsvImportDialog> {
  final CsvImportService _csvService = CsvImportService();
  final List<TransactionModel> _preview = [];
  bool _loading = false;

  // ---------------- PICK CSV ----------------
  Future<void> _pickCsv() async {
    setState(() => _loading = true);

    final file = await _csvService.pickCsvFile();
    if (file == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final parsed = await _csvService.parseCsv(file);

    if (!mounted) return;

    setState(() {
      _preview
        ..clear()
        ..addAll(parsed);
      _loading = false;
    });
  }

  // ---------------- CONFIRM IMPORT ----------------
  Future<void> _confirmImport() async {
    if (_preview.isEmpty) return;

    setState(() => _loading = true);

    try {
      await TransactionService().addTransactionsBatch(_preview);
    } catch (e) {
      debugPrint('CSV import failed: $e');
    }

    if (!mounted) return;

    setState(() => _loading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ---------- HEADER ----------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Import CSV',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _loading ? null : () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Text(
              'Upload bank or wallet statement',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            // ---------- PICK FILE ----------
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _pickCsv,
                icon: const Icon(Icons.upload_file),
                label: const Text('Select CSV File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2575FC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            if (_loading) ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ],

            // ---------- PREVIEW ----------
            if (_preview.isNotEmpty && !_loading) ...[
              const SizedBox(height: 20),
              Text(
                'Preview (${_preview.length} transactions)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 180,
                child: ListView.builder(
                  itemCount: _preview.length,
                  itemBuilder: (context, index) {
                    final tx = _preview[index];
                    return ListTile(
                      dense: true,
                      title: Text(tx.title),
                      subtitle: Text(tx.category),
                      trailing: Text(
                        '${tx.type == 'debit' ? '-' : '+'} Rs ${tx.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: tx.type == 'debit'
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 15),

              // ---------- CONFIRM ----------
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _confirmImport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'CONFIRM IMPORT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
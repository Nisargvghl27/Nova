import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/transaction_model.dart';
import '../../services/transaction_service.dart';
import '../../services/sms_parser_service.dart';

class SmsImportDialog extends StatefulWidget {
  const SmsImportDialog({super.key});

  @override
  State<SmsImportDialog> createState() => _SmsImportDialogState();
}

class _SmsImportDialogState extends State<SmsImportDialog> {
  final TextEditingController _smsController = TextEditingController();
  final List<TransactionModel> _preview = [];

  bool _loading = false;

  // ---------------- PARSE SMS ----------------
  Future<void> _parseSms() async {
    final text = _smsController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _loading = true;
      _preview.clear();
    });

    try {
      final parsed = SmsParserService().parseBulkSms(text);

      setState(() {
        _preview.addAll(parsed);
        _loading = false;
      });
    } catch (e) {
      debugPrint('SMS parse error: $e');
      setState(() => _loading = false);
    }
  }

  // ---------------- CONFIRM IMPORT ----------------
  Future<void> _confirmImport() async {
    if (_preview.isEmpty) return;

    setState(() => _loading = true);

    try {
      await TransactionService().addTransactionsBatch(_preview);
    } catch (e) {
      debugPrint('SMS import failed: $e');
    }

    if (!mounted) return;

    setState(() => _loading = false);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _smsController.dispose();
    super.dispose();
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
                  'Paste SMS',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _loading ? null : () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 8),
            const Text(
              'Paste bank SMS messages below',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 15),

            // ---------- SMS INPUT ----------
            TextField(
              controller: _smsController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText:
                    'Example:\nRs. 499 debited from A/c XXXX\nRs. 2000 credited to your account',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(15),
              ),
            ),

            const SizedBox(height: 15),

            // ---------- PARSE BUTTON ----------
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _parseSms,
                icon: const Icon(Icons.sms_rounded),
                label: const Text('PARSE SMS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
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

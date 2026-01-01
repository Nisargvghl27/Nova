import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/sms_parser_service.dart';
import '../services/transaction_service.dart';

class PasteSmsScreen extends StatefulWidget {
  const PasteSmsScreen({super.key});

  @override
  State<PasteSmsScreen> createState() => _PasteSmsScreenState();
}

class _PasteSmsScreenState extends State<PasteSmsScreen> {
  final TextEditingController _controller = TextEditingController();
  final SmsParserService _parser = SmsParserService();

  TransactionModel? _preview;
  String? _error;

  void _parseSms() {
    final result = _parser.parse(_controller.text);

    setState(() {
      _preview = result;
      _error = result == null
          ? 'Could not parse SMS. Please check format.'
          : null;
    });
  }

  Future<void> _confirm() async {
    if (_preview == null) return;

    await TransactionService().addTransaction(_preview!);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paste Bank SMS'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Paste bank SMS here...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _parseSms,
                child: const Text('PARSE SMS'),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!,
                  style: const TextStyle(color: Colors.red)),
            ],

            if (_preview != null) ...[
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  title: Text(_preview!.title),
                  subtitle: Text(
                      '${_preview!.note} • ${_preview!.date}'),
                  trailing: Text(
                    '${_preview!.type == 'debit' ? '-' : '+'} Rs ${_preview!.amount}',
                    style: TextStyle(
                      color: _preview!.type == 'debit'
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: _confirm,
                  child: const Text('CONFIRM & SAVE'),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

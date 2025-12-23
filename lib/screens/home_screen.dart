import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import 'edit_transaction_screen.dart';
import '../services/csv_import_service.dart';
import '../services/transaction_service.dart';

class HomeScreen extends StatelessWidget {
  final List<TransactionModel> transactions;
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final Function(String) onDelete;
  final VoidCallback onUndo;

  const HomeScreen({
    super.key,
    required this.transactions,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.onDelete,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // ================= HEADER =================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Good Morning,',
                              style: TextStyle(fontSize: 14, color: Colors.grey)),
                          Text(
                            'Alex Johnson',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Icon(Icons.notifications_none_rounded),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // ================= BALANCE CARD =================
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Balance',
                              style: TextStyle(color: Colors.white70)),
                          Text(
                            'Rs ${totalBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 36,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.arrow_upward,
                                  color: Colors.greenAccent, size: 18),
                              const SizedBox(width: 5),
                              Text('+ Rs ${totalIncome.toStringAsFixed(0)}',
                                  style: const TextStyle(color: Colors.white)),
                              const SizedBox(width: 20),
                              const Icon(Icons.arrow_downward,
                                  color: Colors.redAccent, size: 18),
                              const SizedBox(width: 5),
                              Text('- Rs ${totalExpense.toStringAsFixed(0)}',
                                  style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= CSV IMPORT CARD =================
                  _importCsvCard(context),

                  const SizedBox(height: 20),

                  const Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // ================= TRANSACTIONS =================
          if (transactions.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.monetization_on_outlined,
                        size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 20),
                    Text("No transactions yet!",
                        style: TextStyle(color: Colors.grey[400])),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tx = transactions[index];
                    return Dismissible(
                      key: Key(tx.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        onDelete(tx.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${tx.title} deleted'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditTransactionScreen(transaction: tx),
                            ),
                          );
                        },
                        child: _transactionTile(tx),
                      ),
                    );
                  },
                  childCount: transactions.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ================= CSV IMPORT CARD =================

  Widget _importCsvCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCsvImportSheet(context),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2575FC).withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.upload_file_rounded,
                  color: Color(0xFF2575FC)),
            ),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Import CSV',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('Upload bank or wallet statement',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  // ================= CSV BOTTOM SHEET =================

  void _showCsvImportSheet(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _CsvImportDialog(),
  );
  }


  // ================= TRANSACTION TILE =================

  Widget _transactionTile(TransactionModel tx) {
    final bool isDebit = tx.type == 'debit';
    final Color color = _getColorForCategory(tx.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withAlpha(30),
            child: Icon(_getIconForCategory(tx.category), color: color),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(DateFormat.MMMd().format(tx.date),
                    style:
                        const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Text(
            "${isDebit ? '-' : '+'} Rs ${tx.amount.toStringAsFixed(2)}",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDebit ? Colors.red : Colors.green),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Food':
        return Icons.fastfood_rounded;
      case 'Travel':
        return Icons.directions_car_rounded;
      case 'Bills':
        return Icons.receipt_long_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Food':
        return Colors.orange;
      case 'Travel':
        return Colors.blue;
      case 'Bills':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

// ================= CSV IMPORT BOTTOM SHEET =================

class _CsvImportDialog extends StatefulWidget {
  const _CsvImportDialog();

  @override
  State<_CsvImportDialog> createState() => _CsvImportDialogState();
}

class _CsvImportDialogState extends State<_CsvImportDialog> {
  final CsvImportService _csvService = CsvImportService();
  final List<TransactionModel> _preview = [];
  bool _loading = false;

  Future<void> _pickCsv() async {
    setState(() => _loading = true);

    final file = await _csvService.pickCsvFile();
    if (file == null) {
      setState(() => _loading = false);
      return;
    }

    final parsed = await _csvService.parseCsv(file);

    setState(() {
      _preview.clear();
      _preview.addAll(parsed);
      _loading = false;
    });
  }

  Future<void> _confirmImport() async {
    setState(() => _loading = true);

    for (final tx in _preview) {
      await TransactionService().addTransaction(tx);
    }

    if (!mounted) return;
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
                  onPressed: () => Navigator.pop(context),
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
            if (_preview.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Preview (${_preview.length} transactions)',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                        fontWeight: FontWeight.bold, color: Colors.white),
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


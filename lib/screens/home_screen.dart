import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

import 'edit_transaction_screen.dart';
import 'dialogs/csv_import_dialog.dart';
import 'paste_sms_screen.dart';

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
                          Text(
                            'Good Morning,',
                            style:
                                TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            'Alex Johnson',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
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
                          const Text(
                            'Total Balance',
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            'Rs ${totalBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 36,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.arrow_upward,
                                  color: Colors.greenAccent, size: 18),
                              const SizedBox(width: 5),
                              Text(
                                '+ Rs ${totalIncome.toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(width: 20),
                              const Icon(Icons.arrow_downward,
                                  color: Colors.redAccent, size: 18),
                              const SizedBox(width: 5),
                              Text(
                                '- Rs ${totalExpense.toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= IMPORT OPTIONS =================
                  _importOptions(context),

                  const SizedBox(height: 25),

                  const Text(
                    'Recent Transactions',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    Text(
                      "No transactions yet!",
                      style: TextStyle(color: Colors.grey[400]),
                    ),
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
                        child:
                            const Icon(Icons.delete, color: Colors.white),
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

  // ================= IMPORT OPTIONS =================

  Widget _importOptions(BuildContext context) {
    return Column(
      children: [
        _importCard(
          icon: Icons.upload_file_rounded,
          color: const Color(0xFF2575FC),
          title: 'Import CSV',
          subtitle: 'Upload bank or wallet statement',
          onTap: () => _showCsvImportSheet(context),
        ),
        const SizedBox(height: 15),
        _importCard(
          icon: Icons.sms_rounded,
          color: Colors.orange,
          title: 'Paste SMS',
          subtitle: 'Paste bank SMS to auto-extract data',
          onTap: () => _showSmsImportScreen(context),
        ),
      ],
    );
  }

  Widget _importCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  // ================= DIALOG / NAVIGATION =================

  void _showCsvImportSheet(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CsvImportDialog(),
    );
  }

  void _showSmsImportScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PasteSmsScreen()),
    );
  }

  // ================= TRANSACTION TILE =================

  Widget _transactionTile(TransactionModel tx) {
    final bool isDebit = tx.type == 'debit';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                isDebit ? Colors.red.withAlpha(30) : Colors.green.withAlpha(30),
            child: Icon(
              isDebit ? Icons.arrow_upward : Icons.arrow_downward,
              color: isDebit ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  DateFormat('MMM dd, yyyy').format(tx.date),
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            "${isDebit ? '-' : '+'} Rs ${tx.amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDebit ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

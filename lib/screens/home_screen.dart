import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class HomeScreen extends StatelessWidget {
  final List<Transaction> transactions;
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
        // Slivers are much faster than SingleChildScrollView + shrinkWrap
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Good Morning,', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          Text('Alex Johnson', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Icon(Icons.notifications_none_rounded),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Balance Card
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Balance', style: TextStyle(color: Colors.white70)),
                          Text(
                            '\$${totalBalance.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.arrow_upward, color: Colors.greenAccent, size: 18),
                              const SizedBox(width: 5),
                              Text('+ \$${totalIncome.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white)),
                              const SizedBox(width: 20),
                              const Icon(Icons.arrow_downward, color: Colors.redAccent, size: 18),
                              const SizedBox(width: 5),
                              Text('- \$${totalExpense.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // List Logic using SliverList for high performance
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final tx = transactions[index];
                  return Dismissible(
                    key: Key(tx.id), // Use ID as key, not UniqueKey()
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      onDelete(tx.id);
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${tx.title} deleted'),
                          action: SnackBarAction(
                            label: 'UNDO',
                            textColor: Colors.orange,
                            onPressed: onUndo,
                          ),
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
                    child: _transactionTile(tx),
                  );
                },
                childCount: transactions.length,
              ),
            ),
          ),
          // Bottom padding for FAB
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _transactionTile(Transaction tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: tx.color.withOpacity(0.15),
            child: Icon(tx.icon, color: tx.color),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("${tx.date.day}/${tx.date.month}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Text(
            "${tx.isExpense ? '-' : '+'} \$${tx.amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: tx.isExpense ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
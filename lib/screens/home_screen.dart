import 'package:flutter/material.dart';
import 'dart:async'; // Required for the timer
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
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 80),
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

          // List Logic
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              
              return Dismissible(
                key: UniqueKey(), 
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  // 1. Delete Logic
                  onDelete(tx.id);
                  
                  // 2. Clear previous bars
                  ScaffoldMessenger.of(context).clearSnackBars();
                  
                  // 3. Show SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${tx.title} deleted'),
                      duration: const Duration(seconds: 2),
                      // Removed "floating" behavior so it sits at the bottom
                      action: SnackBarAction(
                        label: 'UNDO',
                        textColor: Colors.orange,
                        onPressed: onUndo,
                      ),
                    ),
                  );

                  Future.delayed(const Duration(seconds: 3), () {

                    try {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    } catch (e) {
                      // context might be invalid if screen changed, which is fine
                    }
                  });
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
          ),
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
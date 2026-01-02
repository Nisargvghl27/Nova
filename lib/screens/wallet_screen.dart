import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class WalletScreen extends StatelessWidget {
  final List<TransactionModel> transactions;

  const WalletScreen({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    // 🔹 Calculate balance from transactions
    double balance = 0;
    for (var tx in transactions) {
      if (tx.type == 'debit') {
        balance -= tx.amount;
      } else {
        balance += tx.amount;
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Wallet',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1️⃣ Virtual Card (dynamic balance)
            _buildCreditCard(balance),

            const SizedBox(height: 30),

            // 2️⃣ Action Buttons (future use)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(Icons.arrow_upward, 'Send'),
                _buildActionButton(Icons.arrow_downward, 'Request'),
                _buildActionButton(Icons.add, 'Top Up'),
                _buildActionButton(Icons.grid_view_rounded, 'More'),
              ],
            ),

            const SizedBox(height: 30),

            // 3️⃣ Recent Transactions
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            if (transactions.isEmpty)
              const Center(child: Text("No transactions yet"))
            else
              ...transactions.take(5).map((tx) => _buildTransactionItem(tx)),
          ],
        ),
      ),
    );
  }

  // ================= UI PARTS =================

  Widget _buildCreditCard(double balance) {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2575FC), Color(0xFF6A11CB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2575FC).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Balance',
                  style: TextStyle(color: Colors.white70)),
              Icon(Icons.credit_card, color: Colors.white70),
            ],
          ),
          Text(
            'Rs ${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            '**** **** **** 8921',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF2575FC), size: 28),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildTransactionItem(TransactionModel tx) {
    final isDebit = tx.type == 'debit';
    final color = _getColor(tx.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(_getIcon(tx.category), color: color),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(tx.category,
                    style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              ],
            ),
          ),
          Text(
            (isDebit ? '-Rs ' : '+Rs ') + tx.amount.toStringAsFixed(0),
            style: TextStyle(
              color: isDebit ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  IconData _getIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.fastfood;
      case 'Travel':
        return Icons.directions_car;
      case 'Bills':
        return Icons.receipt;
      default:
        return Icons.category;
    }
  }

  Color _getColor(String category) {
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

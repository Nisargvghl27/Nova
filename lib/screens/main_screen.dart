import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'wallet_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';
import 'add_transaction_screen.dart';
import '../models/transaction_model.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Transaction> _transactions = [
    Transaction(
      id: '1',
      title: 'Lunch',
      amount: 15.00,
      date: DateTime.now(),
      category: 'Food',
      isExpense: true,
      icon: Icons.fastfood_rounded,
      color: Colors.orange,
    ),
  ];

  // 1. New variables to temporarily store deleted data
  Transaction? _recentlyDeletedTransaction;
  int? _recentlyDeletedIndex;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addNewTransaction(Transaction newTx) {
    setState(() {
      _transactions.insert(0, newTx);
    });
  }

  // 2. Updated remove function to REMEMBER the item
  void _removeTransaction(String id) {
    setState(() {
      final index = _transactions.indexWhere((tx) => tx.id == id);
      if (index != -1) {
        _recentlyDeletedIndex = index;
        _recentlyDeletedTransaction = _transactions[index];
        _transactions.removeAt(index);
      }
    });
  }

  // 3. New function to RESTORE the item
  void _undoDelete() {
    setState(() {
      if (_recentlyDeletedTransaction != null && _recentlyDeletedIndex != null) {
        _transactions.insert(_recentlyDeletedIndex!, _recentlyDeletedTransaction!);
        // Reset the variables
        _recentlyDeletedTransaction = null;
        _recentlyDeletedIndex = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double income = 0;
    double expense = 0;

    for (final tx in _transactions) {
      if (tx.isExpense) {
        expense += tx.amount;
      } else {
        income += tx.amount;
      }
    }

    const double openingBalance = 1000;
    final double totalBalance = openingBalance + income - expense;

    final List<Widget> pages = <Widget>[
      HomeScreen(
        transactions: _transactions,
        totalBalance: totalBalance,
        totalIncome: income,
        totalExpense: expense,
        onDelete: _removeTransaction,
        onUndo: _undoDelete, // 4. Pass the undo function
      ),
      const WalletScreen(),
      const StatsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2575FC),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2575FC),
        child: const Icon(Icons.add_rounded),
        onPressed: () async {
          final newTransaction = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );

          if (newTransaction != null) {
            _addNewTransaction(newTransaction as Transaction);
          }
        },
      ),
    );
  }
}
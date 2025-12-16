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

  // FIXED: Added 'category' parameter
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

  // Variables for Undo
  Transaction? _recentlyDeletedTransaction;
  int? _recentlyDeletedIndex;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Adds a new item to the top of the list
  void _addNewTransaction(Transaction newTx) {
    setState(() {
      _transactions.insert(0, newTx);
    });
  }

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

  void _undoDelete() {
    setState(() {
      if (_recentlyDeletedTransaction != null && _recentlyDeletedIndex != null) {
        _transactions.insert(_recentlyDeletedIndex!, _recentlyDeletedTransaction!);
        _recentlyDeletedTransaction = null;
        _recentlyDeletedIndex = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Calculate Totals
    double income = 0;
    double expense = 0;
    for (final tx in _transactions) {
      if (tx.isExpense) expense += tx.amount;
      else income += tx.amount;
    }
    const double openingBalance = 1000;
    final double totalBalance = openingBalance + income - expense;

    // 2. Define Pages
    final List<Widget> pages = <Widget>[
      HomeScreen(
        transactions: _transactions,
        totalBalance: totalBalance,
        totalIncome: income,
        totalExpense: expense,
        onDelete: _removeTransaction,
        onUndo: _undoDelete,
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
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2575FC),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),

      // 3. Floating Action Button (Opens AddTransactionScreen)
      floatingActionButton: _selectedIndex == 0 
        ? FloatingActionButton(
            backgroundColor: const Color(0xFF2575FC),
            shape: const CircleBorder(),
            child: const Icon(Icons.add_rounded, color: Colors.white),
            onPressed: () async {
              // Open the Add Screen and wait for result
              final newTransaction = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTransactionScreen(),
                ),
              );

              // If user saved a transaction, add it to the list
              if (newTransaction != null && newTransaction is Transaction) {
                _addNewTransaction(newTransaction);
              }
            },
          )
        : null, 
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'wallet_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';
import 'add_transaction_screen.dart';
import '../models/transaction_model.dart';
import '../services/sms_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final SmsService _smsService = SmsService(); // <--- 1. Initialize Service
  bool _isLoading = true; // <--- 2. Loading State

  // We start with an empty list, data will come from SMS + Manual
  List<Transaction> _transactions = [];

  Transaction? _recentlyDeletedTransaction;
  int? _recentlyDeletedIndex;

  @override
  void initState() {
    super.initState();
    _loadAllData(); // <--- 3. Trigger Data Load on App Start
  }

  // <--- 4. NEW FUNCTION: Load SMS Data
  // Update this function inside _MainScreenState
  Future<void> _loadAllData() async {
    debugPrint("🔄 STARTING DATA LOAD...");
    
    // 1. ASK FOR PERMISSION FIRST
    // We assume your SmsService has a method to query, 
    // but usually, we need to ensure permissions are granted at the UI level.
    // If you are using 'telephony' or 'permission_handler', we should check here.
    
    // For now, let's just try to fetch and print the result.
    try {
      List<Transaction> smsTransactions = await _smsService.getBankTransactions();
      debugPrint("📩 SMS SERVICE RETURNED: ${smsTransactions.length} transactions");

      // 2. DEBUGGING: Print the first one if it exists
      if (smsTransactions.isNotEmpty) {
        debugPrint("📝 First Transaction: ${smsTransactions.first.merchant} - ${smsTransactions.first.amount}");
      } else {
        debugPrint("⚠️ NO TRANSACTIONS FOUND. Check Permissions or Regex.");
      }

      if (mounted) {
        setState(() {
          _transactions = smsTransactions;
          _transactions.sort((a, b) => b.date.compareTo(a.date));
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ ERROR LOADING DATA: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addNewTransaction(Transaction newTx) {
    setState(() {
      _transactions.insert(0, newTx);
      // Re-sort to be safe, in case user adds an old date
      _transactions.sort((a, b) => b.date.compareTo(a.date));
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Transaction deleted"),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: _undoDelete,
        ),
      ),
    );
  }

  void _undoDelete() {
    if (_recentlyDeletedTransaction != null && _recentlyDeletedIndex != null) {
      setState(() {
        _transactions.insert(_recentlyDeletedIndex!, _recentlyDeletedTransaction!);
        _recentlyDeletedTransaction = null;
        _recentlyDeletedIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate Totals
    double income = 0;
    double expense = 0;
    for (final tx in _transactions) {
      if (tx.isExpense) {
        expense += tx.amount;
      } else {
        income += tx.amount;
      }
    }

    final double totalBalance = income - expense;

    final List<Widget> pages = [
      // <--- 5. Pass Loading State or Data
      _isLoading
          ? const Center(child: CircularProgressIndicator())
          : HomeScreen(
              transactions: _transactions,
              totalBalance: totalBalance,
              totalIncome: income,
              totalExpense: expense,
              onDelete: _removeTransaction,
              onUndo: _undoDelete,
            ),
      const WalletScreen(),
      StatsScreen(transactions: _transactions),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2575FC),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),

      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF2575FC),
              child: const Icon(Icons.add_rounded, color: Colors.white),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTransactionScreen(),
                  ),
                );

                if (result != null && result is Transaction) {
                  _addNewTransaction(result);
                }
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
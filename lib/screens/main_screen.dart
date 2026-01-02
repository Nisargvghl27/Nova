import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'wallet_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';
import 'add_transaction_screen.dart';
import 'transaction_screen.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TransactionModel>>(
      stream: TransactionService().transactionsStream(),
      builder: (context, snapshot) {
        // ---------------- LOADING ----------------
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ---------------- ERROR ----------------
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                "Error loading transactions\n${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // ---------------- DATA ----------------
        final List<TransactionModel> transactions = snapshot.data ?? [];

        double income = 0;
        double expense = 0;

        for (final tx in transactions) {
          if (tx.type == 'debit') {
            expense += tx.amount;
          } else {
            income += tx.amount;
          }
        }

        final double totalBalance = income - expense;

        final List<Widget> pages = [
          // 🏠 HOME
          HomeScreen(
            transactions: transactions,
            totalBalance: totalBalance,
            totalIncome: income,
            totalExpense: expense,
            onDelete: (id) =>
                TransactionService().deleteTransaction(id),
            onUndo: () {},
          ),

          // 📄 TRANSACTIONS (NEWHook: search, filters, csv, edit)
          TransactionsScreen(
            transactions: transactions,
            onDelete: (id) =>
                TransactionService().deleteTransaction(id),
          ),

          // 💼 WALLET
          WalletScreen(transactions: transactions),

          // 📊 STATS
          StatsScreen(transactions: transactions),

          // 👤 PROFILE
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
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_rounded),
                label: 'Transactions',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet_rounded),
                label: 'Wallet',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_rounded),
                label: 'Stats',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),

          floatingActionButton: _selectedIndex == 0 ||
                  _selectedIndex == 1
              ? FloatingActionButton(
                  backgroundColor: const Color(0xFF2575FC),
                  child:
                      const Icon(Icons.add_rounded, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddTransactionScreen(),
                      ),
                    );
                  },
                )
              : null,

          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }
}

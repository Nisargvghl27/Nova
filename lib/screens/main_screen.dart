// // import 'package:flutter/material.dart';
// // import 'home_screen.dart';
// // import 'wallet_screen.dart';
// // import 'stats_screen.dart';
// // import 'profile_screen.dart';
// // import 'add_transaction_screen.dart';
// // import 'transaction_screen.dart';
// // import '../models/transaction_model.dart';
// // import '../services/transaction_service.dart';

// // class MainScreen extends StatefulWidget {
// //   const MainScreen({super.key});

// //   @override
// //   State<MainScreen> createState() => _MainScreenState();
// // }

// // class _MainScreenState extends State<MainScreen> {
// //   int _selectedIndex = 0;

// //   void _onItemTapped(int index) {
// //     setState(() {
// //       _selectedIndex = index;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return StreamBuilder<List<TransactionModel>>(
// //       stream: TransactionService().transactionsStream(),
// //       builder: (context, snapshot) {
// //         // ---------------- LOADING ----------------
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const Scaffold(
// //             body: Center(child: CircularProgressIndicator()),
// //           );
// //         }

// //         // ---------------- ERROR ----------------
// //         if (snapshot.hasError) {
// //           return Scaffold(
// //             body: Center(
// //               child: Text(
// //                 "Error loading transactions\n${snapshot.error}",
// //                 textAlign: TextAlign.center,
// //               ),
// //             ),
// //           );
// //         }

// //         // ---------------- DATA ----------------
// //         final List<TransactionModel> transactions = snapshot.data ?? [];

// //         double income = 0;
// //         double expense = 0;

// //         for (final tx in transactions) {
// //           if (tx.type == 'debit') {
// //             expense += tx.amount;
// //           } else {
// //             income += tx.amount;
// //           }
// //         }

// //         final double totalBalance = income - expense;

// //         final List<Widget> pages = [
// //           // HOME
// //           HomeScreen(
// //             transactions: transactions,
// //             totalBalance: totalBalance,
// //             totalIncome: income,
// //             totalExpense: expense,
// //             onDelete: (id) => TransactionService().deleteTransaction(id),
// //             onUndo: () {},
// //           ),

// //           // TRANSACTIONS
// //           TransactionsScreen(
// //             transactions: transactions,
// //             onDelete: (id) => TransactionService().deleteTransaction(id),
// //           ),

// //           // WALLET
// //           WalletScreen(transactions: transactions),

// //           // STATS
// //           StatsScreen(transactions: transactions),

// //           // PROFILE
// //           ProfileScreen(
// //             onWalletTap: () => _onItemTapped(2),
// //           ),
// //         ];

// //         return Scaffold(
// //           backgroundColor: Colors.grey[50],
// //           body: IndexedStack(
// //             index: _selectedIndex,
// //             children: pages,
// //           ),
// //           bottomNavigationBar: BottomNavigationBar(
// //             currentIndex: _selectedIndex,
// //             onTap: _onItemTapped,
// //             type: BottomNavigationBarType.fixed,
// //             backgroundColor: Colors.white,
// //             selectedItemColor: const Color(0xFF2575FC),
// //             unselectedItemColor: Colors.grey,
// //             showUnselectedLabels: true,
// //             items: const [
// //               BottomNavigationBarItem(
// //                 icon: Icon(Icons.home_rounded),
// //                 label: 'Home',
// //               ),
// //               BottomNavigationBarItem(
// //                 icon: Icon(Icons.list_alt_rounded),
// //                 label: 'History',
// //               ),
// //               BottomNavigationBarItem(
// //                 icon: Icon(Icons.account_balance_wallet_rounded),
// //                 label: 'Wallet',
// //               ),
// //               BottomNavigationBarItem(
// //                 icon: Icon(Icons.bar_chart_rounded),
// //                 label: 'Stats',
// //               ),
// //               BottomNavigationBarItem(
// //                 icon: Icon(Icons.person_rounded),
// //                 label: 'Profile',
// //               ),
// //             ],
// //           ),

// //           // --- UPDATED FLOATING ACTION BUTTON ---
// //           // Only show on Home Screen (Index 0)
// //           floatingActionButton: _selectedIndex == 0
// //               ? Container(
// //                   height: 60,
// //                   width: 60,
// //                   decoration: BoxDecoration(
// //                     shape: BoxShape.circle,
// //                     gradient: const LinearGradient(
// //                       colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
// //                       begin: Alignment.topLeft,
// //                       end: Alignment.bottomRight,
// //                     ),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: const Color(0xFF2575FC).withOpacity(0.4),
// //                         blurRadius: 10,
// //                         offset: const Offset(0, 4),
// //                       ),
// //                     ],
// //                   ),
// //                   child: FloatingActionButton(
// //                     onPressed: () {
// //                       Navigator.push(
// //                         context,
// //                         MaterialPageRoute(
// //                           builder: (_) => const AddTransactionScreen(),
// //                         ),
// //                       );
// //                     },
// //                     backgroundColor: Colors.transparent,
// //                     elevation: 0,
// //                     child: const Icon(Icons.add_rounded,
// //                         color: Colors.white, size: 32),
// //                   ),
// //                 )
// //               : null,
// //           floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
// //         );
// //       },
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'home_screen.dart';
// import 'wallet_screen.dart';
// import 'stats_screen.dart';
// import 'profile_screen.dart';
// import 'add_transaction_screen.dart';
// import 'transaction_screen.dart';
// import '../models/transaction_model.dart';
// import '../services/transaction_service.dart';

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   int _selectedIndex = 0;

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // 🔹 Theme Colors
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final navBarColor = Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Colors.white;
//     final selectedItemColor = Theme.of(context).bottomNavigationBarTheme.selectedItemColor ?? const Color(0xFF2575FC);
//     final unselectedItemColor = Theme.of(context).bottomNavigationBarTheme.unselectedItemColor ?? Colors.grey;

//     return StreamBuilder<List<TransactionModel>>(
//       stream: TransactionService().transactionsStream(),
//       builder: (context, snapshot) {
//         // ---------------- LOADING ----------------
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         // ---------------- ERROR ----------------
//         if (snapshot.hasError) {
//           return Scaffold(
//             body: Center(
//               child: Text(
//                 "Error loading transactions\n${snapshot.error}",
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           );
//         }

//         // ---------------- DATA ----------------
//         final List<TransactionModel> transactions = snapshot.data ?? [];

//         double income = 0;
//         double expense = 0;

//         for (final tx in transactions) {
//           if (tx.type == 'debit') {
//             expense += tx.amount;
//           } else {
//             income += tx.amount;
//           }
//         }

//         final double totalBalance = income - expense;

//         final List<Widget> pages = [
//           // HOME
//           HomeScreen(
//             transactions: transactions,
//             totalBalance: totalBalance,
//             totalIncome: income,
//             totalExpense: expense,
//             onDelete: (id) => TransactionService().deleteTransaction(id),
//             onUndo: () {},
//           ),

//           // TRANSACTIONS
//           TransactionsScreen(
//             transactions: transactions,
//             onDelete: (id) => TransactionService().deleteTransaction(id),
//           ),

//           // WALLET
//           WalletScreen(transactions: transactions),

//           // STATS
//           StatsScreen(transactions: transactions),

//           // PROFILE
//           ProfileScreen(
//             onWalletTap: () => _onItemTapped(2),
//           ),
//         ];

//         return Scaffold(
//           // 🔹 Use theme scaffold background
//           backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          
//           body: IndexedStack(
//             index: _selectedIndex,
//             children: pages,
//           ),
          
//           bottomNavigationBar: Theme(
//             data: Theme.of(context).copyWith(
//               canvasColor: navBarColor, // Sets background for fixed type
//             ),
//             child: BottomNavigationBar(
//               currentIndex: _selectedIndex,
//               onTap: _onItemTapped,
//               type: BottomNavigationBarType.fixed,
//               backgroundColor: navBarColor,
//               selectedItemColor: selectedItemColor,
//               unselectedItemColor: unselectedItemColor,
//               showUnselectedLabels: true,
//               items: const [
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.home_rounded),
//                   label: 'Home',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.list_alt_rounded),
//                   label: 'History',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.account_balance_wallet_rounded),
//                   label: 'Wallet',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.bar_chart_rounded),
//                   label: 'Stats',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.person_rounded),
//                   label: 'Profile',
//                 ),
//               ],
//             ),
//           ),

//           // --- FLOATING ACTION BUTTON ---
//           floatingActionButton: _selectedIndex == 0
//               ? Container(
//                   height: 60,
//                   width: 60,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xFF2575FC).withOpacity(0.4),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: FloatingActionButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const AddTransactionScreen(),
//                         ),
//                       );
//                     },
//                     backgroundColor: Colors.transparent,
//                     elevation: 0,
//                     child: const Icon(Icons.add_rounded,
//                         color: Colors.white, size: 32),
//                   ),
//                 )
//               : null,
//           floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//         );
//       },
//     );
//   }
// }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBarColor = Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Colors.white;
    final selectedItemColor = Theme.of(context).bottomNavigationBarTheme.selectedItemColor ?? const Color(0xFF2575FC);
    final unselectedItemColor = Theme.of(context).bottomNavigationBarTheme.unselectedItemColor ?? Colors.grey;

    return StreamBuilder<List<TransactionModel>>(
      stream: TransactionService().transactionsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Error loading transactions\n${snapshot.error}")),
          );
        }

        // 🔹 SPLIT INTO ACTIVE AND DELETED
        final List<TransactionModel> allTransactions = snapshot.data ?? [];
        final List<TransactionModel> activeTransactions = 
            allTransactions.where((tx) => !tx.isDeleted).toList();
        final List<TransactionModel> deletedTransactions = 
            allTransactions.where((tx) => tx.isDeleted).toList();

        double income = 0;
        double expense = 0;

        for (final tx in activeTransactions) {
          if (tx.type == 'debit') {
            expense += tx.amount;
          } else {
            income += tx.amount;
          }
        }

        final double totalBalance = income - expense;

        final List<Widget> pages = [
          // HOME (Active only)
          HomeScreen(
            transactions: activeTransactions,
            totalBalance: totalBalance,
            totalIncome: income,
            totalExpense: expense,
            onDelete: (id) => TransactionService().deleteTransaction(id),
            onUndo: () {}, // Deprecated, but kept for interface compatibility
          ),

          // TRANSACTIONS (Active + Deleted list passed)
          TransactionsScreen(
            transactions: activeTransactions,
            deletedTransactions: deletedTransactions, // 🔹 Pass deleted list
            onDelete: (id) => TransactionService().deleteTransaction(id),
          ),

          // WALLET (Active only)
          WalletScreen(transactions: activeTransactions),

          // STATS (Active only)
          StatsScreen(transactions: activeTransactions),

          // PROFILE
          ProfileScreen(
            onWalletTap: () => _onItemTapped(2),
          ),
        ];

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(canvasColor: navBarColor),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: navBarColor,
              selectedItemColor: selectedItemColor,
              unselectedItemColor: unselectedItemColor,
              showUnselectedLabels: true,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: 'History'),
                BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Wallet'),
                BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Stats'),
                BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
              ],
            ),
          ),
          floatingActionButton: _selectedIndex == 0
              ? Container(
                  height: 60, width: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2575FC).withOpacity(0.4),
                        blurRadius: 10, offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
                      );
                    },
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
                  ),
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }
}
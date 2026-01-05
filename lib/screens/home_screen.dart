// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/transaction_model.dart';
// import 'edit_transaction_screen.dart';
// import '../services/csv_import_service.dart';
// import '../services/transaction_service.dart';

// class HomeScreen extends StatelessWidget {
//   final List<TransactionModel> transactions;
//   final double totalBalance;
//   final double totalIncome;
//   final double totalExpense;
//   final Function(String) onDelete;
//   final VoidCallback onUndo;

//   const HomeScreen({
//     super.key,
//     required this.transactions,
//     required this.totalBalance,
//     required this.totalIncome,
//     required this.totalExpense,
//     required this.onDelete,
//     required this.onUndo,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       body: CustomScrollView(
//         slivers: [
//           // ================= HEADER =================
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: const [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Good Morning,',
//                               style: TextStyle(fontSize: 14, color: Colors.grey)),
//                           Text(
//                             'Alex Johnson',
//                             style: TextStyle(
//                                 fontSize: 24, fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       ),
//                       Icon(Icons.notifications_none_rounded),
//                     ],
//                   ),
//                   const SizedBox(height: 30),

//                   // ================= BALANCE CARD =================
//                   Container(
//                     height: 200,
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//                       ),
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(25),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text('Total Balance',
//                               style: TextStyle(color: Colors.white70)),
//                           Text(
//                             'Rs ${totalBalance.toStringAsFixed(2)}',
//                             style: const TextStyle(
//                                 fontSize: 36,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                           Row(
//                             children: [
//                               const Icon(Icons.arrow_upward,
//                                   color: Colors.greenAccent, size: 18),
//                               const SizedBox(width: 5),
//                               Text('+ Rs ${totalIncome.toStringAsFixed(0)}',
//                                   style: const TextStyle(color: Colors.white)),
//                               const SizedBox(width: 20),
//                               const Icon(Icons.arrow_downward,
//                                   color: Colors.redAccent, size: 18),
//                               const SizedBox(width: 5),
//                               Text('- Rs ${totalExpense.toStringAsFixed(0)}',
//                                   style: const TextStyle(color: Colors.white)),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // ================= CSV IMPORT CARD =================
//                   _importCsvCard(context),

//                   const SizedBox(height: 20),

//                   const Text(
//                     'Recent Transactions',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 10),
//                 ],
//               ),
//             ),
//           ),

//           // ================= TRANSACTIONS =================
//           if (transactions.isEmpty)
//             SliverFillRemaining(
//               hasScrollBody: false,
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.monetization_on_outlined,
//                         size: 80, color: Colors.grey[300]),
//                     const SizedBox(height: 20),
//                     Text("No transactions yet!",
//                         style: TextStyle(color: Colors.grey[400])),
//                   ],
//                 ),
//               ),
//             )
//           else
//             SliverPadding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//               sliver: SliverList(
//                 delegate: SliverChildBuilderDelegate(
//                   (context, index) {
//                     final tx = transactions[index];
//                     return Dismissible(
//                       key: Key(tx.id),
//                       direction: DismissDirection.endToStart,
//                       onDismissed: (_) {
//                         onDelete(tx.id);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text('${tx.title} deleted'),
//                             duration: const Duration(seconds: 2),
//                           ),
//                         );
//                       },
//                       background: Container(
//                         margin: const EdgeInsets.only(bottom: 15),
//                         alignment: Alignment.centerRight,
//                         padding: const EdgeInsets.only(right: 20),
//                         decoration: BoxDecoration(
//                           color: Colors.red.shade400,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: const Icon(Icons.delete, color: Colors.white),
//                       ),
//                       child: GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) =>
//                                   EditTransactionScreen(transaction: tx),
//                             ),
//                           );
//                         },
//                         child: _transactionTile(tx),
//                       ),
//                     );
//                   },
//                   childCount: transactions.length,
//                 ),
//               ),
//             ),

//           const SliverToBoxAdapter(child: SizedBox(height: 100)),
//         ],
//       ),
//     );
//   }

//   // ================= CSV IMPORT CARD =================

//   Widget _importCsvCard(BuildContext context) {
//     return GestureDetector(
//       onTap: () => _showCsvImportSheet(context),
//       child: Container(
//         padding: const EdgeInsets.all(18),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withAlpha(15),
//               blurRadius: 10,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF2575FC).withAlpha(25),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.upload_file_rounded,
//                   color: Color(0xFF2575FC)),
//             ),
//             const SizedBox(width: 15),
//             const Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Import CSV',
//                       style:
//                           TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                   SizedBox(height: 4),
//                   Text('Upload bank or wallet statement',
//                       style: TextStyle(color: Colors.grey)),
//                 ],
//               ),
//             ),
//             const Icon(Icons.arrow_forward_ios, size: 16),
//           ],
//         ),
//       ),
//     );
//   }

//   // ================= CSV BOTTOM SHEET =================

//   void _showCsvImportSheet(BuildContext context) {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (_) => const _CsvImportDialog(),
//   );
//   }


//   // ================= TRANSACTION TILE =================

//   Widget _transactionTile(TransactionModel tx) {
//     final bool isDebit = tx.type == 'debit';
//     final Color color = _getColorForCategory(tx.category);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 15),
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withAlpha(12),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             backgroundColor: color.withAlpha(30),
//             child: Icon(_getIconForCategory(tx.category), color: color),
//           ),
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(tx.title,
//                     style: const TextStyle(fontWeight: FontWeight.bold)),
//                 Text(DateFormat.MMMd().format(tx.date),
//                     style:
//                         const TextStyle(fontSize: 12, color: Colors.grey)),
//               ],
//             ),
//           ),
//           Text(
//             "${isDebit ? '-' : '+'} Rs ${tx.amount.toStringAsFixed(2)}",
//             style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: isDebit ? Colors.red : Colors.green),
//           ),
//         ],
//       ),
//     );
//   }

//   IconData _getIconForCategory(String category) {
//     switch (category) {
//       case 'Food':
//         return Icons.fastfood_rounded;
//       case 'Travel':
//         return Icons.directions_car_rounded;
//       case 'Bills':
//         return Icons.receipt_long_rounded;
//       default:
//         return Icons.category_rounded;
//     }
//   }

//   Color _getColorForCategory(String category) {
//     switch (category) {
//       case 'Food':
//         return Colors.orange;
//       case 'Travel':
//         return Colors.blue;
//       case 'Bills':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }
// }

// // ================= CSV IMPORT BOTTOM SHEET =================

// class _CsvImportDialog extends StatefulWidget {
//   const _CsvImportDialog();

//   @override
//   State<_CsvImportDialog> createState() => _CsvImportDialogState();
// }

// class _CsvImportDialogState extends State<_CsvImportDialog> {
//   final CsvImportService _csvService = CsvImportService();
//   final List<TransactionModel> _preview = [];
//   bool _loading = false;

//   Future<void> _pickCsv() async {
//     setState(() => _loading = true);

//     final file = await _csvService.pickCsvFile();
//     if (file == null) {
//       setState(() => _loading = false);
//       return;
//     }

//     final parsed = await _csvService.parseCsv(file);

//     setState(() {
//       _preview.clear();
//       _preview.addAll(parsed);
//       _loading = false;
//     });
//   }

//   Future<void> _confirmImport() async {
//     setState(() => _loading = true);

//     for (final tx in _preview) {
//       await TransactionService().addTransaction(tx);
//     }

//     if (!mounted) return;
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       insetPadding: const EdgeInsets.symmetric(horizontal: 24),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // ---------- HEADER ----------
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Import CSV',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 10),
//             const Text(
//               'Upload bank or wallet statement',
//               style: TextStyle(color: Colors.grey),
//             ),

//             const SizedBox(height: 25),

//             // ---------- PICK FILE ----------
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton.icon(
//                 onPressed: _loading ? null : _pickCsv,
//                 icon: const Icon(Icons.upload_file),
//                 label: const Text('Select CSV File'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF2575FC),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                 ),
//               ),
//             ),

//             if (_loading) ...[
//               const SizedBox(height: 20),
//               const CircularProgressIndicator(),
//             ],

//             // ---------- PREVIEW ----------
//             if (_preview.isNotEmpty) ...[
//               const SizedBox(height: 20),
//               Text(
//                 'Preview (${_preview.length} transactions)',
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               const SizedBox(height: 10),

//               SizedBox(
//                 height: 180,
//                 child: ListView.builder(
//                   itemCount: _preview.length,
//                   itemBuilder: (context, index) {
//                     final tx = _preview[index];
//                     return ListTile(
//                       dense: true,
//                       title: Text(tx.title),
//                       subtitle: Text(tx.category),
//                       trailing: Text(
//                         '${tx.type == 'debit' ? '-' : '+'} Rs ${tx.amount.toStringAsFixed(0)}',
//                         style: TextStyle(
//                           color: tx.type == 'debit'
//                               ? Colors.red
//                               : Colors.green,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               const SizedBox(height: 15),

//               // ---------- CONFIRM ----------
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _loading ? null : _confirmImport,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                   ),
//                   child: const Text(
//                     'CONFIRM IMPORT',
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      backgroundColor: const Color(0xFFF8F9FD),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ================= HEADER =================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _AnimatedBalanceCard(
                    totalBalance: totalBalance,
                    totalIncome: totalIncome,
                    totalExpense: totalExpense,
                  ),
                  const SizedBox(height: 20),
                  _ImportCsvCard(onTap: () => _showCsvImportSheet(context)),
                  const SizedBox(height: 28),
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ================= TRANSACTIONS =================
          if (transactions.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tx = transactions[index];
                    return _AnimatedTransactionTile(
                      transaction: tx,
                      index: index,
                      onDelete: () {
                        HapticFeedback.mediumImpact();
                        onDelete(tx.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${tx.title} deleted'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditTransactionScreen(transaction: tx),
                          ),
                        );
                      },
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning,',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Alex Johnson',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.notifications_none_rounded, size: 24),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.monetization_on_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No transactions yet!",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start tracking your expenses",
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  void _showCsvImportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CsvImportBottomSheet(),
    );
  }
}

// ================= ANIMATED BALANCE CARD =================

class _AnimatedBalanceCard extends StatefulWidget {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;

  const _AnimatedBalanceCard({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  State<_AnimatedBalanceCard> createState() => _AnimatedBalanceCardState();
}

class _AnimatedBalanceCardState extends State<_AnimatedBalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (value * 0.1),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2575FC).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Shimmer effect
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                return Positioned(
                  left: -200 + (_shimmerController.value * 400),
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0),
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Balance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'INR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: widget.totalBalance),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Text(
                        '₹ ${value.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 38,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      );
                    },
                  ),
                  Row(
                    children: [
                      _BalanceBadge(
                        icon: Icons.arrow_upward,
                        color: Colors.greenAccent,
                        amount: widget.totalIncome,
                        isIncome: true,
                      ),
                      const SizedBox(width: 16),
                      _BalanceBadge(
                        icon: Icons.arrow_downward,
                        color: Colors.redAccent,
                        amount: widget.totalExpense,
                        isIncome: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double amount;
  final bool isIncome;

  const _BalanceBadge({
    required this.icon,
    required this.color,
    required this.amount,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            '${isIncome ? '+' : '-'} ₹${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ================= IMPORT CSV CARD =================

class _ImportCsvCard extends StatefulWidget {
  final VoidCallback onTap;

  const _ImportCsvCard({required this.onTap});

  @override
  State<_ImportCsvCard> createState() => _ImportCsvCardState();
}

class _ImportCsvCardState extends State<_ImportCsvCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap();
          },
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2575FC).withOpacity(
                          0.1 + (_pulseController.value * 0.05),
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.upload_file_rounded,
                        color: Color(0xFF2575FC),
                        size: 24,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Import CSV',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Upload bank or wallet statement',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= ANIMATED TRANSACTION TILE =================

class _AnimatedTransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _AnimatedTransactionTile({
    required this.transaction,
    required this.index,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDebit = transaction.type == 'debit';
    final Color color = _getColorForCategory(transaction.category);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Dismissible(
        key: Key(transaction.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete(),
        confirmDismiss: (_) async {
          HapticFeedback.mediumImpact();
          return true;
        },
        background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.redAccent, Colors.red],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              // margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Hero(
                    tag: 'icon_${transaction.id}',
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _getIconForCategory(transaction.category),
                        color: color,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat.MMMd().format(transaction.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "${isDebit ? '-' : '+'} ₹${transaction.amount.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: isDebit ? Colors.red[600] : Colors.green[600],
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Travel':
        return Icons.flight_rounded;
      case 'Bills':
        return Icons.receipt_long_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Entertainment':
        return Icons.movie_rounded;
      default:
        return Icons.attach_money_rounded;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Food':
        return const Color(0xFFFF6B6B);
      case 'Travel':
        return const Color(0xFF4ECDC4);
      case 'Bills':
        return const Color(0xFF95E1D3);
      case 'Shopping':
        return const Color(0xFFFFA07A);
      case 'Entertainment':
        return const Color(0xFFBA68C8);
      default:
        return const Color(0xFF78909C);
    }
  }
}

// ================= CSV IMPORT BOTTOM SHEET =================

class _CsvImportBottomSheet extends StatefulWidget {
  const _CsvImportBottomSheet();

  @override
  State<_CsvImportBottomSheet> createState() => _CsvImportBottomSheetState();
}

class _CsvImportBottomSheetState extends State<_CsvImportBottomSheet>
    with SingleTickerProviderStateMixin {
  final CsvImportService _csvService = CsvImportService();
  final List<TransactionModel> _preview = [];
  bool _loading = false;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _pickCsv() async {
    setState(() => _loading = true);
    HapticFeedback.mediumImpact();

    final file = await _csvService.pickCsvFile();
    if (file == null) {
      setState(() => _loading = false);
      return;
    }

    final parsed = await _csvService.parseCsv(file);

    if (mounted) {
      setState(() {
        _preview.clear();
        _preview.addAll(parsed);
        _loading = false;
      });
    }
  }

  Future<void> _confirmImport() async {
    setState(() => _loading = true);
    HapticFeedback.heavyImpact();

    for (final tx in _preview) {
      await TransactionService().addTransaction(tx);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      )),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Import CSV',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Upload your bank or wallet statement',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Pick file button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _pickCsv,
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text(
                    'Select CSV File',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2575FC),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              if (_loading) ...[
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
              ],

              // Preview
              if (_preview.isNotEmpty) ...[
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Preview',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.grey[800],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2575FC).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_preview.length} transactions',
                        style: const TextStyle(
                          color: Color(0xFF2575FC),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _preview.length,
                    itemBuilder: (context, index) {
                      final tx = _preview[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[200]!,
                              width: index == _preview.length - 1 ? 0 : 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tx.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    tx.category,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${tx.type == 'debit' ? '-' : '+'} ₹${tx.amount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: tx.type == 'debit'
                                    ? Colors.red[600]
                                    : Colors.green[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _confirmImport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'CONFIRM IMPORT',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
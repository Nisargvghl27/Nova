// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/transaction_model.dart';

// class StatsScreen extends StatefulWidget {
//   final List<TransactionModel> transactions;

//   const StatsScreen({super.key, required this.transactions});

//   @override
//   State<StatsScreen> createState() => _StatsScreenState();
// }

// class _StatsScreenState extends State<StatsScreen> {
//   int _selectedPeriodIndex = 4;
//   final List<String> _periods = ['Day', 'Week', 'Month', 'Year', 'All'];

//   @override
//   Widget build(BuildContext context) {
//     if (widget.transactions.isEmpty) {
//       debugPrint("📊 STATS: No transactions received!");
//     } else {
//       debugPrint("📊 STATS: Received ${widget.transactions.length} transactions.");
//       debugPrint("📅 First Date: ${widget.transactions.last.date}");
//       debugPrint("📅 Last Date: ${widget.transactions.first.date}");
//     }

//     // ✅ FIXED: Filter only DEBIT transactions (expenses)
//     List<TransactionModel> periodExpenses = _getFilteredTransactions();

//     double totalSpending =
//         periodExpenses.fold(0, (sum, item) => sum + item.amount);

//     Map<String, double> categoryTotals =
//         _calculateCategoryTotals(periodExpenses);

//     List<MapEntry<String, double>> sortedCategories =
//         categoryTotals.entries.toList()
//           ..sort((a, b) => b.value.compareTo(a.value));

//     Map<int, double> weeklySpending =
//         _calculateWeeklySpending(periodExpenses);

//     double maxDaySpending =
//         weeklySpending.values.fold(0, (max, val) => val > max ? val : max);
//     if (maxDaySpending == 0) maxDaySpending = 1;

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text(
//           'Statistics',
//           style: TextStyle(
//               color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: false,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // PERIOD SELECTOR
//             Container(
//               height: 50,
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Row(
//                 children: List.generate(_periods.length, (index) {
//                   return Expanded(
//                     child: GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           _selectedPeriodIndex = index;
//                         });
//                       },
//                       child: Container(
//                         margin: const EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           color: _selectedPeriodIndex == index
//                               ? Colors.white
//                               : Colors.transparent,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Center(
//                           child: Text(
//                             _periods[index],
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 12,
//                               color: _selectedPeriodIndex == index
//                                   ? Colors.black
//                                   : Colors.grey,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 }),
//               ),
//             ),

//             const SizedBox(height: 30),

//             const Text(
//               'Total Spending',
//               style: TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//             const SizedBox(height: 5),
//             Text(
//               'Rs ${totalSpending.toStringAsFixed(2)}',
//               style: const TextStyle(
//                 fontSize: 32,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 20),

//             // BAR CHART
//             SizedBox(
//               height: 200,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   _buildBar('Mon', weeklySpending[1]! / maxDaySpending),
//                   _buildBar('Tue', weeklySpending[2]! / maxDaySpending),
//                   _buildBar('Wed', weeklySpending[3]! / maxDaySpending),
//                   _buildBar('Thu', weeklySpending[4]! / maxDaySpending),
//                   _buildBar('Fri', weeklySpending[5]! / maxDaySpending),
//                   _buildBar('Sat', weeklySpending[6]! / maxDaySpending),
//                   _buildBar('Sun', weeklySpending[7]! / maxDaySpending),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 40),

//             const Text(
//               'Top Categories',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 20),

//             if (sortedCategories.isEmpty)
//               const Center(child: Text("No expenses for this period"))
//             else
//               ...sortedCategories.map((entry) {
//                 return _buildCategoryItem(
//                   icon: _getIconForCategory(entry.key),
//                   color: _getColorForCategory(entry.key),
//                   category: entry.key,
//                   amount: '-Rs ${entry.value.toStringAsFixed(0)}',
//                   percent:
//                       totalSpending == 0 ? 0 : entry.value / totalSpending,
//                 );
//               }),
//           ],
//         ),
//       ),
//     );
//   }

//   // ================= LOGIC =================

//   List<TransactionModel> _getFilteredTransactions() {
//     DateTime now = DateTime.now();

//     // ✅ FIXED: Expense = debit
//     List<TransactionModel> expenses =
//         widget.transactions.where((tx) => tx.type == 'debit').toList();

//     if (_selectedPeriodIndex == 0) {
//       return expenses.where((tx) =>
//           tx.date.year == now.year &&
//           tx.date.month == now.month &&
//           tx.date.day == now.day).toList();
//     } else if (_selectedPeriodIndex == 1) {
//       return expenses.where((tx) => now.difference(tx.date).inDays < 7).toList();
//     } else if (_selectedPeriodIndex == 2) {
//       return expenses.where((tx) =>
//           tx.date.year == now.year &&
//           tx.date.month == now.month).toList();
//     } else if (_selectedPeriodIndex == 3) {
//       return expenses.where((tx) => tx.date.year == now.year).toList();
//     } else {
//       return expenses;
//     }
//   }

//   Map<String, double> _calculateCategoryTotals(List<TransactionModel> txs) {
//     Map<String, double> totals = {};
//     for (var tx in txs) {
//       totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
//     }
//     return totals;
//   }

//   Map<int, double> _calculateWeeklySpending(List<TransactionModel> txs) {
//     Map<int, double> days = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};

//     for (var tx in txs) {
//       days[tx.date.weekday] =
//           (days[tx.date.weekday] ?? 0) + tx.amount;
//     }
//     return days;
//   }

//   // ================= UI HELPERS =================

//   IconData _getIconForCategory(String category) {
//     switch (category) {
//       case 'Food':
//         return Icons.fastfood_rounded;
//       case 'Transport':
//         return Icons.directions_car_rounded;
//       case 'Shopping':
//         return Icons.shopping_bag_rounded;
//       case 'Entertainment':
//         return Icons.movie_rounded;
//       case 'Health':
//         return Icons.medical_services_rounded;
//       case 'Bills':
//         return Icons.receipt_long_rounded;
//       case 'Fuel':
//         return Icons.local_gas_station_rounded;
//       default:
//         return Icons.category_rounded;
//     }
//   }

//   Color _getColorForCategory(String category) {
//     switch (category) {
//       case 'Food':
//         return Colors.orange;
//       case 'Transport':
//         return Colors.blue;
//       case 'Shopping':
//         return Colors.purple;
//       case 'Entertainment':
//         return Colors.red;
//       case 'Health':
//         return Colors.teal;
//       case 'Bills':
//         return Colors.green;
//       case 'Fuel':
//         return Colors.amber;
//       default:
//         return Colors.indigo;
//     }
//   }

//   Widget _buildBar(String label, double heightPct) {
//     if (heightPct.isNaN || heightPct.isInfinite) heightPct = 0;

//     return Column(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         Container(
//           width: 35,
//           height: 150 * heightPct,
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//               begin: Alignment.bottomCenter,
//               end: Alignment.topCenter,
//             ),
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//         const SizedBox(height: 10),
//         Text(label, style: TextStyle(color: Colors.grey[500])),
//       ],
//     );
//   }

//   Widget _buildCategoryItem({
//     required IconData icon,
//     required Color color,
//     required String category,
//     required String amount,
//     required double percent,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 20),
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               CircleAvatar(
//                 backgroundColor: color.withOpacity(0.1),
//                 child: Icon(icon, color: color),
//               ),
//               const SizedBox(width: 15),
//               Expanded(
//                 child: Text(category,
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, fontSize: 16)),
//               ),
//               Text(amount,
//                   style: const TextStyle(
//                       fontWeight: FontWeight.bold, color: Colors.red)),
//             ],
//           ),
//           const SizedBox(height: 10),
//           LinearProgressIndicator(
//             value: percent,
//             color: color,
//             backgroundColor: Colors.grey[200],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class StatsScreen extends StatefulWidget {
  final List<TransactionModel> transactions;

  const StatsScreen({super.key, required this.transactions});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedPeriodIndex = 4;
  final List<String> _periods = ['Day', 'Week', 'Month', 'Year', 'All'];

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<TransactionModel> periodExpenses = _getFilteredTransactions();
    double totalSpending = periodExpenses.fold(0, (sum, item) => sum + item.amount);
    Map<String, double> categoryTotals = _calculateCategoryTotals(periodExpenses);
    List<MapEntry<String, double>> sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    Map<int, double> weeklySpending = _calculateWeeklySpending(periodExpenses);
    double maxDaySpending = weeklySpending.values.fold(0, (max, val) => val > max ? val : max);
    if (maxDaySpending == 0) maxDaySpending = 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPeriodSelector(),
                    const SizedBox(height: 32),
                    _buildTotalSpendingCard(totalSpending),
                    const SizedBox(height: 32),
                    _buildBarChart(weeklySpending, maxDaySpending),
                    const SizedBox(height: 40),
                    _buildTopCategoriesHeader(),
                    const SizedBox(height: 20),
                    if (sortedCategories.isEmpty)
                      _buildEmptyState()
                    else
                      ...sortedCategories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final categoryEntry = entry.value;
                        return _buildAnimatedCategoryItem(
                          index: index,
                          icon: _getIconForCategory(categoryEntry.key),
                          color: _getColorForCategory(categoryEntry.key),
                          category: categoryEntry.key,
                          amount: categoryEntry.value,
                          percent: totalSpending == 0 ? 0 : categoryEntry.value / totalSpending,
                        );
                      }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2575FC).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Track your spending patterns',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= PERIOD SELECTOR =================

  Widget _buildPeriodSelector() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (value * 0.05),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: Row(
          children: List.generate(_periods.length, (index) {
            final isSelected = _selectedPeriodIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedPeriodIndex = index);
                  _animationController.reset();
                  _animationController.forward();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                          )
                        : null,
                    color: isSelected ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF2575FC).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      _periods[index],
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isSelected ? Colors.white : Colors.grey[600],
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ================= TOTAL SPENDING CARD =================

  Widget _buildTotalSpendingCard(double totalSpending) {
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
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2575FC).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.trending_down_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Total Spending',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: totalSpending),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Text(
                  '₹ ${value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'in ${_periods[_selectedPeriodIndex].toLowerCase()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BAR CHART =================

  Widget _buildBarChart(Map<int, double> weeklySpending, double maxDaySpending) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2575FC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    size: 18,
                    color: Color(0xFF2575FC),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Weekly Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 180,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildAnimatedBar('Mon', weeklySpending[1]! / maxDaySpending, 0),
                  _buildAnimatedBar('Tue', weeklySpending[2]! / maxDaySpending, 1),
                  _buildAnimatedBar('Wed', weeklySpending[3]! / maxDaySpending, 2),
                  _buildAnimatedBar('Thu', weeklySpending[4]! / maxDaySpending, 3),
                  _buildAnimatedBar('Fri', weeklySpending[5]! / maxDaySpending, 4),
                  _buildAnimatedBar('Sat', weeklySpending[6]! / maxDaySpending, 5),
                  _buildAnimatedBar('Sun', weeklySpending[7]! / maxDaySpending, 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBar(String label, double heightPct, int index) {
    if (heightPct.isNaN || heightPct.isInfinite) heightPct = 0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: heightPct),
      duration: Duration(milliseconds: 800 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 36,
              height: 140 * animValue,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: animValue > 0.1
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2575FC).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= TOP CATEGORIES HEADER =================

  Widget _buildTopCategoriesHeader() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              size: 20,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Top Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ================= CATEGORY ITEM =================

  Widget _buildAnimatedCategoryItem({
    required int index,
    required IconData icon,
    required Color color,
    required String category,
    required double amount,
    required double percent,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
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
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(percent * 100).toStringAsFixed(1)}% of total',
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
                  '-₹${amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Colors.red[600],
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: percent),
              duration: Duration(milliseconds: 1000 + (index * 100)),
              curve: Curves.easeOutCubic,
              builder: (context, animValue, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: animValue,
                    minHeight: 8,
                    backgroundColor: Colors.grey[100],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= EMPTY STATE =================

  Widget _buildEmptyState() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (value * 0.1),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pie_chart_outline_rounded,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No expenses for this period',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding transactions to see statistics',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ================= FILTERING LOGIC =================

  List<TransactionModel> _getFilteredTransactions() {
    DateTime now = DateTime.now();
    List<TransactionModel> expenses =
        widget.transactions.where((tx) => tx.type == 'debit').toList();

    switch (_selectedPeriodIndex) {
      case 0: // Day
        return expenses.where((tx) =>
            tx.date.year == now.year &&
            tx.date.month == now.month &&
            tx.date.day == now.day).toList();
      case 1: // Week
        return expenses.where((tx) => now.difference(tx.date).inDays < 7).toList();
      case 2: // Month
        return expenses.where((tx) =>
            tx.date.year == now.year && tx.date.month == now.month).toList();
      case 3: // Year
        return expenses.where((tx) => tx.date.year == now.year).toList();
      default: // All
        return expenses;
    }
  }

  Map<String, double> _calculateCategoryTotals(List<TransactionModel> txs) {
    Map<String, double> totals = {};
    for (var tx in txs) {
      totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
    }
    return totals;
  }

  Map<int, double> _calculateWeeklySpending(List<TransactionModel> txs) {
    Map<int, double> days = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    for (var tx in txs) {
      days[tx.date.weekday] = (days[tx.date.weekday] ?? 0) + tx.amount;
    }
    return days;
  }

  // ================= CATEGORY HELPERS =================

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Transport':
        return Icons.directions_car_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Entertainment':
        return Icons.movie_rounded;
      case 'Health':
        return Icons.favorite_rounded;
      case 'Bills':
        return Icons.receipt_long_rounded;
      case 'Fuel':
        return Icons.local_gas_station_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Food':
        return const Color(0xFFFF6B6B);
      case 'Transport':
        return const Color(0xFF4ECDC4);
      case 'Shopping':
        return const Color(0xFFFFA07A);
      case 'Entertainment':
        return const Color(0xFFBA68C8);
      case 'Health':
        return const Color(0xFFFF8787);
      case 'Bills':
        return const Color(0xFF95E1D3);
      case 'Fuel':
        return const Color(0xFFFFD93D);
      default:
        return const Color(0xFF78909C);
    }
  }
}
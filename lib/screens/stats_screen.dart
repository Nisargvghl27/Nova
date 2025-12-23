import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class StatsScreen extends StatefulWidget {
  final List<TransactionModel> transactions;

  const StatsScreen({super.key, required this.transactions});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _selectedPeriodIndex = 4;
  final List<String> _periods = ['Day', 'Week', 'Month', 'Year', 'All'];

  @override
  Widget build(BuildContext context) {
    if (widget.transactions.isEmpty) {
      debugPrint("📊 STATS: No transactions received!");
    } else {
      debugPrint("📊 STATS: Received ${widget.transactions.length} transactions.");
      debugPrint("📅 First Date: ${widget.transactions.last.date}");
      debugPrint("📅 Last Date: ${widget.transactions.first.date}");
    }

    // ✅ FIXED: Filter only DEBIT transactions (expenses)
    List<TransactionModel> periodExpenses = _getFilteredTransactions();

    double totalSpending =
        periodExpenses.fold(0, (sum, item) => sum + item.amount);

    Map<String, double> categoryTotals =
        _calculateCategoryTotals(periodExpenses);

    List<MapEntry<String, double>> sortedCategories =
        categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    Map<int, double> weeklySpending =
        _calculateWeeklySpending(periodExpenses);

    double maxDaySpending =
        weeklySpending.values.fold(0, (max, val) => val > max ? val : max);
    if (maxDaySpending == 0) maxDaySpending = 1;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Statistics',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PERIOD SELECTOR
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: List.generate(_periods.length, (index) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPeriodIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _selectedPeriodIndex == index
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _periods[index],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: _selectedPeriodIndex == index
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Total Spending',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Text(
              'Rs ${totalSpending.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // BAR CHART
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar('Mon', weeklySpending[1]! / maxDaySpending),
                  _buildBar('Tue', weeklySpending[2]! / maxDaySpending),
                  _buildBar('Wed', weeklySpending[3]! / maxDaySpending),
                  _buildBar('Thu', weeklySpending[4]! / maxDaySpending),
                  _buildBar('Fri', weeklySpending[5]! / maxDaySpending),
                  _buildBar('Sat', weeklySpending[6]! / maxDaySpending),
                  _buildBar('Sun', weeklySpending[7]! / maxDaySpending),
                ],
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              'Top Categories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            if (sortedCategories.isEmpty)
              const Center(child: Text("No expenses for this period"))
            else
              ...sortedCategories.map((entry) {
                return _buildCategoryItem(
                  icon: _getIconForCategory(entry.key),
                  color: _getColorForCategory(entry.key),
                  category: entry.key,
                  amount: '-Rs ${entry.value.toStringAsFixed(0)}',
                  percent:
                      totalSpending == 0 ? 0 : entry.value / totalSpending,
                );
              }),
          ],
        ),
      ),
    );
  }

  // ================= LOGIC =================

  List<TransactionModel> _getFilteredTransactions() {
    DateTime now = DateTime.now();

    // ✅ FIXED: Expense = debit
    List<TransactionModel> expenses =
        widget.transactions.where((tx) => tx.type == 'debit').toList();

    if (_selectedPeriodIndex == 0) {
      return expenses.where((tx) =>
          tx.date.year == now.year &&
          tx.date.month == now.month &&
          tx.date.day == now.day).toList();
    } else if (_selectedPeriodIndex == 1) {
      return expenses.where((tx) => now.difference(tx.date).inDays < 7).toList();
    } else if (_selectedPeriodIndex == 2) {
      return expenses.where((tx) =>
          tx.date.year == now.year &&
          tx.date.month == now.month).toList();
    } else if (_selectedPeriodIndex == 3) {
      return expenses.where((tx) => tx.date.year == now.year).toList();
    } else {
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
      days[tx.date.weekday] =
          (days[tx.date.weekday] ?? 0) + tx.amount;
    }
    return days;
  }

  // ================= UI HELPERS =================

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Food':
        return Icons.fastfood_rounded;
      case 'Transport':
        return Icons.directions_car_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Entertainment':
        return Icons.movie_rounded;
      case 'Health':
        return Icons.medical_services_rounded;
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
        return Colors.orange;
      case 'Transport':
        return Colors.blue;
      case 'Shopping':
        return Colors.purple;
      case 'Entertainment':
        return Colors.red;
      case 'Health':
        return Colors.teal;
      case 'Bills':
        return Colors.green;
      case 'Fuel':
        return Colors.amber;
      default:
        return Colors.indigo;
    }
  }

  Widget _buildBar(String label, double heightPct) {
    if (heightPct.isNaN || heightPct.isInfinite) heightPct = 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 35,
          height: 150 * heightPct,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: TextStyle(color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required Color color,
    required String category,
    required String amount,
    required double percent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(category,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              Text(amount,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.red)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: percent,
            color: color,
            backgroundColor: Colors.grey[200],
          ),
        ],
      ),
    );
  }
}

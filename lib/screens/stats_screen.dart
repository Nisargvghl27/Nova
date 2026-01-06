import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  int _selectedPeriodIndex = 4;
  final List<String> _periods = ['Day', 'Week', 'Month', 'Year', 'All'];

  @override
  Widget build(BuildContext context) {
    // ✅ READ FROM PROVIDER
    final transactions = ref.watch(transactionProvider);

    // Filter only expenses
    final expenses =
        transactions.where((tx) => tx.type == 'debit').toList();

    final periodExpenses = _getFilteredTransactions(expenses);

    final totalSpending =
        periodExpenses.fold(0.0, (sum, tx) => sum + tx.amount);

    final categoryTotals = _calculateCategoryTotals(periodExpenses);

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final weeklySpending = _calculateWeeklySpending(periodExpenses);

    double maxDaySpending =
        weeklySpending.values.fold(0, (max, v) => v > max ? v : max);
    if (maxDaySpending == 0) maxDaySpending = 1;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Statistics',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                      onTap: () => setState(() {
                        _selectedPeriodIndex = index;
                      }),
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
                children: List.generate(7, (i) {
                  final day = i + 1;
                  return _buildBar(
                    ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i],
                    weeklySpending[day]! / maxDaySpending,
                  );
                }),
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
              ...sortedCategories.map((e) => _buildCategoryItem(
                    icon: _getIconForCategory(e.key),
                    color: _getColorForCategory(e.key),
                    category: e.key,
                    amount: '-Rs ${e.value.toStringAsFixed(0)}',
                    percent:
                        totalSpending == 0 ? 0 : e.value / totalSpending,
                  )),
          ],
        ),
      ),
    );
  }

  // ================= LOGIC =================

  List<TransactionModel> _getFilteredTransactions(
      List<TransactionModel> expenses) {
    final now = DateTime.now();

    switch (_selectedPeriodIndex) {
      case 0:
        return expenses.where((tx) =>
            tx.date.year == now.year &&
            tx.date.month == now.month &&
            tx.date.day == now.day).toList();
      case 1:
        return expenses
            .where((tx) => now.difference(tx.date).inDays < 7)
            .toList();
      case 2:
        return expenses.where((tx) =>
            tx.date.year == now.year &&
            tx.date.month == now.month).toList();
      case 3:
        return expenses
            .where((tx) => tx.date.year == now.year)
            .toList();
      default:
        return expenses;
    }
  }

  Map<String, double> _calculateCategoryTotals(
      List<TransactionModel> txs) {
    final Map<String, double> totals = {};
    for (final tx in txs) {
      totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
    }
    return totals;
  }

  Map<int, double> _calculateWeeklySpending(
      List<TransactionModel> txs) {
    final days = {for (int i = 1; i <= 7; i++) i: 0.0};
    for (final tx in txs) {
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
    if (!heightPct.isFinite) heightPct = 0;

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

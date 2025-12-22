import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class StatsScreen extends StatefulWidget {
  final List<Transaction> transactions;

  const StatsScreen({super.key, required this.transactions});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  // 1. CHANGED: Default to index 4 ('All') so you see data immediately
  int _selectedPeriodIndex = 4;
  final List<String> _periods = ['Day', 'Week', 'Month', 'Year', 'All'];

  @override
  Widget build(BuildContext context) {
    // --- DEBUG PRINTS (Check your console!) ---
    if (widget.transactions.isEmpty) {
      debugPrint("📊 STATS: No transactions received!");
    } else {
      debugPrint("📊 STATS: Received ${widget.transactions.length} transactions.");
      debugPrint("📅 First Date: ${widget.transactions.last.date}"); // Oldest (since we sorted desc)
      debugPrint("📅 Last Date: ${widget.transactions.first.date}"); // Newest
    }
    // ------------------------------------------

    // 2. Filter Logic: Get expenses for the selected period
    List<Transaction> periodExpenses = _getFilteredTransactions();
    
    // 3. Calculate Total for that period
    double totalSpending = periodExpenses.fold(0, (sum, item) => sum + item.amount);

    // 4. Prepare Data for Categories
    Map<String, double> categoryTotals = _calculateCategoryTotals(periodExpenses);
    List<MapEntry<String, double>> sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Sort highest first

    // 5. Prepare Data for Bar Chart
    // CHANGED: Pass 'periodExpenses' so the chart matches the selected tab
    Map<int, double> weeklySpending = _calculateWeeklySpending(periodExpenses);
    
    double maxDaySpending = weeklySpending.values.fold(0, (max, val) => val > max ? val : max);
    if (maxDaySpending == 0) maxDaySpending = 1; // Avoid division by zero

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Statistics',
          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Icon(Icons.calendar_month_outlined, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Period Selector
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
                          color: _selectedPeriodIndex == index ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _selectedPeriodIndex == index
                              ? [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            _periods[index],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12, // Slightly smaller text to fit "All"
                              color: _selectedPeriodIndex == index ? Colors.black : Colors.grey,
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

            // 2. The Chart Area
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
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Custom Bar Chart Widget
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar('Mon', weeklySpending[1]! / maxDaySpending, weeklySpending[1]! > 0),
                  _buildBar('Tue', weeklySpending[2]! / maxDaySpending, weeklySpending[2]! > 0),
                  _buildBar('Wed', weeklySpending[3]! / maxDaySpending, weeklySpending[3]! > 0),
                  _buildBar('Thu', weeklySpending[4]! / maxDaySpending, weeklySpending[4]! > 0),
                  _buildBar('Fri', weeklySpending[5]! / maxDaySpending, weeklySpending[5]! > 0),
                  _buildBar('Sat', weeklySpending[6]! / maxDaySpending, weeklySpending[6]! > 0),
                  _buildBar('Sun', weeklySpending[7]! / maxDaySpending, weeklySpending[7]! > 0),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 3. Top Categories List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Top Categories',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.swap_vert, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 20),

            // Generate List dynamically
            if (sortedCategories.isEmpty)
               const Center(
                 child: Padding(
                   padding: EdgeInsets.all(20.0),
                   child: Text("No expenses for this period"),
                 ),
               )
            else
              ...sortedCategories.map((entry) {
                return _buildCategoryItem(
                  icon: _getIconForCategory(entry.key),
                  color: _getColorForCategory(entry.key),
                  category: entry.key,
                  amount: '-Rs ${entry.value.toStringAsFixed(0)}',
                  percent: totalSpending == 0 ? 0 : entry.value / totalSpending,
                );
              }),
          ],
        ),
      ),
    );
  }

  // --- LOGIC HELPERS ---

  List<Transaction> _getFilteredTransactions() {
    DateTime now = DateTime.now();
    // Filter out income, keep only expenses
    List<Transaction> expenses = widget.transactions.where((tx) => tx.isExpense).toList();

    if (_selectedPeriodIndex == 0) { // Day
      return expenses.where((tx) => tx.date.year == now.year && tx.date.month == now.month && tx.date.day == now.day).toList();
    } else if (_selectedPeriodIndex == 1) { // Week
      return expenses.where((tx) => now.difference(tx.date).inDays < 7).toList();
    } else if (_selectedPeriodIndex == 2) { // Month
      return expenses.where((tx) => tx.date.year == now.year && tx.date.month == now.month).toList();
    } else if (_selectedPeriodIndex == 3) { // Year
      return expenses.where((tx) => tx.date.year == now.year).toList();
    } else { 
      // All Time (Index 4) - Return everything!
      return expenses;
    }
  }

  Map<String, double> _calculateCategoryTotals(List<Transaction> txs) {
    Map<String, double> totals = {};
    for (var tx in txs) {
      totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
    }
    return totals;
  }

  // CHANGED: Now accepts the list of transactions to calculate
  Map<int, double> _calculateWeeklySpending(List<Transaction> txs) {
    Map<int, double> days = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    
    for (var tx in txs) {
      // weekday: 1 = Mon, 7 = Sun
      // This sums up all spending by day of the week for the selected period
      days[tx.date.weekday] = (days[tx.date.weekday] ?? 0) + tx.amount;
    }
    return days;
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Food': return Icons.fastfood_rounded;
      case 'Transport': return Icons.directions_car_rounded;
      case 'Shopping': return Icons.shopping_bag_rounded;
      case 'Entertainment': return Icons.movie_rounded;
      case 'Health': return Icons.medical_services_rounded;
      case 'Bills': return Icons.receipt_long_rounded;
      case 'Fuel': return Icons.local_gas_station_rounded;
      default: return Icons.category_rounded;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Food': return Colors.orange;
      case 'Transport': return Colors.blue;
      case 'Shopping': return Colors.purple;
      case 'Entertainment': return Colors.red;
      case 'Health': return Colors.teal;
      case 'Bills': return Colors.green;
      case 'Fuel': return Colors.amber;
      default: return Colors.indigo;
    }
  }

  // --- UI WIDGETS ---

  Widget _buildBar(String label, double heightPct, bool isActive) {
    if (heightPct.isNaN || heightPct.isInfinite) heightPct = 0;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 35,
          height: 150 * heightPct, 
          constraints: const BoxConstraints(minHeight: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2575FC) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.grey[100],
              color: color,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
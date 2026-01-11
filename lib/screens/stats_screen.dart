import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../constants/categories.dart';

class StatsScreen extends StatefulWidget {
  final List<TransactionModel> transactions;

  const StatsScreen({super.key, required this.transactions});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  int _selectedPeriodIndex = 0;
  final List<String> _periods = ['7 Days', '30 Days', '90 Days', '1 Year'];

  late AnimationController _animationController;
  int _touchedIndex = -1; // For Donut Chart interaction

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
    // 1. Filter for expenses only
    final allExpenses = widget.transactions.where((tx) => tx.type == 'debit').toList();
    
    // 2. Generate Chart Data & Period Total
    final chartData = _generateChartData(allExpenses);
    
    // 3. Top Categories calculation
    Map<String, double> categoryTotals = _calculateCategoryTotals(chartData.filteredTransactions);
    List<MapEntry<String, double>> sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
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
                    
                    // TOTAL SPENDING CARD
                    _buildTotalSpendingCard(chartData.totalPeriodSpending, chartData.dateRange),
                    
                    const SizedBox(height: 32),
                    
                    // EXPENSE DISTRIBUTION (Modern Donut + Legend)
                    if (sortedCategories.isNotEmpty) ...[
                      _buildExpenseDistribution(sortedCategories, chartData.totalPeriodSpending),
                      const SizedBox(height: 32),
                    ],

                    // TREND CHART (Line Chart)
                    _buildTrendChart(chartData),
                    
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
                          icon: CategoryStyle.getStyle(categoryEntry.key).icon,
                          color: CategoryStyle.getStyle(categoryEntry.key).color,
                          category: categoryEntry.key,
                          amount: categoryEntry.value,
                          percent: chartData.totalPeriodSpending == 0 
                              ? 0 
                              : categoryEntry.value / chartData.totalPeriodSpending,
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

  // ================= IMPROVED EXPENSE DISTRIBUTION UI =================

  Widget _buildExpenseDistribution(List<MapEntry<String, double>> sortedCategories, double total) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = Theme.of(context).cardColor;

    // Show top 4 categories and group the rest into 'Others'
    List<MapEntry<String, double>> displayList = [];
    if (sortedCategories.length > 5) {
      displayList = sortedCategories.take(4).toList();
      double otherTotal = sortedCategories.skip(4).fold(0, (sum, item) => sum + item.value);
      displayList.add(MapEntry('Others', otherTotal));
    } else {
      displayList = sortedCategories;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
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
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.pie_chart_rounded, size: 18, color: Colors.purple),
              ),
              const SizedBox(width: 12),
              Text(
                "Expense Distribution",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              // 1. Donut Chart with Center Text
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  _touchedIndex = -1;
                                  return;
                                }
                                _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 4,
                          centerSpaceRadius: 50,
                          sections: _generatePieSections(displayList, total),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Total",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white38 : Colors.grey[500],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "₹${total > 9999 ? (total / 1000).toStringAsFixed(1) + 'k' : total.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // 2. Dynamic Legend
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: displayList.map((entry) {
                    final style = CategoryStyle.getStyle(entry.key);
                    final percentage = total > 0 ? (entry.value / total * 100).toStringAsFixed(0) : "0";
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: style.color, 
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: style.color.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2))
                              ]
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : Colors.grey[700],
                              ),
                            ),
                          ),
                          Text(
                            "$percentage%",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white30 : Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generatePieSections(List<MapEntry<String, double>> displayList, double total) {
    return List.generate(displayList.length, (i) {
      final isTouched = i == _touchedIndex;
      final radius = isTouched ? 22.0 : 16.0;
      final category = displayList[i].key;
      final value = displayList[i].value;
      final color = CategoryStyle.getStyle(category).color;

      return PieChartSectionData(
        color: color,
        value: value,
        title: '', 
        radius: radius,
        badgeWidget: null,
      );
    });
  }

  // ================= DATA LOGIC & TREND CHART =================

  _ChartData _generateChartData(List<TransactionModel> allExpenses) {
    final now = DateTime.now();
    List<double> values = [];
    List<String> labels = [];
    List<TransactionModel> filteredTxs = [];
    String dateRange = "";

    DateTime cleanDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

    if (_selectedPeriodIndex == 0) {
      int days = 7;
      dateRange = 'Last 7 Days';
      Map<int, double> dailyTotals = {}; 
      for (int i = 0; i < days; i++) dailyTotals[i] = 0.0;

      for (var tx in allExpenses) {
        final txDate = cleanDate(tx.date);
        final diff = cleanDate(now).difference(txDate).inDays;
        if (diff >= 0 && diff < days) {
          filteredTxs.add(tx);
          dailyTotals[diff] = (dailyTotals[diff] ?? 0) + tx.amount;
        }
      }

      for (int i = days - 1; i >= 0; i--) {
        values.add(dailyTotals[i] ?? 0.0);
        DateTime d = now.subtract(Duration(days: i));
        labels.add(i == 0 ? 'Today' : DateFormat('E').format(d));
      }

    } else if (_selectedPeriodIndex == 1) {
      dateRange = 'Last 30 Days';
      int weeks = 5; 
      Map<int, double> weeklyTotals = {};
      for (int i = 0; i < weeks; i++) weeklyTotals[i] = 0.0;

      for (var tx in allExpenses) {
        final diffDays = cleanDate(now).difference(cleanDate(tx.date)).inDays;
        if (diffDays >= 0 && diffDays < 35) {
           if (diffDays < 30) filteredTxs.add(tx); 
           int weekIndex = (diffDays / 7).floor();
           if (weekIndex < weeks) {
             weeklyTotals[weekIndex] = (weeklyTotals[weekIndex] ?? 0) + tx.amount;
           }
        }
      }

      for (int i = weeks - 1; i >= 0; i--) {
        values.add(weeklyTotals[i] ?? 0.0);
        labels.add("W${weeks - i}");
      }

    } else {
      dateRange = _selectedPeriodIndex == 2 ? 'Last 3 Months' : 'Last 1 Year';
      int months = _selectedPeriodIndex == 2 ? 3 : 12;

      Map<int, double> monthlyTotals = {};
      for (int i = 0; i < months; i++) monthlyTotals[i] = 0.0;

      for (var tx in allExpenses) {
        int diffMonths = (now.year - tx.date.year) * 12 + (now.month - tx.date.month);
        if (diffMonths >= 0 && diffMonths < months) {
          filteredTxs.add(tx);
          monthlyTotals[diffMonths] = (monthlyTotals[diffMonths] ?? 0) + tx.amount;
        }
      }

      for (int i = months - 1; i >= 0; i--) {
        values.add(monthlyTotals[i] ?? 0.0);
        DateTime d = DateTime(now.year, now.month - i, 1);
        labels.add(DateFormat('MMM').format(d));
      }
    }

    double maxY = values.isEmpty ? 100 : values.reduce(max);
    if (maxY == 0) maxY = 100;
    maxY = maxY * 1.2; 

    double totalSpent = filteredTxs.fold(0, (sum, item) => sum + item.amount);

    return _ChartData(
      values: values,
      labels: labels,
      maxY: maxY,
      dateRange: dateRange,
      totalPeriodSpending: totalSpent,
      filteredTransactions: filteredTxs,
    );
  }

  Widget _buildTrendChart(_ChartData data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textColor = isDark ? Colors.white : Colors.black87;

    List<FlSpot> spots = [];
    for(int i=0; i<data.values.length; i++) {
      spots.add(FlSpot(i.toDouble(), data.values[i]));
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
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
                child: const Icon(Icons.show_chart_rounded, size: 18, color: Color(0xFF2575FC)),
              ),
              const SizedBox(width: 12),
              Text(
                _getChartTitle(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200, 
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark ? Colors.white10 : Colors.grey[200],
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < data.labels.length) {
                           if (data.labels.length > 7 && index % 2 != 0) return const SizedBox();
                           return Padding(
                             padding: const EdgeInsets.only(top: 8),
                             child: Text(
                               data.labels[index],
                               style: TextStyle(
                                 color: isDark ? Colors.white54 : Colors.grey[600],
                                 fontSize: 10,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                           );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (data.values.length - 1).toDouble(),
                minY: 0,
                maxY: data.maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [const Color(0xFF2575FC).withOpacity(0.3), const Color(0xFF2575FC).withOpacity(0.0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getChartTitle() {
    switch (_selectedPeriodIndex) {
      case 0: return 'Daily Trend';
      case 1: return 'Weekly Trend';
      case 2: return 'Monthly Trend';
      case 3: return 'Yearly Trend';
      default: return 'Spending Trend';
    }
  }

  // ================= GENERAL UI COMPONENTS =================

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Statistics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black)),
                Text('Analyze your expenses', style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;

    return Container(
      height: 50,
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(4),
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
                decoration: BoxDecoration(
                  gradient: isSelected ? const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]) : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _periods[index],
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.grey[600]),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTotalSpendingCard(double totalSpending, String dateRange) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF2575FC).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(dateRange, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          Text('₹ ${totalSpending.toStringAsFixed(2)}', style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: -1)),
          const SizedBox(height: 8),
          Text('Total Spent', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTopCategoriesHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.emoji_events_rounded, size: 20, color: Colors.orange),
        ),
        const SizedBox(width: 12),
        Text('Top Categories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black)),
      ],
    );
  }

  Widget _buildAnimatedCategoryItem({
    required int index, required IconData icon, required Color color, required String category, required double amount, required double percent,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                    Text('${(percent * 100).toStringAsFixed(1)}% of total', style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey[600])),
                  ],
                ),
              ),
              Text('-₹${amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.red[600])),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Icon(Icons.pie_chart_outline_rounded, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text('No expenses yet', style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.grey[600])),
        ],
      ),
    );
  }

  Map<String, double> _calculateCategoryTotals(List<TransactionModel> txs) {
    Map<String, double> totals = {};
    for (var tx in txs) totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
    return totals;
  }
}

class _ChartData {
  final List<double> values;
  final List<String> labels;
  final double maxY;
  final String dateRange;
  final double totalPeriodSpending;
  final List<TransactionModel> filteredTransactions;

  _ChartData({
    required this.values,
    required this.labels,
    required this.maxY,
    required this.dateRange,
    required this.totalPeriodSpending,
    required this.filteredTransactions,
  });
}
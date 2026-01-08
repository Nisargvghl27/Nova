import 'dart:math';
import 'dart:ui' as ui;
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
  int _selectedPeriodIndex = 0;
  final List<String> _periods = ['7 Days', '30 Days', '90 Days', '1 Year'];

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
    // 1. Filter for expenses only
    final allExpenses = widget.transactions.where((tx) => tx.type == 'debit').toList();
    
    // 2. Generate Chart Data & Period Total based on selection
    final chartData = _generateChartData(allExpenses);
    
    // 3. Top Categories (Based on the filtered period)
    Map<String, double> categoryTotals = _calculateCategoryTotals(chartData.filteredTransactions);
    List<MapEntry<String, double>> sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final bgColor = Theme.of(context).scaffoldBackgroundColor;

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
                    
                    // 🔹 TOTAL SPENDING CARD
                    _buildTotalSpendingCard(chartData.totalPeriodSpending, chartData.dateRange),
                    
                    const SizedBox(height: 32),
                    
                    // 🔹 DYNAMIC TREND CHART
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
                          icon: _getIconForCategory(categoryEntry.key),
                          color: _getColorForCategory(categoryEntry.key),
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

  // ================= DATA LOGIC =================

  _ChartData _generateChartData(List<TransactionModel> allExpenses) {
    final now = DateTime.now();
    List<double> values = [];
    List<String> labels = [];
    List<TransactionModel> filteredTxs = [];
    String dateRange = "";

    // Helper to strip time
    DateTime cleanDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

    if (_selectedPeriodIndex == 0) {
      // -----------------------------------------
      // 7 DAYS: Daily Spending (Last 7 Days)
      // -----------------------------------------
      int days = 7;
      dateRange = 'Last 7 Days';

      // 1. Create buckets for each day
      Map<int, double> dailyTotals = {}; 
      for (int i = 0; i < days; i++) dailyTotals[i] = 0.0;

      // 2. Filter & Aggregate
      for (var tx in allExpenses) {
        final txDate = cleanDate(tx.date);
        final diff = cleanDate(now).difference(txDate).inDays;

        if (diff >= 0 && diff < days) {
          filteredTxs.add(tx);
          // Store in reverse order bucket (0 = today, 6 = 7 days ago)
          dailyTotals[diff] = (dailyTotals[diff] ?? 0) + tx.amount;
        }
      }

      // 3. Build Lists (Oldest to Newest)
      for (int i = days - 1; i >= 0; i--) {
        values.add(dailyTotals[i] ?? 0.0);
        
        // Generate Label
        DateTime d = now.subtract(Duration(days: i));
        if (i == 0) {
          labels.add('Today');
        } else {
          labels.add(DateFormat('E').format(d)); // Mon, Tue, etc.
        }
      }

    } else if (_selectedPeriodIndex == 1) {
      // -----------------------------------------
      // 30 DAYS: Weekly Spending (Last 5 Weeks)
      // -----------------------------------------
      dateRange = 'Last 30 Days';
      int weeks = 5; // Look back 5 weeks to cover 30 days
      
      Map<int, double> weeklyTotals = {};
      for (int i = 0; i < weeks; i++) weeklyTotals[i] = 0.0;

      for (var tx in allExpenses) {
        final diffDays = cleanDate(now).difference(cleanDate(tx.date)).inDays;

        // Roughly 35 days window to capture "5 weeks"
        if (diffDays >= 0 && diffDays < 35) {
           if (diffDays < 30) filteredTxs.add(tx); // Strict filter for Total Amount

           int weekIndex = (diffDays / 7).floor();
           if (weekIndex < weeks) {
             weeklyTotals[weekIndex] = (weeklyTotals[weekIndex] ?? 0) + tx.amount;
           }
        }
      }

      // Oldest week -> Newest week
      for (int i = weeks - 1; i >= 0; i--) {
        values.add(weeklyTotals[i] ?? 0.0);
        // Labels: "Week 1", "Week 2"... (Chronological)
        // i=4 is oldest (Week 1), i=0 is newest (Week 5)
        labels.add("W${weeks - i}");
      }

    } else if (_selectedPeriodIndex == 2) {
      // -----------------------------------------
      // 90 DAYS: Monthly Spending (Last 3 Months)
      // -----------------------------------------
      dateRange = 'Last 3 Months';
      int months = 3;

      Map<int, double> monthlyTotals = {};
      for (int i = 0; i < months; i++) monthlyTotals[i] = 0.0;

      for (var tx in allExpenses) {
        int diffMonths = (now.year - tx.date.year) * 12 + (now.month - tx.date.month);

        if (diffMonths >= 0 && diffMonths < months) {
          filteredTxs.add(tx);
          monthlyTotals[diffMonths] = (monthlyTotals[diffMonths] ?? 0) + tx.amount;
        }
      }

      // Oldest Month -> Current Month
      for (int i = months - 1; i >= 0; i--) {
        values.add(monthlyTotals[i] ?? 0.0);
        
        // Label: Month Name
        DateTime d = DateTime(now.year, now.month - i, 1);
        labels.add(DateFormat('MMM').format(d));
      }

    } else {
      // -----------------------------------------
      // 1 YEAR: Monthly Spending (Last 12 Months)
      // -----------------------------------------
      dateRange = 'Last 1 Year';
      int months = 12;

      Map<int, double> monthlyTotals = {};
      for (int i = 0; i < months; i++) monthlyTotals[i] = 0.0;

      for (var tx in allExpenses) {
        int diffMonths = (now.year - tx.date.year) * 12 + (now.month - tx.date.month);

        if (diffMonths >= 0 && diffMonths < months) {
          filteredTxs.add(tx);
          monthlyTotals[diffMonths] = (monthlyTotals[diffMonths] ?? 0) + tx.amount;
        }
      }

      // Oldest -> Newest
      for (int i = months - 1; i >= 0; i--) {
        values.add(monthlyTotals[i] ?? 0.0);
        
        DateTime d = DateTime(now.year, now.month - i, 1);
        // Use single letter or short month for tight fit if needed, 'MMM' usually fits
        labels.add(DateFormat('MMM').format(d));
      }
    }

    // Dynamic Max Y Scaling
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

  // ================= CHART WIDGET =================

  Widget _buildTrendChart(_ChartData data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textColor = isDark ? Colors.white : Colors.black87;

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
      child: Container(
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
                  child: const Icon(
                    Icons.show_chart_rounded,
                    size: 18,
                    color: Color(0xFF2575FC),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _getChartTitle(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 🔹 THE CHART
            SizedBox(
              height: 200, 
              width: double.infinity,
              child: CustomPaint(
                painter: _ChartWithAxisPainter(
                  data: data.values,
                  labels: data.labels,
                  maxY: data.maxY,
                  lineColor: const Color(0xFF2575FC),
                  fillColors: [
                    const Color(0xFF2575FC).withOpacity(0.3),
                    const Color(0xFF2575FC).withOpacity(0.0),
                  ],
                  isDark: isDark,
                ),
              ),
            ),
          ],
        ),
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

  // ================= STANDARD WIDGETS =================

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), 
            blurRadius: 10, 
            offset: const Offset(0, 2)
          )
        ],
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
                Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  'Analyze your expenses',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.grey,
                  ),
                ),
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
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
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
                  gradient: isSelected
                      ? const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)])
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _periods[index],
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: isSelected 
                           ? Colors.white 
                           : (isDark ? Colors.white70 : Colors.grey[600]),
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
                  child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  dateRange,
                  style: const TextStyle(
                    color: Colors.white,
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
            const SizedBox(height: 8),
            Text(
              'Total Spent',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCategoriesHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.emoji_events_rounded, size: 20, color: Colors.orange),
        ),
        const SizedBox(width: 12),
        Text(
          'Top Categories',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedCategoryItem({
    required int index, required IconData icon, required Color color, required String category, required double amount, required double percent,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
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

  IconData _getIconForCategory(String category) {
     switch (category) {
      case 'Food & Dining': return Icons.restaurant_rounded;
      case 'Groceries': return Icons.local_grocery_store_rounded;
      case 'Rent': return Icons.home_rounded;
      case 'Transport': return Icons.directions_bus_rounded;
      case 'Shopping': return Icons.shopping_bag_rounded;
      case 'Entertainment': return Icons.movie_rounded;
      case 'Healthcare': return Icons.health_and_safety_rounded;
      case 'Bills': return Icons.receipt_long_rounded;
      case 'Fuel': return Icons.local_gas_station_rounded;
      default: return Icons.category_rounded;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Food & Dining': return const Color(0xFFFF6B6B);
      case 'Groceries': return const Color(0xFF4ECDC4);
      case 'Transport': return const Color(0xFF5D9CEC);
      case 'Shopping': return const Color(0xFFEC87C0);
      case 'Entertainment': return const Color(0xFF967ADC);
      case 'Healthcare': return const Color(0xFFDA4453);
      case 'Bills': return const Color(0xFF95E1D3);
      case 'Fuel': return const Color(0xFFED5565);
      default: return const Color(0xFF78909C);
    }
  }
}

// ================= DATA CLASS =================
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

// ================= CHART PAINTER =================
class _ChartWithAxisPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final double maxY;
  final Color lineColor;
  final List<Color> fillColors;
  final bool isDark;

  _ChartWithAxisPainter({
    required this.data,
    required this.labels,
    required this.maxY,
    required this.lineColor,
    required this.fillColors,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double bottomPadding = 30.0; // Increased to fit labels
    const double leftPadding = 40.0;
    final double chartW = size.width - leftPadding;
    final double chartH = size.height - bottomPadding;

    // 🔹 DRAW Y-AXIS LABELS
    _drawText(canvas, '0', Offset(0, chartH - 10), isDark, alignRight: false);
    _drawText(canvas, '${(maxY/2).toInt()}', Offset(0, chartH/2 - 10), isDark, alignRight: false);
    _drawText(canvas, '${maxY.toInt()}', Offset(0, -10), isDark, alignRight: false);
    
    // 🔹 DRAW BASELINE
    final gridPaint = Paint()
      ..color = isDark ? Colors.white12 : Colors.grey[300]!
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(leftPadding, chartH), 
      Offset(size.width, chartH), 
      gridPaint
    );

    if (data.isEmpty || data.every((e) => e == 0)) return;

    // 🔹 PREPARE POINTS
    final path = Path();
    final double step = chartW / (data.length > 1 ? data.length - 1 : 1);
    
    // Scale data points
    double firstY = chartH - (data[0] / maxY * chartH);
    path.moveTo(leftPadding, firstY);

    List<Offset> points = [];
    points.add(Offset(leftPadding, firstY));

    // 🔹 CALCULATE POINTS
    for (int i = 1; i < data.length; i++) {
      double x = leftPadding + (i * step);
      double y = chartH - (data[i] / maxY * chartH);
      points.add(Offset(x, y));
    }

    // 🔹 DRAW PATH (CURVED)
    if (data.length == 1) {
      path.lineTo(size.width, firstY);
    } else {
      // Cubic Bezier Smoothing
      for (int i = 0; i < points.length - 1; i++) {
        final p1 = points[i];
        final p2 = points[i + 1];
        final cp1 = Offset((p1.dx + p2.dx) / 2, p1.dy);
        final cp2 = Offset((p1.dx + p2.dx) / 2, p2.dy);
        path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
      }
    }

    // Fill Gradient
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, chartH);
    fillPath.lineTo(leftPadding, chartH);
    fillPath.close();

    final gradient = ui.Gradient.linear(
      Offset(0, 0),
      Offset(0, chartH),
      fillColors,
    );

    canvas.drawPath(fillPath, Paint()..shader = gradient..style = PaintingStyle.fill);

    // Line Stroke
    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, strokePaint);

    // 🔹 DRAW X-AXIS LABELS (Aligned with points)
    for (int i = 0; i < points.length; i++) {
      if (i < labels.length) {
        final point = points[i];
        // Center text on the X coordinate
        _drawCenteredText(canvas, labels[i], Offset(point.dx, chartH + 10), isDark);
      }
    }
  }

  void _drawText(Canvas canvas, String text, Offset pos, bool isDark, {bool alignRight = false}) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: isDark ? Colors.white54 : Colors.grey[600],
        fontSize: 10, 
        fontWeight: FontWeight.w600,
      ),
    );
    final tp = TextPainter(
      text: textSpan,
      textDirection: ui.TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, pos);
  }

  void _drawCenteredText(Canvas canvas, String text, Offset centerPos, bool isDark) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: isDark ? Colors.white54 : Colors.grey[600],
        fontSize: 10, 
        fontWeight: FontWeight.w600,
      ),
    );
    final tp = TextPainter(
      text: textSpan,
      textDirection: ui.TextDirection.ltr,
    );
    tp.layout();
    // Offset by half width to center
    tp.paint(canvas, Offset(centerPos.dx - (tp.width / 2), centerPos.dy));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
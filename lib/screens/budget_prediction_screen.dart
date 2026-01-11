import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/budget_service.dart';
import '../services/transaction_service.dart';
import '../constants/categories.dart';

class BudgetPredictionScreen extends StatefulWidget {
  const BudgetPredictionScreen({super.key});

  @override
  State<BudgetPredictionScreen> createState() => _BudgetPredictionScreenState();
}

class _BudgetPredictionScreenState extends State<BudgetPredictionScreen> {
  final BudgetService _budgetService = BudgetService();
  final TransactionService _txService = TransactionService();

  // State
  Map<String, double> _currentMonthSpending = {};
  Map<String, double> _predictions = {};
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Calculate Current Month Spending (for Progress Bar)
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      
      // Fetch recent transactions stream
      final txStream = _txService.transactionsStream();
      
      // Get first snapshot (we assume data is available or empty list)
      final transactions = await txStream.first.timeout(
        const Duration(seconds: 5),
        onTimeout: () => [],
      ); 
      
      // Filter for current month's active expenses
      final currentMonthTxs = transactions.where((tx) {
        final isThisMonth = !tx.date.isBefore(startOfMonth); // Include 1st of month
        final isDebit = tx.type == 'debit';
        final isNotDeleted = !tx.isDeleted;
        return isThisMonth && isDebit && isNotDeleted;
      }).toList();

      final Map<String, double> spending = {};
      for (var tx in currentMonthTxs) {
        spending[tx.category] = (spending[tx.category] ?? 0) + tx.amount;
      }

      // Load AI Predictions
      final predictions = await _budgetService.calculatePredictions();

      if (mounted) {
        setState(() {
          _currentMonthSpending = spending;
          _predictions = predictions;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading budget data: $e");
      if (mounted) {
        setState(() => _isLoadingStats = false);
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Could not load data: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Dialog to Set Budget / View Graph Comparison
  void _showSetBudgetDialog(String category, double currentBudget, double spent, double? suggested) {
    final controller = TextEditingController(
      text: currentBudget > 0 ? currentBudget.toStringAsFixed(0) : ''
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(CategoryStyle.getStyle(category).icon, size: 24, color: CategoryStyle.getStyle(category).color),
            const SizedBox(width: 12),
            Expanded(child: Text(category, style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📊 Mini Bar Graph Comparison in Dialog
            const Text("Spending vs Budget", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildVerticalBar("Spent", spent, Colors.redAccent, isDark),
                const SizedBox(width: 20),
                _buildVerticalBar("Current", currentBudget, Colors.blueAccent, isDark),
                const SizedBox(width: 20),
                if (suggested != null && suggested > 0)
                  _buildVerticalBar("Predicted", suggested, Colors.purpleAccent, isDark),
              ],
            ),
            const Divider(height: 30),
            
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Monthly Limit',
                prefixText: '₹ ',
                filled: true,
                fillColor: isDark ? Colors.black12 : Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            
            if (suggested != null && suggested > 0) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                   controller.text = suggested.toStringAsFixed(0);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 18, color: Colors.purple),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Apply Predicted: ₹${suggested.toStringAsFixed(0)}",
                          style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text) ?? 0;
              _budgetService.setBudget(category, val);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2575FC),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save Budget'),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalBar(String label, double amount, Color color, bool isDark) {
    double height = (amount / 5000 * 60).clamp(4.0, 60.0); 
    if (amount == 0) height = 4;

    return Column(
      children: [
        Text("₹${amount.toInt()}", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Container(
          width: 20,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Budget Planner', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoadingStats 
        ? const Center(child: CircularProgressIndicator())
        : StreamBuilder<Map<String, double>>(
            stream: _budgetService.getBudgetsStream(),
            builder: (context, snapshot) {
              final budgets = snapshot.data ?? {};
              
              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: ExpenseCategories.list.length,
                itemBuilder: (context, index) {
                  final category = ExpenseCategories.list[index];
                  final budget = budgets[category] ?? 0.0;
                  final spent = _currentMonthSpending[category] ?? 0.0;
                  final prediction = _predictions[category] ?? 0.0;
                  
                  if (spent == 0 && budget == 0 && prediction == 0) {
                     return const SizedBox.shrink(); 
                  }

                  return _buildBudgetCard(
                    category: category,
                    budget: budget,
                    spent: spent,
                    prediction: prediction,
                    isDark: isDark,
                  );
                },
              );
            },
          ),
    );
  }

  Widget _buildBudgetCard({
    required String category,
    required double budget,
    required double spent,
    required double prediction,
    required bool isDark,
  }) {
    final style = CategoryStyle.getStyle(category);
    // Calculate progress (0.0 to 1.0)
    final progress = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = spent > budget && budget > 0;
    final progressColor = isOverBudget ? Colors.redAccent : const Color(0xFF2575FC);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showSetBudgetDialog(category, budget, spent, prediction);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
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
            // Header: Icon + Category Name + Edit Icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: style.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(style.icon, color: style.color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Icon(Icons.edit_rounded, size: 18, color: isDark ? Colors.white38 : Colors.grey[400]),
              ],
            ),
            
            const SizedBox(height: 18),
            
            // Progress Bar & Stats (The "Bar Graph")
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: "Spent: ", style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600], fontSize: 12)),
                          TextSpan(
                            text: "₹${spent.toStringAsFixed(0)}", 
                            style: TextStyle(
                              color: progressColor, 
                              fontWeight: FontWeight.bold,
                              fontSize: 13
                            )
                          ),
                        ],
                      ),
                    ),
                    Text(
                      budget > 0 ? "Limit: ₹${budget.toStringAsFixed(0)}" : "No Limit Set",
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // BAR GRAPH VISUAL
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: budget > 0 ? progress : 0,
                    // If no budget, showing a small 'trace' or empty track
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(progressColor),
                    minHeight: 10,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Prediction Box
            if (prediction > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800]!.withOpacity(0.5) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.insights_rounded, size: 16, color: Colors.purple[300]),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Predicted need: ₹${prediction.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (budget != prediction)
                       InkWell(
                         onTap: () {
                           HapticFeedback.mediumImpact();
                           _budgetService.setBudget(category, prediction);
                         },
                         child: Container(
                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                           decoration: BoxDecoration(
                             color: Colors.purple.withOpacity(0.1),
                             borderRadius: BorderRadius.circular(6),
                           ),
                           child: const Text(
                             "APPLY",
                             style: TextStyle(
                               fontSize: 10,
                               fontWeight: FontWeight.bold,
                               color: Colors.purpleAccent,
                             ),
                           ),
                         ),
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
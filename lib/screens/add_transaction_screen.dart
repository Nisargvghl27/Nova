import 'package:flutter/material.dart';
import '/../models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _selectedCategory = 'Food';
  bool _isExpense = true; 

  // 1. Defined two separate lists for categories
  final List<String> _expenseCategories = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
    'Health'
  ];

  final List<String> _incomeCategories = [
    'Salary',
    'Business',
    'Investment',
    'Gift',
    'Freelance',
    'Other'
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 2. Determine which list to show based on the toggle
    final List<String> currentCategories = _isExpense ? _expenseCategories : _incomeCategories;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Transaction',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle Switch (Income / Expense)
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    _buildToggleButton('Expense', true),
                    _buildToggleButton('Income', false),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Amount Input
              const Text(
                'Amount',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  prefixStyle: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  border: InputBorder.none,
                  hintText: '0.00',
                  hintStyle: TextStyle(color: Colors.grey[300]),
                ),
              ),
              
              const SizedBox(height: 30),

              // Category Selection
              const Text(
                'Category',
                style: TextStyle(
                    color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: currentCategories.map((category) {
                  return ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    selectedColor: _isExpense ? const Color(0xFF2575FC) : Colors.green, // Blue for expense, Green for income
                    labelStyle: TextStyle(
                      color: _selectedCategory == category ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold
                    ),
                    backgroundColor: Colors.white,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              // Note Input
              const Text(
                'Note',
                style: TextStyle(
                    color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: 'Add a note...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),

              const SizedBox(height: 40),

              // Save Button
              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isExpense 
                      ? [const Color(0xFF6A11CB), const Color(0xFF2575FC)] // Blue gradient for expense
                      : [Colors.green.shade400, Colors.green.shade700],    // Green gradient for income
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: (_isExpense ? const Color(0xFF2575FC) : Colors.green).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (_amountController.text.isEmpty) {
                       return; 
                    }

                    final double amount = double.tryParse(_amountController.text) ?? 0.0;
                    
                    final newTx = Transaction(
                      id: DateTime.now().toString(),
                      title: _noteController.text.isEmpty ? _selectedCategory : _noteController.text,
                      amount: amount,
                      date: DateTime.now(),
                      category: _selectedCategory,
                      isExpense: _isExpense, 
                      icon: _getIconForCategory(_selectedCategory), 
                      color: _getColorForCategory(_selectedCategory, _isExpense), 
                    );

                    Navigator.pop(context, newTx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'SAVE TRANSACTION',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isExpenseBtn) {
    bool isSelected = _isExpense == isExpenseBtn;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpense = isExpenseBtn;
            // 3. IMPORTANT: Reset selected category when switching!
            // If switching to Expense, pick the first expense item.
            // If switching to Income, pick the first income item.
            _selectedCategory = isExpenseBtn ? _expenseCategories[0] : _incomeCategories[0];
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    // 4. Added Income Icons
    switch (category) {
      // Expense
      case 'Food': return Icons.fastfood_rounded;
      case 'Transport': return Icons.directions_car_rounded;
      case 'Shopping': return Icons.shopping_bag_rounded;
      case 'Entertainment': return Icons.sports_esports_rounded;
      case 'Bills': return Icons.receipt_long_rounded;
      case 'Health': return Icons.medical_services_rounded;
      // Income
      case 'Salary': return Icons.attach_money_rounded;
      case 'Business': return Icons.business_center_rounded;
      case 'Investment': return Icons.trending_up_rounded;
      case 'Gift': return Icons.card_giftcard_rounded;
      case 'Freelance': return Icons.computer_rounded;
      default: return Icons.category_rounded;
    }
  }

  Color _getColorForCategory(String category, bool isExpense) {
    // 5. Income usually uses Green, Expense uses varied colors
    if (!isExpense) return Colors.green; 

    switch (category) {
      case 'Food': return Colors.orange;
      case 'Transport': return Colors.blue;
      case 'Shopping': return Colors.purple;
      case 'Entertainment': return Colors.red;
      case 'Bills': return Colors.indigo;
      case 'Health': return Colors.teal;
      default: return Colors.grey;
    }
  }
}
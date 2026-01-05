// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/transaction_model.dart';
// import '../services/transaction_service.dart';

// class AddTransactionScreen extends StatefulWidget {
//   const AddTransactionScreen({super.key});

//   @override
//   State<AddTransactionScreen> createState() => _AddTransactionScreenState();
// }

// class _AddTransactionScreenState extends State<AddTransactionScreen> {
//   final TextEditingController _amountController = TextEditingController();
//   final TextEditingController _noteController = TextEditingController();

//   String _selectedCategory = 'Food';
//   bool _isExpense = true;

//   final List<String> _expenseCategories = [
//     'Food',
//     'Transport',
//     'Shopping',
//     'Entertainment',
//     'Bills',
//     'Health',
//   ];

//   final List<String> _incomeCategories = [
//     'Salary',
//     'Business',
//     'Investment',
//     'Gift',
//     'Freelance',
//     'Other',
//   ];

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _noteController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final List<String> currentCategories =
//         _isExpense ? _expenseCategories : _incomeCategories;

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Add Transaction',
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ================= EXPENSE / INCOME TOGGLE =================
//               Container(
//                 padding: const EdgeInsets.all(5),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   children: [
//                     _buildToggleButton('Expense', true),
//                     _buildToggleButton('Income', false),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 30),

//               // ================= AMOUNT =================
//               const Text(
//                 'Amount',
//                 style: TextStyle(color: Colors.grey, fontSize: 16),
//               ),
//               TextField(
//                 controller: _amountController,
//                 keyboardType:
//                     const TextInputType.numberWithOptions(decimal: true),
//                 style: const TextStyle(
//                   fontSize: 40,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 decoration: InputDecoration(
//                   prefixText: 'Rs ',
//                   prefixStyle: const TextStyle(
//                     fontSize: 40,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   border: InputBorder.none,
//                   hintText: '0.00',
//                   hintStyle: TextStyle(color: Colors.grey[300]),
//                 ),
//               ),

//               const SizedBox(height: 30),

//               // ================= CATEGORY =================
//               const Text(
//                 'Category',
//                 style:
//                     TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 15),
//               Wrap(
//                 spacing: 10,
//                 runSpacing: 10,
//                 children: currentCategories.map((category) {
//                   return ChoiceChip(
//                     label: Text(category),
//                     selected: _selectedCategory == category,
//                     selectedColor: _isExpense
//                         ? const Color(0xFF2575FC)
//                         : Colors.green,
//                     labelStyle: TextStyle(
//                       color: _selectedCategory == category
//                           ? Colors.white
//                           : Colors.black,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     backgroundColor: Colors.white,
//                     onSelected: (_) {
//                       setState(() {
//                         _selectedCategory = category;
//                       });
//                     },
//                   );
//                 }).toList(),
//               ),

//               const SizedBox(height: 30),

//               // ================= NOTE =================
//               const Text(
//                 'Note',
//                 style:
//                     TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 controller: _noteController,
//                 decoration: InputDecoration(
//                   hintText: 'Add a note...',
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15),
//                     borderSide: BorderSide.none,
//                   ),
//                   contentPadding: const EdgeInsets.all(20),
//                 ),
//               ),

//               const SizedBox(height: 40),

//               // ================= SAVE BUTTON =================
//               Container(
//                 width: double.infinity,
//                 height: 55,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: _isExpense
//                         ? const [
//                             Color(0xFF6A11CB),
//                             Color(0xFF2575FC),
//                           ]
//                         : [
//                             Colors.green.shade400,
//                             Colors.green.shade700,
//                           ],
//                   ),
//                   borderRadius: BorderRadius.circular(15),
//                   boxShadow: [
//                     BoxShadow(
//                       color: (_isExpense
//                               ? const Color(0xFF2575FC)
//                               : Colors.green)
//                           .withAlpha(80),
//                       blurRadius: 10,
//                       offset: const Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     if (_amountController.text.isEmpty) return;

//                     final double amount =
//                         double.tryParse(_amountController.text) ?? 0.0;

//                     final newTx = TransactionModel(
//                       id: DateTime.now().millisecondsSinceEpoch.toString(),
//                       title: _noteController.text.isEmpty
//                           ? _selectedCategory
//                           : _noteController.text,
//                       amount: amount,
//                       date: DateTime.now(),
//                       category: _selectedCategory,
//                       type: _isExpense ? 'debit' : 'credit',
//                       source: 'manual',
//                       note: _noteController.text,
//                       createdAt: Timestamp.now(),
//                     );

//                     await TransactionService().addTransaction(newTx);
//                     Navigator.pop(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.transparent,
//                     shadowColor: Colors.transparent,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                   ),
//                   child: const Text(
//                     'SAVE TRANSACTION',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ================= TOGGLE BUTTON =================

//   Widget _buildToggleButton(String text, bool isExpenseBtn) {
//     final bool isSelected = _isExpense == isExpenseBtn;

//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             _isExpense = isExpenseBtn;
//             _selectedCategory =
//                 isExpenseBtn ? _expenseCategories[0] : _incomeCategories[0];
//           });
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             color: isSelected ? Colors.white : Colors.transparent,
//             borderRadius: BorderRadius.circular(15),
//             boxShadow: isSelected
//                 ? [
//                     BoxShadow(
//                       color: Colors.grey.withAlpha(25),
//                       blurRadius: 5,
//                     )
//                   ]
//                 : [],
//           ),
//           child: Center(
//             child: Text(
//               text,
//               style: TextStyle(
//                 color: isSelected ? Colors.black : Colors.grey,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with TickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _selectedCategory = 'Food';
  bool _isExpense = true;
  bool _isSaving = false;

  late AnimationController _scaleController;
  late AnimationController _slideController;

  final List<CategoryData> _expenseCategories = [
    CategoryData('Food', Icons.restaurant_rounded, const Color(0xFFFF6B6B)),
    CategoryData('Transport', Icons.directions_car_rounded, const Color(0xFF4ECDC4)),
    CategoryData('Shopping', Icons.shopping_bag_rounded, const Color(0xFFFFA07A)),
    CategoryData('Entertainment', Icons.movie_rounded, const Color(0xFFBA68C8)),
    CategoryData('Bills', Icons.receipt_long_rounded, const Color(0xFF95E1D3)),
    CategoryData('Health', Icons.favorite_rounded, const Color(0xFFFF8787)),
  ];

  final List<CategoryData> _incomeCategories = [
    CategoryData('Salary', Icons.account_balance_wallet_rounded, const Color(0xFF51CF66)),
    CategoryData('Business', Icons.business_rounded, const Color(0xFF20C997)),
    CategoryData('Investment', Icons.trending_up_rounded, const Color(0xFF37B679)),
    CategoryData('Gift', Icons.card_giftcard_rounded, const Color(0xFF69DB7C)),
    CategoryData('Freelance', Icons.laptop_rounded, const Color(0xFF12B886)),
    CategoryData('Other', Icons.more_horiz_rounded, const Color(0xFF38D9A9)),
  ];

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<CategoryData> currentCategories =
        _isExpense ? _expenseCategories : _incomeCategories;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Column(
          children: [
            // ================= CUSTOM APP BAR =================
            _buildAppBar(),

            // ================= SCROLLABLE CONTENT =================
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Toggle
                      _buildAnimatedToggle(),

                      const SizedBox(height: 32),

                      // Amount Input
                      _buildAmountInput(),

                      const SizedBox(height: 36),

                      // Category Selection
                      _buildCategorySection(currentCategories),

                      const SizedBox(height: 36),

                      // Note Input
                      _buildNoteInput(),

                      const SizedBox(height: 40),

                      // Save Button
                      _buildSaveButton(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= APP BAR =================

  Widget _buildAppBar() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      )),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
              ),
            ),
            const Expanded(
              child: Text(
                'Add Transaction',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(width: 48), // Balance the back button
          ],
        ),
      ),
    );
  }

  // ================= ANIMATED TOGGLE =================

  Widget _buildAnimatedToggle() {
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
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildToggleButton('Expense', true, Icons.arrow_downward_rounded),
            _buildToggleButton('Income', false, Icons.arrow_upward_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isExpenseBtn, IconData icon) {
    final bool isSelected = _isExpense == isExpenseBtn;
    final Color activeColor = isExpenseBtn 
        ? const Color(0xFF2575FC) 
        : const Color(0xFF51CF66);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          setState(() {
            _isExpense = isExpenseBtn;
            _selectedCategory = isExpenseBtn
                ? _expenseCategories[0].name
                : _incomeCategories[0].name;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: isExpenseBtn
                        ? [const Color(0xFF6A11CB), const Color(0xFF2575FC)]
                        : [const Color(0xFF51CF66), const Color(0xFF37B679)],
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= AMOUNT INPUT =================

  Widget _buildAmountInput() {
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
            Text(
              'Amount',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.5,
                color: _isExpense 
                    ? const Color(0xFF2575FC) 
                    : const Color(0xFF51CF66),
              ),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  color: _isExpense 
                      ? const Color(0xFF2575FC) 
                      : const Color(0xFF51CF66),
                ),
                border: InputBorder.none,
                hintText: '0.00',
                hintStyle: TextStyle(
                  color: Colors.grey[300],
                  fontWeight: FontWeight.w800,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (_) {
                HapticFeedback.selectionClick();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= CATEGORY SECTION =================

  Widget _buildCategorySection(List<CategoryData> categories) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (_isExpense 
                      ? const Color(0xFF2575FC) 
                      : const Color(0xFF51CF66)).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.category_rounded,
                  size: 18,
                  color: _isExpense 
                      ? const Color(0xFF2575FC) 
                      : const Color(0xFF51CF66),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 400 + (index * 50)),
                curve: Curves.easeOutCubic,
                builder: (context, animValue, child) {
                  return Transform.scale(
                    scale: 0.8 + (animValue * 0.2),
                    child: Opacity(opacity: animValue, child: child),
                  );
                },
                child: _buildCategoryChip(category),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(CategoryData category) {
    final bool isSelected = _selectedCategory == category.name;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedCategory = category.name;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? category.color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? category.color : Colors.grey[200]!,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: category.color.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              color: isSelected ? Colors.white : category.color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[800],
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= NOTE INPUT =================

  Widget _buildNoteInput() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.edit_note_rounded,
                  size: 18,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Note (Optional)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _noteController,
              maxLines: 3,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: 'Add a description for this transaction...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
              onChanged: (_) {
                HapticFeedback.selectionClick();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= SAVE BUTTON =================

  Widget _buildSaveButton() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (value * 0.05),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isExpense
                ? const [Color(0xFF6A11CB), Color(0xFF2575FC)]
                : const [Color(0xFF51CF66), Color(0xFF37B679)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (_isExpense 
                  ? const Color(0xFF2575FC) 
                  : const Color(0xFF51CF66)).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isSaving ? null : _saveTransaction,
            borderRadius: BorderRadius.circular(20),
            child: Center(
              child: _isSaving
                  ? const SizedBox(
                      height: 26,
                      width: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'SAVE TRANSACTION',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
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

  // ================= SAVE LOGIC =================

  Future<void> _saveTransaction() async {
    if (_amountController.text.isEmpty) {
      HapticFeedback.heavyImpact();
      _showErrorSnackBar('Please enter an amount');
      return;
    }

    final double amount = double.tryParse(_amountController.text) ?? 0.0;

    if (amount <= 0) {
      HapticFeedback.heavyImpact();
      _showErrorSnackBar('Please enter a valid amount');
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      final newTx = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _noteController.text.isEmpty
            ? _selectedCategory
            : _noteController.text,
        amount: amount,
        date: DateTime.now(),
        category: _selectedCategory,
        type: _isExpense ? 'debit' : 'credit',
        source: 'manual',
        note: _noteController.text,
        createdAt: Timestamp.now(),
      );

      await TransactionService().addTransaction(newTx);

      if (mounted) {
        HapticFeedback.heavyImpact();
        Navigator.pop(context);
        
        // Show success message (you can customize this)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Transaction saved successfully'),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        _showErrorSnackBar('Failed to save transaction');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// ================= CATEGORY DATA MODEL =================

class CategoryData {
  final String name;
  final IconData icon;
  final Color color;

  CategoryData(this.name, this.icon, this.color);
}
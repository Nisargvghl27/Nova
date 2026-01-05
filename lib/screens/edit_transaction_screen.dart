// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/transaction_model.dart';
// import '../services/transaction_service.dart';

// class EditTransactionScreen extends StatefulWidget {
//   final TransactionModel transaction;

//   const EditTransactionScreen({
//     super.key,
//     required this.transaction,
//   });

//   @override
//   State<EditTransactionScreen> createState() =>
//       _EditTransactionScreenState();
// }

// class _EditTransactionScreenState extends State<EditTransactionScreen> {
//   late TextEditingController _amountController;
//   late TextEditingController _noteController;

//   late String _selectedCategory;
//   late bool _isExpense;
//   bool _isSaving = false;

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
//   void initState() {
//     super.initState();

//     _amountController =
//         TextEditingController(text: widget.transaction.amount.toString());

//     _noteController =
//         TextEditingController(text: widget.transaction.note);

//     _selectedCategory = widget.transaction.category;
//     _isExpense = widget.transaction.type == 'debit';
//   }

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _noteController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final categories =
//         _isExpense ? _expenseCategories : _incomeCategories;

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text(
//           'Edit Transaction',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ================= TOGGLE =================
//             Container(
//               padding: const EdgeInsets.all(5),
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Row(
//                 children: [
//                   _buildToggle('Expense', true),
//                   _buildToggle('Income', false),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 30),

//             // ================= AMOUNT =================
//             const Text(
//               'Amount',
//               style: TextStyle(color: Colors.grey),
//             ),
//             TextField(
//               controller: _amountController,
//               keyboardType:
//                   const TextInputType.numberWithOptions(decimal: true),
//               style: const TextStyle(
//                 fontSize: 36,
//                 fontWeight: FontWeight.bold,
//               ),
//               decoration: const InputDecoration(
//                 prefixText: 'Rs ',
//                 border: InputBorder.none,
//               ),
//             ),

//             const SizedBox(height: 30),

//             // ================= CATEGORY =================
//             const Text(
//               'Category',
//               style:
//                   TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 15),
//             Wrap(
//               spacing: 10,
//               runSpacing: 10,
//               children: categories.map((cat) {
//                 return ChoiceChip(
//                   label: Text(cat),
//                   selected: _selectedCategory == cat,
//                   selectedColor: _isExpense
//                       ? const Color(0xFF2575FC)
//                       : Colors.green,
//                   labelStyle: TextStyle(
//                     color: _selectedCategory == cat
//                         ? Colors.white
//                         : Colors.black,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   onSelected: (_) =>
//                       setState(() => _selectedCategory = cat),
//                 );
//               }).toList(),
//             ),

//             const SizedBox(height: 30),

//             // ================= NOTE =================
//             const Text(
//               'Note',
//               style:
//                   TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _noteController,
//               decoration: InputDecoration(
//                 hintText: 'Update note...',
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: const EdgeInsets.all(20),
//               ),
//             ),

//             const SizedBox(height: 40),

//             // ================= SAVE =================
//             SizedBox(
//               width: double.infinity,
//               height: 55,
//               child: ElevatedButton(
//                 onPressed: _isSaving ? null : _updateTransaction,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _isExpense ? const Color(0xFF2575FC) : Colors.green,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                 ),
//                 child: _isSaving
//                     ? const CircularProgressIndicator(
//                         color: Colors.white,
//                       )
//                     : const Text(
//                         'UPDATE TRANSACTION',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                           color: Colors.white,
//                         ),
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ================= UPDATE LOGIC =================

//   Future<void> _updateTransaction() async {
//     setState(() => _isSaving = true);

//     final double amount =
//         double.tryParse(_amountController.text) ?? 0;

//     await TransactionService().updateTransaction(
//       widget.transaction.id,
//       {
//         // 🔥 IMPORTANT FIX
//         'title': _noteController.text.isEmpty
//             ? _selectedCategory
//             : _noteController.text,
//         'note': _noteController.text,
//         'amount': amount,
//         'category': _selectedCategory,
//         'type': _isExpense ? 'debit' : 'credit',
//         'updatedAt': Timestamp.now(),
//       },
//     );

//     if (!mounted) return;
//     Navigator.pop(context);
//   }

//   // ================= TOGGLE =================

//   Widget _buildToggle(String text, bool expense) {
//     final selected = _isExpense == expense;

//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             _isExpense = expense;
//             _selectedCategory = expense
//                 ? _expenseCategories.first
//                 : _incomeCategories.first;
//           });
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             color: selected ? Colors.white : Colors.transparent,
//             borderRadius: BorderRadius.circular(15),
//           ),
//           child: Center(
//             child: Text(
//               text,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: selected ? Colors.black : Colors.grey,
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
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen>
    with TickerProviderStateMixin {
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  late String _selectedCategory;
  late bool _isExpense;
  late DateTime _selectedDate;
  bool _isSaving = false;
  bool _isDeleting = false;

  late AnimationController _slideController;
  late AnimationController _fadeController;

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
    _amountController = TextEditingController(
      text: widget.transaction.amount.toStringAsFixed(2),
    );
    _noteController = TextEditingController(
      text: widget.transaction.note ?? '',
    );
    _selectedCategory = widget.transaction.category;
    _isExpense = widget.transaction.type == 'debit';
    _selectedDate = widget.transaction.date;

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
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
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTransactionInfoCard(),
                      const SizedBox(height: 24),
                      _buildAnimatedToggle(),
                      const SizedBox(height: 32),
                      _buildAmountInput(),
                      const SizedBox(height: 36),
                      _buildDatePicker(),
                      const SizedBox(height: 36),
                      _buildCategorySection(currentCategories),
                      const SizedBox(height: 36),
                      _buildNoteInput(),
                      const SizedBox(height: 40),
                      _buildActionButtons(),
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
                'Edit Transaction',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.delete_outline, size: 22, color: Colors.red[600]),
                onPressed: _showDeleteConfirmation,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionInfoCard() {
    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isExpense
                ? [const Color(0xFF6A11CB), const Color(0xFF2575FC)]
                : [const Color(0xFF51CF66), const Color(0xFF37B679)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (_isExpense 
                  ? const Color(0xFF2575FC) 
                  : const Color(0xFF51CF66)).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isExpense ? 'Expense' : 'Income',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.transaction.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Created ${DateFormat('MMM dd, yyyy').format(widget.transaction.date)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
              onChanged: (_) => HapticFeedback.selectionClick(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 650),
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
                  color: const Color(0xFF2575FC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: Color(0xFF2575FC),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Date',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(20),
              child: Ink(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[200]!, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2575FC).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.event_rounded,
                        color: Color(0xFF2575FC),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transaction Date',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    HapticFeedback.lightImpact();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _isExpense ? const Color(0xFF2575FC) : const Color(0xFF51CF66),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      HapticFeedback.mediumImpact();
      setState(() => _selectedDate = picked);
    }
  }

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
            children: categories.map((category) => _buildCategoryChip(category)).toList(),
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
        setState(() => _selectedCategory = category.name);
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
                'Note',
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
              onChanged: (_) => HapticFeedback.selectionClick(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
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
      child: Column(
        children: [
          Container(
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
                onTap: _isSaving ? null : _updateTransaction,
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
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'UPDATE TRANSACTION',
                              style: TextStyle(
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
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.red[300]!, width: 2),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isDeleting ? null : _showDeleteConfirmation,
                borderRadius: BorderRadius.circular(18),
                child: Center(
                  child: _isDeleting
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red[600]!),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline_rounded, color: Colors.red[600], size: 22),
                            const SizedBox(width: 10),
                            Text(
                              'Delete Transaction',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.red[600],
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateTransaction() async {
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
      await TransactionService().updateTransaction(
        widget.transaction.id,
        {
          'title': _noteController.text.isEmpty
              ? _selectedCategory
              : _noteController.text,
          'note': _noteController.text,
          'amount': amount,
          'category': _selectedCategory,
          'type': _isExpense ? 'debit' : 'credit',
          'date': Timestamp.fromDate(_selectedDate),
          'updatedAt': Timestamp.now(),
        },
      );

      if (mounted) {
        HapticFeedback.heavyImpact();
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Transaction updated successfully'),
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
        _showErrorSnackBar('Failed to update transaction');
      }
    }
  }

  void _showDeleteConfirmation() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_forever_rounded,
                color: Colors.red[600],
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Delete Transaction?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This action cannot be undone. The transaction will be permanently removed from your records.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: const Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[400]!, Colors.red[600]!],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _deleteTransaction();
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: const Center(
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTransaction() async {
    setState(() => _isDeleting = true);
    HapticFeedback.heavyImpact();

    try {
      await TransactionService().deleteTransaction(widget.transaction.id);

      if (mounted) {
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Transaction deleted successfully'),
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
    } catch (e) {
      setState(() => _isDeleting = false);
      if (mounted) {
        _showErrorSnackBar('Failed to delete transaction');
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

class CategoryData {
  final String name;
  final IconData icon;
  final Color color;

  CategoryData(this.name, this.icon, this.color);
}
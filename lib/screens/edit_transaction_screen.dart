import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../constants/categories.dart';

class EditTransactionScreen extends ConsumerStatefulWidget {
  final TransactionModel transaction;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
  });

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState
    extends ConsumerState<EditTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  late String _selectedCategory;
  late bool _isExpense;
  bool _isSaving = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _amountController =
        TextEditingController(text: widget.transaction.amount.toString());
    _noteController =
        TextEditingController(text: widget.transaction.note);

    _isExpense = widget.transaction.type == 'debit';

    final categories =
        _isExpense ? ExpenseCategories.list : IncomeCategories.list;

    _selectedCategory = categories.contains(widget.transaction.category)
        ? widget.transaction.category
        : categories.first;

    // 🔹 Animations
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut);

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        _isExpense ? ExpenseCategories.list : IncomeCategories.list;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Edit Transaction',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= TOGGLE =================
                _toggleCard(),

                const SizedBox(height: 30),

                // ================= AMOUNT =================
                const Text('Amount', style: TextStyle(color: Colors.grey)),
                TextField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    prefixText: 'Rs ',
                    border: InputBorder.none,
                  ),
                ),

                const SizedBox(height: 30),

                // ================= CATEGORY =================
                const Text(
                  'Category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: categories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ================= NOTE =================
                const Text(
                  'Note',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText: 'Update note...',
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

                // ================= SAVE =================
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _updateTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isExpense ? const Color(0xFF2575FC) : Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isSaving
                          ? const CircularProgressIndicator(
                              key: ValueKey(1),
                              color: Colors.white,
                            )
                          : const Text(
                              'UPDATE TRANSACTION',
                              key: ValueKey(2),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= UPDATE LOGIC =================

  Future<void> _updateTransaction() async {
    setState(() => _isSaving = true);

    final amount =
        double.tryParse(_amountController.text) ?? 0;

    await ref.read(transactionProvider.notifier).updateTransaction(
      widget.transaction.id,
      {
        'title': _noteController.text.isEmpty
            ? _selectedCategory
            : _noteController.text,
        'note': _noteController.text,
        'amount': amount,
        'category': _selectedCategory,
        'type': _isExpense ? 'debit' : 'credit',
      },
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  // ================= TOGGLE CARD =================

  Widget _toggleCard() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildToggle('Expense', true),
          _buildToggle('Income', false),
        ],
      ),
    );
  }

  Widget _buildToggle(String text, bool expense) {
    final selected = _isExpense == expense;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpense = expense;
            _selectedCategory = expense
                ? ExpenseCategories.list.first
                : IncomeCategories.list.first;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

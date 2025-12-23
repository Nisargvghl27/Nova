import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  late String _selectedCategory;
  late bool _isExpense;
  bool _isSaving = false;

  final List<String> _expenseCategories = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
    'Health',
  ];

  final List<String> _incomeCategories = [
    'Salary',
    'Business',
    'Investment',
    'Gift',
    'Freelance',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    _amountController =
        TextEditingController(text: widget.transaction.amount.toString());

    _noteController =
        TextEditingController(text: widget.transaction.note);

    _selectedCategory = widget.transaction.category;
    _isExpense = widget.transaction.type == 'debit';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        _isExpense ? _expenseCategories : _incomeCategories;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Edit Transaction',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= TOGGLE =================
            Container(
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
            ),

            const SizedBox(height: 30),

            // ================= AMOUNT =================
            const Text(
              'Amount',
              style: TextStyle(color: Colors.grey),
            ),
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
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categories.map((cat) {
                return ChoiceChip(
                  label: Text(cat),
                  selected: _selectedCategory == cat,
                  selectedColor: _isExpense
                      ? const Color(0xFF2575FC)
                      : Colors.green,
                  labelStyle: TextStyle(
                    color: _selectedCategory == cat
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (_) =>
                      setState(() => _selectedCategory = cat),
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            // ================= NOTE =================
            const Text(
              'Note',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  backgroundColor: _isExpense ? const Color(0xFF2575FC) : Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'UPDATE TRANSACTION',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UPDATE LOGIC =================

  Future<void> _updateTransaction() async {
    setState(() => _isSaving = true);

    final double amount =
        double.tryParse(_amountController.text) ?? 0;

    await TransactionService().updateTransaction(
      widget.transaction.id,
      {
        // 🔥 IMPORTANT FIX
        'title': _noteController.text.isEmpty
            ? _selectedCategory
            : _noteController.text,
        'note': _noteController.text,
        'amount': amount,
        'category': _selectedCategory,
        'type': _isExpense ? 'debit' : 'credit',
        'updatedAt': Timestamp.now(),
      },
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  // ================= TOGGLE =================

  Widget _buildToggle(String text, bool expense) {
    final selected = _isExpense == expense;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpense = expense;
            _selectedCategory = expense
                ? _expenseCategories.first
                : _incomeCategories.first;
          });
        },
        child: Container(
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

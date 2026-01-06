import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../constants/categories.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState
    extends ConsumerState<AddTransactionScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isExpense = true;
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = ExpenseCategories.list.first;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        _isExpense ? ExpenseCategories.list : IncomeCategories.list;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Add Transaction'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= TOGGLE =================
            Row(
              children: [
                _toggle('Expense', true),
                _toggle('Income', false),
              ],
            ),

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
              decoration: const InputDecoration(prefixText: 'Rs '),
            ),

            const SizedBox(height: 20),

            // ================= DATE =================
            const Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('MMM dd, yyyy')
                        .format(_selectedDate)),
                    const Icon(Icons.calendar_month),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ================= CATEGORY =================
            const Text('Category',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            // ================= NOTE =================
            const Text('Note', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Add a note...',
              ),
            ),

            const SizedBox(height: 40),

            // ================= SAVE =================
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isExpense ? const Color(0xFF2575FC) : Colors.green,
                ),
                child: const Text(
                  'SAVE TRANSACTION',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SAVE LOGIC =================

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    final tx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _noteController.text.isEmpty
          ? _selectedCategory
          : _noteController.text,
      amount: amount,
      date: _selectedDate,
      category: _selectedCategory,
      type: _isExpense ? 'debit' : 'credit',
      source: 'manual',
      note: _noteController.text,
      createdAt: DateTime.now(),
    );

    // ✅ SINGLE SOURCE OF TRUTH
    await ref.read(transactionProvider.notifier).addTransaction(tx);

    if (!mounted) return;
    Navigator.pop(context);
  }

  // ================= TOGGLE =================

  Widget _toggle(String text, bool expense) {
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
        child: Container(
          padding: const EdgeInsets.all(12),
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

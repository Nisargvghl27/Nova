import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../constants/categories.dart';
import 'edit_transaction_screen.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState
    extends ConsumerState<TransactionsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  DateTimeRange? _dateRange;

  late final List<String> _filterCategories;

  @override
  void initState() {
    super.initState();
    _filterCategories = [
      'All',
      ...ExpenseCategories.list,
      ...IncomeCategories.list,
    ];
  }

  List<TransactionModel> _filtered(List<TransactionModel> list) {
    var result = list;

    if (_searchQuery.isNotEmpty) {
      result = result
          .where((tx) =>
              tx.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedCategory != 'All') {
      result = result
          .where((tx) => tx.category == _selectedCategory)
          .toList();
    }

    if (_dateRange != null) {
      result = result.where((tx) {
        return tx.date.isAfter(
              _dateRange!.start.subtract(const Duration(days: 1)),
            ) &&
            tx.date.isBefore(
              _dateRange!.end.add(const Duration(days: 1)),
            );
      }).toList();
    }

    return result;
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (range != null) setState(() => _dateRange = range);
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = 'All';
      _dateRange = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    final filtered = _filtered(transactions);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Transactions'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _pickDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by title...',
                prefixIcon: Icon(Icons.search),
                filled: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                items: _filterCategories
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No transactions found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final tx = filtered[i];
                      return Dismissible(
                        key: Key(tx.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          ref
                              .read(transactionProvider.notifier)
                              .deleteTransaction(tx.id);
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: _tile(tx),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tile(TransactionModel tx) {
    final isDebit = tx.type == 'debit';

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditTransactionScreen(transaction: tx),
          ),
        );
      },
      leading: CircleAvatar(
        backgroundColor:
            isDebit ? Colors.red.withAlpha(30) : Colors.green.withAlpha(30),
        child: Icon(
          isDebit ? Icons.arrow_upward : Icons.arrow_downward,
          color: isDebit ? Colors.red : Colors.green,
        ),
      ),
      title: Text(tx.title),
      subtitle: Text(DateFormat('MMM dd, yyyy').format(tx.date)),
      trailing: Text(
        '${isDebit ? '-' : '+'} Rs ${tx.amount.toStringAsFixed(2)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDebit ? Colors.red : Colors.green,
        ),
      ),
    );
  }
}

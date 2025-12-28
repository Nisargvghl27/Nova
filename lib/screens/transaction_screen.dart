import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import 'add_transaction_screen.dart';
import 'edit_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  final List<TransactionModel> transactions;
  final Function(String) onDelete;

  const TransactionsScreen({
    super.key,
    required this.transactions,
    required this.onDelete,
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  DateTimeRange? _dateRange;

  final List<String> _categories = [
    'All',
    'Food',
    'Travel',
    'Bills',
    'Shopping',
    'Entertainment',
    'Health',
    'Other',
  ];

  List<TransactionModel> get _filteredTransactions {
    List<TransactionModel> list = widget.transactions;

    // 🔍 Search by title
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((tx) =>
              tx.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // 🏷 Filter by category
    if (_selectedCategory != 'All') {
      list =
          list.where((tx) => tx.category == _selectedCategory).toList();
    }

    // 📅 Filter by date range
    if (_dateRange != null) {
      list = list.where((tx) {
        return tx.date.isAfter(_dateRange!.start
                .subtract(const Duration(days: 1))) &&
            tx.date.isBefore(
                _dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    return list;
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (range != null) {
      setState(() => _dateRange = range);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        ],
      ),

      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by title...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // 🏷 CATEGORY FILTER
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: _categories.map((cat) {
                final bool selected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    selectedColor: const Color(0xFF2575FC),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) {
                      setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // 📋 TRANSACTION LIST
          Expanded(
            child: _filteredTransactions.isEmpty
                ? const Center(
                    child: Text(
                      'No transactions found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = _filteredTransactions[index];

                      return Dismissible(
                        key: Key(tx.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) =>
                            widget.onDelete(tx.id),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding:
                              const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                          child: const Icon(Icons.delete,
                              color: Colors.white),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditTransactionScreen(
                                        transaction: tx),
                              ),
                            );
                          },
                          child: _transactionTile(tx),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ================= TRANSACTION TILE =================

  Widget _transactionTile(TransactionModel tx) {
    final bool isDebit = tx.type == 'debit';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                isDebit ? Colors.red.withAlpha(30) : Colors.green.withAlpha(30),
            child: Icon(
              isDebit ? Icons.arrow_upward : Icons.arrow_downward,
              color: isDebit ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat.MMMd().format(tx.date),
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            "${isDebit ? '-' : '+'} Rs ${tx.amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDebit ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

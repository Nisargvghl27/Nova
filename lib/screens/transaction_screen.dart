import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../constants/categories.dart';
import '../services/transaction_service.dart';
import 'edit_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  final List<TransactionModel> transactions;
  final List<TransactionModel> deletedTransactions;
  final Function(String) onDelete;

  const TransactionsScreen({
    super.key,
    required this.transactions,
    required this.deletedTransactions,
    required this.onDelete,
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  DateTimeRange? _dateRange;

  // ================= FILTER LOGIC =================
  List<TransactionModel> get _filteredTransactions {
    // safe copy + latest first
    List<TransactionModel> list = List.from(widget.transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    // search (title + category)
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((tx) =>
              tx.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              tx.category.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // category filter
    if (_selectedCategory != 'All') {
      list = list.where((tx) => tx.category == _selectedCategory).toList();
    }

    // date range filter
    if (_dateRange != null) {
      list = list.where((tx) {
        return tx.date.isAfter(
              _dateRange!.start.subtract(const Duration(days: 1)),
            ) &&
            tx.date.isBefore(
              _dateRange!.end.add(const Duration(days: 1)),
            );
      }).toList();
    }

    return list;
  }

  // ================= DATE PICKER =================
  Future<void> _pickDateRange() async {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFF2575FC),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E1E1E),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF2575FC),
                    onPrimary: Colors.white,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (range != null) {
      setState(() => _dateRange = range);
    }
  }

  void _clearFilters() {
    HapticFeedback.mediumImpact();
    setState(() {
      _searchQuery = '';
      _selectedCategory = 'All';
      _dateRange = null;
    });
  }

  // ================= DELETE =================
  void _performDelete(TransactionModel tx) {
    widget.onDelete(tx.id);
    HapticFeedback.mediumImpact();
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.list_alt_rounded, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Transactions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            onPressed: _pickDateRange,
            icon: Icon(
              Icons.date_range_rounded,
              color: _dateRange != null
                  ? const Color(0xFF2575FC)
                  : (isDark ? Colors.white70 : Colors.grey),
            ),
          ),
          if (_searchQuery.isNotEmpty ||
              _selectedCategory != 'All' ||
              _dateRange != null)
            IconButton(
              onPressed: _clearFilters,
              icon: const Icon(Icons.filter_alt_off_rounded, color: Colors.red),
            ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            // search + filter
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search transactions',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (v) =>
                          setState(() => _searchQuery = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: _showCategoryFilterSheet,
                  ),
                ],
              ),
            ),

            // list
            Expanded(
              child: _filteredTransactions.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final tx = _filteredTransactions[index];
                        return _AnimatedTransactionTile(
                          transaction: tx,
                          index: index,
                          onDelete: () => _performDelete(tx),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditTransactionScreen(transaction: tx),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No transactions found',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  // ================= CATEGORY FILTER =================
  void _showCategoryFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          children: [
            ListTile(
              title: const Text('All'),
              onTap: () {
                setState(() => _selectedCategory = 'All');
                Navigator.pop(context);
              },
            ),
            ...ExpenseCategories.list.map(
              (cat) => ListTile(
                title: Text(cat),
                onTap: () {
                  setState(() => _selectedCategory = cat);
                  Navigator.pop(context);
                },
              ),
            ),
            ...IncomeCategories.list.map(
              (cat) => ListTile(
                title: Text(cat),
                onTap: () {
                  setState(() => _selectedCategory = cat);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ================= ANIMATED TILE =================
class _AnimatedTransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _AnimatedTransactionTile({
    required this.transaction,
    required this.index,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDebit = transaction.type == 'debit';
    final style = CategoryStyle.getStyle(transaction.category);

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        leading: Icon(style.icon, color: style.color),
        title: Text(transaction.title),
        subtitle: Text(
          '${transaction.category} • ${DateFormat('MMM dd').format(transaction.date)}',
        ),
        trailing: Text(
          '${isDebit ? '-' : '+'}₹${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: isDebit ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// import '../models/transaction_model.dart';
// import '../services/transaction_service.dart';
// import '../constants/categories.dart';

// class AddTransactionScreen extends StatefulWidget {
//   const AddTransactionScreen({super.key});

//   @override
//   State<AddTransactionScreen> createState() => _AddTransactionScreenState();
// }

// class _AddTransactionScreenState extends State<AddTransactionScreen>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _amountController = TextEditingController();
//   final TextEditingController _noteController = TextEditingController();

//   bool _isExpense = true;
//   bool _isSaving = false;
//   DateTime _selectedDate = DateTime.now();
//   late String _selectedCategory;

//   late AnimationController _fadeController;

//   @override
//   void initState() {
//     super.initState();
//     _selectedCategory = ExpenseCategories.list.first;
//     _fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     )..forward();
//   }

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _noteController.dispose();
//     _fadeController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: _isExpense
//                   ? const Color(0xFF2575FC)
//                   : const Color(0xFF51CF66),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null) setState(() => _selectedDate = picked);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FD),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.close_rounded, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Add Transaction',
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.w700,
//             fontSize: 18,
//           ),
//         ),
//       ),
//       body: FadeTransition(
//         opacity: _fadeController,
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             children: [
//               _buildAnimatedToggle(),
//               const SizedBox(height: 32),
//               _buildAmountInput(),
//               const SizedBox(height: 32),
//               _buildLabel('Date'),
//               const SizedBox(height: 10),
//               _buildDatePicker(),
//               const SizedBox(height: 24),
//               _buildLabel('Category'),
//               const SizedBox(height: 10),
              
//               // --- NEW CATEGORY SELECTOR ---
//               _buildCategorySelector(),

//               const SizedBox(height: 24),
//               _buildLabel('Note'),
//               const SizedBox(height: 10),
//               _buildNoteInput(),
//               const SizedBox(height: 40),
//               _buildSaveButton(),
//               SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ---------------- UI WIDGETS ----------------

//   Widget _buildLabel(String text) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w600,
//           color: Colors.grey[600],
//           letterSpacing: 0.5,
//         ),
//       ),
//     );
//   }

//   Widget _buildAnimatedToggle() {
//     return Container(
//       height: 55,
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           AnimatedAlign(
//             duration: const Duration(milliseconds: 250),
//             curve: Curves.easeOutCubic,
//             alignment:
//                 _isExpense ? Alignment.centerLeft : Alignment.centerRight,
//             child: Container(
//               width: (MediaQuery.of(context).size.width - 48 - 8) / 2,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: _isExpense
//                       ? [const Color(0xFF6A11CB), const Color(0xFF2575FC)]
//                       : [const Color(0xFF51CF66), const Color(0xFF37B679)],
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: (_isExpense
//                             ? const Color(0xFF2575FC)
//                             : const Color(0xFF51CF66))
//                         .withOpacity(0.3),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Row(
//             children: [
//               _buildToggleButton('Expense', true),
//               _buildToggleButton('Income', false),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildToggleButton(String text, bool isExpense) {
//     final isSelected = _isExpense == isExpense;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           HapticFeedback.lightImpact();
//           setState(() {
//             _isExpense = isExpense;
//             _selectedCategory = isExpense
//                 ? ExpenseCategories.list.first
//                 : IncomeCategories.list.first;
//           });
//         },
//         child: Container(
//           color: Colors.transparent,
//           alignment: Alignment.center,
//           child: Text(
//             text,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: isSelected ? Colors.white : Colors.grey[600],
//               fontSize: 15,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAmountInput() {
//     final color =
//         _isExpense ? const Color(0xFF2575FC) : const Color(0xFF51CF66);

//     return Column(
//       children: [
//         const Text(
//           'AMOUNT',
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w700,
//             color: Colors.grey,
//             letterSpacing: 1.2,
//           ),
//         ),
//         const SizedBox(height: 10),
//         IntrinsicWidth(
//           child: TextField(
//             controller: _amountController,
//             keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             style: TextStyle(
//               fontSize: 40,
//               fontWeight: FontWeight.w800,
//               color: color,
//             ),
//             textAlign: TextAlign.center,
//             decoration: InputDecoration(
//               prefixText: '₹',
//               prefixStyle: TextStyle(
//                 fontSize: 40,
//                 fontWeight: FontWeight.w800,
//                 color: color.withOpacity(0.7),
//               ),
//               border: InputBorder.none,
//               hintText: '0',
//               hintStyle: TextStyle(
//                 color: Colors.grey[300],
//                 fontSize: 40,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//             inputFormatters: [
//               FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDatePicker() {
//     return GestureDetector(
//       onTap: _pickDate,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.03),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: (_isExpense
//                         ? const Color(0xFF2575FC)
//                         : const Color(0xFF51CF66))
//                     .withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 Icons.calendar_today_rounded,
//                 size: 18,
//                 color: _isExpense
//                     ? const Color(0xFF2575FC)
//                     : const Color(0xFF51CF66),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Text(
//               DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//             const Spacer(),
//             const Icon(Icons.arrow_forward_ios_rounded,
//                 size: 14, color: Colors.grey),
//           ],
//         ),
//       ),
//     );
//   }

//   // ==================== NEW CATEGORY PICKER ====================
//   Widget _buildCategorySelector() {
//     final style = CategoryStyle.getStyle(_selectedCategory);

//     return GestureDetector(
//       onTap: _showCategoryBottomSheet,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.03),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: style.color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(style.icon, color: style.color, size: 24),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 _selectedCategory,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//             const Icon(Icons.keyboard_arrow_down_rounded,
//                 color: Colors.grey, size: 26),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showCategoryBottomSheet() {
//     final categories =
//         _isExpense ? ExpenseCategories.list : IncomeCategories.list;

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) {
//         return Container(
//           height: MediaQuery.of(context).size.height * 0.7,
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//           ),
//           child: Column(
//             children: [
//               // Handle
//               const SizedBox(height: 12),
//               Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Select Category',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//               const SizedBox(height: 20),
              
//               // Grid
//               Expanded(
//                 child: GridView.builder(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     crossAxisSpacing: 16,
//                     mainAxisSpacing: 16,
//                     childAspectRatio: 0.9, // Adjust height
//                   ),
//                   itemCount: categories.length,
//                   itemBuilder: (context, index) {
//                     final cat = categories[index];
//                     final style = CategoryStyle.getStyle(cat);
//                     final isSelected = _selectedCategory == cat;

//                     return GestureDetector(
//                       onTap: () {
//                         setState(() => _selectedCategory = cat);
//                         Navigator.pop(context);
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: isSelected
//                               ? style.color.withOpacity(0.1)
//                               : Colors.white,
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color: isSelected
//                                 ? style.color
//                                 : Colors.grey[200]!,
//                             width: 2,
//                           ),
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                 color: isSelected 
//                                     ? Colors.white 
//                                     : style.color.withOpacity(0.1),
//                                 shape: BoxShape.circle,
//                               ),
//                               child: Icon(
//                                 style.icon,
//                                 color: style.color,
//                                 size: 24,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               cat,
//                               textAlign: TextAlign.center,
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: isSelected 
//                                     ? FontWeight.w700 
//                                     : FontWeight.w500,
//                                 color: isSelected 
//                                     ? style.color 
//                                     : Colors.grey[800],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildNoteInput() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: _noteController,
//         maxLines: 3,
//         minLines: 1,
//         style: const TextStyle(fontWeight: FontWeight.w500),
//         decoration: InputDecoration(
//           hintText: 'Add a description...',
//           hintStyle: TextStyle(color: Colors.grey[400]),
//           prefixIcon: Padding(
//             padding: const EdgeInsets.only(bottom: 2),
//             child: Icon(Icons.edit_note_rounded, color: Colors.grey[400]),
//           ),
//           border: InputBorder.none,
//           contentPadding:
//               const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         ),
//       ),
//     );
//   }

//   Widget _buildSaveButton() {
//     return Container(
//       width: double.infinity,
//       height: 56,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: _isExpense
//               ? [const Color(0xFF6A11CB), const Color(0xFF2575FC)]
//               : [const Color(0xFF51CF66), const Color(0xFF37B679)],
//         ),
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: (_isExpense
//                     ? const Color(0xFF2575FC)
//                     : const Color(0xFF51CF66))
//                 .withOpacity(0.4),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: _isSaving ? null : _save,
//           borderRadius: BorderRadius.circular(18),
//           child: Center(
//             child: _isSaving
//                 ? const SizedBox(
//                     width: 24,
//                     height: 24,
//                     child: CircularProgressIndicator(
//                         color: Colors.white, strokeWidth: 2.5),
//                   )
//                 : const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.check_circle_rounded, color: Colors.white),
//                       SizedBox(width: 8),
//                       Text(
//                         'SAVE TRANSACTION',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 1,
//                         ),
//                       ),
//                     ],
//                   ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _save() async {
//     final amount = double.tryParse(_amountController.text);
//     if (amount == null || amount <= 0) return;

//     setState(() => _isSaving = true);

//     final tx = TransactionModel(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       title: _noteController.text.isEmpty
//           ? _selectedCategory
//           : _noteController.text,
//       amount: amount,
//       date: _selectedDate,
//       category: _selectedCategory,
//       type: _isExpense ? 'debit' : 'credit',
//       source: 'manual',
//       note: _noteController.text,
//       createdAt: Timestamp.now(),
//     );

//     await TransactionService().addTransaction(tx);
//     if (mounted) Navigator.pop(context);
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../constants/categories.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isExpense = true;
  bool _isSaving = false;
  DateTime _selectedDate = DateTime.now();
  late String _selectedCategory;

  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _selectedCategory = ExpenseCategories.list.first;
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark 
              ? ColorScheme.dark(
                  primary: _isExpense ? const Color(0xFF2575FC) : const Color(0xFF51CF66),
                  onPrimary: Colors.white,
                  surface: const Color(0xFF1E1E1E),
                  onSurface: Colors.white,
                )
              : ColorScheme.light(
                  primary: _isExpense ? const Color(0xFF2575FC) : const Color(0xFF51CF66),
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 Theme Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Transaction',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildAnimatedToggle(),
              const SizedBox(height: 32),
              _buildAmountInput(),
              const SizedBox(height: 32),
              _buildLabel('Date'),
              const SizedBox(height: 10),
              _buildDatePicker(),
              const SizedBox(height: 24),
              _buildLabel('Category'),
              const SizedBox(height: 10),
              _buildCategorySelector(),
              const SizedBox(height: 24),
              _buildLabel('Note'),
              const SizedBox(height: 10),
              _buildNoteInput(),
              const SizedBox(height: 40),
              _buildSaveButton(),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- UI WIDGETS ----------------

  Widget _buildLabel(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildAnimatedToggle() {
    return Container(
      height: 55,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Dynamic card color
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment:
                _isExpense ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: (MediaQuery.of(context).size.width - 48 - 8) / 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isExpense
                      ? [const Color(0xFF6A11CB), const Color(0xFF2575FC)]
                      : [const Color(0xFF51CF66), const Color(0xFF37B679)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (_isExpense
                            ? const Color(0xFF2575FC)
                            : const Color(0xFF51CF66))
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              _buildToggleButton('Expense', true),
              _buildToggleButton('Income', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isExpense) {
    final isSelected = _isExpense == isExpense;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            _isExpense = isExpense;
            _selectedCategory = isExpense
                ? ExpenseCategories.list.first
                : IncomeCategories.list.first;
          });
        },
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected 
                  ? Colors.white 
                  : (isDark ? Colors.white60 : Colors.grey[600]),
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    final color = _isExpense ? const Color(0xFF2575FC) : const Color(0xFF51CF66);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          'AMOUNT',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white54 : Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        IntrinsicWidth(
          child: TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              prefixText: '₹',
              prefixStyle: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: color.withOpacity(0.7),
              ),
              border: InputBorder.none,
              hintText: '0',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                fontSize: 40,
                fontWeight: FontWeight.w800,
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (_isExpense
                        ? const Color(0xFF2575FC)
                        : const Color(0xFF51CF66))
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: _isExpense
                    ? const Color(0xFF2575FC)
                    : const Color(0xFF51CF66),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final style = CategoryStyle.getStyle(_selectedCategory);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: _showCategoryBottomSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: style.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(style.icon, color: style.color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _selectedCategory,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.grey, size: 26),
          ],
        ),
      ),
    );
  }

  void _showCategoryBottomSheet() {
    final categories = _isExpense ? ExpenseCategories.list : IncomeCategories.list;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Select Category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final style = CategoryStyle.getStyle(cat);
                    final isSelected = _selectedCategory == cat;

                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategory = cat);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? style.color.withOpacity(0.1)
                              : cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? style.color
                                : (isDark ? Colors.white10 : Colors.grey[200]!),
                            width: 2,
                          ),
                          boxShadow: [
                             if (!isDark && !isSelected)
                               BoxShadow(
                                 color: Colors.black.withOpacity(0.02),
                                 blurRadius: 4,
                                 offset: const Offset(0, 2),
                               ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? (isDark ? Colors.white : Colors.white) 
                                    : style.color.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                style.icon,
                                color: style.color,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              cat,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected 
                                    ? FontWeight.w700 
                                    : FontWeight.w500,
                                color: isSelected 
                                    ? style.color 
                                    : (isDark ? Colors.white70 : Colors.grey[800]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoteInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _noteController,
        maxLines: 3,
        minLines: 1,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(
          hintText: 'Add a description...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Icon(Icons.edit_note_rounded, color: Colors.grey[400]),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isExpense
              ? [const Color(0xFF6A11CB), const Color(0xFF2575FC)]
              : [const Color(0xFF51CF66), const Color(0xFF37B679)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: (_isExpense
                    ? const Color(0xFF2575FC)
                    : const Color(0xFF51CF66))
                .withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isSaving ? null : _save,
          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'SAVE TRANSACTION',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    setState(() => _isSaving = true);

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
      createdAt: Timestamp.now(),
    );

    await TransactionService().addTransaction(tx);
    if (mounted) Navigator.pop(context);
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../models/transaction_model.dart';
// import '../services/sms_parser_service.dart';
// import '../services/transaction_service.dart';

// class PasteSmsScreen extends StatefulWidget {
//   const PasteSmsScreen({super.key});

//   @override
//   State<PasteSmsScreen> createState() => _PasteSmsScreenState();
// }

// class _PasteSmsScreenState extends State<PasteSmsScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final SmsParserService _parser = SmsParserService();

//   TransactionModel? _preview;
//   String? _error;
//   bool _isSaving = false;

//   void _parseSms() {
//     FocusScope.of(context).unfocus(); // Hide keyboard
//     final result = _parser.parse(_controller.text);

//     setState(() {
//       _preview = result;
//       _error =
//           result == null ? 'Could not identify transaction details.' : null;
//     });
//   }

//   Future<void> _confirm() async {
//     if (_preview == null) return;

//     setState(() => _isSaving = true);
//     HapticFeedback.mediumImpact();

//     await TransactionService().addTransaction(_preview!);

//     if (!mounted) return;
//     Navigator.pop(context);
    
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Transaction imported successfully'),
//         backgroundColor: Color(0xFF2575FC),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FD),
//       appBar: AppBar(
//         title: const Text(
//           'Import from SMS',
//           style: TextStyle(
//               color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         physics: const BouncingScrollPhysics(),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const Text(
//               'Paste your bank SMS below',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 12),
            
//             // --- PASTE AREA ---
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: TextField(
//                 controller: _controller,
//                 maxLines: 6,
//                 style: const TextStyle(fontSize: 16, height: 1.5),
//                 decoration: InputDecoration(
//                   hintText: 'e.g. "Rs 500 debited from a/c... for Swiggy"',
//                   hintStyle: TextStyle(color: Colors.grey[400]),
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.all(20),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),

//             // --- PARSE BUTTON ---
//             SizedBox(
//               height: 50,
//               child: OutlinedButton.icon(
//                 onPressed: _parseSms,
//                 icon: const Icon(Icons.analytics_outlined),
//                 label: const Text('ANALYZE SMS'),
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: const Color(0xFF2575FC),
//                   side: const BorderSide(color: Color(0xFF2575FC), width: 1.5),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                 ),
//               ),
//             ),

//             // --- ERROR MESSAGE ---
//             if (_error != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 16),
//                 child: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.red[50],
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.red[100]!),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.error_outline_rounded, color: Colors.red[400]),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           _error!,
//                           style: TextStyle(color: Colors.red[700]),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//             // --- PREVIEW CARD ---
//             if (_preview != null) ...[
//               const SizedBox(height: 32),
//               const Text(
//                 'Preview Transaction',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//               const SizedBox(height: 16),
              
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(24),
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color(0xFF2575FC).withOpacity(0.1),
//                       blurRadius: 20,
//                       offset: const Offset(0, 8),
//                     ),
//                   ],
//                   border: Border.all(
//                     color: const Color(0xFF2575FC).withOpacity(0.1),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           _preview!.type == 'debit' ? 'EXPENSE' : 'INCOME',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.grey[600],
//                             letterSpacing: 1,
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 10,
//                             vertical: 6,
//                           ),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFF0F3FF),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(
//                             _preview!.category,
//                             style: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF2575FC),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     Text(
//                       '₹${_preview!.amount.toStringAsFixed(2)}',
//                       style: const TextStyle(
//                         fontSize: 36,
//                         fontWeight: FontWeight.w800,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       _preview!.title,
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey[700],
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 20),
//                     const Divider(),
//                     const SizedBox(height: 10),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.calendar_today_rounded, 
//                             size: 14, color: Colors.grey[400]),
//                         const SizedBox(width: 8),
//                         Text(
//                           'Today, ${TimeOfDay.now().format(context)}',
//                           style: TextStyle(
//                             color: Colors.grey[500],
//                             fontSize: 13,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 32),

//               // --- SAVE BUTTON ---
//               Container(
//                 width: double.infinity,
//                 height: 56,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//                   ),
//                   borderRadius: BorderRadius.circular(18),
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color(0xFF2575FC).withOpacity(0.4),
//                       blurRadius: 12,
//                       offset: const Offset(0, 6),
//                     ),
//                   ],
//                 ),
//                 child: Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     onTap: _isSaving ? null : _confirm,
//                     borderRadius: BorderRadius.circular(18),
//                     child: Center(
//                       child: _isSaving
//                           ? const SizedBox(
//                               height: 24,
//                               width: 24,
//                               child: CircularProgressIndicator(
//                                   color: Colors.white, strokeWidth: 2.5),
//                             )
//                           : const Text(
//                               'CONFIRM & SAVE',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 letterSpacing: 1,
//                               ),
//                             ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction_model.dart';
import '../services/sms_parser_service.dart';
import '../services/transaction_service.dart';

class PasteSmsScreen extends StatefulWidget {
  const PasteSmsScreen({super.key});

  @override
  State<PasteSmsScreen> createState() => _PasteSmsScreenState();
}

class _PasteSmsScreenState extends State<PasteSmsScreen> {
  final TextEditingController _controller = TextEditingController();
  final SmsParserService _parser = SmsParserService();

  TransactionModel? _preview;
  String? _error;
  bool _isSaving = false;

  void _parseSms() {
    FocusScope.of(context).unfocus();
    final result = _parser.parse(_controller.text);

    setState(() {
      _preview = result;
      _error =
          result == null ? 'Could not identify transaction details.' : null;
    });
  }

  Future<void> _confirm() async {
    if (_preview == null) return;

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    await TransactionService().addTransaction(_preview!);

    if (!mounted) return;
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction imported successfully'),
        backgroundColor: Color(0xFF2575FC),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 Theme Colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Import from SMS',
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Paste your bank SMS below',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            
            // --- PASTE AREA ---
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                maxLines: 6,
                style: TextStyle(fontSize: 16, height: 1.5, color: textColor),
                decoration: InputDecoration(
                  hintText: 'e.g. "Rs 500 debited from a/c... for Swiggy"',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- PARSE BUTTON ---
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _parseSms,
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('ANALYZE SMS'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2575FC),
                  side: const BorderSide(color: Color(0xFF2575FC), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            // --- ERROR MESSAGE ---
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: Colors.red[400]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.red[400]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // --- PREVIEW CARD ---
            if (_preview != null) ...[
              const SizedBox(height: 32),
              Text(
                'Preview Transaction',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2575FC).withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF2575FC).withOpacity(0.1),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _preview!.type == 'debit' ? 'EXPENSE' : 'INCOME',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white60 : Colors.grey[600],
                            letterSpacing: 1,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2575FC).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _preview!.category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2575FC),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '₹${_preview!.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _preview!.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_rounded, 
                            size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 8),
                        Text(
                          'Today, ${TimeOfDay.now().format(context)}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- SAVE BUTTON ---
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2575FC).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isSaving ? null : _confirm,
                    borderRadius: BorderRadius.circular(18),
                    child: Center(
                      child: _isSaving
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              'CONFIRM & SAVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
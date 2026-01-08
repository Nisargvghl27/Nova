// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../services/transaction_service.dart';

// class NotificationsScreen extends StatelessWidget {
//   const NotificationsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final bgColor = Theme.of(context).scaffoldBackgroundColor;
//     final textColor = isDark ? Colors.white : Colors.black;

//     return Scaffold(
//       backgroundColor: bgColor,
//       appBar: AppBar(
//         title: Text('Notifications', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         // 🔹 This listens to the collection shown in your screenshot
//         stream: TransactionService().getNotificationsStream(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }

//           final docs = snapshot.data?.docs ?? [];
          
//           if (docs.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.notifications_none_rounded, size: 60, color: Colors.grey[400]),
//                   const SizedBox(height: 16),
//                   Text("No new notifications", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
//                 ],
//               ),
//             );
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(20),
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final doc = docs[index];
//               final data = doc.data() as Map<String, dynamic>;
//               final String type = data['type'] ?? 'unknown';
              
//               // Only show Money Requests
//               if (type == 'money_request') {
//                 return _buildRequestCard(context, doc.id, data);
//               }
              
//               return const SizedBox.shrink();
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildRequestCard(BuildContext context, String docId, Map<String, dynamic> data) {
//     final email = data['fromEmail'] ?? 'Unknown';
//     final amount = (data['amount'] as num).toDouble();
//     final isDark = Theme.of(context).brightness == Brightness.dark;
    
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF2575FC).withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(Icons.currency_rupee_rounded, color: Color(0xFF2575FC)),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Payment Request",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                         color: isDark ? Colors.white : Colors.black,
//                       ),
//                     ),
//                     Text(
//                       "from $email",
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey[500],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Text(
//                 "₹${amount.toStringAsFixed(0)}",
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w900,
//                   fontSize: 18,
//                   color: Color(0xFF2575FC),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               // DECLINE BUTTON
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () async {
//                     await TransactionService().handleRequest(docId, false, data);
//                   },
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: Colors.red,
//                     side: BorderSide(color: Colors.red.withOpacity(0.5)),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: const Text("Decline"),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               // PAY BUTTON
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     try {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text("Processing Payment..."))
//                       );
//                       await TransactionService().handleRequest(docId, true, data);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text("Payment Sent Successfully!"))
//                       );
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
//                       );
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF2575FC),
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: const Text("Pay Now"),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/transaction_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  
  @override
  void initState() {
    super.initState();
    // 🔹 Mark all as read when screen opens
    TransactionService().markNotificationsAsRead();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: TransactionService().getNotificationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final docs = snapshot.data?.docs ?? [];
          
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text("No new notifications", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final String type = data['type'] ?? 'unknown';
              
              // Only show Money Requests
              if (type == 'money_request') {
                return _buildRequestCard(context, doc.id, data);
              }
              
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, String docId, Map<String, dynamic> data) {
    final email = data['fromEmail'] ?? 'Unknown';
    final amount = (data['amount'] as num).toDouble();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2575FC).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.currency_rupee_rounded, color: Color(0xFF2575FC)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Payment Request",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      "from $email",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "₹${amount.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Color(0xFF2575FC),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // DECLINE BUTTON
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await TransactionService().handleRequest(docId, false, data);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Decline"),
                ),
              ),
              const SizedBox(width: 12),
              // PAY BUTTON
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Processing Payment..."))
                      );
                      await TransactionService().handleRequest(docId, true, data);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Payment Sent Successfully!"))
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2575FC),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Pay Now"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
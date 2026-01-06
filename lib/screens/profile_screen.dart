// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../services/auth_service.dart';
// import 'edit_profile_screen.dart'; 

// class ProfileScreen extends StatefulWidget {
//   final VoidCallback? onWalletTap;

//   const ProfileScreen({
//     super.key,
//     this.onWalletTap,
//   });

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   bool _biometricEnabled = true;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     )..forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // 1. Get the latest User object each time the widget rebuilds
//     final User? user = FirebaseAuth.instance.currentUser;

//     if (user == null) {
//       return const Scaffold(body: Center(child: Text('No user logged in')));
//     }

//     return StreamBuilder<DocumentSnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .snapshots(),
//       builder: (context, snapshot) {
//         // 2. Priority: Auth Display Name -> Firestore Name -> Email -> 'User'
//         // Since we reload the user in setState, user.displayName will be the new name
//         String userName =
//             user.displayName ??
//             (snapshot.data?.data() as Map<String, dynamic>?)?['name']
//                 ?.toString() ??
//             user.email?.split('@')[0] ??
//             'User';
//         String userEmail = user.email ?? 'No email';
//         String? photoUrl = user.photoURL;

//         return Scaffold(
//           backgroundColor: const Color(0xFFF8F9FD),
//           body: CustomScrollView(
//             physics: const BouncingScrollPhysics(),
//             slivers: [
//               _buildSliverAppBar(userName, userEmail, photoUrl),

//               SliverPadding(
//                 padding: const EdgeInsets.all(24),
//                 sliver: SliverToBoxAdapter(
//                   child: SingleChildScrollView(
//                     physics: const NeverScrollableScrollPhysics(),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         // Pass the current name to the button
//                         _buildEditProfileButton(context, userName),
//                         const SizedBox(height: 32),
//                         _buildStatsCards(),
//                         const SizedBox(height: 32),
//                         _buildSectionHeader('General', Icons.settings_rounded),
//                         const SizedBox(height: 16),
//                         _buildSettingItem(
//                           icon: Icons.account_balance_wallet_rounded,
//                           title: 'My Wallet',
//                           subtitle: 'View all transactions',
//                           color1: const Color(0xFF6A11CB),
//                           color2: const Color(0xFF2575FC),
//                           index: 0,
//                           onTap: () {
//                             HapticFeedback.lightImpact();
//                             if (widget.onWalletTap != null) {
//                               widget.onWalletTap!();
//                             } else {
//                               _showInfoSnackBar(
//                                 context,
//                                 'Use the Wallet tab in bottom navigation',
//                               );
//                             }
//                           },
//                         ),
//                         _buildSettingItem(
//                           icon: Icons.notifications_rounded,
//                           title: 'Notifications',
//                           subtitle: 'Manage alerts',
//                           color1: const Color(0xFFFF6B6B),
//                           color2: const Color(0xFFFF8E53),
//                           index: 1,
//                           onTap: () {
//                             HapticFeedback.lightImpact();
//                             _showComingSoonSnackBar(context);
//                           },
//                         ),
//                         _buildSettingItem(
//                           icon: Icons.favorite_rounded,
//                           title: 'Favorites',
//                           subtitle: 'Saved items',
//                           color1: const Color(0xFFBA68C8),
//                           color2: const Color(0xFFE91E63),
//                           index: 2,
//                           onTap: () {
//                             HapticFeedback.lightImpact();
//                             _showComingSoonSnackBar(context);
//                           },
//                         ),
//                         const SizedBox(height: 32),
//                         _buildSectionHeader('Security', Icons.shield_rounded),
//                         const SizedBox(height: 16),
//                         _buildSettingItem(
//                           icon: Icons.lock_rounded,
//                           title: 'Change Password',
//                           subtitle: 'Update your password',
//                           color1: const Color(0xFF51CF66),
//                           color2: const Color(0xFF37B679),
//                           index: 3,
//                           onTap: () {
//                             HapticFeedback.lightImpact();
//                             _showComingSoonSnackBar(context);
//                           },
//                         ),
//                         _buildBiometricItem(index: 4),
//                         const SizedBox(height: 32),
//                         _buildSectionHeader('About', Icons.info_rounded),
//                         const SizedBox(height: 16),
//                         _buildSettingItem(
//                           icon: Icons.help_rounded,
//                           title: 'Help & Support',
//                           subtitle: 'Get assistance',
//                           color1: const Color(0xFF4ECDC4),
//                           color2: const Color(0xFF44A08D),
//                           index: 5,
//                           onTap: () {
//                             HapticFeedback.lightImpact();
//                             _showComingSoonSnackBar(context);
//                           },
//                         ),
//                         _buildSettingItem(
//                           icon: Icons.privacy_tip_rounded,
//                           title: 'Privacy Policy',
//                           subtitle: 'Terms & conditions',
//                           color1: const Color(0xFF78909C),
//                           color2: const Color(0xFF546E7A),
//                           index: 6,
//                           onTap: () {
//                             HapticFeedback.lightImpact();
//                             _showComingSoonSnackBar(context);
//                           },
//                         ),
//                         const SizedBox(height: 40),
//                         _buildLogoutButton(),
//                         const SizedBox(height: 20),
//                         _buildAppVersion(),
//                         SizedBox(
//                           height: MediaQuery.of(context).padding.bottom + 20,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildEditProfileButton(BuildContext context, String currentName) {
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0.0, end: 1.0),
//       duration: const Duration(milliseconds: 500),
//       curve: Curves.easeOutCubic,
//       builder: (context, value, child) {
//         return Transform.scale(
//           scale: 0.95 + (value * 0.05),
//           child: Opacity(opacity: value, child: child),
//         );
//       },
//       child: Center(
//         child: Container(
//           width: 200,
//           height: 52,
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//             ),
//             borderRadius: BorderRadius.circular(26),
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xFF2575FC).withOpacity(0.3),
//                 blurRadius: 12,
//                 offset: const Offset(0, 6),
//               ),
//             ],
//           ),
//           child: Material(
//             color: Colors.transparent,
//             child: InkWell(
//               onTap: () async { // 1. Made async
//                 HapticFeedback.lightImpact();
                
//                 // 2. Wait for the user to come back from Edit Screen
//                 await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => EditProfileScreen(
//                       currentName: currentName,
//                     ),
//                   ),
//                 );

//                 // 3. Force rebuild to show the updated name
//                 if (mounted) {
//                   setState(() {});
//                 }
//               },
//               borderRadius: BorderRadius.circular(26),
//               child: const Center(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.edit_rounded, color: Colors.white, size: 20),
//                     SizedBox(width: 8),
//                     Text(
//                       'Edit Profile',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 16,
//                         letterSpacing: 0.3,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSliverAppBar(
//     String userName,
//     String userEmail,
//     String? photoUrl,
//   ) {
//     return SliverAppBar(
//       expandedHeight: MediaQuery.of(context).size.height * 0.35,
//       pinned: false,
//       stretch: true,
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       flexibleSpace: FlexibleSpaceBar(
//         background: FadeTransition(
//           opacity: _animationController,
//           child: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//               ),
//             ),
//             child: Stack(
//               children: [
//                 Positioned(
//                   top: -50,
//                   right: -50,
//                   child: Container(
//                     width: 200,
//                     height: 200,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white.withOpacity(0.1),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: -30,
//                   left: -30,
//                   child: Container(
//                     width: 150,
//                     height: 150,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white.withOpacity(0.1),
//                     ),
//                   ),
//                 ),
//                 SafeArea(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                       vertical: 20,
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const SizedBox(height: 28),
//                         TweenAnimationBuilder<double>(
//                           tween: Tween(begin: 0.0, end: 1.0),
//                           duration: const Duration(milliseconds: 600),
//                           curve: Curves.easeOutCubic,
//                           builder: (context, value, child) {
//                             return Transform.scale(
//                               scale: 0.8 + (value * 0.2),
//                               child: Opacity(opacity: value, child: child),
//                             );
//                           },
//                           child: Container(
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.2),
//                                   blurRadius: 20,
//                                   offset: const Offset(0, 10),
//                                 ),
//                               ],
//                             ),
//                             child: CircleAvatar(
//                               radius: 52,
//                               backgroundImage: photoUrl != null
//                                   ? NetworkImage(photoUrl)
//                                   : null,
//                               backgroundColor: Colors.white,
//                               child: photoUrl == null
//                                   ? Text(
//                                       userName.isNotEmpty
//                                           ? userName[0].toUpperCase()
//                                           : 'U',
//                                       style: const TextStyle(
//                                         fontSize: 48,
//                                         fontWeight: FontWeight.w800,
//                                         color: Color(0xFF2575FC),
//                                       ),
//                                     )
//                                   : null,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         TweenAnimationBuilder<double>(
//                           tween: Tween(begin: 0.0, end: 1.0),
//                           duration: const Duration(milliseconds: 700),
//                           curve: Curves.easeOutCubic,
//                           builder: (context, value, child) {
//                             return Transform.translate(
//                               offset: Offset(0, 20 * (1 - value)),
//                               child: Opacity(opacity: value, child: child),
//                             );
//                           },
//                           child: Column(
//                             children: [
//                               Text(
//                                 userName,
//                                 style: const TextStyle(
//                                   fontSize: 28,
//                                   fontWeight: FontWeight.w800,
//                                   color: Colors.white,
//                                   letterSpacing: -0.5,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 8,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.2),
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Text(
//                                   userEmail,
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatsCards() {
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0.0, end: 1.0),
//       duration: const Duration(milliseconds: 600),
//       curve: Curves.easeOutCubic,
//       builder: (context, value, child) {
//         return Transform.translate(
//           offset: Offset(0, 20 * (1 - value)),
//           child: Opacity(opacity: value, child: child),
//         );
//       },
//       child: Row(
//         children: [
//           Expanded(
//             child: _buildStatCard(
//               icon: Icons.receipt_long_rounded,
//               label: 'Transactions',
//               value: '124',
//               color: const Color(0xFF2575FC),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: _buildStatCard(
//               icon: Icons.category_rounded,
//               label: 'Categories',
//               value: '8',
//               color: const Color(0xFFFF6B6B),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: _buildStatCard(
//               icon: Icons.calendar_today_rounded,
//               label: 'Days Active',
//               value: '45',
//               color: const Color(0xFF51CF66),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard({
//     required IconData icon,
//     required String label,
//     required String value,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: color, size: 20),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w800,
//               letterSpacing: -0.5,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 11,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w600,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title, IconData icon) {
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0.0, end: 1.0),
//       duration: const Duration(milliseconds: 700),
//       curve: Curves.easeOutCubic,
//       builder: (context, value, child) {
//         return Transform.translate(
//           offset: Offset(0, 10 * (1 - value)),
//           child: Opacity(opacity: value, child: child),
//         );
//       },
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: const Color(0xFF2575FC).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, size: 18, color: const Color(0xFF2575FC)),
//           ),
//           const SizedBox(width: 12),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w800,
//               letterSpacing: -0.3,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSettingItem({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Color color1,
//     required Color color2,
//     required int index,
//     required VoidCallback onTap,
//   }) {
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0.0, end: 1.0),
//       duration: Duration(milliseconds: 600 + (index * 50)),
//       curve: Curves.easeOutCubic,
//       builder: (context, value, child) {
//         return Transform.translate(
//           offset: Offset(30 * (1 - value), 0),
//           child: Opacity(opacity: value, child: child),
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.03),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             onTap: onTap,
//             borderRadius: BorderRadius.circular(20),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(colors: [color1, color2]),
//                       borderRadius: BorderRadius.circular(14),
//                       boxShadow: [
//                         BoxShadow(
//                           color: color1.withOpacity(0.3),
//                           blurRadius: 8,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Icon(icon, color: Colors.white, size: 22),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           title,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                             letterSpacing: -0.3,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           subtitle,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.arrow_forward_ios,
//                       size: 14,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBiometricItem({required int index}) {
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0.0, end: 1.0),
//       duration: Duration(milliseconds: 600 + (index * 50)),
//       curve: Curves.easeOutCubic,
//       builder: (context, value, child) {
//         return Transform.translate(
//           offset: Offset(30 * (1 - value), 0),
//           child: Opacity(opacity: value, child: child),
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
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
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFFFFA07A), Color(0xFFFF6B6B)],
//                 ),
//                 borderRadius: BorderRadius.circular(14),
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color(0xFFFF6B6B).withOpacity(0.3),
//                     blurRadius: 8,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.fingerprint_rounded,
//                 color: Colors.white,
//                 size: 22,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Biometric Login',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: -0.3,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Face ID / Touch ID',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Switch(
//               value: _biometricEnabled,
//               onChanged: (val) {
//                 HapticFeedback.lightImpact();
//                 setState(() => _biometricEnabled = val);
//               },
//               activeColor: const Color(0xFF2575FC),
//               activeTrackColor: const Color(0xFF2575FC).withOpacity(0.3),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLogoutButton() {
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0.0, end: 1.0),
//       duration: const Duration(milliseconds: 900),
//       curve: Curves.easeOutCubic,
//       builder: (context, value, child) {
//         return Transform.scale(
//           scale: 0.95 + (value * 0.05),
//           child: Opacity(opacity: value, child: child),
//         );
//       },
//       child: Container(
//         width: double.infinity,
//         height: 56,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: Colors.red[300]!, width: 2),
//         ),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             onTap: () => _showLogoutConfirmation(context),
//             borderRadius: BorderRadius.circular(18),
//             child: Center(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.logout_rounded, color: Colors.red[600], size: 22),
//                   const SizedBox(width: 10),
//                   Text(
//                     'Log Out',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.red[600],
//                       letterSpacing: 0.3,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAppVersion() {
//     return Center(
//       child: Text(
//         'Version 1.0.0',
//         style: TextStyle(
//           fontSize: 12,
//           color: Colors.grey[400],
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }

//   void _showLogoutConfirmation(BuildContext context) {
//     HapticFeedback.mediumImpact();
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//         ),
//         padding: const EdgeInsets.all(28),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.red[50],
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.logout_rounded,
//                 color: Colors.red[600],
//                 size: 48,
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Log Out?',
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.w800,
//                 letterSpacing: -0.5,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'Are you sure you want to log out of your account?',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 15,
//                 height: 1.5,
//               ),
//             ),
//             const SizedBox(height: 32),
//             Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     height: 52,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         onTap: () {
//                           HapticFeedback.lightImpact();
//                           Navigator.pop(context);
//                         },
//                         borderRadius: BorderRadius.circular(16),
//                         child: const Center(
//                           child: Text(
//                             'Cancel',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w700,
//                               letterSpacing: 0.3,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Container(
//                     height: 52,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Colors.red[400]!, Colors.red[600]!],
//                       ),
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.red.withOpacity(0.3),
//                           blurRadius: 12,
//                           offset: const Offset(0, 6),
//                         ),
//                       ],
//                     ),
//                     child: Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         onTap: () async {
//                           HapticFeedback.heavyImpact();
//                           Navigator.pop(context);
//                           await AuthService().logout();
//                         },
//                         borderRadius: BorderRadius.circular(16),
//                         child: const Center(
//                           child: Text(
//                             'Log Out',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w800,
//                               color: Colors.white,
//                               letterSpacing: 0.3,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showComingSoonSnackBar(BuildContext context) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Row(
//           children: [
//             Icon(Icons.info_outline, color: Colors.white),
//             SizedBox(width: 12),
//             Text('Feature coming soon!'),
//           ],
//         ),
//         backgroundColor: const Color(0xFF2575FC),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }

//   void _showInfoSnackBar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.info_outline, color: Colors.white),
//             const SizedBox(width: 12),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: const Color(0xFF2575FC),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'edit_profile_screen.dart'; 
import '../../main.dart'; // Import to access themeNotifier

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onWalletTap;

  const ProfileScreen({
    super.key,
    this.onWalletTap,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _biometricEnabled = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    // 🔹 Helper variables for theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.grey[600];

    if (user == null) {
      return const Scaffold(body: Center(child: Text('No user logged in')));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        String userName =
            user.displayName ??
            (snapshot.data?.data() as Map<String, dynamic>?)?['name']
                ?.toString() ??
            user.email?.split('@')[0] ??
            'User';
        String userEmail = user.email ?? 'No email';
        String? photoUrl = user.photoURL;

        return Scaffold(
          // 🔹 Use theme background color
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(userName, userEmail, photoUrl),

              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildEditProfileButton(context, userName),
                        const SizedBox(height: 32),
                        _buildStatsCards(isDark), // Pass isDark
                        const SizedBox(height: 32),
                        _buildSectionHeader('General', Icons.settings_rounded, textColor),
                        const SizedBox(height: 16),
                        
                        // 🔹 DARK MODE TOGGLE
                        _buildThemeSwitch(isDark),

                        _buildSettingItem(
                          icon: Icons.account_balance_wallet_rounded,
                          title: 'My Wallet',
                          subtitle: 'View all transactions',
                          color1: const Color(0xFF6A11CB),
                          color2: const Color(0xFF2575FC),
                          index: 0,
                          isDark: isDark,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            if (widget.onWalletTap != null) {
                              widget.onWalletTap!();
                            } else {
                              _showInfoSnackBar(context, 'Use the Wallet tab in bottom navigation');
                            }
                          },
                        ),
                        _buildSettingItem(
                          icon: Icons.notifications_rounded,
                          title: 'Notifications',
                          subtitle: 'Manage alerts',
                          color1: const Color(0xFFFF6B6B),
                          color2: const Color(0xFFFF8E53),
                          index: 1,
                          isDark: isDark,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _showComingSoonSnackBar(context);
                          },
                        ),
                        _buildSettingItem(
                          icon: Icons.favorite_rounded,
                          title: 'Favorites',
                          subtitle: 'Saved items',
                          color1: const Color(0xFFBA68C8),
                          color2: const Color(0xFFE91E63),
                          index: 2,
                          isDark: isDark,
                          onTap: () {
                             HapticFeedback.lightImpact();
                            _showComingSoonSnackBar(context);
                          },
                        ),
                        const SizedBox(height: 32),
                        _buildSectionHeader('Security', Icons.shield_rounded, textColor),
                        const SizedBox(height: 16),
                        _buildSettingItem(
                          icon: Icons.lock_rounded,
                          title: 'Change Password',
                          subtitle: 'Update your password',
                          color1: const Color(0xFF51CF66),
                          color2: const Color(0xFF37B679),
                          index: 3,
                          isDark: isDark,
                          onTap: () {
                             HapticFeedback.lightImpact();
                            _showComingSoonSnackBar(context);
                          },
                        ),
                        _buildBiometricItem(index: 4, isDark: isDark),
                        const SizedBox(height: 32),
                        _buildSectionHeader('About', Icons.info_rounded, textColor),
                        const SizedBox(height: 16),
                         _buildSettingItem(
                          icon: Icons.help_rounded,
                          title: 'Help & Support',
                          subtitle: 'Get assistance',
                          color1: const Color(0xFF4ECDC4),
                          color2: const Color(0xFF44A08D),
                          index: 5,
                          isDark: isDark,
                          onTap: () {
                             HapticFeedback.lightImpact();
                            _showComingSoonSnackBar(context);
                          },
                        ),
                        _buildSettingItem(
                          icon: Icons.privacy_tip_rounded,
                          title: 'Privacy Policy',
                          subtitle: 'Terms & conditions',
                          color1: const Color(0xFF78909C),
                          color2: const Color(0xFF546E7A),
                          index: 6,
                          isDark: isDark,
                          onTap: () {
                             HapticFeedback.lightImpact();
                            _showComingSoonSnackBar(context);
                          },
                        ),
                        const SizedBox(height: 40),
                        _buildLogoutButton(isDark),
                        const SizedBox(height: 20),
                        _buildAppVersion(),
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔹 NEW: Theme Switch Widget
  Widget _buildThemeSwitch(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Dynamic color
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.indigo, Colors.blueAccent]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.dark_mode_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dark Mode',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isDark,
              onChanged: (val) {
                HapticFeedback.mediumImpact();
                // Update global notifier
                themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
              },
              activeColor: const Color(0xFF2575FC),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditProfileButton(BuildContext context, String currentName) {
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
      child: Center(
        child: Container(
          width: 200,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2575FC).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                HapticFeedback.lightImpact();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                      currentName: currentName,
                    ),
                  ),
                );
                if (mounted) setState(() {});
              },
              borderRadius: BorderRadius.circular(26),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(String userName, String userEmail, String? photoUrl) {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.35,
      pinned: false,
      stretch: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: FadeTransition(
          opacity: _animationController,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -30,
                  left: -30,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 28),
                        CircleAvatar(
                          radius: 52,
                          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                          backgroundColor: Colors.white,
                          child: photoUrl == null
                              ? Text(
                                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2575FC),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            userEmail,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
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

  Widget _buildStatsCards(bool isDark) {
    // Dynamic colors
    final cardColor = Theme.of(context).cardColor;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.receipt_long_rounded,
            label: 'Transactions',
            value: '124',
            color: const Color(0xFF2575FC),
            bgColor: cardColor,
            textColor: textColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.category_rounded,
            label: 'Categories',
            value: '8',
            color: const Color(0xFFFF6B6B),
            bgColor: cardColor,
            textColor: textColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today_rounded,
            label: 'Days Active',
            value: '45',
            color: const Color(0xFF51CF66),
            bgColor: cardColor,
            textColor: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color textColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2575FC).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF2575FC)),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color1,
    required Color color2,
    required int index,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color1, color2]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: color1.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricItem({required int index, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFA07A), Color(0xFFFF6B6B)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.fingerprint_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Biometric Login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  'Face ID / Touch ID',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _biometricEnabled,
            onChanged: (val) => setState(() => _biometricEnabled = val),
            activeColor: const Color(0xFF2575FC),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(bool isDark) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red[300]!, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutConfirmation(context),
          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: Colors.red[600], size: 22),
                const SizedBox(width: 10),
                Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppVersion() {
    return Center(
      child: Text(
        'Version 1.0.0',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[400],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    HapticFeedback.mediumImpact();
    // Also update bottom sheet to support dark mode background
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             // ... Content remains mostly similar, just ensure text colors are handled by theme automatically or passed in
            const Text(
              'Log Out?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            const Text('Are you sure you want to log out of your account?'),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // Slightly darker grey for dark mode compat later if needed
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(16),
                        child: const Center(
                          child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await AuthService().logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      fixedSize: const Size.fromHeight(52),
                    ),
                    child: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 12),
            Text('Feature coming soon!'),
          ],
        ),
        backgroundColor: const Color(0xFF2575FC),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2575FC),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
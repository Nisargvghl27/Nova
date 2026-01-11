// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../services/auth_service.dart';
// import '../services/biometric_service.dart';
// import 'edit_profile_screen.dart';
// import '../../main.dart'; 
// import 'notifications_screen.dart'; 
// import 'budget_prediction_screen.dart';

// class ProfileScreen extends StatefulWidget {
//   final VoidCallback? onWalletTap;
//   const ProfileScreen({super.key, this.onWalletTap});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   bool _biometricEnabled = false;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     )..forward();
//     _loadBiometricSettings();
//   }

//   Future<void> _loadBiometricSettings() async {
//     final enabled = await BiometricService.isEnabled();
//     if (mounted) setState(() => _biometricEnabled = enabled);
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _showChangePasswordDialog(BuildContext context) {
//     final oldPassController = TextEditingController();
//     final newPassController = TextEditingController();
//     bool isLoading = false;
//     String? errorText;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//               title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (errorText != null)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 12),
//                       child: Text(
//                         errorText!,
//                         style: const TextStyle(color: Colors.red, fontSize: 13),
//                       ),
//                     ),
//                   TextField(
//                     controller: oldPassController,
//                     obscureText: true,
//                     decoration: const InputDecoration(
//                       labelText: 'Current Password',
//                       border: OutlineInputBorder(),
//                       prefixIcon: Icon(Icons.lock_outline),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   TextField(
//                     controller: newPassController,
//                     obscureText: true,
//                     decoration: const InputDecoration(
//                       labelText: 'New Password',
//                       border: OutlineInputBorder(),
//                       prefixIcon: Icon(Icons.key),
//                     ),
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: isLoading ? null : () => Navigator.pop(ctx),
//                   child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
//                 ),
//                 ElevatedButton(
//                   onPressed: isLoading ? null : () async {
//                     if (oldPassController.text.isEmpty || newPassController.text.isEmpty) {
//                       setDialogState(() => errorText = "Fields cannot be empty");
//                       return;
//                     }
//                     if (newPassController.text.length < 6) {
//                       setDialogState(() => errorText = "Password must be at least 6 chars");
//                       return;
//                     }

//                     setDialogState(() {
//                       isLoading = true;
//                       errorText = null;
//                     });

//                     try {
//                       await AuthService().changePassword(
//                         currentPassword: oldPassController.text,
//                         newPassword: newPassController.text,
//                       );
//                       if (mounted) {
//                         Navigator.pop(ctx);
//                         _showInfoSnackBar(context, "Password updated successfully!");
//                       }
//                     } catch (e) {
//                       setDialogState(() {
//                         isLoading = false;
//                         errorText = e.toString();
//                       });
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF2575FC),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                   child: isLoading 
//                     ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                     : const Text('Update', style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final User? user = FirebaseAuth.instance.currentUser;
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final textColor = isDark ? Colors.white : Colors.black87;

//     if (user == null) return const Scaffold(body: Center(child: Text('No user logged in')));

//     return StreamBuilder<DocumentSnapshot>(
//       stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
//       builder: (context, snapshot) {
//         String userName = user.displayName ?? 'User';
//         String? base64Photo;
//         String? phone; 
//         String? bio;
//         String? location;
//         String? profession;
//         String? dob;
//         String? username;
        
//         if (snapshot.hasData && snapshot.data!.data() != null) {
//           final data = snapshot.data!.data() as Map<String, dynamic>;
//           if (data.containsKey('name')) userName = data['name'];
//           if (data.containsKey('base64Photo')) base64Photo = data['base64Photo'];
//           if (data.containsKey('phone')) phone = data['phone'];
//           if (data.containsKey('bio')) bio = data['bio'];
//           if (data.containsKey('location')) location = data['location'];
//           if (data.containsKey('profession')) profession = data['profession'];
//           if (data.containsKey('dob')) dob = data['dob'];
//           if (data.containsKey('username')) username = data['username'];
//         }

//         String userEmail = user.email ?? 'No email';
//         String? photoUrl = user.photoURL;

//         return Scaffold(
//           backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//           body: CustomScrollView(
//             physics: const BouncingScrollPhysics(),
//             slivers: [
//               _buildSliverAppBar(userName, userEmail, photoUrl, base64Photo, location),
              
//               SliverPadding(
//                 padding: const EdgeInsets.all(24),
//                 sliver: SliverToBoxAdapter(
//                   child: Column(
//                     children: [
//                       // Pass ALL fields to Edit Screen
//                       _buildEditProfileButton(
//                         context, userName, base64Photo, 
//                         phone, bio, location, profession, dob, username
//                       ),
                      
//                       const SizedBox(height: 24),
//                       _buildUserInfoSection(bio, phone, profession, dob, username, isDark),
                      
//                       const SizedBox(height: 32),
//                       _buildSectionHeader('General', Icons.settings_rounded, textColor),
//                       const SizedBox(height: 16),
                      
//                       _buildThemeSwitch(isDark),
                      
//                       // ⬇️ BUDGET PLANNER ITEM
//                       _buildSettingItem(
//                         icon: Icons.pie_chart_rounded,
//                         title: 'Budget Planner',
//                         subtitle: 'Set limits & predictions',
//                         color1: const Color(0xFF11998e),
//                         color2: const Color(0xFF38ef7d),
//                         index: 0,
//                         isDark: isDark,
//                         onTap: () {
//                           HapticFeedback.lightImpact();
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => const BudgetPredictionScreen(),
//                             ),
//                           );
//                         },
//                       ),

//                       _buildSettingItem(
//                         icon: Icons.account_balance_wallet_rounded,
//                         title: 'My Wallet',
//                         subtitle: 'View all transactions',
//                         color1: const Color(0xFF6A11CB),
//                         color2: const Color(0xFF2575FC),
//                         index: 1,
//                         isDark: isDark,
//                         onTap: () {
//                           HapticFeedback.lightImpact();
//                           if (widget.onWalletTap != null) widget.onWalletTap!();
//                         },
//                       ),
//                       _buildSettingItem(
//                         icon: Icons.notifications_rounded,
//                         title: 'Notifications',
//                         subtitle: 'View payment requests',
//                         color1: const Color(0xFFFF6B6B),
//                         color2: const Color(0xFFFF8E53),
//                         index: 2,
//                         isDark: isDark,
//                         onTap: () {
//                            HapticFeedback.lightImpact();
//                            Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
//                         },
//                       ),
                      
//                       const SizedBox(height: 32),
//                       _buildSectionHeader('Security', Icons.shield_rounded, textColor),
//                       const SizedBox(height: 16),
                      
//                       // ⬇️ UPDATED CHANGE PASSWORD ITEM
//                       _buildSettingItem(
//                         icon: Icons.lock_rounded,
//                         title: 'Change Password',
//                         subtitle: 'Update your password',
//                         color1: const Color(0xFF51CF66),
//                         color2: const Color(0xFF37B679),
//                         index: 3,
//                         isDark: isDark,
//                         onTap: () {
//                           HapticFeedback.lightImpact();
//                           _showChangePasswordDialog(context);
//                         },
//                       ),
                      
//                       _buildBiometricItem(index: 4, isDark: isDark),
                      
//                       // REMOVED "ABOUT" SECTION HERE (Help & Support, Privacy Policy)
                      
//                       const SizedBox(height: 40),
//                       _buildLogoutButton(isDark),
//                       const SizedBox(height: 20),
//                       _buildAppVersion(),
                      
//                       SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildSliverAppBar(String userName, String userEmail, String? photoUrl, String? base64Photo, String? location) {
//     ImageProvider? imageProvider;
//     if (base64Photo != null && base64Photo.isNotEmpty) {
//       try {
//         imageProvider = MemoryImage(base64Decode(base64Photo));
//       } catch (e) {
//         print("Error decoding base64: $e");
//       }
//     }
//     imageProvider ??= (photoUrl != null ? NetworkImage(photoUrl) : null);

//     return SliverAppBar(
//       expandedHeight: 330,
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
//                   top: -50, right: -50,
//                   child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1))),
//                 ),
//                 SafeArea(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//                     child: Center(
//                       child: FittedBox(
//                         fit: BoxFit.scaleDown,
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const SizedBox(height: 10),
//                             Container(
//                               decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 4)),
//                               child: CircleAvatar(
//                                 radius: 50,
//                                 backgroundImage: imageProvider,
//                                 backgroundColor: Colors.white,
//                                 child: imageProvider == null
//                                     ? Text(userName.isNotEmpty ? userName[0].toUpperCase() : 'U', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Color(0xFF2575FC)))
//                                     : null,
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             Text(userName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
//                             const SizedBox(height: 6),
//                             Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                               decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
//                               child: Text(userEmail, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
//                             ),
                            
//                             if (location != null && location.isNotEmpty) ...[
//                               const SizedBox(height: 8),
//                               Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(Icons.location_on, color: Colors.white.withOpacity(0.8), size: 16),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     location, 
//                                     style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500)
//                                   ),
//                                 ],
//                               ),
//                             ],

//                             const SizedBox(height: 10),
//                           ],
//                         ),
//                       ),
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

//   Widget _buildUserInfoSection(
//     String? bio, String? phone, String? profession, 
//     String? dob, String? username, bool isDark
//   ) {
//     bool hasData = [bio, phone, profession, dob, username].any((e) => e != null && e.isNotEmpty);
//     if (!hasData) return const SizedBox.shrink();

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(24),
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
          
//           if (phone != null && phone.isNotEmpty) ...[
//             _buildInfoRow(Icons.phone_rounded, 'Phone', phone, const Color(0xFF2575FC), isDark),
//           ],

//           if (profession != null && profession.isNotEmpty) ...[
//              if (phone != null) _buildDivider(isDark),
//              _buildInfoRow(Icons.work_rounded, 'Profession', profession, Colors.orange, isDark),
//           ],
          
//           if (username != null && username.isNotEmpty) ...[
//              if (phone != null || profession != null) _buildDivider(isDark),
//              _buildInfoRow(Icons.alternate_email_rounded, 'Username', "@$username", Colors.purple, isDark),
//           ],

//           if (bio != null && bio.isNotEmpty) ...[
//             if (phone != null || profession != null || username != null) _buildDivider(isDark),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildIconContainer(Icons.format_quote_rounded, const Color(0xFF6A11CB)),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('About Me', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.grey[600])),
//                       const SizedBox(height: 4),
//                       Text(bio, style: TextStyle(fontSize: 15, height: 1.4, color: isDark ? Colors.white : Colors.black87)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
          
//           if (dob != null && dob.isNotEmpty) ...[
//              if (bio != null) _buildDivider(isDark),
//              _buildInfoRow(Icons.cake_rounded, 'Birthday', dob, Colors.pink, isDark),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String label, String value, Color color, bool isDark) {
//     return Row(
//       children: [
//         _buildIconContainer(icon, color),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.grey[600])),
//               const SizedBox(height: 2),
//               Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildIconContainer(IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
//       child: Icon(icon, color: color, size: 20),
//     );
//   }

//   Widget _buildDivider(bool isDark) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 16),
//       child: Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey[200]),
//     );
//   }

//   Widget _buildEditProfileButton(
//     BuildContext context, 
//     String currentName, String? currentBase64, String? currentPhone, 
//     String? currentBio, String? location, String? profession, String? dob, String? username
//   ) {
//     return Center(
//       child: Container(
//         width: 200, height: 52,
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
//           borderRadius: BorderRadius.circular(26),
//           boxShadow: [BoxShadow(color: const Color(0xFF2575FC).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
//         ),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             onTap: () async {
//               HapticFeedback.lightImpact();
//               await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => EditProfileScreen(
//                     currentName: currentName,
//                     currentBase64Photo: currentBase64,
//                     currentPhone: currentPhone,
//                     currentBio: currentBio,
//                     currentLocation: location,
//                     currentProfession: profession,
//                     currentDob: dob,
//                     currentUsername: username,
//                   ),
//                 ),
//               );
//               if (mounted) setState(() {});
//             },
//             borderRadius: BorderRadius.circular(26),
//             child: const Center(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.edit_rounded, color: Colors.white, size: 20),
//                   SizedBox(width: 8),
//                   Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title, IconData icon, Color textColor) {
//     return Row(children: [
//       Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF2575FC).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: const Color(0xFF2575FC))),
//       const SizedBox(width: 12),
//       Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor)),
//     ]);
//   }

//   Widget _buildThemeSwitch(bool isDark) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
//       child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
//         Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.indigo, Colors.blueAccent]), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.dark_mode_rounded, color: Colors.white, size: 22)),
//         const SizedBox(width: 16),
//         Expanded(child: Text('Dark Mode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87))),
//         Switch(value: isDark, onChanged: (val) async { HapticFeedback.mediumImpact(); themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light; final prefs = await SharedPreferences.getInstance(); await prefs.setBool('isDark', val); }, activeColor: const Color(0xFF2575FC)),
//       ])),
//     );
//   }

//   Widget _buildSettingItem({required IconData icon, required String title, required String subtitle, required Color color1, required Color color2, required int index, required VoidCallback onTap, required bool isDark}) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
//       child: Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
//         Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: LinearGradient(colors: [color1, color2]), borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: color1.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]), child: Icon(icon, color: Colors.white, size: 22)),
//         const SizedBox(width: 16),
//         Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)), const SizedBox(height: 4), Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey[600]))])),
//         const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
//       ])))),
//     );
//   }

//   Widget _buildBiometricItem({required int index, required bool isDark}) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
//       child: Row(children: [
//         Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFA07A), Color(0xFFFF6B6B)]), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.fingerprint_rounded, color: Colors.white, size: 22)),
//         const SizedBox(width: 16),
//         Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Biometric Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)), Text('Fingerprint', style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey[600]))])),
//         Switch(value: _biometricEnabled, onChanged: (val) async { HapticFeedback.mediumImpact(); bool authenticated = await BiometricService.authenticate(); if (authenticated) { await BiometricService.setEnabled(val); setState(() => _biometricEnabled = val); if (mounted) _showInfoSnackBar(context, val ? 'Biometric Login Enabled' : 'Biometric Login Disabled'); } }, activeColor: const Color(0xFF2575FC)),
//       ]),
//     );
//   }

//   Widget _buildLogoutButton(bool isDark) {
//     return Container(
//       width: double.infinity, height: 56,
//       decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.red[300]!, width: 2)),
//       child: Material(color: Colors.transparent, child: InkWell(onTap: () => _showLogoutConfirmation(context), borderRadius: BorderRadius.circular(18), child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.logout_rounded, color: Colors.red[600], size: 22), const SizedBox(width: 10), Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.red[600]))])))),
//     );
//   }

//   Widget _buildAppVersion() {
//     return Center(child: Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.w500)));
//   }

//   void _showLogoutConfirmation(BuildContext context) {
//     HapticFeedback.mediumImpact();
//     showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (context) => Container(decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))), padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Log Out?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 12), const Text('Are you sure you want to log out of your account?'), const SizedBox(height: 32), Row(children: [Expanded(child: Container(height: 52, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)), child: Material(color: Colors.transparent, child: InkWell(onTap: () => Navigator.pop(context), borderRadius: BorderRadius.circular(16), child: const Center(child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))))))), const SizedBox(width: 12), Expanded(child: ElevatedButton(onPressed: () async { Navigator.pop(context); await AuthService().logout(); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), fixedSize: const Size.fromHeight(52)), child: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))])])));
//   }

//   void _showComingSoonSnackBar(BuildContext context) {
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Row(children: [Icon(Icons.info_outline, color: Colors.white), SizedBox(width: 12), Text('Feature coming soon!')]), backgroundColor: Color(0xFF2575FC), behavior: SnackBarBehavior.floating));
//   }

//   void _showInfoSnackBar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: const Color(0xFF2575FC), behavior: SnackBarBehavior.floating));
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import 'edit_profile_screen.dart';
import '../../main.dart'; 
import 'notifications_screen.dart'; 
import 'budget_prediction_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onWalletTap;
  const ProfileScreen({super.key, this.onWalletTap});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _loadBiometricSettings();
  }

  Future<void> _loadBiometricSettings() async {
    final enabled = await BiometricService.isEnabled();
    if (mounted) setState(() => _biometricEnabled = enabled);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    bool isLoading = false;
    String? errorText;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        errorText!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  TextField(
                    controller: oldPassController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPassController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.key),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (oldPassController.text.isEmpty || newPassController.text.isEmpty) {
                      setDialogState(() => errorText = "Fields cannot be empty");
                      return;
                    }
                    if (newPassController.text.length < 6) {
                      setDialogState(() => errorText = "Password must be at least 6 chars");
                      return;
                    }

                    setDialogState(() {
                      isLoading = true;
                      errorText = null;
                    });

                    try {
                      await AuthService().changePassword(
                        currentPassword: oldPassController.text,
                        newPassword: newPassController.text,
                      );
                      if (mounted) {
                        Navigator.pop(ctx);
                        _showInfoSnackBar(context, "Password updated successfully!");
                      }
                    } catch (e) {
                      setDialogState(() {
                        isLoading = false;
                        errorText = e.toString();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2575FC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Update', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    if (user == null) return const Scaffold(body: Center(child: Text('No user logged in')));

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        String userName = user.displayName ?? 'User';
        String? base64Photo;
        String? phone; 
        String? bio;
        String? location;
        String? profession;
        String? dob;
        String? username;
        
        if (snapshot.hasData && snapshot.data!.data() != null) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (data.containsKey('name')) userName = data['name'];
          if (data.containsKey('base64Photo')) base64Photo = data['base64Photo'];
          if (data.containsKey('phone')) phone = data['phone'];
          if (data.containsKey('bio')) bio = data['bio'];
          if (data.containsKey('location')) location = data['location'];
          if (data.containsKey('profession')) profession = data['profession'];
          if (data.containsKey('dob')) dob = data['dob'];
          if (data.containsKey('username')) username = data['username'];
        }

        String userEmail = user.email ?? 'No email';
        String? photoUrl = user.photoURL;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(userName, userEmail, photoUrl, base64Photo, location),
              
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Pass ALL fields to Edit Screen
                      _buildEditProfileButton(
                        context, userName, base64Photo, 
                        phone, bio, location, profession, dob, username
                      ),
                      
                      const SizedBox(height: 24),
                      // Pass info with requested ordering handled inside the widget
                      _buildUserInfoSection(bio, phone, profession, dob, username, isDark),
                      
                      const SizedBox(height: 32),
                      _buildSectionHeader('General', Icons.settings_rounded, textColor),
                      const SizedBox(height: 16),
                      
                      _buildThemeSwitch(isDark),
                      
                      _buildSettingItem(
                        icon: Icons.pie_chart_rounded,
                        title: 'Budget Planner',
                        subtitle: 'Set limits & predictions',
                        color1: const Color(0xFF11998e),
                        color2: const Color(0xFF38ef7d),
                        index: 0,
                        isDark: isDark,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BudgetPredictionScreen(),
                            ),
                          );
                        },
                      ),

                      _buildSettingItem(
                        icon: Icons.account_balance_wallet_rounded,
                        title: 'My Wallet',
                        subtitle: 'View all transactions',
                        color1: const Color(0xFF6A11CB),
                        color2: const Color(0xFF2575FC),
                        index: 1,
                        isDark: isDark,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (widget.onWalletTap != null) widget.onWalletTap!();
                        },
                      ),
                      _buildSettingItem(
                        icon: Icons.notifications_rounded,
                        title: 'Notifications',
                        subtitle: 'View payment requests',
                        color1: const Color(0xFFFF6B6B),
                        color2: const Color(0xFFFF8E53),
                        index: 2,
                        isDark: isDark,
                        onTap: () {
                           HapticFeedback.lightImpact();
                           Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
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
                          _showChangePasswordDialog(context);
                        },
                      ),
                      
                      _buildBiometricItem(index: 4, isDark: isDark),
                      
                      const SizedBox(height: 40),
                      _buildLogoutButton(isDark),
                      const SizedBox(height: 20),
                      _buildAppVersion(),
                      
                      SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(String userName, String userEmail, String? photoUrl, String? base64Photo, String? location) {
    ImageProvider? imageProvider;
    if (base64Photo != null && base64Photo.isNotEmpty) {
      try {
        imageProvider = MemoryImage(base64Decode(base64Photo));
      } catch (e) {
        print("Error decoding base64: $e");
      }
    }
    imageProvider ??= (photoUrl != null ? NetworkImage(photoUrl) : null);

    return SliverAppBar(
      expandedHeight: 330,
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
                  top: -50, right: -50,
                  child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1))),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 4)),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: imageProvider,
                                backgroundColor: Colors.white,
                                child: imageProvider == null
                                    ? Text(userName.isNotEmpty ? userName[0].toUpperCase() : 'U', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Color(0xFF2575FC)))
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(userName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                              child: Text(userEmail, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                            ),
                            
                            if (location != null && location.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.location_on, color: Colors.white.withOpacity(0.8), size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    location, 
                                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500)
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 10),
                          ],
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

  // UPDATED: Section now follows order: Username, Phone, Profession, Birthday, About Me
  Widget _buildUserInfoSection(
    String? bio, String? phone, String? profession, 
    String? dob, String? username, bool isDark
  ) {
    bool hasData = [bio, phone, profession, dob, username].any((e) => e != null && e.isNotEmpty);
    if (!hasData) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
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
          // 1. Username
          if (username != null && username.isNotEmpty) ...[
             _buildInfoRow(Icons.alternate_email_rounded, 'Username', "@$username", Colors.purple, isDark),
          ],

          // 2. Phone
          if (phone != null && phone.isNotEmpty) ...[
            if (username != null && username.isNotEmpty) _buildDivider(isDark),
            _buildInfoRow(Icons.phone_rounded, 'Phone', phone, const Color(0xFF2575FC), isDark),
          ],

          // 3. Profession
          if (profession != null && profession.isNotEmpty) ...[
             if ((username != null && username.isNotEmpty) || (phone != null && phone.isNotEmpty)) 
               _buildDivider(isDark),
             _buildInfoRow(Icons.work_rounded, 'Profession', profession, Colors.orange, isDark),
          ],
          
          // 4. Birthday (Date of Birth)
          if (dob != null && dob.isNotEmpty) ...[
             if ((username != null && username.isNotEmpty) || (phone != null && phone.isNotEmpty) || (profession != null && profession.isNotEmpty))
               _buildDivider(isDark),
             _buildInfoRow(Icons.cake_rounded, 'Birthday', dob, Colors.pink, isDark),
          ],

          // 5. About Me (Bio) - Now at the end
          if (bio != null && bio.isNotEmpty) ...[
            if ((username != null && username.isNotEmpty) || (phone != null && phone.isNotEmpty) || (profession != null && profession.isNotEmpty) || (dob != null && dob.isNotEmpty))
              _buildDivider(isDark),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIconContainer(Icons.format_quote_rounded, const Color(0xFF6A11CB)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('About Me', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.grey[600])),
                      const SizedBox(height: 4),
                      Text(bio, style: TextStyle(fontSize: 15, height: 1.4, color: isDark ? Colors.white : Colors.black87)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color, bool isDark) {
    return Row(
      children: [
        _buildIconContainer(icon, color),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.grey[600])),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconContainer(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey[200]),
    );
  }

  Widget _buildEditProfileButton(
    BuildContext context, 
    String currentName, String? currentBase64, String? currentPhone, 
    String? currentBio, String? location, String? profession, String? dob, String? username
  ) {
    return Center(
      child: Container(
        width: 200, height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [BoxShadow(color: const Color(0xFF2575FC).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
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
                    currentBase64Photo: currentBase64,
                    currentPhone: currentPhone,
                    currentBio: currentBio,
                    currentLocation: location,
                    currentProfession: profession,
                    currentDob: dob,
                    currentUsername: username,
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
                  Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color textColor) {
    return Row(children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF2575FC).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: const Color(0xFF2575FC))),
      const SizedBox(width: 12),
      Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor)),
    ]);
  }

  Widget _buildThemeSwitch(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.indigo, Colors.blueAccent]), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.dark_mode_rounded, color: Colors.white, size: 22)),
        const SizedBox(width: 16),
        Expanded(child: Text('Dark Mode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87))),
        Switch(value: isDark, onChanged: (val) async { HapticFeedback.mediumImpact(); themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light; final prefs = await SharedPreferences.getInstance(); await prefs.setBool('isDark', val); }, activeColor: const Color(0xFF2575FC)),
      ])),
    );
  }

  Widget _buildSettingItem({required IconData icon, required String title, required String subtitle, required Color color1, required Color color2, required int index, required VoidCallback onTap, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: LinearGradient(colors: [color1, color2]), borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: color1.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]), child: Icon(icon, color: Colors.white, size: 22)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)), const SizedBox(height: 4), Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey[600]))])),
        const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ])))),
    );
  }

  Widget _buildBiometricItem({required int index, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFA07A), Color(0xFFFF6B6B)]), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.fingerprint_rounded, color: Colors.white, size: 22)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Biometric Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)), Text('Fingerprint', style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey[600]))])),
        Switch(value: _biometricEnabled, onChanged: (val) async { HapticFeedback.mediumImpact(); bool authenticated = await BiometricService.authenticate(); if (authenticated) { await BiometricService.setEnabled(val); setState(() => _biometricEnabled = val); if (mounted) _showInfoSnackBar(context, val ? 'Biometric Login Enabled' : 'Biometric Login Disabled'); } }, activeColor: const Color(0xFF2575FC)),
      ]),
    );
  }

  Widget _buildLogoutButton(bool isDark) {
    return Container(
      width: double.infinity, height: 56,
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.red[300]!, width: 2)),
      child: Material(color: Colors.transparent, child: InkWell(onTap: () => _showLogoutConfirmation(context), borderRadius: BorderRadius.circular(18), child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.logout_rounded, color: Colors.red[600], size: 22), const SizedBox(width: 10), Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.red[600]))])))),
    );
  }

  Widget _buildAppVersion() {
    return Center(child: Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.w500)));
  }

  void _showLogoutConfirmation(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (context) => Container(decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))), padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Log Out?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 12), const Text('Are you sure you want to log out of your account?'), const SizedBox(height: 32), Row(children: [Expanded(child: Container(height: 52, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)), child: Material(color: Colors.transparent, child: InkWell(onTap: () => Navigator.pop(context), borderRadius: BorderRadius.circular(16), child: const Center(child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))))))), const SizedBox(width: 12), Expanded(child: ElevatedButton(onPressed: () async { Navigator.pop(context); await AuthService().logout(); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), fixedSize: const Size.fromHeight(52)), child: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))])])));
  }

  void _showComingSoonSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Row(children: [Icon(Icons.info_outline, color: Colors.white), SizedBox(width: 12), Text('Feature coming soon!')]), backgroundColor: Color(0xFF2575FC), behavior: SnackBarBehavior.floating));
  }

  void _showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: const Color(0xFF2575FC), behavior: SnackBarBehavior.floating));
  }
}
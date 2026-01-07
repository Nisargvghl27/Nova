import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'edit_profile_screen.dart'; 
import '../../main.dart'; 
import 'notifications_screen.dart'; // 🔹 1. IMPORT ADDED

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onWalletTap;

  const ProfileScreen({super.key, this.onWalletTap});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    if (user == null) return const Scaffold(body: Center(child: Text('No user logged in')));

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        String userName = user.displayName ?? 
            (snapshot.data?.data() as Map<String, dynamic>?)?['name']?.toString() ?? 
            user.email?.split('@')[0] ?? 'User';
        String userEmail = user.email ?? 'No email';
        String? photoUrl = user.photoURL;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(userName, userEmail, photoUrl),
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildEditProfileButton(context, userName),
                        const SizedBox(height: 32),
                        _buildStatsCards(isDark),
                        const SizedBox(height: 32),
                        _buildSectionHeader('General', Icons.settings_rounded, textColor),
                        const SizedBox(height: 16),
                        _buildThemeSwitch(isDark),
                        
                        // Wallet Item
                        _buildSettingItem(
                          icon: Icons.account_balance_wallet_rounded,
                          title: 'My Wallet',
                          subtitle: 'View all transactions',
                          color1: const Color(0xFF6A11CB),
                          color2: const Color(0xFF2575FC),
                          isDark: isDark,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            if (widget.onWalletTap != null) widget.onWalletTap!();
                          },
                        ),
                        
                        // 🔹 2. NOTIFICATIONS ITEM (UPDATED)
                        _buildSettingItem(
                          icon: Icons.notifications_rounded,
                          title: 'Notifications',
                          subtitle: 'View payment requests', // Updated Text
                          color1: const Color(0xFFFF6B6B),
                          color2: const Color(0xFFFF8E53),
                          isDark: isDark,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            // 🔹 Navigate to the new screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                            );
                          },
                        ),

                        // Other items...
                        _buildSettingItem(
                          icon: Icons.favorite_rounded,
                          title: 'Favorites',
                          subtitle: 'Saved items',
                          color1: const Color(0xFFBA68C8),
                          color2: const Color(0xFFE91E63),
                          isDark: isDark,
                          onTap: () => _showComingSoonSnackBar(context),
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
                          isDark: isDark,
                          onTap: () => _showComingSoonSnackBar(context),
                        ),
                        _buildBiometricItem(isDark: isDark),
                        const SizedBox(height: 40),
                        _buildLogoutButton(isDark),
                        const SizedBox(height: 20),
                        _buildAppVersion(),
                        SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
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

  // ... (Keep existing helper widgets: _buildSliverAppBar, _buildStatsCards, etc.)
  // For brevity, assume the standard helper widgets from your previous file are here.
  // Paste the helper methods (_buildSliverAppBar, _buildThemeSwitch, etc.) from your previous file below this line.

  // ---------------- HELPER WIDGETS (Paste from your existing file) ----------------
  
  Widget _buildThemeSwitch(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
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
              child: Text('Dark Mode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
            ),
            Switch(
              value: isDark,
              onChanged: (val) {
                HapticFeedback.mediumImpact();
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
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(currentName: currentName))),
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
  
  Widget _buildSliverAppBar(String userName, String userEmail, String? photoUrl) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: false,
      stretch: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                  backgroundColor: Colors.white,
                  child: photoUrl == null ? Text(userName.isNotEmpty ? userName[0] : 'U', style: const TextStyle(fontSize: 40, color: Color(0xFF2575FC))) : null,
                ),
                const SizedBox(height: 16),
                Text(userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(userEmail, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(bool isDark) {
      // Just a placeholder to match your layout
      return const SizedBox.shrink(); 
  }

  Widget _buildSectionHeader(String title, IconData icon, Color textColor) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2575FC), size: 20),
        const SizedBox(width: 12),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon, required String title, required String subtitle, 
    required Color color1, required Color color2, required VoidCallback onTap, required bool isDark
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(gradient: LinearGradient(colors: [color1, color2]), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
      subtitle: Text(subtitle, style: TextStyle(color: isDark ? Colors.white70 : Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }

  Widget _buildBiometricItem({required bool isDark}) {
    return SwitchListTile(
      value: _biometricEnabled,
      onChanged: (val) => setState(() => _biometricEnabled = val),
      title: Text('Biometric Login', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
      secondary: const Icon(Icons.fingerprint, color: Colors.orange),
    );
  }

  Widget _buildLogoutButton(bool isDark) {
    return OutlinedButton.icon(
      onPressed: () => _showLogoutConfirmation(context),
      icon: const Icon(Icons.logout, color: Colors.red),
      label: const Text('Log Out', style: TextStyle(color: Colors.red)),
      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
    );
  }

  Widget _buildAppVersion() {
    return const Text('Version 1.0.0', style: TextStyle(color: Colors.grey));
  }
  
  void _showLogoutConfirmation(BuildContext context) async {
      await AuthService().logout();
  }

  void _showComingSoonSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming Soon!')));
  }
}
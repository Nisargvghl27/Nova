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
// ⬇️ IMPORT THE NEW SCREEN
import 'budget_prediction_screen.dart';

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
    if (mounted) {
      setState(() => _biometricEnabled = enabled);
    }
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

    if (user == null) {
      return const Scaffold(body: Center(child: Text('No user logged in')));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        String userName = user.displayName ?? 'User';
        if (snapshot.hasData && snapshot.data!.data() != null) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (data.containsKey('name')) userName = data['name'];
        }

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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildEditProfileButton(context, userName),
                      const SizedBox(height: 32),
                      _buildStatsCards(isDark),
                      const SizedBox(height: 32),
                      _buildSectionHeader(
                          'General', Icons.settings_rounded, textColor),
                      const SizedBox(height: 16),
                      _buildThemeSwitch(isDark),
                      
                      // ⬇️ BUDGET PLANNER ITEM
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
                          if (widget.onWalletTap != null) {
                            widget.onWalletTap!();
                          }
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),
                      _buildSectionHeader(
                          'Security', Icons.shield_rounded, textColor),
                      const SizedBox(height: 16),

                      _buildSettingItem(
                        icon: Icons.lock_rounded,
                        title: 'Change Password',
                        subtitle: 'Update your password',
                        color1: const Color(0xFF51CF66),
                        color2: const Color(0xFF37B679),
                        index: 3,
                        isDark: isDark,
                        onTap: () => _showComingSoonSnackBar(context),
                      ),

                      _buildBiometricItem(index: 4, isDark: isDark),

                      const SizedBox(height: 32),
                      _buildSectionHeader(
                          'About', Icons.info_rounded, textColor),
                      const SizedBox(height: 16),

                      _buildSettingItem(
                        icon: Icons.help_rounded,
                        title: 'Help & Support',
                        subtitle: 'Get assistance',
                        color1: const Color(0xFF4ECDC4),
                        color2: const Color(0xFF44A08D),
                        index: 5,
                        isDark: isDark,
                        onTap: () => _showComingSoonSnackBar(context),
                      ),
                      _buildSettingItem(
                        icon: Icons.privacy_tip_rounded,
                        title: 'Privacy Policy',
                        subtitle: 'Terms & conditions',
                        color1: const Color(0xFF78909C),
                        color2: const Color(0xFF546E7A),
                        index: 6,
                        isDark: isDark,
                        onTap: () => _showComingSoonSnackBar(context),
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
            ],
          ),
        );
      },
    );
  }

  // ... (Keep existing helpers: _buildThemeSwitch, _buildBiometricItem, _buildEditProfileButton, _buildSliverAppBar, _buildStatsCards, _buildStatCard, _buildSectionHeader, _buildSettingItem, _buildLogoutButton, _buildAppVersion, _showLogoutConfirmation, _showComingSoonSnackBar, _showInfoSnackBar)
  // [INCLUDE ALL PREVIOUS HELPER METHODS HERE TO AVOID ERRORS]
  
  // ⬇️ RE-INCLUDED HELPER METHODS FOR COMPLETENESS:
  Widget _buildThemeSwitch(bool isDark) {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Colors.indigo, Colors.blueAccent]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.dark_mode_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Dark Mode',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Switch(
              value: isDark,
              onChanged: (val) async {
                HapticFeedback.mediumImpact();
                themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isDark', val);
              },
              activeColor: const Color(0xFF2575FC),
            ),
          ],
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
              gradient: const LinearGradient(
                  colors: [Color(0xFFFFA07A), Color(0xFFFF6B6B)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.fingerprint_rounded,
                color: Colors.white, size: 22),
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
                  'Fingerprint',
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
            onChanged: (val) async {
              HapticFeedback.mediumImpact();
              bool authenticated = await BiometricService.authenticate();
              if (authenticated) {
                await BiometricService.setEnabled(val);
                setState(() => _biometricEnabled = val);
                if (mounted) {
                  _showInfoSnackBar(context, val ? 'Biometric Login Enabled' : 'Biometric Login Disabled');
                }
              }
            },
            activeColor: const Color(0xFF2575FC),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton(BuildContext context, String currentName) {
    return Center(
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
                    ),
                  ),
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
    final cardColor = Theme.of(context).cardColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    return Row(
      children: [
        Expanded(child: _buildStatCard(icon: Icons.receipt_long_rounded, label: 'Transactions', value: '124', color: const Color(0xFF2575FC), bgColor: cardColor, textColor: textColor)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(icon: Icons.category_rounded, label: 'Categories', value: '8', color: const Color(0xFFFF6B6B), bgColor: cardColor, textColor: textColor)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(icon: Icons.calendar_today_rounded, label: 'Days Active', value: '45', color: const Color(0xFF51CF66), bgColor: cardColor, textColor: textColor)),
      ],
    );
  }

  Widget _buildStatCard({required IconData icon, required String label, required String value, required Color color, required Color bgColor, required Color textColor}) {
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
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600]), textAlign: TextAlign.center),
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
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor)),
      ],
    );
  }

  Widget _buildSettingItem({required IconData icon, required String title, required String subtitle, required Color color1, required Color color2, required int index, required VoidCallback onTap, required bool isDark}) {
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
                      Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey[600])),
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
                Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.red[600])),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppVersion() {
    return Center(child: Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.w500)));
  }

  void _showLogoutConfirmation(BuildContext context) {
    HapticFeedback.mediumImpact();
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
            const Text('Log Out?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            const Text('Are you sure you want to log out of your account?'),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(16),
                        child: const Center(child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
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
        content: const Row(children: [Icon(Icons.info_outline, color: Colors.white), SizedBox(width: 12), Text('Feature coming soon!')]),
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
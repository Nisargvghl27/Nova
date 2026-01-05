import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: user == null
          ? const Center(child: Text("No user logged in"))
          : StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() as Map<String, dynamic>?;

          final name = data?['name'] ?? user.displayName ?? 'User';
          final email = user.email ?? 'No email';
          final photoUrl = data?['photoUrl'] ?? user.photoURL;
          final biometricEnabled = data?['biometric'] ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(
                top: 60, left: 20, right: 20, bottom: 40),
            child: Column(
              children: [
                /// PROFILE HEADER
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        backgroundImage: photoUrl != null
                            ? NetworkImage(photoUrl)
                            : null,
                        child: photoUrl == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// EDIT PROFILE
                SizedBox(
                  width: 200,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      // NEXT STEP: Navigate to EditProfileScreen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                _buildSectionHeader('General'),
                const SizedBox(height: 10),
                _buildSettingItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'My Wallet',
                  onTap: () {},
                ),
                _buildSettingItem(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  onTap: () {},
                ),
                _buildSettingItem(
                  icon: Icons.favorite_border_rounded,
                  title: 'Favorites',
                  onTap: () {},
                ),

                const SizedBox(height: 30),

                _buildSectionHeader('Security'),
                const SizedBox(height: 10),
                _buildSettingItem(
                  icon: Icons.lock_outline_rounded,
                  title: 'Change Password',
                  onTap: () async {
                    await FirebaseAuth.instance
                        .sendPasswordResetEmail(email: email);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                          Text("Password reset email sent")),
                    );
                  },
                ),
                _buildSettingItem(
                  icon: Icons.fingerprint_rounded,
                  title: 'Face ID / Touch ID',
                  isSwitch: true,
                  switchValue: biometricEnabled,
                  onSwitchChanged: (val) async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .set(
                      {'biometric': val},
                      SetOptions(merge: true),
                    );
                  },
                ),

                const SizedBox(height: 40),

                /// LOGOUT
                TextButton(
                  onPressed: () async {
                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text(
                            'Are you sure you want to log out?'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: const Text('Logout',
                                style:
                                TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await AuthService().logout();
                    }
                  },
                  child: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// SECTION HEADER
  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  /// SETTING ITEM
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    bool isSwitch = false,
    bool switchValue = false,
    VoidCallback? onTap,
    ValueChanged<bool>? onSwitchChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.black87, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          isSwitch
              ? Switch(
            value: switchValue,
            onChanged: onSwitchChanged,
            activeThumbColor: const Color(0xFF2575FC),
          )
              : const Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 40),
        child: Column(
          children: [
            // 1. Profile Header
            const Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/300?img=12'), // Placeholder image
                    backgroundColor: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Alex Johnson',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'alex.johnson@email.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 2. Edit Profile Button
            SizedBox(
              width: 200,
              height: 45,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 3. Settings Groups
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
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.fingerprint_rounded,
              title: 'Face ID / Touch ID',
              isSwitch: true, // Example of a switch
              onTap: () {},
            ),

            const SizedBox(height: 40),

            // 4. Log Out
            TextButton(
              onPressed: () {},
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
      ),
    );
  }

  // Helper: Section Header Text
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

  // Helper: Settings Item Tile
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    bool isSwitch = false,
    required VoidCallback onTap,
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
          if (isSwitch)
            Switch(
              value: true,
              onChanged: (val) {},
              activeColor: const Color(0xFF2575FC),
            )
          else
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class ExpenseCategories {
  static const List<String> list = [
    'Food & Dining',
    'Groceries',
    'Rent',
    'Utilities',
    'Internet & Mobile',
    'Electricity',
    'Water',
    'Gas',
    'Transport',
    'Fuel',
    'Vehicle Maintenance',
    'Travel',
    'Shopping',
    'Clothing',
    'Electronics',
    'Personal Care',
    'Beauty & Grooming',
    'Entertainment',
    'Movies & OTT',
    'Gaming',
    'Healthcare',
    'Medicines',
    'Insurance',
    'Education',
    'Subscriptions',
    'Gifts & Donations',
    'Kids',
    'Pets',
    'Taxes',
    'Others',
  ];
}

class IncomeCategories {
  static const List<String> list = [
    'Salary',
    'Business Income',
    'Freelance',
    'Consulting',
    'Bonus',
    'Commission',
    'Interest',
    'Dividends',
    'Investment Returns',
    'Rental Income',
    'Pension',
    'Scholarship',
    'Government Benefits',
    'Refund',
    'Cashback',
    'Gift Received',
    'Side Hustle',
    'Royalties',
    'Selling Assets',
    'Other Income',
  ];
}

/// Helper class to get Style (Icon + Color) for any category
class CategoryStyle {
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  CategoryStyle({
    required this.icon,
    required this.color,
  }) : backgroundColor = color.withOpacity(0.1);

  static CategoryStyle getStyle(String category) {
    switch (category) {
      // --- EXPENSES ---
      case 'Food & Dining':
        return CategoryStyle(icon: Icons.restaurant_rounded, color: const Color(0xFFFF6B6B));
      case 'Groceries':
        return CategoryStyle(icon: Icons.local_grocery_store_rounded, color: const Color(0xFF4ECDC4));
      case 'Rent':
        return CategoryStyle(icon: Icons.home_rounded, color: const Color(0xFF6A11CB));
      case 'Utilities':
        return CategoryStyle(icon: Icons.build_rounded, color: const Color(0xFF95E1D3));
      case 'Internet & Mobile':
        return CategoryStyle(icon: Icons.wifi_rounded, color: const Color(0xFF45B7D1));
      case 'Electricity':
        return CategoryStyle(icon: Icons.electric_bolt_rounded, color: const Color(0xFFFFCE54));
      case 'Water':
        return CategoryStyle(icon: Icons.water_drop_rounded, color: const Color(0xFF4FC1E9));
      case 'Gas':
        return CategoryStyle(icon: Icons.local_fire_department_rounded, color: const Color(0xFFFF8787));
      case 'Transport':
        return CategoryStyle(icon: Icons.directions_bus_rounded, color: const Color(0xFF5D9CEC));
      case 'Fuel':
        return CategoryStyle(icon: Icons.local_gas_station_rounded, color: const Color(0xFFED5565));
      case 'Vehicle Maintenance':
        return CategoryStyle(icon: Icons.car_repair_rounded, color: const Color(0xFFCCD1D9));
      case 'Travel':
        return CategoryStyle(icon: Icons.flight_takeoff_rounded, color: const Color(0xFFAC92EC));
      case 'Shopping':
        return CategoryStyle(icon: Icons.shopping_bag_rounded, color: const Color(0xFFEC87C0));
      case 'Clothing':
        return CategoryStyle(icon: Icons.checkroom_rounded, color: const Color(0xFFD770AD));
      case 'Electronics':
        return CategoryStyle(icon: Icons.devices_rounded, color: const Color(0xFF37BC9B));
      case 'Personal Care':
        return CategoryStyle(icon: Icons.spa_rounded, color: const Color(0xFFA0D468));
      case 'Beauty & Grooming':
        return CategoryStyle(icon: Icons.face_rounded, color: const Color(0xFFED5565));
      case 'Entertainment':
        return CategoryStyle(icon: Icons.confirmation_number_rounded, color: const Color(0xFF967ADC));
      case 'Movies & OTT':
        return CategoryStyle(icon: Icons.movie_rounded, color: const Color(0xFFDA4453));
      case 'Gaming':
        return CategoryStyle(icon: Icons.sports_esports_rounded, color: const Color(0xFF967ADC));
      case 'Healthcare':
        return CategoryStyle(icon: Icons.health_and_safety_rounded, color: const Color(0xFFDA4453));
      case 'Medicines':
        return CategoryStyle(icon: Icons.medication_rounded, color: const Color(0xFF37BC9B));
      case 'Insurance':
        return CategoryStyle(icon: Icons.security_rounded, color: const Color(0xFF4A89DC));
      case 'Education':
        return CategoryStyle(icon: Icons.school_rounded, color: const Color(0xFFF6BB42));
      case 'Subscriptions':
        return CategoryStyle(icon: Icons.autorenew_rounded, color: const Color(0xFF3BAFDA));
      case 'Gifts & Donations':
        return CategoryStyle(icon: Icons.volunteer_activism_rounded, color: const Color(0xFFD770AD));
      case 'Kids':
        return CategoryStyle(icon: Icons.child_care_rounded, color: const Color(0xFFF6BB42));
      case 'Pets':
        return CategoryStyle(icon: Icons.pets_rounded, color: const Color(0xFFAAB2BD));
      case 'Taxes':
        return CategoryStyle(icon: Icons.receipt_long_rounded, color: const Color(0xFF656D78));
      case 'Others':
        return CategoryStyle(icon: Icons.more_horiz_rounded, color: const Color(0xFFAAB2BD));

      // --- INCOME ---
      case 'Salary':
        return CategoryStyle(icon: Icons.account_balance_wallet_rounded, color: const Color(0xFF8CC152));
      case 'Business Income':
        return CategoryStyle(icon: Icons.store_rounded, color: const Color(0xFF37BC9B));
      case 'Freelance':
        return CategoryStyle(icon: Icons.laptop_mac_rounded, color: const Color(0xFF4FC1E9));
      case 'Consulting':
        return CategoryStyle(icon: Icons.support_agent_rounded, color: const Color(0xFF5D9CEC));
      case 'Bonus':
        return CategoryStyle(icon: Icons.star_rounded, color: const Color(0xFFFFCE54));
      case 'Commission':
        return CategoryStyle(icon: Icons.percent_rounded, color: const Color(0xFFF6BB42));
      case 'Interest':
        return CategoryStyle(icon: Icons.trending_up_rounded, color: const Color(0xFFA0D468));
      case 'Dividends':
        return CategoryStyle(icon: Icons.pie_chart_rounded, color: const Color(0xFFAC92EC));
      case 'Investment Returns':
        return CategoryStyle(icon: Icons.currency_exchange_rounded, color: const Color(0xFF48CFAD));
      case 'Rental Income':
        return CategoryStyle(icon: Icons.house_rounded, color: const Color(0xFFD770AD));
      case 'Pension':
        return CategoryStyle(icon: Icons.elderly_rounded, color: const Color(0xFFAAB2BD));
      case 'Scholarship':
        return CategoryStyle(icon: Icons.school_rounded, color: const Color(0xFF4FC1E9));
      case 'Government Benefits':
        return CategoryStyle(icon: Icons.account_balance_rounded, color: const Color(0xFF656D78));
      case 'Refund':
        return CategoryStyle(icon: Icons.replay_rounded, color: const Color(0xFF3BAFDA));
      case 'Cashback':
        return CategoryStyle(icon: Icons.savings_rounded, color: const Color(0xFFEC87C0));
      case 'Gift Received':
        return CategoryStyle(icon: Icons.card_giftcard_rounded, color: const Color(0xFF967ADC));
      case 'Side Hustle':
        return CategoryStyle(icon: Icons.work_rounded, color: const Color(0xFFE9573F));
      case 'Royalties':
        return CategoryStyle(icon: Icons.music_note_rounded, color: const Color(0xFFDA4453));
      case 'Selling Assets':
        return CategoryStyle(icon: Icons.sell_rounded, color: const Color(0xFF967ADC));
      case 'Other Income':
        return CategoryStyle(icon: Icons.attach_money_rounded, color: const Color(0xFFAAB2BD));

      default:
        return CategoryStyle(icon: Icons.category_rounded, color: Colors.grey);
    }
  }
}
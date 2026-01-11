import '../constants/categories.dart';

class CategoryService {
  // 🔹 Priority 1: High Specificity (Recharges, Bills, Groceries, Medical)
  static final Map<String, List<String>> _highPriorityKeywords = {
    'Healthcare': [
      'medical', 'pharmacy', 'hospital', 'clinic', 'doctor', 'dr.', 'medicos', 
      'chemist', 'apollo', 'pharmeasy', '1mg', 'netmeds', 'medplus', 'lab', 
      'diagnostics', 'scan', 'mri', 'health', 'ambulance', 'medlife'
    ],
    'Internet & Mobile': [
      'recharge', 'prepaid', 'postpaid', 'jio', 'airtel', 'vi ', 'bsnl', 'vodafone',
      'idea', 'mtnl', 'data pack', 'wifi', 'fiber', 'broadband', 'act corp', 
      'hathway', 'spectranet', 'tatasky', 'dishtv', 'dth', 'netflix'
    ],
    'Utilities': [
      'electricity', 'bescom', 'tata power', 'adani power', 'bses', 'bill', 
      'water', 'gas', 'indane', 'hp gas', 'bharat gas', 'mgl', 'igl', 'cylinder',
      'municipal', 'bijli', 'power'
    ],
    'Groceries': [
      'blinkit', 'zepto', 'instamart', 'bigbasket', 'dmart', 'nature basket', 
      'spencer', 'more store', 'reliance fresh', 'kirana', 'vegetable', 'fruit', 
      'milk', 'dairy', 'grocery', 'supermarket', 'mart', 'bazaar'
    ],
    'Fuel': [
      'petrol', 'diesel', 'fuel', 'shell', 'hpcl', 'bpcl', 'ioc', 'indian oil', 
      'bharat petroleum', 'pump', 'cng', 'station'
    ],
    'Food & Dining': [
      'swiggy', 'zomato', 'eatsure', 'dominos', 'pizza', 'burger', 'kfc', 
      'mcdonald', 'starbucks', 'cafe', 'coffee', 'restaurant', 'hotel', 'dining',
      'barbeque', 'biryani', 'wow momo', 'chai', 'faasos', 'behrouz', 'baker', 'kitchen'
    ],
  };

  // 🔹 Priority 2: General Categories
  static final Map<String, List<String>> _generalKeywords = {
    'Travel': [
      'uber', 'ola', 'rapido', 'namma yatri', 'irctc', 'rail', 'metro', 'flight', 
      'indigo', 'air india', 'vistara', 'akasa', 'makemytrip', 'goibibo', 'easemytrip', 
      'redbus', 'abhibus', 'toll', 'fastag', 'ticket', 'yatra'
    ],
    'Shopping': [
      'amazon', 'flipkart', 'myntra', 'ajio', 'meesho', 'nykaa', 'tata neu', 
      'reliance digital', 'croma', 'store', 'shop', 'mall', 'decathlon', 'nike', 
      'adidas', 'zara', 'h&m', 'fashion', 'retail', 'lifestyle', 'pantaloons', 'trends'
    ],
    'Entertainment': [
      'bookmyshow', 'pvr', 'inox', 'cinepolis', 'movie', 'cinema', 'hotstar', 
      'prime video', 'youtube', 'spotify', 'apple music', 'game', 'steam', 'playstation', 
      'club', 'entertainment'
    ],
    'UPI': [
      'upi', 'gpay', 'phonepe', 'paytm', 'bharatpe', 'bhim', 'cred', 'fam'
    ],
    'Income': [
      'salary', 'credited', 'refund', 'cashback', 'received', 'interest', 'dividend'
    ]
  };

  /// 🔹 Intelligent Category Detection
  static String detectCategory({
    required String merchant,
    required String smsText,
    required bool isDebit,
  }) {
    final text = '${merchant.toLowerCase()} ${smsText.toLowerCase()}';

    // 1. Handle Income (Credit) specifically
    if (!isDebit) {
       if (text.contains('refund')) return 'Refund';
       if (text.contains('cashback')) return 'Cashback';
       if (text.contains('salary')) return 'Salary';
       return 'Income';
    }

    // 2. Check High Priority Lists First
    for (final entry in _highPriorityKeywords.entries) {
      for (final keyword in entry.value) {
        if (text.contains(keyword)) {
          return entry.key;
        }
      }
    }

    // 3. Check General Lists
    for (final entry in _generalKeywords.entries) {
      for (final keyword in entry.value) {
        if (text.contains(keyword)) {
          return entry.key;
        }
      }
    }

    // 4. Default fallback
    return 'Others';
  }
}
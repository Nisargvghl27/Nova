class CategoryService {
  static final Map<String, List<String>> _categoryKeywords = {
    'Food': [
      'swiggy',
      'zomato',
      'restaurant',
      'cafe',
      'hotel',
      'pizza',
      'burger',
      'food',
    ],
    'Travel': [
      'uber',
      'ola',
      'rapido',
      'bus',
      'train',
      'flight',
      'irctc',
      'metro',
      'fuel',
      'petrol',
      'diesel',
    ],
    'Shopping': [
      'amazon',
      'flipkart',
      'myntra',
      'ajio',
      'meesho',
      'mall',
      'store',
      'shop',
    ],
    'Bills': [
      'electricity',
      'water',
      'gas',
      'recharge',
      'mobile',
      'wifi',
      'broadband',
      'bill',
    ],
    'Entertainment': [
      'netflix',
      'prime',
      'hotstar',
      'spotify',
      'movie',
      'theatre',
    ],
    'Healthcare': [
      'hospital',
      'pharmacy',
      'medical',
      'clinic',
      'doctor',
      'apollo',
    ],
    'Education': [
      'course',
      'udemy',
      'coursera',
      'college',
      'fees',
      'school',
    ],
    'Income': [
      'salary',
      'credited',
      'refund',
      'cashback',
      'received',
    ],
  };

  /// 🔹 Main category detector
  static String detectCategory({
    required String merchant,
    required String smsText,
    required bool isDebit,
  }) {
    final text = '${merchant.toLowerCase()} ${smsText.toLowerCase()}';

    // Income first (credit has priority)
    if (!isDebit) return 'Income';

    for (final entry in _categoryKeywords.entries) {
      for (final keyword in entry.value) {
        if (text.contains(keyword)) {
          return entry.key;
        }
      }
    }

    return 'Other';
  }
}

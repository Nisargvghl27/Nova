import 'package:flutter/material.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _selectedPeriodIndex = 0;
  final List<String> _periods = ['Day', 'Week', 'Month', 'Year'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Statistics',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Icon(Icons.calendar_month_outlined, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Period Selector (Day, Week, Month...)
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: List.generate(_periods.length, (index) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPeriodIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _selectedPeriodIndex == index
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _selectedPeriodIndex == index
                              ? [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 5,
                                  )
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            _periods[index],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _selectedPeriodIndex == index
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 30),

            // 2. The Chart Area
            const Text(
              'Total Spending',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            const Text(
              '\$2,540.00',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            
            // Custom Bar Chart Widget
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar('Mon', 0.4, false),
                  _buildBar('Tue', 0.7, false),
                  _buildBar('Wed', 0.3, false),
                  _buildBar('Thu', 0.9, true), // Highest day
                  _buildBar('Fri', 0.6, false),
                  _buildBar('Sat', 0.5, false),
                  _buildBar('Sun', 0.2, false),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 3. Top Categories List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Top Categories',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.swap_vert, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 20),

            _buildCategoryItem(
              icon: Icons.fastfood_rounded,
              color: Colors.orange,
              category: 'Food & Drink',
              amount: '-\$450.00',
              percent: 0.6,
            ),
            _buildCategoryItem(
              icon: Icons.shopping_bag_rounded,
              color: Colors.purple,
              category: 'Shopping',
              amount: '-\$280.00',
              percent: 0.4,
            ),
            _buildCategoryItem(
              icon: Icons.directions_car_rounded,
              color: Colors.blue,
              category: 'Transport',
              amount: '-\$120.00',
              percent: 0.25,
            ),
          ],
        ),
      ),
    );
  }

  // Helper for the Chart Bars
  Widget _buildBar(String label, double heightPct, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 35,
          height: 150 * heightPct, // Max height is 150
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2575FC) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            gradient: isActive 
              ? const LinearGradient(
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ) 
              : null,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Helper for Category List
  Widget _buildCategoryItem({
    required IconData icon,
    required Color color,
    required String category,
    required String amount,
    required double percent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Simple Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.grey[100],
              color: color,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
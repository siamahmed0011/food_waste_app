import 'package:flutter/material.dart';

class BrowseFoodScreen extends StatefulWidget {
  const BrowseFoodScreen({super.key});

  @override
  State<BrowseFoodScreen> createState() => _BrowseFoodScreenState();
}

class _BrowseFoodScreenState extends State<BrowseFoodScreen> {
  int _selectedFilter = 0;

  final List<String> filters = const [
    'All',
    'Nearby',
    'Urgent',
    'Fresh',
  ];

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFFF6F7F9);
    const Color primary = Color(0xFFF57C00);
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          children: [
            const Text(
              'Browse Food',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Find available food donations near your organization.',
              style: TextStyle(
                fontSize: 14.5,
                color: bodyColor,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search food, location, donor...',
                  prefixIcon: Icon(Icons.search_rounded),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final selected = _selectedFilter == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? primary : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        filters[index],
                        style: TextStyle(
                          color: selected ? Colors.white : titleColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 18),

            const _FoodCard(
              foodName: 'Rice, Curry & Chicken',
              donorName: 'Green Kitchen',
              quantity: '20 meal packs',
              location: 'Mirpur, Dhaka',
              pickupTime: 'Pickup before 6:00 PM',
              condition: 'Fresh',
              category: 'Cooked Food',
              isUrgent: true,
            ),
            const SizedBox(height: 14),
            const _FoodCard(
              foodName: 'Bread & Bakery Items',
              donorName: 'Daily Bakery',
              quantity: '15 boxes',
              location: 'Dhanmondi, Dhaka',
              pickupTime: 'Pickup at 5:30 PM',
              condition: 'Packed',
              category: 'Bakery',
              isUrgent: false,
            ),
            const SizedBox(height: 14),
            const _FoodCard(
              foodName: 'Bananas & Apples',
              donorName: 'Fresh Mart',
              quantity: '10 cartons',
              location: 'Uttara, Dhaka',
              pickupTime: 'Pickup tomorrow 9:00 AM',
              condition: 'Fresh',
              category: 'Fruits',
              isUrgent: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  final String foodName;
  final String donorName;
  final String quantity;
  final String location;
  final String pickupTime;
  final String condition;
  final String category;
  final bool isUrgent;

  const _FoodCard({
    required this.foodName,
    required this.donorName,
    required this.quantity,
    required this.location,
    required this.pickupTime,
    required this.condition,
    required this.category,
    required this.isUrgent,
  });

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFFF57C00);
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFFFF1E4),
                child: Icon(Icons.fastfood_outlined, color: primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  foodName,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
              ),
              if (isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4D8),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Urgent',
                    style: TextStyle(
                      color: Color(0xFF9A6700),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Donor: $donorName',
            style: const TextStyle(
              color: bodyColor,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$category • $quantity',
            style: const TextStyle(
              color: bodyColor,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            location,
            style: const TextStyle(
              color: bodyColor,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            pickupTime,
            style: const TextStyle(
              color: bodyColor,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Condition: $condition',
            style: const TextStyle(
              color: bodyColor,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: titleColor,
                    side: const BorderSide(color: Color(0xFFE3E8E4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pickup request sent'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text('Request Pickup'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
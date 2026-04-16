import 'package:flutter/material.dart';

class OrganizationRequestsScreen extends StatefulWidget {
  const OrganizationRequestsScreen({super.key});

  @override
  State<OrganizationRequestsScreen> createState() =>
      _OrganizationRequestsScreenState();
}

class _OrganizationRequestsScreenState
    extends State<OrganizationRequestsScreen> {
  int selectedTab = 0;

  final List<String> tabs = const [
    'Pending',
    'Accepted',
    'Collected',
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
              'My Requests',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Track all your pickup requests and collection status.',
              style: TextStyle(
                fontSize: 14.5,
                color: bodyColor,
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final selected = selectedTab == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTab = index;
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
                        tabs[index],
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

            if (selectedTab == 0) ...[
              const _RequestStatusCard(
                foodName: 'Rice, Curry & Chicken',
                donorName: 'Green Kitchen',
                location: 'Mirpur, Dhaka',
                status: 'Pending',
                statusColor: Color(0xFF9A6700),
                statusBg: Color(0xFFFFF4D8),
                action1: 'Cancel',
                action2: 'Wait',
              ),
              const SizedBox(height: 14),
              const _RequestStatusCard(
                foodName: 'Bread & Bakery Items',
                donorName: 'Daily Bakery',
                location: 'Dhanmondi, Dhaka',
                status: 'Pending',
                statusColor: Color(0xFF9A6700),
                statusBg: Color(0xFFFFF4D8),
                action1: 'Cancel',
                action2: 'Wait',
              ),
            ] else if (selectedTab == 1) ...[
              const _RequestStatusCard(
                foodName: 'Vegetable Meal Boxes',
                donorName: 'Fresh Meals',
                location: 'Uttara, Dhaka',
                status: 'Accepted',
                statusColor: primary,
                statusBg: Color(0xFFFFF1E4),
                action1: 'Message',
                action2: 'View Pickup',
              ),
            ] else ...[
              const _RequestStatusCard(
                foodName: 'Bakery Surplus',
                donorName: 'Bake House',
                location: 'Banani, Dhaka',
                status: 'Collected',
                statusColor: Colors.green,
                statusBg: Color(0xFFE7F6EA),
                action1: 'Details',
                action2: 'Done',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RequestStatusCard extends StatelessWidget {
  final String foodName;
  final String donorName;
  final String location;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final String action1;
  final String action2;

  const _RequestStatusCard({
    required this.foodName,
    required this.donorName,
    required this.location,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    required this.action1,
    required this.action2,
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
        borderRadius: BorderRadius.circular(22),
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
                child: Icon(Icons.assignment_turned_in_outlined, color: primary),
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
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
            location,
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
                  child: Text(action1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: Text(action2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
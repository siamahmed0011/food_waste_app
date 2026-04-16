import 'package:flutter/material.dart';
import 'browse_food_screen.dart';
import 'organization_requests_screen.dart';

class OrganizationDashboardScreen extends StatefulWidget {
  const OrganizationDashboardScreen({super.key});

  @override
  State<OrganizationDashboardScreen> createState() =>
      _OrganizationDashboardScreenState();
}

class _OrganizationDashboardScreenState
    extends State<OrganizationDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _OrganizationHomeTab(),
    BrowseFoodScreen(),
    OrganizationRequestsScreen(),
    _OrganizationHistoryTab(),
    _OrganizationProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFFF57C00);
    const Color background = Color(0xFFF6F7F9);

    return Scaffold(
      backgroundColor: background,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: primary,
        unselectedItemColor: const Color(0xFF7A7F87),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _OrganizationHomeTab extends StatelessWidget {
  const _OrganizationHomeTab();

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFFF57C00);
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFFFF1E4),
                  child: Icon(
                    Icons.apartment_rounded,
                    color: primary.withValues(alpha: 0.95),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back 👋',
                        style: TextStyle(
                          fontSize: 15,
                          color: bodyColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Organization Dashboard',
                        style: TextStyle(
                          fontSize: 18,
                          color: titleColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    size: 28,
                    color: titleColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.20),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _OrgStatItem(value: '12', label: 'Available'),
                  _OrgStatItem(value: '4', label: 'Requests'),
                  _OrgStatItem(value: '8', label: 'Collected'),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _OrgQuickActionCard(
                    icon: Icons.search_rounded,
                    title: 'Browse Food',
                    subtitle: 'Find nearby donations',
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: _OrgQuickActionCard(
                    icon: Icons.assignment_turned_in_outlined,
                    title: 'My Requests',
                    subtitle: 'Track request status',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            const Text(
              'Nearby Donation',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1E4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.fastfood_outlined,
                      color: primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '20 meal packs available nearby',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: titleColor,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Rice, Curry • Mirpur • Pickup before 6 PM',
                          style: TextStyle(
                            color: bodyColor,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 12),

            const _OrgActivityTile(
              title: 'Pickup confirmed',
              subtitle: 'Restaurant donation confirmed for collection',
            ),
            const _OrgActivityTile(
              title: 'New donation nearby',
              subtitle: 'A donor posted 15 meal boxes near your area',
            ),
            const _OrgActivityTile(
              title: 'Request submitted',
              subtitle: 'You requested pickup for bakery surplus food',
            ),
          ],
        ),
      ),
    );
  }
}

class _OrganizationHistoryTab extends StatelessWidget {
  const _OrganizationHistoryTab();

  @override
  Widget build(BuildContext context) {
    return const _OrgSimpleTabWrapper(
      title: 'History',
      subtitle: 'Collected donation records and completed pickups will appear here.',
      icon: Icons.history_rounded,
    );
  }
}

class _OrganizationProfileTab extends StatelessWidget {
  const _OrganizationProfileTab();

  @override
  Widget build(BuildContext context) {
    return const _OrgSimpleTabWrapper(
      title: 'Profile',
      subtitle: 'Manage organization details, service area and contact information.',
      icon: Icons.apartment_rounded,
    );
  }
}

class _OrgStatItem extends StatelessWidget {
  final String value;
  final String label;

  const _OrgStatItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _OrgQuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OrgQuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);
    const Color primary = Color(0xFFF57C00);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 34, color: primary),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: bodyColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrgActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _OrgActivityTile({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFFF57C00);
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFFFF1E4),
            child: Icon(
              Icons.local_shipping_outlined,
              color: primary.withValues(alpha: 0.95),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: bodyColor,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrgSimpleTabWrapper extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _OrgSimpleTabWrapper({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);
    const Color primary = Color(0xFFF57C00);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFFFFF1E4),
                  child: Icon(icon, color: primary, size: 30),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: bodyColor,
                    fontSize: 14.5,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
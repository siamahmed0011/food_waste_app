import 'package:flutter/material.dart';

class DonorDashboardScreen extends StatefulWidget {
  const DonorDashboardScreen({super.key});

  @override
  State<DonorDashboardScreen> createState() => _DonorDashboardScreenState();
}

class _DonorDashboardScreenState extends State<DonorDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF6F7F3);
    const primary = Color(0xFF2E7D32);
    const bodyColor = Color(0xFF6B7280);
    const cardColor = Colors.white;
    const borderColor = Color(0xFFE6EBE7);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: const [
            _DonorHomeTab(),
            _DonorPostsTab(),
            _DonorHistoryTab(),
            _DonorProfileTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Open Post Food form')),
          );
        },
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: cardColor,
          border: Border(
            top: BorderSide(color: borderColor),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (value) {
            setState(() {
              _selectedIndex = value;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: cardColor,
          elevation: 0,
          selectedItemColor: primary,
          unselectedItemColor: bodyColor,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              label: 'My Posts',
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
      ),
    );
  }
}

class _DonorHomeTab extends StatelessWidget {
  const _DonorHomeTab();

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2E7D32);
    const titleColor = Color(0xFF142233);
    const bodyColor = Color(0xFF6B7280);
    const cardColor = Colors.white;
    const borderColor = Color(0xFFE6EBE7);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back 👋',
                      style: TextStyle(
                        fontSize: 15,
                        color: bodyColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Donor Dashboard',
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
                  color: titleColor,
                  size: 28,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Stats Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  value: '1',
                  label: 'Meals Shared',
                ),
                _StatItem(
                  value: '0',
                  label: 'Active Posts',
                ),
                _StatItem(
                  value: '0',
                  label: 'Completed',
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

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
                child: _ActionCard(
                  icon: Icons.add_box_outlined,
                  title: 'Post Food',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Open Post Food form')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ActionCard(
                  icon: Icons.history_rounded,
                  title: 'History',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Open donation history')),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),

          const SizedBox(height: 14),

          const _ActivityTile(
            title: 'Food picked up',
            subtitle: 'NGO collected your donation',
          ),
          const SizedBox(height: 12),
          const _ActivityTile(
            title: 'Post created',
            subtitle: 'You added 20 meal packs',
          ),
          const SizedBox(height: 12),
          const _ActivityTile(
            title: 'Request received',
            subtitle: 'NGO requested pickup',
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: borderColor),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Donation Tip',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Add pickup time, quantity and food condition clearly to help organizations respond faster.',
                  style: TextStyle(
                    fontSize: 13.8,
                    color: bodyColor,
                    height: 1.6,
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

class _DonorPostsTab extends StatelessWidget {
  const _DonorPostsTab();

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF142233);
    const bodyColor = Color(0xFF6B7280);
    const borderColor = Color(0xFFE6EBE7);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Posts',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage your current and previous donation posts.',
            style: TextStyle(
              fontSize: 14.5,
              color: bodyColor,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: borderColor),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 46,
                  color: bodyColor,
                ),
                SizedBox(height: 12),
                Text(
                  'No active posts yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Create a food post to start sharing meals with nearby organizations.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.8,
                    color: bodyColor,
                    height: 1.6,
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

class _DonorHistoryTab extends StatelessWidget {
  const _DonorHistoryTab();

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF142233);
    const bodyColor = Color(0xFF6B7280);
   

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Donation History',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track all your previous donation activities.',
            style: TextStyle(
              fontSize: 14.5,
              color: bodyColor,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 18),
          const _HistoryCard(
            title: 'Rice & Curry Packs',
            subtitle: '20 meal packs • Picked up successfully',
            date: '12 Apr 2026',
          ),
          const SizedBox(height: 12),
          const _HistoryCard(
            title: 'Vegetable Meals',
            subtitle: '15 meal packs • Request received',
            date: '08 Apr 2026',
          ),
        ],
      ),
    );
  }
}

class _DonorProfileTab extends StatelessWidget {
  const _DonorProfileTab();

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2E7D32);
    const titleColor = Color(0xFF142233);
    const bodyColor = Color(0xFF6B7280);
    const borderColor = Color(0xFFE6EBE7);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
      child: Column(
        children: [
          Container(
            height: 88,
            width: 88,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 46,
              color: primary,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Siam',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Donor Account',
            style: TextStyle(
              fontSize: 14.5,
              color: bodyColor,
            ),
          ),
          const SizedBox(height: 24),
          _ProfileTile(
            icon: Icons.person_outline_rounded,
            title: 'Edit Profile',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _ProfileTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _ProfileTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
              ),
              title: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({
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
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF142233);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: titleColor,
              size: 34,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ActivityTile({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2E7D32);
    const titleColor = Color(0xFF142233);
    const bodyColor = Color(0xFF6B7280);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: primary,
            size: 30,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: bodyColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;

  const _HistoryCard({
    required this.title,
    required this.subtitle,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2E7D32);
    const titleColor = Color(0xFF142233);
    const bodyColor = Color(0xFF6B7280);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: primary,
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
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13.6,
                    color: bodyColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: const TextStyle(
              fontSize: 12.8,
              color: bodyColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE6EBE7);
    const titleColor = Color(0xFF142233);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: ListTile(
        leading: Icon(icon, color: titleColor),
        title: Text(
          title,
          style: const TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: titleColor,
        ),
        onTap: onTap,
      ),
    );
  }
}
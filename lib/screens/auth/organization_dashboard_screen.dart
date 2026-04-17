import 'package:flutter/material.dart';
import 'browse_food_screen.dart';
import 'organization_requests_screen.dart';
import 'edit_organization_profile_screen.dart';

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
    const Color primary = Color(0xFF1565C0);
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
    const Color primary = Color(0xFF1565C0);
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
                  backgroundColor: const Color(0xFFE8F1FD),
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
                  _OrgStatItem(value: '0', label: 'Available'),
                  _OrgStatItem(value: '0', label: 'Requests'),
                  _OrgStatItem(value: '0', label: 'Collected'),
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
                      color: const Color(0xFFE8F1FD),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.fastfood_outlined, color: primary),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No nearby donation yet',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: titleColor,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'When donors post food near your area, it will appear here.',
                          style: TextStyle(color: bodyColor, fontSize: 13.5),
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
                      color: const Color(0xFFE8F1FD),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'New',
                      style: TextStyle(
                        color: primary,
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
              title: 'No recent activity',
              subtitle:
                  'Your recent requests and collections will appear here.',
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
      subtitle:
          'Collected donation records and completed pickups will appear here.',
      icon: Icons.history_rounded,
    );
  }
}

class _OrganizationProfileTab extends StatefulWidget {
  const _OrganizationProfileTab();

  @override
  State<_OrganizationProfileTab> createState() =>
      _OrganizationProfileTabState();
}

class _OrganizationProfileTabState extends State<_OrganizationProfileTab> {
  Map<String, String> profileData = {
    'name': '',
    'email': '',
    'phone': '',
    'website': '',
    'address': '',
    'serviceArea': '',
    'about': '',
    'hours': '',
    'pickup': '',
  };

  String _displayValue(String key) {
    final value = (profileData[key] ?? '').trim();
    return value.isEmpty ? 'Not added yet' : value;
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF1565C0);
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);
    const Color background = Color(0xFFF6F7F9);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Organization Profile',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manage your NGO details, contact information and service area.',
                style: TextStyle(fontSize: 14.5, color: bodyColor),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
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
                    const CircleAvatar(
                      radius: 42,
                      backgroundColor: Color(0xFFE8F1FD),
                      child: Icon(
                        Icons.apartment_rounded,
                        size: 42,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      (profileData['name'] ?? '').trim().isEmpty
                          ? 'Organization Name'
                          : profileData['name']!.trim(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F1FD),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: primary,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Organization Account',
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      (profileData['about'] ?? '').trim().isEmpty
                          ? 'No description added yet'
                          : profileData['about']!.trim(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: bodyColor,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final result =
                              await Navigator.push<Map<String, String>>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditOrganizationProfileScreen(
                                    initialData: profileData,
                                  ),
                                ),
                              );

                          if (!context.mounted) return;

                          if (result != null) {
                            setState(() {
                              profileData = result;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                content: const Text(
                                  'Profile updated successfully',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text(
                          'Edit Profile',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: const [
                  Expanded(
                    child: _OrgInfoStatCard(
                      value: '0',
                      label: 'Collected',
                      icon: Icons.inventory_2_outlined,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _OrgInfoStatCard(
                      value: '0',
                      label: 'Active Requests',
                      icon: Icons.assignment_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _ProfileSectionTitle(title: 'Contact Information'),
              const SizedBox(height: 12),
              _ProfileInfoCard(
                children: [
                  _ProfileInfoTile(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    value: _displayValue('email'),
                  ),
                  const _ProfileDivider(),
                  _ProfileInfoTile(
                    icon: Icons.call_outlined,
                    title: 'Phone',
                    value: _displayValue('phone'),
                  ),
                  const _ProfileDivider(),
                  _ProfileInfoTile(
                    icon: Icons.language_outlined,
                    title: 'Website',
                    value: _displayValue('website'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _ProfileSectionTitle(title: 'Location & Service Area'),
              const SizedBox(height: 12),
              _ProfileInfoCard(
                children: [
                  _ProfileInfoTile(
                    icon: Icons.location_on_outlined,
                    title: 'Address',
                    value: _displayValue('address'),
                  ),
                  const _ProfileDivider(),
                  _ProfileInfoTile(
                    icon: Icons.map_outlined,
                    title: 'Service Area',
                    value: _displayValue('serviceArea'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _ProfileSectionTitle(title: 'Organization Details'),
              const SizedBox(height: 12),
              _ProfileInfoCard(
                children: [
                  _ProfileInfoTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About',
                    value: _displayValue('about'),
                  ),
                  const _ProfileDivider(),
                  _ProfileInfoTile(
                    icon: Icons.access_time_outlined,
                    title: 'Operating Hours',
                    value: _displayValue('hours'),
                  ),
                  const _ProfileDivider(),
                  _ProfileInfoTile(
                    icon: Icons.local_shipping_outlined,
                    title: 'Pickup Capability',
                    value: _displayValue('pickup'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _ProfileSectionTitle(title: 'Account Settings'),
              const SizedBox(height: 12),
              _ProfileInfoCard(
                children: [
                  _SettingTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    subtitle: 'Manage alerts and updates',
                    onTap: () {},
                  ),
                  const _ProfileDivider(),
                  _SettingTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Privacy & Security',
                    subtitle: 'Change password and security settings',
                    onTap: () {},
                  ),
                  const _ProfileDivider(),
                  _SettingTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    subtitle: 'Get help or report a problem',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrgInfoStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _OrgInfoStatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF1565C0);
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
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
        children: [
          Icon(icon, color: primary, size: 24),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: bodyColor, fontSize: 13.5)),
        ],
      ),
    );
  }
}

class _ProfileSectionTitle extends StatelessWidget {
  final String title;

  const _ProfileSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1D2939),
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final List<Widget> children;

  const _ProfileInfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(children: children),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileInfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF1565C0);
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FD),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: primary, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.8,
                    color: bodyColor,
                    height: 1.5,
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

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF1565C0);
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F1FD),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: primary),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800, color: titleColor),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: bodyColor, fontSize: 13),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: bodyColor),
    );
  }
}

class _ProfileDivider extends StatelessWidget {
  const _ProfileDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF1F1F1));
  }
}

class _OrgStatItem extends StatelessWidget {
  final String value;
  final String label;

  const _OrgStatItem({required this.value, required this.label});

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
    const Color primary = Color(0xFF1565C0);

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
            style: const TextStyle(fontSize: 12.5, color: bodyColor),
          ),
        ],
      ),
    );
  }
}

class _OrgActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _OrgActivityTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF1565C0);
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE8F1FD),
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
                  style: const TextStyle(color: bodyColor, fontSize: 13.5),
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
    const Color primary = Color(0xFF1565C0);

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
                  backgroundColor: const Color(0xFFE8F1FD),
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

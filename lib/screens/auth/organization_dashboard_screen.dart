import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFFF6F7F9);

    final pages = [
      _OrganizationHomeTab(
        onBrowseTap: () {
          setState(() {
            _currentIndex = 1;
          });
        },
        onRequestsTap: () {
          setState(() {
            _currentIndex = 2;
          });
        },
        onProfileTap: () {
          setState(() {
            _currentIndex = 4;
          });
        },
      ),
      const BrowseFoodScreen(),
      const OrganizationRequestsScreen(),
      const _OrganizationHistoryTab(),
      const _OrganizationProfileTab(),
    ];

    return Scaffold(
      backgroundColor: background,
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF1565C0),
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
  final VoidCallback onBrowseTap;
  final VoidCallback onRequestsTap;
  final VoidCallback onProfileTap;

  const _OrganizationHomeTab({
    required this.onBrowseTap,
    required this.onRequestsTap,
    required this.onProfileTap,
  });

  static const Color primary = Color(0xFF1565C0);
  static const Color titleColor = Color(0xFF1D2939);
  static const Color bodyColor = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please sign in first',
            style: TextStyle(color: bodyColor),
          ),
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                final data =
                    snapshot.data?.data() as Map<String, dynamic>? ?? {};
                final name = (data['name'] ?? 'Organization').toString();
                final serviceArea =
                    (data['serviceArea'] ?? 'Service area not added')
                        .toString();

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.20),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 62,
                        width: 62,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.apartment_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome back 👋',
                              style: TextStyle(
                                fontSize: 14.5,
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              serviceArea,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onProfileTap,
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('food_posts')
                  .snapshots(),
              builder: (context, foodSnapshot) {
                final foodDocs = foodSnapshot.data?.docs ?? [];

                final availableCount = foodDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = (data['status'] ?? 'available').toString();
                  return status == 'available';
                }).length;

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('pickup_requests')
                      .where('organizationId', isEqualTo: user.uid)
                      .snapshots(),
                  builder: (context, requestSnapshot) {
                    final requestDocs = requestSnapshot.data?.docs ?? [];

                    final pendingCount = requestDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return (data['status'] ?? '').toString() == 'pending';
                    }).length;

                    final collectedCount = requestDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return (data['status'] ?? '').toString() == 'collected';
                    }).length;

                    return Row(
                      children: [
                        Expanded(
                          child: _DashboardStatCard(
                            value: '$availableCount',
                            label: 'Available',
                            icon: Icons.fastfood_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DashboardStatCard(
                            value: '$pendingCount',
                            label: 'Pending',
                            icon: Icons.assignment_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DashboardStatCard(
                            value: '$collectedCount',
                            label: 'Collected',
                            icon: Icons.inventory_2_outlined,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
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
                  child: _QuickActionCard(
                    icon: Icons.search_rounded,
                    title: 'Browse Food',
                    subtitle: 'Find available donations',
                    onTap: onBrowseTap,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.assignment_turned_in_outlined,
                    title: 'My Requests',
                    subtitle: 'Track live request status',
                    onTap: onRequestsTap,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),
            const Text(
              'Latest Food Posts',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('food_posts')
                  .orderBy('createdAt', descending: true)
                  .limit(3)
                  .snapshots(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return _EmptyCard(
                    icon: Icons.fastfood_outlined,
                    title: 'No food posts yet',
                    subtitle:
                        'When donors publish food posts, they will appear here.',
                  );
                }

                return Column(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _LatestFoodCard(
                      foodName: (data['foodName'] ?? 'Food Item').toString(),
                      donorName: (data['donorName'] ?? 'Donor').toString(),
                      quantity: (data['quantity'] ?? 'Not specified')
                          .toString(),
                      location: (data['location'] ?? 'No location').toString(),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 22),
            const Text(
              'Recent Notifications',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('createdAt', descending: true)
                  .limit(3)
                  .snapshots(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return _EmptyCard(
                    icon: Icons.notifications_none_rounded,
                    title: 'No notifications yet',
                    subtitle:
                        'Request updates and important alerts will appear here.',
                  );
                }

                return Column(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _NotificationPreviewCard(
                      title: (data['title'] ?? '').toString(),
                      body: (data['body'] ?? '').toString(),
                    );
                  }).toList(),
                );
              },
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
  Map<String, String> profileData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (doc.exists && doc.data() != null) {
        final raw = doc.data()!;
        final converted = <String, String>{};

        for (final entry in raw.entries) {
          converted[entry.key] = entry.value?.toString() ?? '';
        }

        setState(() {
          profileData = converted;
          isLoading = false;
        });
      } else {
        setState(() {
          profileData = {};
          isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        profileData = {};
        isLoading = false;
      });
    }
  }

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

    if (isLoading) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(child: CircularProgressIndicator(color: primary)),
      );
    }

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
                      color: Colors.black.withOpacity(0.04),
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

                          if (!mounted) return;

                          if (result != null) {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .set(result, SetOptions(merge: true));
                            }

                            await _loadProfile();

                            if (!mounted) return;

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
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _DashboardStatCard({
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
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: bodyColor, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);
    const Color primary = Color(0xFF1565C0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
      ),
    );
  }
}

class _LatestFoodCard extends StatelessWidget {
  final String foodName;
  final String donorName;
  final String quantity;
  final String location;

  const _LatestFoodCard({
    required this.foodName,
    required this.donorName,
    required this.quantity,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF1565C0);
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  foodName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'By $donorName',
                  style: const TextStyle(color: bodyColor, fontSize: 13.5),
                ),
                const SizedBox(height: 3),
                Text(
                  '$quantity • $location',
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

class _NotificationPreviewCard extends StatelessWidget {
  final String title;
  final String body;

  const _NotificationPreviewCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF1565C0);
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FD),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.notifications_none_rounded, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: const TextStyle(
                    color: bodyColor,
                    fontSize: 13.5,
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

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF1565C0);
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: primary),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: bodyColor,
              fontSize: 13.5,
              height: 1.6,
            ),
          ),
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
            color: Colors.black.withOpacity(0.04),
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

class _ProfileDivider extends StatelessWidget {
  const _ProfileDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF1F1F1));
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

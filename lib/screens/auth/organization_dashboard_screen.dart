import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'browse_food_screen.dart';
import 'organization_requests_screen.dart';
import 'edit_organization_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome_screen.dart';

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

  static const Color primary = Color(0xFF1565C0);
  static const Color background = Color(0xFFF4F7FC);
  static const Color titleColor = Color(0xFF102A43);
  static const Color bodyColor = Color(0xFF6B7280);

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return const Color(0xFF16A34A);
      case 'declined':
        return const Color(0xFFDC2626);
      case 'cancelled':
        return const Color(0xFFF59E0B);
      case 'collected':
        return const Color(0xFF0F766E);
      default:
        return primary;
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'accepted':
        return const Color(0xFFDCFCE7);
      case 'declined':
        return const Color(0xFFFEE2E2);
      case 'cancelled':
        return const Color(0xFFFEF3C7);
      case 'collected':
        return const Color(0xFFCCFBF1);
      default:
        return const Color(0xFFDBEAFE);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'accepted':
        return Icons.check_circle_rounded;
      case 'declined':
        return Icons.cancel_rounded;
      case 'cancelled':
        return Icons.remove_circle_outline_rounded;
      case 'collected':
        return Icons.inventory_2_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  String _formatTime(dynamic value) {
    if (value is Timestamp) {
      final dt = value.toDate();
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      return '$day/$month/${dt.year} • $hour:$minute $period';
    }
    return 'Not available';
  }

  Future<void> _deleteHistoryItem(BuildContext context, String docId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Delete History',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'Are you sure you want to delete this history item?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await FirebaseFirestore.instance
          .collection('pickup_requests')
          .doc(docId)
          .delete();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('History item deleted'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(
          child: Text(
            'Please sign in first',
            style: TextStyle(color: bodyColor),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('pickup_requests')
              .where('organizationId', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: primary),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: bodyColor,
                      height: 1.6,
                    ),
                  ),
                ),
              );
            }

            final allDocs = snapshot.data?.docs ?? [];

            final historyDocs = allDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final status = (data['status'] ?? '').toString();
              return status == 'accepted' ||
                  status == 'declined' ||
                  status == 'cancelled' ||
                  status == 'collected';
            }).toList();

            historyDocs.sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;

              final aTime =
                  (aData['updatedAt'] as Timestamp?)?.millisecondsSinceEpoch ??
                      0;
              final bTime =
                  (bData['updatedAt'] as Timestamp?)?.millisecondsSinceEpoch ??
                      0;

              return bTime.compareTo(aTime);
            });

            int acceptedCount = 0;
            int declinedCount = 0;
            int cancelledCount = 0;
            int collectedCount = 0;

            for (final doc in historyDocs) {
              final data = doc.data() as Map<String, dynamic>;
              final status = (data['status'] ?? '').toString();

              if (status == 'accepted') acceptedCount++;
              if (status == 'declined') declinedCount++;
              if (status == 'cancelled') cancelledCount++;
              if (status == 'collected') collectedCount++;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'History',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'See all completed and past request activities in real time.',
                    style: TextStyle(
                      fontSize: 14.5,
                      color: bodyColor,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1E88E5),
                          Color(0xFF1565C0),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.20),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(0x33FFFFFF),
                          child: Icon(
                            Icons.history_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Request History',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'All your old request outcomes in one place',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: _HistorySummaryCard(
                          title: 'Accepted',
                          value: '$acceptedCount',
                          icon: Icons.check_circle_outline,
                          color: const Color(0xFF16A34A),
                          bg: const Color(0xFFDCFCE7),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _HistorySummaryCard(
                          title: 'Collected',
                          value: '$collectedCount',
                          icon: Icons.inventory_2_outlined,
                          color: const Color(0xFF0F766E),
                          bg: const Color(0xFFCCFBF1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _HistorySummaryCard(
                          title: 'Declined',
                          value: '$declinedCount',
                          icon: Icons.close_rounded,
                          color: const Color(0xFFDC2626),
                          bg: const Color(0xFFFEE2E2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _HistorySummaryCard(
                          title: 'Cancelled',
                          value: '$cancelledCount',
                          icon: Icons.cancel_outlined,
                          color: const Color(0xFFF59E0B),
                          bg: const Color(0xFFFEF3C7),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (historyDocs.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
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
                      child: const Column(
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 44,
                            color: primary,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No history yet',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Accepted, declined, cancelled and collected requests will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: bodyColor,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: historyDocs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        final foodName =
                            (data['foodName'] ?? 'Food Item').toString();
                        final donorName =
                            (data['donorName'] ?? 'Donor').toString();
                        final quantity =
                            (data['quantity'] ?? 'Not specified').toString();
                        final location =
                            (data['location'] ?? 'No location').toString();
                        final status =
                            (data['status'] ?? 'unknown').toString();
                        final updatedAt = _formatTime(data['updatedAt']);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 23,
                                    backgroundColor: _statusBg(status),
                                    child: Icon(
                                      _statusIcon(status),
                                      color: _statusColor(status),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          foodName,
                                          style: const TextStyle(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w800,
                                            color: titleColor,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _statusBg(status),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: Text(
                                            status[0].toUpperCase() +
                                                status.substring(1),
                                            style: TextStyle(
                                              color: _statusColor(status),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        _deleteHistoryItem(context, doc.id),
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _HistoryInfoRow(
                                icon: Icons.person_outline_rounded,
                                text: 'Donor: $donorName',
                              ),
                              const SizedBox(height: 8),
                              _HistoryInfoRow(
                                icon: Icons.inventory_2_outlined,
                                text: 'Quantity: $quantity',
                              ),
                              const SizedBox(height: 8),
                              _HistoryInfoRow(
                                icon: Icons.location_on_outlined,
                                text: 'Location: $location',
                              ),
                              const SizedBox(height: 8),
                              _HistoryInfoRow(
                                icon: Icons.access_time_outlined,
                                text: 'Updated: $updatedAt',
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HistorySummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;

  const _HistorySummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
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
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF102A43),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HistoryInfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF1565C0);
    const Color bodyColor = Color(0xFF6B7280);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 2),
        Icon(icon, size: 18, color: primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: bodyColor,
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
class _OrganizationProfileTab extends StatefulWidget {
  const _OrganizationProfileTab({super.key});

  @override
  State<_OrganizationProfileTab> createState() =>
      _OrganizationProfileTabState();
}

class _OrganizationProfileTabState extends State<_OrganizationProfileTab> {
  static const Color primary = Color(0xFF1565C0);
  static const Color bg = Color(0xFFF4F7FC);
  static const Color titleColor = Color(0xFF102A43);
  static const Color bodyColor = Color(0xFF6B7280);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _serviceAreaController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    _serviceAreaController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  void _fillControllers(Map<String, dynamic> data) {
    if (_isEditing) return;
    _nameController.text = (data['name'] ?? '').toString();
    _emailController.text = (data['email'] ?? '').toString();
    _phoneController.text = (data['phone'] ?? '').toString();
    _addressController.text = (data['address'] ?? '').toString();
    _websiteController.text = (data['website'] ?? '').toString();
    _serviceAreaController.text = (data['serviceArea'] ?? '').toString();
    _aboutController.text = (data['about'] ?? '').toString();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'role': 'organization',
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'website': _websiteController.text.trim(),
        'serviceArea': _serviceAreaController.text.trim(),
        'about': _aboutController.text.trim(),
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => WelcomeScreen()),
      (route) => false,
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          color: titleColor,
          fontSize: 15.5,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: primary),
          filled: true,
          fillColor: _isEditing ? Colors.white : const Color(0xFFF9FBFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: primary, width: 1.4),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login first'),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: bg,
            body: Center(
              child: CircularProgressIndicator(color: primary),
            ),
          );
        }

        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        _fillControllers(data);

        final displayName = _nameController.text.trim().isEmpty
            ? 'NGO Name'
            : _nameController.text.trim();

        final displayEmail = _emailController.text.trim().isEmpty
            ? 'No email added yet'
            : _emailController.text.trim();

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.white,
            centerTitle: true,
            title: const Text(
              'NGO Profile',
              style: TextStyle(
                color: titleColor,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                    if (!_isEditing) {
                      _fillControllers(data);
                    }
                  });
                },
                child: Text(
                  _isEditing ? 'Cancel' : 'Edit',
                  style: const TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 26,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1E88E5),
                            Color(0xFF1565C0),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.22),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 86,
                            width: 86,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.apartment_rounded,
                              size: 42,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            displayName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            displayEmail,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_user_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isEditing
                                      ? 'Editing enabled'
                                      : 'Real-time profile data',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    _buildField(
                      label: 'NGO Name',
                      hint: 'Enter NGO name',
                      controller: _nameController,
                      icon: Icons.apartment_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'NGO name is required';
                        }
                        return null;
                      },
                    ),
                    _buildField(
                      label: 'Email',
                      hint: 'Enter email',
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildField(
                      label: 'Phone',
                      hint: 'Enter phone number',
                      controller: _phoneController,
                      icon: Icons.call_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildField(
                      label: 'Address',
                      hint: 'Enter full address',
                      controller: _addressController,
                      icon: Icons.location_on_outlined,
                      maxLines: 3,
                    ),
                    _buildField(
                      label: 'Website',
                      hint: 'Enter website',
                      controller: _websiteController,
                      icon: Icons.language_outlined,
                    ),
                    _buildField(
                      label: 'Service Area',
                      hint: 'e.g. Mirpur, Uttara, Dhanmondi',
                      controller: _serviceAreaController,
                      icon: Icons.map_outlined,
                    ),
                    _buildField(
                      label: 'About NGO',
                      hint: 'Write short description about NGO',
                      controller: _aboutController,
                      icon: Icons.info_outline_rounded,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: (_isEditing && !_isSaving)
                            ? _saveProfile
                            : null,
                        icon: _isSaving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _isSaving ? 'Saving...' : 'Save Changes',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          disabledBackgroundColor: Colors.blue.shade200,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primary,
                          side: const BorderSide(color: primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_waste_app/features/donor/create_food_screen.dart';
import 'package:food_waste_app/features/donor/donor_profile_screen.dart';
import 'package:food_waste_app/features/donor/donor_notifications_screen.dart';
import 'package:food_waste_app/features/donor/my_donations_screen.dart';
import 'package:food_waste_app/features/donor/donor_home_screen.dart';

class DonorDashboardScreen extends StatefulWidget {
  const DonorDashboardScreen({super.key});

  @override
  State<DonorDashboardScreen> createState() => _DonorDashboardScreenState();
}

class _DonorDashboardScreenState extends State<DonorDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DonorHomeScreen(),
    const _RequestsTab(),
    MyDonationsScreen(),
    const DonorProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2E7D32);
    const Color background = Color(0xFFF6F7F9);

    return Scaffold(
      backgroundColor: background,
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateFoodScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: primary,
        unselectedItemColor: const Color(0xFF7A7F87),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 14,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        selectedIconTheme: const IconThemeData(size: 28),
        unselectedIconTheme: const IconThemeData(size: 24),
        showUnselectedLabels: true,
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
            icon: Icon(Icons.handshake_outlined),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'My Donations',
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

class _DonorHomeTab extends StatefulWidget {
  const _DonorHomeTab();

  @override
  State<_DonorHomeTab> createState() => _DonorHomeTabState();
}

class _DonorHomeTabState extends State<_DonorHomeTab> {
  bool _showRecentActivity = true;

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 21) return 'Good evening';
    return 'Good night';
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2E7D32);
    const Color accent = Color(0xFF66BB6A);
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF55616F);
    const Color background = Color(0xFFF5F7F5);
    const Color surface = Color(0xFFFFFFFF);

    final user = FirebaseAuth.instance.currentUser;
    final greeting = _getGreeting(DateTime.now().hour);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(31),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(46),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.volunteer_activism_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: user == null
                          ? null
                          : FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .snapshots(),
                      builder: (context, snapshot) {
                        String donorName = 'Donor';
                        String donorSubtitle = 'Ready to donate today';

                        if (snapshot.hasData && snapshot.data!.exists) {
                          final data =
                              snapshot.data!.data() as Map<String, dynamic>;
                          final rawName =
                              (data['name'] ??
                                      data['fullName'] ??
                                      data['username'])
                                  ?.toString() ??
                              '';
                          final fallbackEmail =
                              (data['email'] ?? user?.email ?? '').toString();

                          if (rawName.isNotEmpty) {
                            donorName = rawName;
                            donorSubtitle = 'Verified donor';
                          } else if (fallbackEmail.isNotEmpty) {
                            final username = fallbackEmail.split('@').first;
                            donorName = username.isNotEmpty
                                ? username
                                : 'Donor';
                          }
                        } else if (user?.email != null) {
                          final username = user!.email!.split('@').first;
                          donorName = username.isNotEmpty ? username : 'Donor';
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              donorName,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              donorSubtitle,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DonorNotificationsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            StreamBuilder<QuerySnapshot>(
              stream: user == null
                  ? null
                  : FirebaseFirestore.instance
                        .collection('food_posts')
                        .where('donorId', isEqualTo: user.uid)
                        .snapshots(),
              builder: (context, postSnapshot) {
                final totalPosts = postSnapshot.data?.docs.length ?? 0;

                return StreamBuilder<QuerySnapshot>(
                  stream: user == null
                      ? null
                      : FirebaseFirestore.instance
                            .collection('pickup_requests')
                            .where('donorId', isEqualTo: user.uid)
                            .snapshots(),
                  builder: (context, requestSnapshot) {
                    final requests = requestSnapshot.data?.docs ?? [];
                    final completed = requests.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return (data['pickupStatus'] ?? '')
                              .toString()
                              .toLowerCase() ==
                          'completed';
                    }).length;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatItem(
                              icon: Icons.restaurant_menu_rounded,
                              value: '$totalPosts',
                              label: 'Meals Shared',
                              accent: accent,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatItem(
                              icon: Icons.autorenew,
                              value: '${totalPosts - completed}',
                              label: 'Active Posts',
                              accent: const Color(0xFF4CAF50),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatItem(
                              icon: Icons.check_circle_rounded,
                              value: '$completed',
                              label: 'Completed',
                              accent: const Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
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
                    icon: Icons.add_box_outlined,
                    title: 'Post Food',
                    subtitle: 'Create a donation',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateFoodScreen(),
                        ),
                      );
                    },
                    background: const Color(0xFFE8F5E9),
                    iconColor: primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'My Donations',
                    subtitle: 'Manage your posts',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MyDonationsScreen()),
                      );
                    },
                    background: const Color(0xFFE9F7EF),
                    iconColor: const Color(0xFF388E3C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showRecentActivity = !_showRecentActivity;
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: primary,
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(_showRecentActivity ? 'Hide' : 'Show'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: _showRecentActivity
                  ? Column(
                      key: const ValueKey('activity_visible'),
                      children: const [
                        _ActivityTile(
                          title: 'Food picked up',
                          subtitle: 'NGO collected your donation',
                        ),
                        _ActivityTile(
                          title: 'Post created',
                          subtitle: 'You added a food donation',
                        ),
                        _ActivityTile(
                          title: 'Request received',
                          subtitle: 'NGO requested pickup',
                        ),
                      ],
                    )
                  : Container(
                      key: const ValueKey('activity_hidden'),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF7ED),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Recent activity is hidden. Tap Show to view your latest updates.',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: bodyColor,
                          height: 1.5,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Donation Tip',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: titleColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Add pickup time, quantity and food condition clearly to help organizations respond faster.',
                    style: TextStyle(
                      color: bodyColor,
                      fontSize: 14.5,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestsTab extends StatelessWidget {
  const _RequestsTab();

  Future<void> _updateRequestStatus({
    required BuildContext context,
    required String requestId,
    required String status,
    required String organizationName,
    required String foodName,
    required String organizationId,
    required String postId,
  }) async {
    final normalizedStatus = status.toLowerCase();

    String pickupStatus = 'pending';
    if (normalizedStatus == 'accepted') {
      pickupStatus = 'accepted';
    } else if (normalizedStatus == 'declined') {
      pickupStatus = 'cancelled';
    } else if (normalizedStatus == 'cancelled') {
      pickupStatus = 'cancelled';
    }

    await FirebaseFirestore.instance
        .collection('pickup_requests')
        .doc(requestId)
        .update({
          'status': normalizedStatus,
          'pickupStatus': pickupStatus,
          'updatedAt': Timestamp.now(),
          'pickupUpdatedAt': Timestamp.now(),
        });

    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': organizationId,
      'title': normalizedStatus == 'accepted'
          ? 'Request accepted'
          : 'Request declined',
      'body': normalizedStatus == 'accepted'
          ? 'Your request for $foodName was accepted by donor'
          : 'Your request for $foodName was declined by donor',
      'type': normalizedStatus == 'accepted'
          ? 'request_accepted'
          : 'request_declined',
      'isRead': false,
      'createdAt': Timestamp.now(),
      'requestId': requestId,
      'postId': postId,
      'organizationName': organizationName,
    });

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          normalizedStatus == 'accepted'
              ? 'Request accepted'
              : 'Request declined',
        ),
      ),
    );
  }

  Color _statusTextColor(String status, String pickupStatus) {
    final s = status.toLowerCase();
    final p = pickupStatus.toLowerCase();

    if (s == 'pending') return const Color(0xFF9A6700);
    if (s == 'declined') return Colors.red;
    if (s == 'cancelled') return Colors.redAccent;

    if (s == 'accepted') {
      if (p == 'scheduled') return Colors.orange;
      if (p == 'on_the_way') return Colors.deepPurple;
      if (p == 'completed') return Colors.teal;
      return const Color(0xFF2E7D32);
    }

    return const Color(0xFF2E7D32);
  }

  Color _statusBgColor(String status, String pickupStatus) {
    final s = status.toLowerCase();
    final p = pickupStatus.toLowerCase();

    if (s == 'pending') return const Color(0xFFFFF4D8);
    if (s == 'declined') return const Color(0xFFFFE5E5);
    if (s == 'cancelled') return const Color(0xFFFFEAEA);

    if (s == 'accepted') {
      if (p == 'scheduled') return const Color(0xFFFFF1E0);
      if (p == 'on_the_way') return const Color(0xFFF0E9FF);
      if (p == 'completed') return const Color(0xFFE7F8F4);
      return const Color(0xFFE7F6EA);
    }

    return const Color(0xFFE7F6EA);
  }

  String _statusLabel(String status, String pickupStatus) {
    final s = status.toLowerCase();
    final p = pickupStatus.toLowerCase();

    if (s == 'pending') return 'Pending';
    if (s == 'declined') return 'Declined';
    if (s == 'cancelled') return 'Cancelled';

    if (s == 'accepted') {
      if (p == 'scheduled') return 'Pickup Scheduled';
      if (p == 'on_the_way') return 'On the Way';
      if (p == 'completed') return 'Completed';
      return 'Accepted';
    }

    return status;
  }

  void _showRequestDetails(BuildContext context, Map<String, dynamic> data) {
    const Color titleColor = Color(0xFF1D2939);
    const Color primary = Color(0xFF2E7D32);

    final ngoName =
        (data['organizationName'] ?? data['ngoName'] ?? 'Organization')
            .toString();
    final foodName = (data['foodName'] ?? data['foodTitle'] ?? 'Food Item')
        .toString();
    final quantity = (data['quantity'] ?? '-').toString();
    final location = (data['location'] ?? '-').toString();
    final status = (data['status'] ?? '-').toString();
    final pickupStatus = (data['pickupStatus'] ?? '-').toString();
    final phone = (data['phone'] ?? data['organizationPhone'] ?? '-')
        .toString();
    final email = (data['email'] ?? data['organizationEmail'] ?? '-')
        .toString();
    final note =
        (data['note'] ??
                data['pickupNote'] ??
                data['message'] ??
                data['requestNote'] ??
                '-')
            .toString();

    final requestedAt = data['requestedAt'];
    String requestedTime = '-';
    if (requestedAt is Timestamp) {
      final d = requestedAt.toDate();
      requestedTime =
          '${d.day}/${d.month}/${d.year} • ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 54,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Request Details',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAF8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5ECE7)),
                    ),
                    child: Column(
                      children: [
                        _detailsRow('NGO Name', ngoName),
                        _detailsRow('Food', foodName),
                        _detailsRow('Quantity', quantity),
                        _detailsRow('Location', location),
                        _detailsRow('Status', status),
                        _detailsRow('Pickup Status', pickupStatus),
                        _detailsRow('Phone', phone),
                        _detailsRow('Email', email),
                        _detailsRow('Request Time', requestedTime),
                        _detailsRow('Note', note, isLast: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailsRow(String label, String value, {bool isLast = false}) {
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: titleColor,
                fontSize: 13.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                color: bodyColor,
                fontSize: 13.8,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SafeArea(
        child: Center(
          child: Text('Please sign in first', style: TextStyle(fontSize: 16)),
        ),
      );
    }

    Widget sectionHeader() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Requests',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Organizations interested in your food posts.',
            style: TextStyle(fontSize: 14.5, color: bodyColor),
          ),
          SizedBox(height: 18),
        ],
      );
    }

    Widget requestSummary(int totalCount, int pendingCount) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.request_page,
                color: Color(0xFF2E7D32),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$totalCount active request${totalCount == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pendingCount > 0
                        ? '$pendingCount pending approval${pendingCount == 1 ? '' : 's'}'
                        : 'No pending requests at the moment',
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: bodyColor,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF4FBF6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'Latest',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pickup_requests')
            .where('donorId', isEqualTo: user.uid)
            .orderBy('requestedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Error loading requests: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          final pendingCount = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final status = (data['status'] ?? 'pending')
                .toString()
                .toLowerCase();
            return status == 'pending';
          }).length;

          if (docs.isEmpty) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
              children: [
                sectionHeader(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 28,
                    horizontal: 18,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4FBF6),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.inbox_outlined,
                          size: 34,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'No requests yet',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Organizations will request your food donations here once someone shows interest.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: bodyColor,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 22),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateFoodScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Create a donation',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
            itemCount: docs.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionHeader(),
                    requestSummary(docs.length, pendingCount),
                  ],
                );
              }

              final doc = docs[index - 1];
              final data = doc.data() as Map<String, dynamic>;
              final requestId = doc.id;
              final organizationName =
                  (data['organizationName'] ?? 'Organization').toString();
              final foodName = (data['foodName'] ?? 'Food Item').toString();
              final quantity = (data['quantity'] ?? '').toString();
              final location = (data['location'] ?? '').toString();
              final status = (data['status'] ?? 'pending').toString();
              final pickupStatus = (data['pickupStatus'] ?? 'pending')
                  .toString();
              final organizationId = (data['organizationId'] ?? '').toString();
              final postId = (data['postId'] ?? '').toString();

              final details =
                  '$foodName${quantity.isNotEmpty ? ' • $quantity' : ''}${location.isNotEmpty ? ' • $location' : ''}';
              final isPending = status.toLowerCase() == 'pending';

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _RequestCard(
                  ngoName: organizationName,
                  details: details,
                  status: _statusLabel(status, pickupStatus),
                  statusColor: _statusTextColor(status, pickupStatus),
                  statusBg: _statusBgColor(status, pickupStatus),
                  isPending: isPending,
                  onViewTap: () {
                    _showRequestDetails(context, data);
                  },
                  onAcceptTap: () async {
                    if (!isPending) return;
                    await _updateRequestStatus(
                      context: context,
                      requestId: requestId,
                      status: 'accepted',
                      organizationName: organizationName,
                      foodName: foodName,
                      organizationId: organizationId,
                      postId: postId,
                    );
                  },
                  onDeclineTap: () async {
                    if (!isPending) return;
                    await _updateRequestStatus(
                      context: context,
                      requestId: requestId,
                      status: 'declined',
                      organizationName: organizationName,
                      foodName: foodName,
                      organizationId: organizationId,
                      postId: postId,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1D2939),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
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
  final VoidCallback? onTap;
  final Color background;
  final Color iconColor;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    required this.background,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, size: 28, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: bodyColor,
                height: 1.5,
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

  const _ActivityTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2E7D32);
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF55616F);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutQuad,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F6EA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.check, color: primary, size: 24),
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
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: bodyColor,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String ngoName;
  final String details;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final bool isPending;
  final VoidCallback onViewTap;
  final VoidCallback onAcceptTap;
  final VoidCallback onDeclineTap;

  const _RequestCard({
    required this.ngoName,
    required this.details,
    required this.status,
    this.statusColor = const Color(0xFF9A6700),
    this.statusBg = const Color(0xFFFFF4D8),
    required this.isPending,
    required this.onViewTap,
    required this.onAcceptTap,
    required this.onDeclineTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2E7D32);
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ngoName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
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
          const SizedBox(height: 16),
          const Text(
            'Requested item',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: titleColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            details,
            style: const TextStyle(
              color: bodyColor,
              fontSize: 13.75,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1.5),
          const SizedBox(height: 14),
          if (isPending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDeclineTap,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFDE4F4F)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      foregroundColor: const Color(0xFFDE4F4F),
                      backgroundColor: const Color(0xFFFFF1F1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onViewTap,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primary.withAlpha(51)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      foregroundColor: primary,
                      backgroundColor: const Color(0xFFF5FBF8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Details'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAcceptTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      foregroundColor: bodyColor,
                      backgroundColor: const Color(0xFFF7F7F7),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onViewTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('View'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

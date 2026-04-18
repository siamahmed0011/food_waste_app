import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'create_food_screen.dart';
import 'donor_profile_screen.dart';

class DonorDashboardScreen extends StatefulWidget {
  const DonorDashboardScreen({super.key});

  @override
  State<DonorDashboardScreen> createState() => _DonorDashboardScreenState();
}

class _DonorDashboardScreenState extends State<DonorDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _DonorHomeTab(),
    _MyPostsTab(),
    _RequestsTab(),
    _HistoryTab(),
    DonorProfileScreen(),
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
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
            icon: Icon(Icons.inventory_2_outlined),
            label: 'My Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handshake_outlined),
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

class _DonorHomeTab extends StatelessWidget {
  const _DonorHomeTab();

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2E7D32);
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);

    final user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFE7EFE7),
                  child: Icon(
                    Icons.person,
                    color: primary.withOpacity(0.95),
                    size: 28,
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
                          fontSize: 15,
                          color: bodyColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'Donor Dashboard',
                        style: const TextStyle(
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

                    final activePosts = totalPosts;
                    final completed = requests.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return (data['pickupStatus'] ?? '')
                              .toString()
                              .toLowerCase() ==
                          'completed';
                    }).length;

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: primary,
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
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            value: '$totalPosts',
                            label: 'Meals Shared',
                          ),
                          _StatItem(
                            value: '$activePosts',
                            label: 'Active Posts',
                          ),
                          _StatItem(
                            value: '$completed',
                            label: 'Completed',
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 22),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DonorProfileScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xFFFFE5E5),
                      child: Icon(Icons.person, color: Colors.red),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'View and update your profile details',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 18),
                  ],
                ),
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
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: _QuickActionCard(
                    icon: Icons.history_rounded,
                    title: 'History',
                    subtitle: 'View completed',
                  ),
                ),
              ],
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

            const _ActivityTile(
              title: 'Food picked up',
              subtitle: 'NGO collected your donation',
            ),
            const _ActivityTile(
              title: 'Post created',
              subtitle: 'You added a food donation',
            ),
            const _ActivityTile(
              title: 'Request received',
              subtitle: 'NGO requested pickup',
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE7E7E7)),
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

class _MyPostsTab extends StatelessWidget {
  const _MyPostsTab();

  @override
  Widget build(BuildContext context) {
    return const _SimpleTabWrapper(
      title: 'My Posts',
      subtitle: 'All your active and past donation posts will appear here.',
      icon: Icons.inventory_2_outlined,
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

  @override
  Widget build(BuildContext context) {
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SafeArea(
        child: Center(
          child: Text(
            'Please sign in first',
            style: TextStyle(fontSize: 16),
          ),
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
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
            children: [
              const Text(
                'Requests',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Organizations interested in your food posts.',
                style: TextStyle(fontSize: 14.5, color: bodyColor),
              ),
              const SizedBox(height: 18),

              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (snapshot.hasError)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 46,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'No requests yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'When organizations request your food posts, they will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: bodyColor,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final requestId = doc.id;
                  final organizationName =
                      (data['organizationName'] ?? 'Organization').toString();
                  final foodName = (data['foodName'] ?? 'Food Item').toString();
                  final quantity = (data['quantity'] ?? '').toString();
                  final location = (data['location'] ?? '').toString();
                  final status = (data['status'] ?? 'pending').toString();
                  final pickupStatus =
                      (data['pickupStatus'] ?? 'pending').toString();
                  final organizationId =
                      (data['organizationId'] ?? '').toString();
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
                      primaryText: isPending ? 'Accept' : 'View',
                      secondaryText: isPending ? 'Decline' : 'Close',
                      onPrimaryTap: () async {
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
                      onSecondaryTap: () async {
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
                }),
            ],
          );
        },
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return const _SimpleTabWrapper(
      title: 'History',
      subtitle: 'Completed pickups and donation records will appear here.',
      icon: Icons.history_rounded,
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

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

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);

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
            Icon(icon, size: 34, color: titleColor),
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

class _ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ActivityTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2E7D32);
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE7EFE7),
            child: Icon(
              Icons.check,
              color: primary.withOpacity(0.95),
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

class _RequestCard extends StatelessWidget {
  final String ngoName;
  final String details;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final String primaryText;
  final String secondaryText;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;

  const _RequestCard({
    super.key,
    required this.ngoName,
    required this.details,
    required this.status,
    this.statusColor = const Color(0xFF9A6700),
    this.statusBg = const Color(0xFFFFF4D8),
    required this.primaryText,
    required this.secondaryText,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2E7D32);
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFE7F6EA),
                child: Icon(Icons.apartment_rounded, color: primary),
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
          const Text(
            'Pickup Request',
            style: TextStyle(fontWeight: FontWeight.w700, color: titleColor),
          ),
          const SizedBox(height: 4),
          Text(
            details,
            style: const TextStyle(
              color: bodyColor,
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onSecondaryTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: titleColor,
                    side: const BorderSide(color: Color(0xFFE3E8E4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: Text(secondaryText),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onPrimaryTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: Text(primaryText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SimpleTabWrapper extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SimpleTabWrapper({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);
    const Color primary = Color(0xFF2E7D32);

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
                  backgroundColor: const Color(0xFFE7F6EA),
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
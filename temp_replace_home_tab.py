from pathlib import Path

path = Path(r'c:\Users\Acer\Desktop\Food App\food_waste_app\lib\screens\auth\donor_dashboard_screen.dart')
text = path.read_text()
start_marker = 'class _DonorHomeTabState extends State<_DonorHomeTab> {'
end_marker = 'class _RequestsTab extends StatelessWidget {'
start = text.index(start_marker)
end = text.index(end_marker)
replacement = '''class _DonorHomeTabState extends State<_DonorHomeTab> {
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
                    color: Colors.black.withOpacity(0.12),
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
                      color: Colors.white.withOpacity(0.18),
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
                          final data = snapshot.data!.data() as Map<String, dynamic>;
                          final rawName = (data['name'] ?? data['fullName'] ?? data['username'])?.toString() ?? '';
                          final fallbackEmail = (data['email'] ?? user?.email ?? '').toString();

                          if (rawName.isNotEmpty) {
                            donorName = rawName;
                            donorSubtitle = 'Verified donor';
                          } else if (fallbackEmail.isNotEmpty) {
                            final username = fallbackEmail.split('@').first;
                            donorName = username.isNotEmpty ? username : 'Donor';
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

                    return Row(
                      children: [
                        Expanded(
                          child: _StatItem(
                            icon: Icons.restaurant_menu_rounded,
                            value: '$totalPosts',
                            label: 'Meals Shared',
                            accent: accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatItem(
                            icon: Icons.autorenew,
                            value: '${totalPosts - completed}',
                            label: 'Active Posts',
                            accent: const Color(0xFF4CAF50),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatItem(
                            icon: Icons.check_circle_rounded,
                            value: '$completed',
                            label: 'Completed',
                            accent: const Color(0xFF1B5E20),
                          ),
                        ),
                      ],
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                    color: Colors.black.withOpacity(0.06),
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
'''
path.write_text(text[:start] + replacement + text[end:])

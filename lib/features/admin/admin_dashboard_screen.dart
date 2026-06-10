import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_waste_app/features/auth/auth_gate.dart';
import 'package:food_waste_app/features/auth/sign_in_screen.dart';
import 'package:food_waste_app/features/admin/admin_all_users_screen.dart';
import 'package:food_waste_app/features/admin/admin_manage_donations_screen.dart';
import 'admin_requests_screen.dart' as requests_screen;
import 'admin_pickups_screen.dart' as pickups_screen;

const String kUsersCollection = 'users';
const String kRequestsCollection = 'pickup_requests';
const String kDonationsCollection = 'food_posts'; // proyojon hole change koro
const String kPickupsCollection = 'pickup_requests';




class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  // ── UI state ────────────────────────────────────────────────────────────────
  bool _showActivity = true;
  bool _showNotifications = true;
  String _insightPeriod = 'weekly'; // 'weekly' | 'monthly'
  int _selectedNav = 0;
  late AnimationController _greetingAnim;
  late Animation<double> _greetingFade;

  // ── Real data bound by StreamBuilder ───────────────────────────
  int totalUsers = 0;
  int totalDonations = 0;
  int totalRequests = 0;
  int totalPickups = 0;
  int totalOrgs = 0;
  int newUsersThisWeek = 0;
  int newDonationsThisWeek = 0;
  int newUsersThisMonth = 0;
  int newDonationsThisMonth = 0;

  List<Map<String, dynamic>> recentActivity = [];

  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'System alert',
      'subtitle': 'Notifications module pending integration',
      'time': 'Just now',
      'isRead': false,
    },
  ];


  bool _isLoadingUser = true;
  String? errorMessage;
  Map<String, dynamic>? _userData;

  Future<void> _fetchUser() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SignInScreen()),
          );
        });
        return;
      }
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (!doc.exists) {
        setState(() {
          errorMessage = 'User profile not found in database.';
          _isLoadingUser = false;
        });
        return;
      }
      setState(() {
        _userData = doc.data();
        _isLoadingUser = false;
        errorMessage = null;
      });
    } catch (e) {
      print('Admin fetch error: $e');
      setState(() {
        errorMessage = e.toString();
        _isLoadingUser = false;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    _fetchUser();
    _greetingAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _greetingFade = CurvedAnimation(
      parent: _greetingAnim,
      curve: Curves.easeOut,
    );
    _greetingAnim.forward();
  }

  @override
  void dispose() {
    _greetingAnim.dispose();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  int get _weeklyUsers => newUsersThisWeek;
  int get _monthlyUsers => newUsersThisMonth;
  int get _weeklyDonations => newDonationsThisWeek;
  int get _monthlyDonations => newDonationsThisMonth;


bool _isThisWeek(dynamic value) {
  DateTime? dateTime;
  if (value is Timestamp) dateTime = value.toDate();
  if (value is DateTime) dateTime = value;
  if (dateTime == null) return false;

  final now = DateTime.now();
  final start = DateTime(
    now.subtract(Duration(days: now.weekday - 1)).year,
    now.subtract(Duration(days: now.weekday - 1)).month,
    now.subtract(Duration(days: now.weekday - 1)).day,
  );

  return dateTime.isAfter(start) || dateTime.isAtSameMomentAs(start);
}
  bool _isThisMonth(dynamic timestamp) {
    if (timestamp == null) return false;
    DateTime? date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is String) {
      date = DateTime.tryParse(timestamp);
    }
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

String _normalizeRole(dynamic value) {
  return value?.toString().toLowerCase().trim() ?? '';
}
String _normalize(dynamic value) {
  return value?.toString().toLowerCase().trim() ?? '';
}

  // ── BUILD ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (errorMessage != null || _userData == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                errorMessage ?? 'User data not found.',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchUser,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final data = _userData!;
    final role = data['role']?.toString().toLowerCase();

    if (role != 'admin') {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Access Denied', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('You do not have admin privileges.'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                  );
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, usersSnap) {
            if (usersSnap.hasError) return _ErrorState(message: usersSnap.error.toString());
            if (!usersSnap.hasData) return const Center(child: CircularProgressIndicator());

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('pickup_requests').snapshots(),
              builder: (context, requestsSnap) {
                if (requestsSnap.hasError) return _ErrorState(message: requestsSnap.error.toString());
                if (!requestsSnap.hasData) return const Center(child: CircularProgressIndicator());

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('food_posts').snapshots(),
                  builder: (context, donationsSnap) {
                    if (donationsSnap.hasError) return _ErrorState(message: donationsSnap.error.toString());
                    if (!donationsSnap.hasData) return const Center(child: CircularProgressIndicator());

                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance.collection('pickup_requests').snapshots(),
                      builder: (context, pickupsSnap) {
                        if (pickupsSnap.hasError) return _ErrorState(message: pickupsSnap.error.toString());
                        if (!pickupsSnap.hasData) return const Center(child: CircularProgressIndicator());

                        final usersDocs = usersSnap.data!.docs;
                        final requestDocs = requestsSnap.data!.docs;
                        final donationDocs = donationsSnap.data!.docs;
                        final pickupDocs = pickupsSnap.data!.docs;

                        final organizationDocs = usersDocs.where((doc) {
                          final r = _normalizeRole(doc.data()['role']);
                          return r == 'organization' || r == 'ngo' || r == 'org';
                        }).toList();

                        final openRequestDocs = requestDocs.where((doc) {
                          final status = _normalize(doc.data()['status']);
                          return status == 'pending' || status == 'open' || status == 'requested';
                        }).toList();

                        final completedPickupDocs = pickupDocs.where((doc) {
                          final status = _normalize(doc.data()['status']);
                          return status == 'completed';
                        }).toList();

                        totalUsers = usersDocs.length;
                        totalDonations = donationDocs.length;
                        totalRequests = openRequestDocs.length;
                        totalPickups = completedPickupDocs.length;
                        totalOrgs = organizationDocs.length;
                        
                        newUsersThisWeek = usersDocs.where((d) => _isThisWeek(d.data()['createdAt'])).length;
                        newDonationsThisWeek = donationDocs.where((d) => _isThisWeek(d.data()['createdAt'])).length;
                        
                        newUsersThisMonth = usersDocs.where((d) => _isThisMonth(d.data()['createdAt'])).length;
                        newDonationsThisMonth = donationDocs.where((d) => _isThisMonth(d.data()['createdAt'])).length;

                        recentActivity = [];

                        return Column(
                          children: [
                            _buildTopBar(),
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.only(bottom: 32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildHeroBanner(),
                                    const SizedBox(height: 20),
                                    _buildStatRow(),
                                    const SizedBox(height: 24),
                                    _buildInsightsSection(),
                                    const SizedBox(height: 24),
                                    _buildSectionWithToggle(
                                      title: 'Recent Activity',
                                      subtitle: 'Live platform events',
                                      isVisible: _showActivity,
                                      onToggle: () => setState(() => _showActivity = !_showActivity),
                                      child: _buildActivityList(),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildSectionWithToggle(
                                      title: 'Notifications',
                                      subtitle: 'Admin alerts',
                                      isVisible: _showNotifications,
                                      onToggle: () => setState(() => _showNotifications = !_showNotifications),
                                      child: _buildNotificationList(),
                                      badge: notifications.where((n) => !(n['isRead'] as bool)).length,
                                    ),
                                    const SizedBox(height: 24),
                                    _buildQuickActions(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ── TOP BAR ──────────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => Scaffold.of(ctx).openDrawer(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.menu_rounded, color: Color(0xFF1A1F36), size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Admin Dashboard',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1F36),
              ),
            ),
          ),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications_outlined, color: Color(0xFF1A1F36), size: 20),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF00897B), Color(0xFF00695C)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.admin_panel_settings_outlined, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  // ── HERO BANNER ──────────────────────────────────────────────────────────────
  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF004D40), Color(0xFF00796B), Color(0xFF00897B)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00796B).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            top: -15,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -25,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          FadeTransition(
            opacity: _greetingFade,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_outlined, color: Colors.white70, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        'SYSTEM ADMIN PANEL',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${_greeting()}, Admin',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Monitor donors, NGOs and food donations\nfrom your real-time control center.',
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _BannerStat(value: totalUsers.toString(), label: 'Users'),
                    _dividerLine(),
                    _BannerStat(value: totalDonations.toString(), label: 'Donations'),
                    _dividerLine(),
                    _BannerStat(value: totalRequests.toString(), label: 'Requests'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dividerLine() => Container(
        width: 1,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.white24,
      );

  // ── STAT ROW ─────────────────────────────────────────────────────────────────
  Widget _buildStatRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.people_outline,
              label: 'Total Users',
              value: totalUsers.toString(),
              sub: 'Admins: 1',
              iconColor: const Color(0xFF7B1FA2),
              iconBg: const Color(0xFFF3E5F5),
              topColor: const Color(0xFF7B1FA2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: Icons.lunch_dining_outlined,
              label: 'Donations',
              value: totalDonations.toString(),
              sub: '+$newDonationsThisWeek this week',
              iconColor: const Color(0xFF2E7D32),
              iconBg: const Color(0xFFE8F5E9),
              topColor: const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: Icons.inbox_outlined,
              label: 'Requests',
              value: totalRequests.toString(),
              sub: 'Live requests',
              iconColor: const Color(0xFFE65100),
              iconBg: const Color(0xFFFFF3E0),
              topColor: const Color(0xFFE65100),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: Icons.local_shipping_outlined,
              label: 'Pickups',
              value: totalPickups.toString(),
              sub: 'Monitoring',
              iconColor: const Color(0xFF0288D1),
              iconBg: const Color(0xFFE3F2FD),
              topColor: const Color(0xFF0288D1),
            ),
          ),
        ],
      ),
    );
  }

  // ── INSIGHTS SECTION ─────────────────────────────────────────────────────────
  Widget _buildInsightsSection() {
    final isWeekly = _insightPeriod == 'weekly';
    final users = isWeekly ? _weeklyUsers : _monthlyUsers;
    final donations = isWeekly ? _weeklyDonations : _monthlyDonations;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Platform Insights',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1F36),
                    ),
                  ),
                  Text(
                    'How the platform is performing',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _PeriodChip(
                      label: 'Weekly',
                      selected: isWeekly,
                      onTap: () => setState(() => _insightPeriod = 'weekly'),
                    ),
                    _PeriodChip(
                      label: 'Monthly',
                      selected: !isWeekly,
                      onTap: () => setState(() => _insightPeriod = 'monthly'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InsightCard(
                  icon: Icons.person_add_outlined,
                  label: 'New Users',
                  value: '+$users',
                  period: isWeekly ? 'this week' : 'this month',
                  color: const Color(0xFF7B1FA2),
                  bg: const Color(0xFFF3E5F5),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InsightCard(
                  icon: Icons.corporate_fare_outlined,
                  label: 'New NGOs',
                  value: '+${isWeekly ? 1 : 3}',
                  period: isWeekly ? 'this week' : 'this month',
                  color: const Color(0xFF0288D1),
                  bg: const Color(0xFFE3F2FD),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InsightCard(
                  icon: Icons.volunteer_activism_outlined,
                  label: 'Donations',
                  value: '+$donations',
                  period: isWeekly ? 'this week' : 'this month',
                  color: const Color(0xFF2E7D32),
                  bg: const Color(0xFFE8F5E9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Color(0xFFFF8F00), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isWeekly ? 'Weekly Summary' : 'Monthly Summary',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1F36),
                        ),
                      ),
                      Text(
                        isWeekly
                            ? '$newDonationsThisWeek new food posts, $newUsersThisWeek new users joined this week.'
                            : '$newDonationsThisMonth new food posts, $newUsersThisMonth new users joined this month.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SECTION WITH TOGGLE ───────────────────────────────────────────────────────
  Widget _buildSectionWithToggle({
    required String title,
    required String subtitle,
    required bool isVisible,
    required VoidCallback onToggle,
    required Widget child,
    int badge = 0,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1F36),
                        ),
                      ),
                      if (badge > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badge.toString(),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isVisible ? 'Hide' : 'Show',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isVisible) ...[
            const SizedBox(height: 12),
            child,
          ],
        ],
      ),
    );
  }

  // ── ACTIVITY LIST ─────────────────────────────────────────────────────────────
  Widget _buildActivityList() {
    if (recentActivity.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No recent activity',
            style: GoogleFonts.poppins(color: const Color(0xFF6B7280)),
          ),
        ),
      );
    }
    return Column(
      children: recentActivity
          .map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: item['bg'] as Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: item['color'] as Color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1F36),
                          ),
                        ),
                        Text(
                          item['subtitle'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    item['time'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // ── NOTIFICATION LIST ─────────────────────────────────────────────────────────
  Widget _buildNotificationList() {
    return Column(
      children: notifications
          .map(
            (n) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: (n['isRead'] as bool) ? Colors.white : const Color(0xFFF0FFF4),
                borderRadius: BorderRadius.circular(14),
                border: (n['isRead'] as bool)
                    ? null
                    : Border.all(color: const Color(0xFF2E7D32).withOpacity(0.2), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: (n['isRead'] as bool) ? const Color(0xFFF4F6FA) : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: (n['isRead'] as bool) ? const Color(0xFF9CA3AF) : const Color(0xFF2E7D32),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1F36),
                          ),
                        ),
                        Text(
                          n['subtitle'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        n['time'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                      if (!(n['isRead'] as bool))
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // ── QUICK ACTIONS ─────────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.manage_accounts_outlined,
        'label': 'Manage\nUsers',
        'color': Color(0xFF7B1FA2),
        'bg': Color(0xFFF3E5F5),
        'nav': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAllUsersScreen())),
      },
      {
        'icon': Icons.lunch_dining_outlined,
        'label': 'Manage\nDonations',
        'color': Color(0xFF2E7D32),
        'bg': Color(0xFFE8F5E9),
        'nav': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminManageDonationsScreen())),
      },
      {
        'icon': Icons.inbox_outlined,
        'label': 'View\nRequests',
        'color': Color(0xFFE65100),
        'bg': Color(0xFFFFF3E0),
        'nav': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const requests_screen.AdminRequestsScreen())),
      },
      {
        'icon': Icons.local_shipping_outlined,
        'label': 'Pickups',
        'color': Color(0xFF0288D1),
        'bg': Color(0xFFE3F2FD),
        'nav': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const pickups_screen.AdminPickupsScreen())),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1F36),
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
            children: actions
                .map(
                  (a) => GestureDetector(
                    onTap: a['nav'] as VoidCallback,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: a['bg'] as Color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(a['icon'] as IconData, color: a['color'] as Color, size: 20),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            a['label'] as String,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1F36),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── DRAWER ────────────────────────────────────────────────────────────────────
  Widget _buildDrawer() {
    final items = [
      {'icon': Icons.dashboard_outlined, 'label': 'Dashboard', 'nav': () {}},
      {'icon': Icons.people_outline, 'label': 'Manage Users', 'nav': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAllUsersScreen()))},
      {'icon': Icons.corporate_fare_outlined, 'label': 'Organizations', 'nav': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAllUsersScreen(roleFilter: 'organization')))},
      {'icon': Icons.inbox_outlined, 'label': 'Requests', 'nav': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const requests_screen.AdminRequestsScreen()))},
      {'icon': Icons.lunch_dining_outlined, 'label': 'Donations', 'nav': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminManageDonationsScreen()))},
      {'icon': Icons.local_shipping_outlined, 'label': 'Pickups', 'nav': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const pickups_screen.AdminPickupsScreen()))},
    ];

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF004D40), Color(0xFF00897B)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.admin_panel_settings_outlined, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Admin Panel',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'FoodShare Platform',
                    style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final selected = _selectedNav == i;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedNav = i);
                      if (i != 0) {
                        Navigator.pop(context);
                        final nav = items[i]['nav'] as VoidCallback;
                        nav();
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFFE8F5E9) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            items[i]['icon'] as IconData,
                            color: selected ? const Color(0xFF2E7D32) : const Color(0xFF6B7280),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            items[i]['label'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              color: selected ? const Color(0xFF1B5E20) : const Color(0xFF1A1F36),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.logout_rounded, color: Color(0xFFE53935), size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE53935),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── SMALL REUSABLE WIDGETS ────────────────────────────────────────────────────

class _BannerStat extends StatelessWidget {
  final String value;
  final String label;
  const _BannerStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
        Text(label, style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11)),
      ],
    );
  }
}



class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String period;
  final Color color;
  final Color bg;

  const _InsightCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.period,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 10),
          Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF1A1F36))),
          Text(period, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2E7D32) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
class AdminUsersScreen extends StatelessWidget {
  final String? roleFilter;
  const AdminUsersScreen({super.key, this.roleFilter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          roleFilter == null
              ? "All Users"
              : roleFilter == 'donor'
                  ? "All Donors"
                  : "Organizations",
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(kUsersCollection)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) return _ErrorState(message: snap.error.toString());
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
              snap.data!.docs;

          if (roleFilter != null) {
            docs = docs.where((doc) {
              final role = _normalizeRole(doc.data()['role']);
              if (roleFilter == 'organization') {
                return role == 'organization' ||
                    role == 'ngo' ||
                    role == 'org';
              }
              return role == roleFilter;
            }).toList();
          }

          if (docs.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE8F5EE),
                    child: const Icon(Icons.person, color: Color(0xFF16A34A)),
                  ),
                  title: Text(_userDisplayName(data)),
                  subtitle: Text(
                    "${data['email'] ?? 'No email'}\nRole: ${data['role'] ?? 'N/A'}",
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserDetailsScreen(
                          userId: doc.id,
                          data: data,
                        ),
                      ),
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

class AdminRequestsScreen extends StatelessWidget {
  const AdminRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Requests")),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(kRequestsCollection)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) return _ErrorState(message: snap.error.toString());
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = [...snap.data!.docs];
          docs.sort((a, b) => _timestampToMillis(b.data()['createdAt'])
              .compareTo(_timestampToMillis(a.data()['createdAt'])));

          if (docs.isEmpty) {
            return const Center(child: Text("No requests found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFFEF2F2),
                    child: const Icon(Icons.assignment, color: Color(0xFFEF4444)),
                  ),
                  title: Text(
                    (data['foodTitle'] ??
                            data['title'] ??
                            data['donationTitle'] ??
                            'Untitled Request')
                        .toString(),
                  ),
                  subtitle: Text(
                    "NGO: ${data['ngoName'] ?? data['organizationName'] ?? 'Unknown'}\nStatus: ${data['status'] ?? 'N/A'}",
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RequestDetailsScreen(
                          requestId: doc.id,
                          data: data,
                        ),
                      ),
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

class AdminDonationsScreen extends StatelessWidget {
  const AdminDonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Donations")),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(kDonationsCollection)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) return _ErrorState(message: snap.error.toString());
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = [...snap.data!.docs];
          docs.sort((a, b) => _timestampToMillis(b.data()['createdAt'])
              .compareTo(_timestampToMillis(a.data()['createdAt'])));

          if (docs.isEmpty) {
            return const Center(child: Text("No donations found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE8F5EE),
                    child: const Icon(Icons.fastfood, color: Color(0xFF16A34A)),
                  ),
                  title: Text(
                    (data['foodTitle'] ??
                            data['title'] ??
                            data['foodName'] ??
                            'Untitled Donation')
                        .toString(),
                  ),
                  subtitle: Text(
                    "Donor: ${data['donorName'] ?? data['userName'] ?? data['name'] ?? 'Unknown'}\nStatus: ${data['status'] ?? 'N/A'}",
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DonationDetailsScreen(
                          donationId: doc.id,
                          data: data,
                        ),
                      ),
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

class AdminPickupsScreen extends StatelessWidget {
  final String? statusFilter;
  const AdminPickupsScreen({super.key, this.statusFilter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          statusFilter == null ? "All Pickups" : "Completed Pickups",
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(kPickupsCollection)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) return _ErrorState(message: snap.error.toString());
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snap.data!.docs;

          if (statusFilter != null) {
            docs = docs.where((doc) {
              return _normalize(doc.data()['status']) == statusFilter;
            }).toList();
          }

          if (docs.isEmpty) {
            return const Center(child: Text("No pickups found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFFAF5FF),
                    child: const Icon(Icons.local_shipping,
                        color: Color(0xFFA855F7)),
                  ),
                  title: Text(
                    (data['foodTitle'] ??
                            data['title'] ??
                            data['pickupTitle'] ??
                            'Pickup')
                        .toString(),
                  ),
                  subtitle: Text(
                    "Status: ${data['status'] ?? 'N/A'}\nNGO: ${data['ngoName'] ?? data['organizationName'] ?? 'Unknown'}",
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PickupDetailsScreen(
                          pickupId: doc.id,
                          data: data,
                        ),
                      ),
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

class UserDetailsScreen extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> data;

  const UserDetailsScreen({
    super.key,
    required this.userId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Details")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DetailsCard(
            title: "Basic Information",
            children: [
              _detailRow("Name", _userDisplayName(data)),
              _detailRow("Email", data['email'] ?? 'N/A'),
              _detailRow("Phone", data['phone'] ?? 'N/A'),
              _detailRow("Role", data['role'] ?? 'N/A'),
              _detailRow("Address", data['address'] ?? 'N/A'),
              _detailRow("Created", _dateText(data['createdAt'])),
              _detailRow("User ID", userId),
            ],
          ),
        ],
      ),
    );
  }
}

class RequestDetailsScreen extends StatelessWidget {
  final String requestId;
  final Map<String, dynamic> data;

  const RequestDetailsScreen({
    super.key,
    required this.requestId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Request Details")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DetailsCard(
            title: "Request Information",
            children: [
              _detailRow(
                "Food Title",
                data['foodTitle'] ?? data['title'] ?? data['donationTitle'] ?? 'N/A',
              ),
              _detailRow(
                "NGO Name",
                data['ngoName'] ?? data['organizationName'] ?? 'N/A',
              ),
              _detailRow("NGO Email", data['ngoEmail'] ?? data['email'] ?? 'N/A'),
              _detailRow("NGO Phone", data['ngoPhone'] ?? data['phone'] ?? 'N/A'),
              _detailRow("Pickup Note", data['pickupNote'] ?? 'N/A'),
              _detailRow("Status", data['status'] ?? 'N/A'),
              _detailRow("Request Time", _dateText(data['createdAt'])),
              _detailRow("Request ID", requestId),
            ],
          ),
        ],
      ),
    );
  }
}

class DonationDetailsScreen extends StatelessWidget {
  final String donationId;
  final Map<String, dynamic> data;

  const DonationDetailsScreen({
    super.key,
    required this.donationId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Donation Details")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DetailsCard(
            title: "Donation Information",
            children: [
              _detailRow(
                "Food Title",
                data['foodTitle'] ?? data['title'] ?? data['foodName'] ?? 'N/A',
              ),
              _detailRow(
                "Description",
                data['description'] ?? data['foodDescription'] ?? 'N/A',
              ),
              _detailRow("Quantity", data['quantity'] ?? 'N/A'),
              _detailRow("Location", data['location'] ?? data['address'] ?? 'N/A'),
              _detailRow(
                "Donor Name",
                data['donorName'] ?? data['userName'] ?? data['name'] ?? 'N/A',
              ),
              _detailRow("Donor Email", data['donorEmail'] ?? data['email'] ?? 'N/A'),
              _detailRow("Status", data['status'] ?? 'N/A'),
              _detailRow("Created", _dateText(data['createdAt'])),
              _detailRow("Donation ID", donationId),
            ],
          ),
        ],
      ),
    );
  }
}

class PickupDetailsScreen extends StatelessWidget {
  final String pickupId;
  final Map<String, dynamic> data;

  const PickupDetailsScreen({
    super.key,
    required this.pickupId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pickup Details")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DetailsCard(
            title: "Pickup Information",
            children: [
              _detailRow("Food Title", data['foodTitle'] ?? data['title'] ?? 'N/A'),
              _detailRow(
                "NGO Name",
                data['ngoName'] ?? data['organizationName'] ?? 'N/A',
              ),
              _detailRow("Donor Name", data['donorName'] ?? 'N/A'),
              _detailRow(
                "Pickup Time",
                _dateText(data['pickupTime'] ?? data['createdAt']),
              ),
              _detailRow("Status", data['status'] ?? 'N/A'),
              _detailRow("Pickup Note", data['pickupNote'] ?? 'N/A'),
              _detailRow("Pickup ID", pickupId),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactHero extends StatelessWidget {
  final int totalUsers;
  final int totalDonations;
  final int totalRequests;

  const _CompactHero({
    required this.totalUsers,
    required this.totalDonations,
    required this.totalRequests,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    String greet = "Good Evening";
    if (hour >= 5 && hour < 12) greet = "Good Morning";
    if (hour >= 12 && hour < 18) greet = "Good Afternoon";
    if (hour >= 18 && hour < 24) greet = "Good Evening";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF0F766E), Color(0xFF16A34A)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_outlined, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  "SYSTEM ADMIN PANEL",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "Welcome back, Admin",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            greet,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "Monitor donors, organizations and food donations from a clean, real-time dashboard.",
            style: TextStyle(
              fontSize: 15.5,
              color: Colors.white,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MiniStatusCard(
                  label: "Users",
                  value: totalUsers.toString(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStatusCard(
                  label: "Donations",
                  value: totalDonations.toString(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStatusCard(
                  label: "Requests",
                  value: totalRequests.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStatusCard extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStatusCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}



class _WeeklySummaryCard extends StatelessWidget {
  final int weeklyUsers;
  final int weeklyDonations;
  final int weeklyRequests;
  final int weeklyCompleted;

  const _WeeklySummaryCard({
    required this.weeklyUsers,
    required this.weeklyDonations,
    required this.weeklyRequests,
    required this.weeklyCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                "WEEKLY SUMMARY",
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            "How your platform is performing",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "$weeklyDonations new food posts in the last 7 days and $weeklyCompleted pickups have been completed so far.",
            style: const TextStyle(
              fontSize: 15.5,
              height: 1.45,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          _summaryLine("In the last 7 days, $weeklyUsers new users joined."),
          _summaryLine("So far, $weeklyDonations donation posts were shared."),
          _summaryLine("$weeklyRequests new requests were created this week."),
          _summaryLine("$weeklyCompleted pickups were completed successfully."),
        ],
      ),
    );
  }

  Widget _summaryLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("•  ", style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivitiesCard extends StatelessWidget {
  final List<_RecentActivityItem> activities;

  const _RecentActivitiesCard({
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Real-time logs of donations, requests, pickups and user activity",
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 12),
          if (activities.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text("No recent activity yet."),
            )
          else
            ...activities.map((item) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: item.color.withValues(alpha: 0.12),
                  child: Icon(item.icon, color: item.color),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(item.subtitle),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: item.onTap == null ? null : () => item.onTap!(context),
              );
            }),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xFF111827),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailsCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

Widget _detailRow(String label, dynamic value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            "$label:",
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: Text(value?.toString() ?? 'N/A'),
        ),
      ],
    ),
  );
}

class _AdminDrawer extends StatelessWidget {
  const _AdminDrawer();

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0F766E);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: primary),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    "Admin Panel",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(
            context,
            Icons.dashboard_rounded,
            "Dashboard",
            () => Navigator.pop(context),
          ),
          _drawerItem(
            context,
            Icons.people_alt_rounded,
            "Manage Users",
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
              );
            },
          ),
          _drawerItem(
            context,
            Icons.apartment_rounded,
            "Organizations",
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const AdminUsersScreen(roleFilter: 'organization'),
                ),
              );
            },
          ),
          _drawerItem(
            context,
            Icons.receipt_long_rounded,
            "Requests",
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminRequestsScreen()),
              );
            },
          ),
          _drawerItem(
            context,
            Icons.fastfood_rounded,
            "Donations",
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminDonationsScreen()),
              );
            },
          ),
          _drawerItem(
            context,
            Icons.local_shipping_rounded,
            "Pickups",
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminPickupsScreen()),
              );
            },
          ),
          const Spacer(),
          const Divider(height: 1),
          _drawerItem(
            context,
            Icons.logout_rounded,
            "Logout",
            () => _logout(context),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}



class _RecentActivityItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final void Function(BuildContext context)? onTap;

  _RecentActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });
}

List<_RecentActivityItem> _buildRecentActivities({
  required List<QueryDocumentSnapshot<Map<String, dynamic>>> usersDocs,
  required List<QueryDocumentSnapshot<Map<String, dynamic>>> requestDocs,
  required List<QueryDocumentSnapshot<Map<String, dynamic>>> donationDocs,
  required List<QueryDocumentSnapshot<Map<String, dynamic>>> pickupDocs,
}) {
  final items = <Map<String, dynamic>>[];

  for (final doc in usersDocs) {
    items.add({
      'type': 'user',
      'time': _timestampToMillis(doc.data()['createdAt']),
      'docId': doc.id,
      'data': doc.data(),
    });
  }
  for (final doc in requestDocs) {
    items.add({
      'type': 'request',
      'time': _timestampToMillis(doc.data()['createdAt']),
      'docId': doc.id,
      'data': doc.data(),
    });
  }
  for (final doc in donationDocs) {
    items.add({
      'type': 'donation',
      'time': _timestampToMillis(doc.data()['createdAt']),
      'docId': doc.id,
      'data': doc.data(),
    });
  }
  for (final doc in pickupDocs) {
    items.add({
      'type': 'pickup',
      'time': _timestampToMillis(doc.data()['createdAt']),
      'docId': doc.id,
      'data': doc.data(),
    });
  }

  items.sort((a, b) => (b['time'] as int).compareTo(a['time'] as int));

  return items.take(6).map((item) {
    final type = item['type'] as String;
    final docId = item['docId'] as String;
    final data = item['data'] as Map<String, dynamic>;

    if (type == 'user') {
      final role = _normalizeRole(data['role']);
      final name = _userDisplayName(data);
      final isOrg = role == 'organization' || role == 'ngo' || role == 'org';

      return _RecentActivityItem(
        title: isOrg ? "New organization registered" : "New donor registered",
        subtitle:
            isOrg ? "$name joined as an organization" : "$name joined as a donor",
        icon: isOrg ? Icons.apartment_rounded : Icons.person_add_alt_1_rounded,
        color: isOrg ? const Color(0xFFF59E0B) : const Color(0xFF16A34A),
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserDetailsScreen(userId: docId, data: data),
            ),
          );
        },
      );
    }

    if (type == 'request') {
      return _RecentActivityItem(
        title: "Request updated",
        subtitle:
            "${data['ngoName'] ?? data['organizationName'] ?? 'Organization'} request is ${data['status'] ?? 'N/A'}",
        icon: Icons.assignment_rounded,
        color: const Color(0xFF4F46E5),
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RequestDetailsScreen(
                requestId: docId,
                data: data,
              ),
            ),
          );
        },
      );
    }

    if (type == 'donation') {
      return _RecentActivityItem(
        title: "New donation added",
        subtitle:
            "${data['foodTitle'] ?? data['title'] ?? data['foodName'] ?? 'Donation'} posted",
        icon: Icons.fastfood_rounded,
        color: const Color(0xFFEF4444),
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DonationDetailsScreen(
                donationId: docId,
                data: data,
              ),
            ),
          );
        },
      );
    }

    return _RecentActivityItem(
      title: "Pickup activity",
      subtitle:
          "${data['foodTitle'] ?? data['title'] ?? 'Pickup'} is ${data['status'] ?? 'N/A'}",
      icon: Icons.local_shipping_rounded,
      color: const Color(0xFFA855F7),
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PickupDetailsScreen(
              pickupId: docId,
              data: data,
            ),
          ),
        );
      },
    );
  }).toList();
}

String _normalize(dynamic value) {
  return value?.toString().toLowerCase().trim() ?? '';
}

String _normalizeRole(dynamic value) {
  return value?.toString().toLowerCase().trim() ?? '';
}

String _userDisplayName(Map<String, dynamic> data) {
  return (data['name'] ??
          data['fullName'] ??
          data['organizationName'] ??
          data['ngoName'] ??
          'Unnamed User')
      .toString();
}

int _timestampToMillis(dynamic value) {
  if (value is Timestamp) return value.millisecondsSinceEpoch;
  if (value is DateTime) return value.millisecondsSinceEpoch;
  return 0;
}

bool _isThisWeek(dynamic value) {
  DateTime? dateTime;
  if (value is Timestamp) dateTime = value.toDate();
  if (value is DateTime) dateTime = value;
  if (dateTime == null) return false;

  final now = DateTime.now();
  final start = DateTime(
    now.subtract(Duration(days: now.weekday - 1)).year,
    now.subtract(Duration(days: now.weekday - 1)).month,
    now.subtract(Duration(days: now.weekday - 1)).day,
  );

  return dateTime.isAfter(start) || dateTime.isAtSameMomentAs(start);
}

String _dateText(dynamic value) {
  if (value is Timestamp) {
    final d = value.toDate();
    return "${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}";
  }
  if (value is DateTime) {
    return "${value.day}/${value.month}/${value.year} ${value.hour}:${value.minute.toString().padLeft(2, '0')}";
  }
  return value?.toString() ?? 'N/A';
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading data\n$message',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}


class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color iconColor;
  final Color iconBg;
  final Color topColor;

  const _StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.iconColor,
    required this.iconBg,
    required this.topColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: topColor.withOpacity(0.18), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1F36),
            ),
          ),
          Text(
            sub,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

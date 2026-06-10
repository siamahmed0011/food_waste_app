import re
import os

filepath = r'c:\Users\Acer\Desktop\Food App\food_waste_app\lib\screens\auth\admin_dashboard_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    text = f.read()

# Extract prefix and suffix
start_idx = text.find('class AdminDashboardScreen extends StatefulWidget {')
end_idx = text.find('class AdminUsersScreen extends StatelessWidget {')

if start_idx == -1 or end_idx == -1:
    print("Could not find delimiters!")
    exit(1)

prefix = text[:start_idx]
suffix = text[end_idx:]

# We need the original _isThisWeek, _normalizeRole, _normalize, _buildRecentActivities functions.
# Let's see if they are in suffix or prefix. Wait, they were inside _AdminDashboardScreenState!
# Let's extract them from the original code.

def extract_method(method_name, original_text):
    start = original_text.find(f'{method_name}(')
    if start == -1: return ""
    # Find start of line
    line_start = original_text.rfind('\n', 0, start)
    
    # Simple brace matching
    brace_count = 0
    in_brace = False
    for i in range(start, len(original_text)):
        if original_text[i] == '{':
            brace_count += 1
            in_brace = True
        elif original_text[i] == '}':
            brace_count -= 1
            if in_brace and brace_count == 0:
                return original_text[line_start:i+1]
    return ""

is_this_week = extract_method('bool _isThisWeek', text)
normalize_role = extract_method('String _normalizeRole', text)
normalize = extract_method('String _normalize', text)
build_recent = extract_method('List<Map<String, dynamic>> _buildRecentActivities', text)
error_state = extract_method('class _ErrorState', text) # Wait, _ErrorState is a class!

# Let's find _ErrorState class manually if it exists before AdminUsersScreen.
error_state_idx = text.find('class _ErrorState extends StatelessWidget {')
if error_state_idx != -1 and error_state_idx < end_idx:
    err_end = text.find('}', text.find('}', text.find('build(BuildContext context) {', error_state_idx)) + 1) + 1
    error_state_code = text[error_state_idx:text.find('class', error_state_idx + 10)]
else:
    error_state_code = """
class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

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
              'Error loading data\\n$message',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
"""

is_this_month = """
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
"""

# The new _fetchUser
fetch_user = """
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
"""

new_class_content = """
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

""" + fetch_user + """

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

""" + is_this_week + is_this_month + normalize_role + normalize + build_recent + """

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

                        recentActivity = _buildRecentActivities(
                          usersDocs: usersDocs,
                          donationDocs: donationDocs,
                          requestDocs: requestDocs,
                          pickupDocs: pickupDocs,
                        );

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
                  'Monitor donors, NGOs and food donations\\nfrom your real-time control center.',
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
        'label': 'Manage\\nUsers',
        'color': Color(0xFF7B1FA2),
        'bg': Color(0xFFF3E5F5),
        'nav': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersScreen())),
      },
      {
        'icon': Icons.lunch_dining_outlined,
        'label': 'Manage\\nDonations',
        'color': Color(0xFF2E7D32),
        'bg': Color(0xFFE8F5E9),
        'nav': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDonationsScreen())),
      },
      {
        'icon': Icons.inbox_outlined,
        'label': 'View\\nRequests',
        'color': Color(0xFFE65100),
        'bg': Color(0xFFFFF3E0),
        'nav': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRequestsScreen())),
      },
      {
        'icon': Icons.local_shipping_outlined,
        'label': 'Pickups',
        'color': Color(0xFF0288D1),
        'bg': Color(0xFFE3F2FD),
        'nav': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPickupsScreen())),
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
      {'icon': Icons.people_outline, 'label': 'Manage Users', 'nav': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersScreen()))},
      {'icon': Icons.corporate_fare_outlined, 'label': 'Organizations', 'nav': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersScreen(roleFilter: 'organization')))},
      {'icon': Icons.inbox_outlined, 'label': 'Requests', 'nav': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRequestsScreen()))},
      {'icon': Icons.lunch_dining_outlined, 'label': 'Donations', 'nav': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDonationsScreen()))},
      {'icon': Icons.local_shipping_outlined, 'label': 'Pickups', 'nav': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPickupsScreen()))},
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color iconColor;
  final Color iconBg;
  final Color topColor;

  const _StatCard({
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
        border: Border(top: BorderSide(color: topColor, width: 3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: topColor)),
          Text(label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF1A1F36))),
          Text(sub, style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF6B7280))),
        ],
      ),
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
"""

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(prefix + error_state_code + new_class_content + suffix)
print("Merge complete!")

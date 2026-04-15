import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFF0F766E);
    final Color bg = const Color(0xFFF6F8FB);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: primary.withValues(alpha: 0.12),
              child: const Icon(Icons.admin_panel_settings_rounded,
                  color: Color(0xFF0F766E)),
            ),
          ),
        ],
      ),
      drawer: _AdminDrawer(primary: primary),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AdminHeader(primary: primary),
            const SizedBox(height: 20),

            /// Stats cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: const [
                _StatCard(
                  title: "Total Users",
                  value: "2",
                  icon: Icons.people_alt_rounded,
                  color: Color(0xFF2563EB),
                ),
                _StatCard(
                  title: "Total Donors",
                  value: "0",
                  icon: Icons.volunteer_activism_rounded,
                  color: Color(0xFF16A34A),
                ),
                _StatCard(
                  title: "Organizations",
                  value: "0",
                  icon: Icons.apartment_rounded,
                  color: Color(0xFFF59E0B),
                ),
                _StatCard(
                  title: "Pending Requests",
                  value: "0",
                  icon: Icons.pending_actions_rounded,
                  color: Color(0xFFDC2626),
                ),
              ],
            ),

            const SizedBox(height: 22),

            /// Quick actions
            const Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ActionButton(
                  label: "Verify Users",
                  icon: Icons.verified_user_rounded,
                  color: primary,
                  onTap: () {},
                ),
                _ActionButton(
                  label: "Manage Reports",
                  icon: Icons.report_gmailerrorred_rounded,
                  color: Colors.red,
                  onTap: () {},
                ),
                _ActionButton(
                  label: "View Donations",
                  icon: Icons.bar_chart_rounded,
                  color: Colors.indigo,
                  onTap: () {},
                ),
                _ActionButton(
                  label: "Send Notice",
                  icon: Icons.campaign_rounded,
                  color: Colors.orange,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 22),

            /// Pending approvals
            const Text(
              "Pending Approvals",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const _PendingApprovalCard(
              name: "Smile Foundation",
              subtitle: "Organization Verification Request",
              time: "10 min ago",
            ),
            const SizedBox(height: 10),
            const _PendingApprovalCard(
              name: "John Doe",
              subtitle: "Donor Account Approval Needed",
              time: "25 min ago",
            ),
            const SizedBox(height: 10),
            const _PendingApprovalCard(
              name: "Food For All",
              subtitle: "New NGO Registration",
              time: "1 hour ago",
            ),

            const SizedBox(height: 22),

            /// Recent activities
            const Text(
              "Recent Activities",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const _ActivityTile(
              title: "New donor registered",
              subtitle: "Rahim Uddin joined as a donor",
              icon: Icons.person_add_alt_1_rounded,
              color: Colors.green,
            ),
            const _ActivityTile(
              title: "Report submitted",
              subtitle: "A user reported suspicious activity",
              icon: Icons.report_problem_rounded,
              color: Colors.red,
            ),
            const _ActivityTile(
              title: "Organization approved",
              subtitle: "Helping Hands was verified by admin",
              icon: Icons.check_circle_rounded,
              color: Colors.blue,
            ),

            const SizedBox(height: 22),

            /// Monitoring summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "System Monitoring",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  _MonitorRow(
                    label: "Active Users Today",
                    value: "326",
                    color: Colors.green,
                  ),
                  _MonitorRow(
                    label: "Flagged Accounts",
                    value: "08",
                    color: Colors.red,
                  ),
                  _MonitorRow(
                    label: "Donation Requests Today",
                    value: "41",
                    color: Colors.blue,
                  ),
                  _MonitorRow(
                    label: "Support Tickets",
                    value: "13",
                    color: Colors.orange,
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

class _AdminHeader extends StatelessWidget {
  final Color primary;
  const _AdminHeader({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            primary,
            primary.withValues(alpha: 0.82),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome, Admin",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Monitor users, manage approvals, and control the whole system from here.",
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.white70,
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _PendingApprovalCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String time;

  const _PendingApprovalCard({
    required this.name,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.orange.withValues(alpha: 0.12),
            child: const Icon(Icons.hourglass_top_rounded, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Review"),
          )
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _ActivityTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _MonitorRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MonitorRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  final Color primary;
  const _AdminDrawer({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: primary),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    "Admin Panel",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
          _drawerItem(Icons.dashboard_rounded, "Dashboard", () {}),
          _drawerItem(Icons.people_alt_rounded, "Manage Users", () {}),
          _drawerItem(Icons.apartment_rounded, "Organizations", () {}),
          _drawerItem(Icons.assignment_turned_in_rounded, "Approvals", () {}),
          _drawerItem(Icons.report_problem_rounded, "Reports", () {}),
          _drawerItem(Icons.analytics_rounded, "Analytics", () {}),
          _drawerItem(Icons.settings_rounded, "Settings", () {}),
          const Spacer(),
          const Divider(),
          _drawerItem(Icons.logout_rounded, "Logout", () {}),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  static Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}
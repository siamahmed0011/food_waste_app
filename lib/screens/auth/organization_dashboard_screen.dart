import 'package:flutter/material.dart';

class OrganizationDashboardScreen extends StatelessWidget {
  const OrganizationDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFEF6C00);
    const primarySoft = Color(0xFFFFF3E0);
    const background = Color(0xFFF4F7F1);
    const titleColor = Color(0xFF12202F);
    const bodyColor = Color(0xFF6B7280);
    const borderColor = Color(0xFFE7ECE8);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: primarySoft,
                    child: Icon(
                      Icons.apartment_rounded,
                      color: primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome back 👋",
                          style: TextStyle(
                            fontSize: 13,
                            color: bodyColor,
                          ),
                        ),
                        Text(
                          "Organization Dashboard",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Stats card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatItem(
                      title: "Available",
                      value: "0",
                    ),
                    _StatItem(
                      title: "Requests",
                      value: "0",
                    ),
                    _StatItem(
                      title: "Collected",
                      value: "0",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.search_rounded,
                      label: "Browse Food",
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.assignment_turned_in_rounded,
                      label: "My Requests",
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "Recent Activity",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: ListView(
                  children: const [
                    _ActivityItem(
                      title: "Pickup confirmed",
                      subtitle: "Restaurant donation confirmed for collection",
                    ),
                    _ActivityItem(
                      title: "New donation nearby",
                      subtitle: "A donor posted 15 meal boxes near your area",
                    ),
                    _ActivityItem(
                      title: "Request submitted",
                      subtitle: "You requested pickup for bakery surplus food",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        onPressed: () {},
        child: const Icon(Icons.search),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;

  const _StatItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE7ECE8);
    const titleColor = Color(0xFF12202F);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, size: 26, color: Colors.deepOrange),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFFFF3E0),
        child: Icon(
          Icons.local_shipping_outlined,
          color: Color(0xFFEF6C00),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF12202F),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }
}
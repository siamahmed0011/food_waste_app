import 'package:flutter/material.dart';

class DonorDashboardScreen extends StatelessWidget {
  const DonorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2E7D32);
    const background = Color(0xFFF4F7F1);
    const titleColor = Color(0xFF12202F);
    const bodyColor = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header
              Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.person, color: primary),
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
                          "Donor Dashboard",
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
                  )
                ],
              ),

              const SizedBox(height: 20),

              // 🔹 Stats Card
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
                      title: "Meals Shared",
                      value: "1",
                    ),
                    _StatItem(
                      title: "Active Posts",
                      value: "0",
                    ),
                    _StatItem(
                      title: "Completed",
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

              // 🔹 Quick Actions
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.add_box_rounded,
                      label: "Post Food",
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.history_rounded,
                      label: "History",
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

              // 🔹 Activity List
              Expanded(
                child: ListView(
                  children: const [
                    _ActivityItem(
                      title: "Food picked up",
                      subtitle: "NGO collected your donation",
                    ),
                    _ActivityItem(
                      title: "Post created",
                      subtitle: "You added 20 meal packs",
                    ),
                    _ActivityItem(
                      title: "Request received",
                      subtitle: "NGO requested pickup",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // 🔹 Floating Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        onPressed: () {},
        child: const Icon(Icons.add),
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
            Icon(icon, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
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
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFE8F5E9),
        child: Icon(Icons.check, color: Color(0xFF2E7D32)),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
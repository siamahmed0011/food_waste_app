import 'package:flutter/material.dart';
import 'main_dashboard.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF4F7F1);
    const primary = Color(0xFF2E7D32);
    const primaryDark = Color(0xFF1B4332);
    const titleColor = Color(0xFF12202F);
    const bodyColor = Color(0xFF6B7280);
    const borderColor = Color(0xFFE7ECE8);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔙 Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Choose Role",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: primaryDark,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 🧠 Title
              const Text(
                "Choose your role",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Choose how you want to use the platform and continue.",
                style: TextStyle(
                  fontSize: 14.2,
                  color: bodyColor,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 24),

              // 🟢 Donor Card
              _RoleCard(
                title: "Donor",
                subtitle:
                    "Share surplus food from restaurants, events or homes.",
                icon: Icons.volunteer_activism_rounded,
                color: primary,
                isSelected: selectedRole == "donor",
                onTap: () {
                  setState(() {
                    selectedRole = "donor";
                  });
                },
              ),

              const SizedBox(height: 16),

              // 🟠 Organization Card
              _RoleCard(
                title: "Organization",
                subtitle:
                    "Receive donations and distribute food to people in need.",
                icon: Icons.apartment_rounded,
                color: Color(0xFFEF6C00),
                isSelected: selectedRole == "organization",
                onTap: () {
                  setState(() {
                    selectedRole = "organization";
                  });
                },
              ),

              const Spacer(),

              // 🚀 Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                 onPressed: selectedRole == null
    ? null
    : () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MainDashboard(role: selectedRole!),
          ),
        );
      },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    disabledBackgroundColor: primary.withOpacity(0.4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Continue",
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
  }
}

// 🔹 Role Card Widget
class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF12202F);
    const bodyColor = Color(0xFF6B7280);
    const borderColor = Color(0xFFE7ECE8);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? color : borderColor,
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? color.withOpacity(0.15)
                  : const Color(0x0A000000),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: bodyColor,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 22),
          ],
        ),
      ),
    );
  }
}
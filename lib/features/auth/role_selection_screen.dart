import 'package:flutter/material.dart';
import 'package:food_waste_app/features/auth/sign_up_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF5F5F5);
    const titleColor = Color(0xFF12202F);
    const bodyColor = Color(0xFF6B7280);
    const primary = Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  size: 28,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Join as',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  height: 1.1,
                ),
              ),
              const Text(
                'Donor or Org?',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: primary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Select your role to get started',
                style: TextStyle(
                  fontSize: 14,
                  color: bodyColor,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _RoleCard(
                      title: 'Donor',
                      subtitle: 'Share food',
                      icon: Icons.volunteer_activism,
                      iconColor: primary,
                      bgColor: const Color(0xFFF1F8E9),
                      tags: const ['🏠', '🍽️', '🎉'],
                      isSelected: selectedRole == 'donor',
                      onTap: () {
                        setState(() {
                          selectedRole = 'donor';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _RoleCard(
                      title: 'Organization',
                      subtitle: 'Receive food',
                      icon: Icons.corporate_fare,
                      iconColor: const Color(0xFF0288D1),
                      bgColor: const Color(0xFFE3F2FD),
                      tags: const ['🏢', '🤝', '🏥'],
                      isSelected: selectedRole == 'organization',
                      onTap: () {
                        setState(() {
                          selectedRole = 'organization';
                        });
                      },
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  gradient: selectedRole == null
                      ? null
                      : LinearGradient(
                          colors: selectedRole == 'donor'
                              ? [const Color(0xFF2E7D32), const Color(0xFF43A047)]
                              : [const Color(0xFF0288D1), const Color(0xFF00BCD4)],
                        ),
                  color: selectedRole == null ? Colors.grey.shade300 : null,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  onPressed: selectedRole == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SignUpScreen(
                                role: selectedRole == 'organization'
                                    ? 'ngo'
                                    : 'donor',
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledForegroundColor: Colors.grey.shade600,
                    disabledBackgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    selectedRole == null ? 'Select a role' : 'Continue',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
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

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final List<String> tags;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.tags,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? bgColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? iconColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: iconColor.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 8),
              )
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 36, color: iconColor),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF12202F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: tags.map((tag) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        tag,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Icon(
                        Icons.check_circle,
                        color: iconColor,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'sign_in_screen.dart';
import 'role_selection_screen.dart';

// =========================
// APP COLORS
// =========================
class _AppColors {
  static const background = Color(0xFFF4F7F1);
  static const surface = Colors.white;
  static const primary = Color(0xFF2E7D32);
  static const primaryDark = Color(0xFF1B4332);
  static const primarySoft = Color(0xFFE8F5E9);
  static const orange = Color(0xFFEF6C00);
  static const orangeSoft = Color(0xFFFFF3E0);
  static const title = Color(0xFF12202F);
  static const body = Color(0xFF6B7280);
  static const border = Color(0xFFE7ECE8);
  static const pink = Color(0xFFE91E63);
}

// =========================
// WELCOME SCREEN START
// =========================
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _TopHeader(),
                    const SizedBox(height: 18),

                    _HeroSection(
                      onSignUp: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RoleSelectionScreen(),
                          ),
                        );
                      },
                      onSignIn: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignInScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    const _SectionTitle(
                      title: "About the platform",
                      subtitle:
                          "Our system connects donors with verified organizations to reduce food waste and ensure that safe surplus food reaches people in need quickly and transparently.",
                    ),
                    const SizedBox(height: 18),

                    const _StepCard(
                      number: "1",
                      title: "Donor posts surplus food",
                      description:
                          "Donors share food details, quantity, location and pickup time from their dashboard.",
                      icon: Icons.inventory_2_outlined,
                    ),
                    const SizedBox(height: 14),
                    const _StepCard(
                      number: "2",
                      title: "NGOs request pickup",
                      description:
                          "Nearby organizations browse posts, send pickup requests and receive confirmation in real time.",
                      icon: Icons.local_shipping_outlined,
                    ),
                    const SizedBox(height: 14),
                    const _StepCard(
                      number: "3",
                      title: "Food is collected & served",
                      description:
                          "Verified organizations collect the food, transport it safely and serve vulnerable people.",
                      icon: Icons.volunteer_activism_outlined,
                    ),

                    const SizedBox(height: 32),

                    const _SectionTitle(
                      title: "Who can join?",
                      subtitle:
                          "Choose your role and start contributing to a cleaner, kinder community.",
                    ),
                    const SizedBox(height: 18),

                    const _JoinCard(
                      title: "For Donors",
                      description:
                          "Restaurants, hotels, caterers, households and event organizers who have safe extra food that would otherwise be wasted.",
                      points: [
                        "Post surplus food in a few clicks",
                        "Set expiry and pickup time",
                        "Track your donation history",
                      ],
                      accentColor: _AppColors.primary,
                      icon: Icons.restaurant_menu_rounded,
                    ),
                    const SizedBox(height: 16),
                    const _JoinCard(
                      title: "For Organizations",
                      description:
                          "NGOs, shelters, orphanages and community kitchens who distribute food to people in need.",
                      points: [
                        "View donations near your location",
                        "Request pickups in real time",
                        "Maintain pickup records",
                      ],
                      accentColor: _AppColors.orange,
                      icon: Icons.apartment_rounded,
                    ),

                    const SizedBox(height: 32),

                    const _SectionTitle(
                      title: "Contact Us",
                      subtitle:
                          "Reach out anytime. We are here to help donors, NGOs and volunteers.",
                    ),
                    const SizedBox(height: 18),

                    const _ContactCard(),

                    const SizedBox(height: 26),

                    _BottomCta(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RoleSelectionScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    const Center(
                      child: Text(
                        "© 2026 Food Waste Reduce Management System",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =========================
// TOP HEADER SECTION
// =========================
class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        children: const [
          CircleAvatar(
            radius: 20,
            backgroundColor: _AppColors.primarySoft,
            child: Icon(
              Icons.eco_rounded,
              color: _AppColors.primary,
              size: 22,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Food Waste Reduce Platform",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: _AppColors.primaryDark,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// HERO SECTION
// =========================
class _HeroSection extends StatelessWidget {
  final VoidCallback onSignUp;
  final VoidCallback onSignIn;

  const _HeroSection({
    required this.onSignUp,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          height: 280,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                "assets/images/Food.jpg",
                fit: BoxFit.cover,
              ),

              // Full image overlay - lighter than before
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.28),
                      Colors.black.withOpacity(0.42),
                      Colors.black.withOpacity(0.52),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.14),
                        ),
                      ),
                      child: const Text(
                        "Trusted flow  •  Simple posting  •  Fast pickup",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.8,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const SizedBox(
                      width: 240,
                      child: Text(
                        "A meal shared is a smile shared",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          height: 1.22,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(
                      width: 285,
                      child: Text(
                        "We connect donors with verified NGOs so safe surplus food reaches people in need quickly and responsibly.",
                        style: TextStyle(
                          color: Color(0xE6FFFFFF),
                          fontSize: 13.2,
                          height: 1.55,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF43A047),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onSignIn,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.white.withOpacity(0.08),
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.65),
                                width: 1.1,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              "Sign In",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
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

// =========================
// COMMON CENTER TITLE SECTION
// =========================
class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _AppColors.title,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14.4,
              height: 1.7,
              color: _AppColors.body,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// STEP CARD SECTION
// =========================
class _StepCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final IconData icon;

  const _StepCard({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: _AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: _AppColors.primary,
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: _AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15.8,
                      fontWeight: FontWeight.w800,
                      color: _AppColors.title,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13.8,
                      height: 1.65,
                      color: _AppColors.body,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// JOIN CARD SECTION
// =========================
class _JoinCard extends StatelessWidget {
  final String title;
  final String description;
  final List<String> points;
  final Color accentColor;
  final IconData icon;

  const _JoinCard({
    required this.title,
    required this.description,
    required this.points,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final softColor = accentColor == _AppColors.orange
        ? _AppColors.orangeSoft
        : _AppColors.primarySoft;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: softColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13.8,
              height: 1.65,
              color: _AppColors.body,
            ),
          ),
          const SizedBox(height: 14),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: accentColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        fontSize: 13.8,
                        height: 1.55,
                        color: _AppColors.body,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// CONTACT CARD SECTION
// =========================
class _ContactCard extends StatelessWidget {
  const _ContactCard();

  Widget _item(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: _AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: _AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Colors.black45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14.2,
                    color: _AppColors.title,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE4EC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: _AppColors.pink,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Contact Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _AppColors.title,
            ),
          ),
          const SizedBox(height: 18),
          _item(
            Icons.email_outlined,
            "Email",
            "info@foodwastereduceproject.com",
          ),
          _item(
            Icons.phone_outlined,
            "Phone",
            "+880 01570267657",
          ),
          _item(
            Icons.location_on_outlined,
            "Address",
            "Mirpur, Dhaka, Bangladesh",
          ),
        ],
      ),
    );
  }
}

// =========================
// BOTTOM CTA SECTION
// =========================
class _BottomCta extends StatelessWidget {
  final VoidCallback onPressed;

  const _BottomCta({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE8F5E9),
            Color(0xFFF4F1DE),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Ready to share a meal?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: _AppColors.title,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Join our Food Waste Platform and help make sure that no safe food ends up in the bin while people are still hungry.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              color: _AppColors.body,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "Get Started",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
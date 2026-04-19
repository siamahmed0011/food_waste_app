import 'package:flutter/material.dart';
import 'role_selection_screen.dart';
import 'sign_in_screen.dart';

enum HomeSection { home, about, howItWorks, contact }

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  HomeSection _selectedSection = HomeSection.home;

  void _changeSection(HomeSection section) {
    Navigator.pop(context);
    setState(() {
      _selectedSection = section;
    });
  }

  String _sectionTitle() {
    switch (_selectedSection) {
      case HomeSection.home:
        return 'Food Waste Reduce Platform';
      case HomeSection.about:
        return 'About Us';
      case HomeSection.howItWorks:
        return 'How It Works';
      case HomeSection.contact:
        return 'Contact';
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF6F7F3);
    const primary = Color(0xFF2E7D32);
    const titleColor = Color(0xFF142233);

    return Scaffold(
      backgroundColor: background,
      drawer: _HomeDrawer(
        selectedSection: _selectedSection,
        onSelectSection: _changeSection,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.menu_rounded,
                          color: titleColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _sectionTitle(),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection() {
    switch (_selectedSection) {
      case HomeSection.home:
        return const _HomeView(key: ValueKey('home'));
      case HomeSection.about:
        return const _AboutView(key: ValueKey('about'));
      case HomeSection.howItWorks:
        return const _HowItWorksView(key: ValueKey('how'));
      case HomeSection.contact:
        return const _ContactView(key: ValueKey('contact'));
    }
  }
}

class _HomeDrawer extends StatelessWidget {
  final HomeSection selectedSection;
  final ValueChanged<HomeSection> onSelectSection;

  const _HomeDrawer({
    required this.selectedSection,
    required this.onSelectSection,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2E7D32);
    const titleColor = Color(0xFF142233);
    const bodyColor = Color(0xFF6B7280);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: primary.withValues(alpha: 0.08)),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.eco_rounded, color: primary),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Food Waste Reduce Platform',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _DrawerTile(
              icon: Icons.home_rounded,
              title: 'Home',
              selected: selectedSection == HomeSection.home,
              onTap: () => onSelectSection(HomeSection.home),
            ),
            _DrawerTile(
              icon: Icons.info_outline_rounded,
              title: 'About Us',
              selected: selectedSection == HomeSection.about,
              onTap: () => onSelectSection(HomeSection.about),
            ),
            _DrawerTile(
              icon: Icons.settings_accessibility_rounded,
              title: 'How It Works',
              selected: selectedSection == HomeSection.howItWorks,
              onTap: () => onSelectSection(HomeSection.howItWorks),
            ),
            _DrawerTile(
              icon: Icons.support_agent_rounded,
              title: 'Contact',
              selected: selectedSection == HomeSection.contact,
              onTap: () => onSelectSection(HomeSection.contact),
            ),
            const Divider(height: 28),
            _DrawerTile(
              icon: Icons.person_add_alt_1_rounded,
              title: 'Sign Up',
              selected: false,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RoleSelectionScreen(),
                  ),
                );
              },
            ),
            _DrawerTile(
              icon: Icons.login_rounded,
              title: 'Sign In',
              selected: false,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                );
              },
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Safe sharing. Fast pickup. Trusted community.',
                textAlign: TextAlign.center,
                style: TextStyle(color: bodyColor, fontSize: 12.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF142233);
    const primary = Color(0xFF2E7D32);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        leading: Icon(icon, color: selected ? primary : titleColor),
        title: Text(
          title,
          style: TextStyle(
            color: selected ? primary : titleColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        tileColor: selected ? primary.withValues(alpha: 0.08) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onTap: onTap,
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2E7D32);
    const titleColor = Color(0xFF142233);
    const bodyColor = Color(0xFF6B7280);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              image: const DecorationImage(
                image: AssetImage('assets/images/Food.jpg'),
                fit: BoxFit.cover,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x16000000),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: const [
                      _Badge(text: 'Trusted flow'),
                      _Badge(text: 'Fast pickup'),
                      _Badge(text: 'Verified NGOs'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'A meal shared is a smile shared',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Connect donors with NGOs to reduce food waste efficiently and responsibly.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RoleSelectionScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignInScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.white70,
                              width: 1.2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Center(
            child: Text(
              'Quick Overview',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'A simple and trusted process for donors and organizations.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.5, color: bodyColor, height: 1.7),
            ),
          ),
          const SizedBox(height: 18),
          const _FeatureCard(
            icon: Icons.fastfood_rounded,
            title: 'Post surplus food',
            desc: 'Share extra food easily from your dashboard.',
          ),
          const SizedBox(height: 14),
                      GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SignInScreen(),
                  ),
                );
              },
              child: const _FeatureCard(
                icon: Icons.local_shipping_rounded,
                title: 'Request pickups',
                desc: 'Organizations can request food instantly.',
              ),
            ),
          const SizedBox(height: 14),
          const _FeatureCard(
            icon: Icons.volunteer_activism_rounded,
            title: 'Serve people',
            desc: 'Food reaches people in need safely.',
          ),
        ],
      ),
    );
  }
}

class _AboutView extends StatelessWidget {
  const _AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF142233);
    const bodyColor = Color(0xFF6B7280);
    const primary = Color(0xFF2E7D32);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        children: [
          const _SectionHeader(
            title: 'About Us',
            subtitle:
                'Food Waste Reduce Platform is built to connect food donors with verified organizations so safe surplus food can reach people in need instead of being wasted.',
          ),
          const SizedBox(height: 18),
          _InfoCard(
            icon: Icons.flag_rounded,
            title: 'Our Mission',
            description:
                'To reduce food waste by creating a reliable bridge between donors and organizations and ensuring safe food reaches vulnerable communities quickly.',
            accent: primary,
          ),
          const SizedBox(height: 14),
          _InfoCard(
            icon: Icons.visibility_rounded,
            title: 'Our Vision',
            description:
                'A community where no safe food is wasted and no hungry person is left behind when support is possible.',
            accent: const Color(0xFF7B61FF),
          ),
          const SizedBox(height: 14),
          _InfoCard(
            icon: Icons.verified_user_rounded,
            title: 'Why Trust Us',
            description:
                'We focus on verified organizations, clear pickup flow, responsible sharing and a simple donation process for both sides.',
            accent: const Color(0xFFEF6C00),
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Who we serve',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'We support restaurants, hotels, event organizers, households, NGOs, shelters, orphanages and community kitchens that want to reduce food waste and serve people with dignity.',
                  style: TextStyle(
                    fontSize: 14.5,
                    color: bodyColor,
                    height: 1.7,
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

class _HowItWorksView extends StatelessWidget {
  const _HowItWorksView({super.key});

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF142233);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        children: [
          const _SectionHeader(
            title: 'How It Works',
            subtitle:
                'A simple step-by-step process helps donors and organizations work together safely and efficiently.',
          ),
          const SizedBox(height: 18),
          const _StepCard(
            number: '1',
            title: 'Donor posts surplus food',
            description:
                'A donor adds food details, quantity, pickup time and location from the app.',
          ),
          const SizedBox(height: 14),
          const _StepCard(
            number: '2',
            title: 'Organizations browse nearby food',
            description:
                'Verified organizations can view available donations and choose suitable pickup opportunities.',
          ),
          const SizedBox(height: 14),
          const _StepCard(
            number: '3',
            title: 'Pickup request is sent',
            description:
                'The organization sends a pickup request so the donor can review and confirm it.',
          ),
          const SizedBox(height: 14),
          const _StepCard(
            number: '4',
            title: 'Food is collected safely',
            description:
                'The organization picks up the food and transports it responsibly.',
          ),
          const SizedBox(height: 14),
          const _StepCard(
            number: '5',
            title: 'Food reaches people in need',
            description:
                'Collected food is distributed to vulnerable people through trusted community support.',
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F7EC),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              children: [
                Text(
                  'Key Benefits',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                SizedBox(height: 12),
                _BulletText(text: 'Reduces safe food waste'),
                _BulletText(text: 'Improves community support'),
                _BulletText(text: 'Creates a transparent donation flow'),
                _BulletText(text: 'Saves time for both donors and NGOs'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactView extends StatelessWidget {
  const _ContactView({super.key});

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF142233);
    const bodyColor = Color(0xFF6B7280);
    const borderColor = Color(0xFFE7ECE8);
    const primary = Color(0xFF2E7D32);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        children: [
          const _SectionHeader(
            title: 'Contact Us',
            subtitle:
                'Reach out anytime. We are here to support donors, NGOs and volunteers.',
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: borderColor),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0B000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: const [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFFFCE4EC),
                  child: Icon(
                    Icons.support_agent_rounded,
                    color: Color(0xFFD81B60),
                    size: 28,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                SizedBox(height: 18),
                _ContactTile(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email',
                  value: 'info@foodwastereduceproject.com',
                ),
                SizedBox(height: 12),
                _ContactTile(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: '+880 01570267657',
                ),
                SizedBox(height: 12),
                _ContactTile(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: 'Mirpur, Dhaka, Bangladesh',
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              children: [
                Text(
                  'Support Hours',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Saturday - Thursday\n9:00 AM - 6:00 PM',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    color: bodyColor,
                    height: 1.7,
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

class _Badge extends StatelessWidget {
  final String text;

  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2E7D32);
    const titleColor = Color(0xFF142233);
    const bodyColor = Color(0xFF6B7280);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 14.2,
                    color: bodyColor,
                    height: 1.6,
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF142233);
    const bodyColor = Color(0xFF6B7280);

    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14.5, color: bodyColor, height: 1.7),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color accent;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF142233);
    const bodyColor = Color(0xFF6B7280);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14.3,
                    color: bodyColor,
                    height: 1.7,
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

class _StepCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _StepCard({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2E7D32);
    const titleColor = Color(0xFF142233);
    const bodyColor = Color(0xFF6B7280);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: primary,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
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
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14.3,
                    color: bodyColor,
                    height: 1.7,
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

class _BulletText extends StatelessWidget {
  final String text;

  const _BulletText({required this.text});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2E7D32);
    const bodyColor = Color(0xFF6B7280);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14.3,
                color: bodyColor,
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF142233);
    const bodyColor = Color(0xFF6B7280);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBF8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7ECE8)),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5EA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF2E7D32)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: bodyColor,
                    fontSize: 13.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: titleColor,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
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

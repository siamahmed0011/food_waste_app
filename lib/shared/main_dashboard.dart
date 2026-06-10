import 'package:flutter/material.dart';

class MainDashboard extends StatefulWidget {
  final String role;

  const MainDashboard({
    super.key,
    required this.role,
  });

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int currentIndex = 0;

  late final List<Widget> screens;

  bool get isDonor => widget.role == "donor";

  @override
  void initState() {
    super.initState();

    screens = [
      _HomeScreen(role: widget.role),
      _BrowseScreen(role: widget.role),
      _AddScreen(role: widget.role),
      _ActivityScreen(role: widget.role),
      _ProfileScreen(role: widget.role),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const donorPrimary = Color(0xFF2E7D32);
    const orgPrimary = Color(0xFFEF6C00);

    final primary = isDonor ? donorPrimary : orgPrimary;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F1),
      body: screens[currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: primary,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            showUnselectedLabels: true,
            elevation: 0,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(isDonor ? Icons.search_rounded : Icons.inventory_2_rounded),
                label: isDonor ? "Browse" : "Posts",
              ),
              BottomNavigationBarItem(
                icon: Icon(isDonor ? Icons.add_box_rounded : Icons.local_shipping_rounded),
                label: isDonor ? "Add" : "Pickup",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_rounded),
                label: "Activity",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  final String role;

  const _HomeScreen({required this.role});

  bool get isDonor => role == "donor";

  @override
  Widget build(BuildContext context) {
    const donorPrimary = Color(0xFF2E7D32);
    const donorPrimarySoft = Color(0xFFE8F5E9);
    const orgPrimary = Color(0xFFEF6C00);
    const orgPrimarySoft = Color(0xFFFFF3E0);
    const background = Color(0xFFF4F7F1);
    const titleColor = Color(0xFF12202F);
    const bodyColor = Color(0xFF6B7280);
    const borderColor = Color(0xFFE7ECE8);

    final primary = isDonor ? donorPrimary : orgPrimary;
    final primarySoft = isDonor ? donorPrimarySoft : orgPrimarySoft;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: primarySoft,
                    child: Icon(
                      isDonor ? Icons.person_rounded : Icons.apartment_rounded,
                      color: primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome back 👋",
                          style: TextStyle(
                            fontSize: 13,
                            color: bodyColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isDonor ? "Donor Dashboard" : "Organization Dashboard",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: titleColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: isDonor
                        ? const [Color(0xFF2E7D32), Color(0xFF43A047)]
                        : const [Color(0xFFEF6C00), Color(0xFFF57C00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDonor
                          ? "You’ve made a real impact"
                          : "Your team is making a difference",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isDonor
                          ? "32 meals rescued this week"
                          : "12 pickups completed this week",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: isDonor
                          ? const [
                              _DashboardStatItem(value: "120", label: "Meals Shared"),
                              _DashboardStatItem(value: "03", label: "Active Posts"),
                              _DashboardStatItem(value: "45", label: "Completed"),
                            ]
                          : const [
                              _DashboardStatItem(value: "12", label: "Available"),
                              _DashboardStatItem(value: "05", label: "Requests"),
                              _DashboardStatItem(value: "31", label: "Collected"),
                            ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),

              const SizedBox(height: 12),

              if (isDonor) ...[
                Row(
                  children: const [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.add_box_rounded,
                        title: "Post Food",
                        subtitle: "Create a new donation",
                        color: donorPrimary,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.history_rounded,
                        title: "History",
                        subtitle: "View past donations",
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.access_time_filled_rounded,
                        title: "Pending",
                        subtitle: "Track requests",
                        color: Color(0xFFEF6C00),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.location_on_rounded,
                        title: "Nearby NGOs",
                        subtitle: "See nearby partners",
                        color: Color(0xFF8E24AA),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: const [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.search_rounded,
                        title: "Browse Food",
                        subtitle: "See available donations",
                        color: orgPrimary,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.assignment_turned_in_rounded,
                        title: "My Requests",
                        subtitle: "Track pickup requests",
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.local_shipping_rounded,
                        title: "Pickup Routes",
                        subtitle: "Manage collections",
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.groups_rounded,
                        title: "Volunteers",
                        subtitle: "Coordinate your team",
                        color: Color(0xFF8E24AA),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 22),

              const Text(
                "Recent Activity",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),

              const SizedBox(height: 12),

              if (isDonor) ...[
                const _ActivityCard(
                  icon: Icons.check_circle_rounded,
                  iconBg: Color(0xFFE8F5E9),
                  iconColor: Color(0xFF2E7D32),
                  title: "Pickup completed",
                  subtitle: "Green Hope Foundation collected 20 meal boxes.",
                  time: "2h ago",
                ),
                const SizedBox(height: 12),
                const _ActivityCard(
                  icon: Icons.inventory_2_rounded,
                  iconBg: Color(0xFFE3F2FD),
                  iconColor: Color(0xFF1565C0),
                  title: "New post published",
                  subtitle: "You posted rice meals for pickup at 7:30 PM.",
                  time: "Today",
                ),
                const SizedBox(height: 12),
                const _ActivityCard(
                  icon: Icons.notifications_active_rounded,
                  iconBg: Color(0xFFFFF3E0),
                  iconColor: Color(0xFFEF6C00),
                  title: "Pickup request received",
                  subtitle: "A nearby NGO requested your latest donation.",
                  time: "Yesterday",
                ),
              ] else ...[
                const _ActivityCard(
                  icon: Icons.local_shipping_rounded,
                  iconBg: Color(0xFFFFF3E0),
                  iconColor: Color(0xFFEF6C00),
                  title: "Pickup confirmed",
                  subtitle: "Restaurant donation confirmed for collection.",
                  time: "1h ago",
                ),
                const SizedBox(height: 12),
                const _ActivityCard(
                  icon: Icons.inventory_2_rounded,
                  iconBg: Color(0xFFE8F5E9),
                  iconColor: Color(0xFF2E7D32),
                  title: "New donation nearby",
                  subtitle: "A donor posted 15 meal boxes near your area.",
                  time: "Today",
                ),
                const SizedBox(height: 12),
                const _ActivityCard(
                  icon: Icons.assignment_turned_in_rounded,
                  iconBg: Color(0xFFE3F2FD),
                  iconColor: Color(0xFF1565C0),
                  title: "Request submitted",
                  subtitle: "You requested pickup for bakery surplus food.",
                  time: "Yesterday",
                ),
              ],

              const SizedBox(height: 22),

              const Text(
                "Tips for today",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: primarySoft,
                      child: Icon(
                        Icons.lightbulb_rounded,
                        color: primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isDonor
                            ? "Add clear pickup time and food quantity to help organizations respond faster."
                            : "Check pickup time and location before accepting requests to keep your operations smooth.",
                        style: const TextStyle(
                          fontSize: 14,
                          color: bodyColor,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

class _BrowseScreen extends StatelessWidget {
  final String role;

  const _BrowseScreen({required this.role});

  bool get isDonor => role == "donor";

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF4F7F1);
    const titleColor = Color(0xFF12202F);
    const bodyColor = Color(0xFF6B7280);
    const borderColor = Color(0xFFE7ECE8);
    const donorPrimary = Color(0xFF2E7D32);
    const orgPrimary = Color(0xFFEF6C00);

    final primary = isDonor ? donorPrimary : orgPrimary;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isDonor ? "Browse Donations" : "Available Posts",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isDonor
                    ? "Explore available food donations near you."
                    : "Review nearby donor posts and manage pickup opportunities.",
                style: const TextStyle(
                  fontSize: 14,
                  color: bodyColor,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    icon: const Icon(Icons.search_rounded),
                    hintText: isDonor
                        ? "Search food, location, NGO..."
                        : "Search donor posts, area, quantity...",
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _BrowseFoodCard(
                title: "Rice & Chicken Meals",
                location: "Mirpur, Dhaka",
                quantity: "25 packs",
                time: "Pickup by 7:30 PM",
                status: "Available",
                buttonText: isDonor ? "View Details" : "Request Pickup",
                primaryColor: primary,
              ),
              const SizedBox(height: 12),
              _BrowseFoodCard(
                title: "Fresh Bakery Items",
                location: "Dhanmondi, Dhaka",
                quantity: "12 boxes",
                time: "Pickup by 6:00 PM",
                status: "Urgent",
                buttonText: isDonor ? "View Details" : "Request Pickup",
                primaryColor: primary,
              ),
              const SizedBox(height: 12),
              _BrowseFoodCard(
                title: "Vegetable Curry Meals",
                location: "Uttara, Dhaka",
                quantity: "18 portions",
                time: "Pickup by 8:00 PM",
                status: "Available",
                buttonText: isDonor ? "View Details" : "Request Pickup",
                primaryColor: primary,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        onPressed: () {},
        child: Icon(isDonor ? Icons.tune_rounded : Icons.search_rounded),
      ),
    );
  }
}

class _AddScreen extends StatelessWidget {
  final String role;

  const _AddScreen({required this.role});

  bool get isDonor => role == "donor";

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF4F7F1);
    const titleColor = Color(0xFF12202F);
    const bodyColor = Color(0xFF6B7280);
    const borderColor = Color(0xFFE7ECE8);
    const donorPrimary = Color(0xFF2E7D32);
    const orgPrimary = Color(0xFFEF6C00);

    final primary = isDonor ? donorPrimary : orgPrimary;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isDonor ? "Add Food Donation" : "Manage Pickup",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isDonor
                    ? "Share safe surplus food with nearby organizations."
                    : "Track and organize collection details for approved donations.",
                style: const TextStyle(
                  fontSize: 14,
                  color: bodyColor,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 18),

              if (isDonor) ...[
                const _FormLabel("Food Title"),
                const SizedBox(height: 8),
                const _DashboardInputField(
                  hintText: "Enter food name",
                  icon: Icons.fastfood_rounded,
                ),
                const SizedBox(height: 16),
                const _FormLabel("Quantity"),
                const SizedBox(height: 8),
                const _DashboardInputField(
                  hintText: "e.g. 20 meal boxes",
                  icon: Icons.inventory_2_rounded,
                ),
                const SizedBox(height: 16),
                const _FormLabel("Pickup Time"),
                const SizedBox(height: 8),
                const _DashboardInputField(
                  hintText: "e.g. Today, 7:30 PM",
                  icon: Icons.access_time_rounded,
                ),
                const SizedBox(height: 16),
                const _FormLabel("Location"),
                const SizedBox(height: 8),
                const _DashboardInputField(
                  hintText: "Enter pickup location",
                  icon: Icons.location_on_rounded,
                ),
                const SizedBox(height: 16),
                const _FormLabel("Description"),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor),
                  ),
                  child: const TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Add food details, packaging info, expiry, etc.",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
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
                      "Publish Donation",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                const _FormLabel("Pickup Reference"),
                const SizedBox(height: 8),
                const _DashboardInputField(
                  hintText: "Enter request or post ID",
                  icon: Icons.confirmation_number_rounded,
                ),
                const SizedBox(height: 16),
                const _FormLabel("Assigned Volunteer"),
                const SizedBox(height: 8),
                const _DashboardInputField(
                  hintText: "Enter volunteer name",
                  icon: Icons.groups_rounded,
                ),
                const SizedBox(height: 16),
                const _FormLabel("Pickup Time"),
                const SizedBox(height: 8),
                const _DashboardInputField(
                  hintText: "e.g. Today, 6:30 PM",
                  icon: Icons.access_time_rounded,
                ),
                const SizedBox(height: 16),
                const _FormLabel("Pickup Location"),
                const SizedBox(height: 8),
                const _DashboardInputField(
                  hintText: "Enter donor location",
                  icon: Icons.location_on_rounded,
                ),
                const SizedBox(height: 16),
                const _FormLabel("Notes"),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor),
                  ),
                  child: const TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Add transport, packaging, or route notes.",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
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
                      "Save Pickup Plan",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityScreen extends StatelessWidget {
  final String role;

  const _ActivityScreen({required this.role});

  bool get isDonor => role == "donor";

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF4F7F1);
    const titleColor = Color(0xFF12202F);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const Text(
              "Activity",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 16),
            if (isDonor) ...[
              const _ActivityCard(
                icon: Icons.check_circle_rounded,
                iconBg: Color(0xFFE8F5E9),
                iconColor: Color(0xFF2E7D32),
                title: "Donation completed",
                subtitle: "Your food was successfully collected and delivered.",
                time: "Today",
              ),
              const SizedBox(height: 12),
              const _ActivityCard(
                icon: Icons.local_shipping_rounded,
                iconBg: Color(0xFFE3F2FD),
                iconColor: Color(0xFF1565C0),
                title: "Pickup on the way",
                subtitle: "An organization is heading to your pickup point.",
                time: "3h ago",
              ),
              const SizedBox(height: 12),
              const _ActivityCard(
                icon: Icons.notifications_active_rounded,
                iconBg: Color(0xFFFFF3E0),
                iconColor: Color(0xFFEF6C00),
                title: "Request received",
                subtitle: "Your recent post has a new pickup request.",
                time: "Yesterday",
              ),
            ] else ...[
              const _ActivityCard(
                icon: Icons.assignment_turned_in_rounded,
                iconBg: Color(0xFFE8F5E9),
                iconColor: Color(0xFF2E7D32),
                title: "Request approved",
                subtitle: "A donor approved your pickup request.",
                time: "Today",
              ),
              const SizedBox(height: 12),
              const _ActivityCard(
                icon: Icons.local_shipping_rounded,
                iconBg: Color(0xFFFFF3E0),
                iconColor: Color(0xFFEF6C00),
                title: "Collection in progress",
                subtitle: "Your assigned volunteer is on the way.",
                time: "2h ago",
              ),
              const SizedBox(height: 12),
              const _ActivityCard(
                icon: Icons.inventory_2_rounded,
                iconBg: Color(0xFFE3F2FD),
                iconColor: Color(0xFF1565C0),
                title: "New post matched",
                subtitle: "A nearby donor posted food matching your route.",
                time: "Yesterday",
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  final String role;

  const _ProfileScreen({required this.role});

  bool get isDonor => role == "donor";

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF4F7F1);
    const titleColor = Color(0xFF12202F);
    const bodyColor = Color(0xFF6B7280);
    const borderColor = Color(0xFFE7ECE8);
    const donorPrimary = Color(0xFF2E7D32);
    const donorPrimarySoft = Color(0xFFE8F5E9);
    const orgPrimary = Color(0xFFEF6C00);
    const orgPrimarySoft = Color(0xFFFFF3E0);

    final primary = isDonor ? donorPrimary : orgPrimary;
    final primarySoft = isDonor ? donorPrimarySoft : orgPrimarySoft;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const Text(
              "Profile",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: primarySoft,
                    child: Icon(
                      isDonor ? Icons.person_rounded : Icons.apartment_rounded,
                      color: primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDonor ? "Donor Account" : "Organization Account",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isDonor ? "donor@example.com" : "organization@example.com",
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: bodyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _ProfileTile(
              icon: Icons.edit_outlined,
              title: "Edit Profile",
            ),
            _ProfileTile(
              icon: isDonor ? Icons.history_rounded : Icons.assignment_turned_in_rounded,
              title: isDonor ? "Donation History" : "Pickup Records",
            ),
            const _ProfileTile(
              icon: Icons.settings_outlined,
              title: "Settings",
            ),
            const _ProfileTile(
              icon: Icons.help_outline_rounded,
              title: "Help & Support",
            ),
            const _ProfileTile(
              icon: Icons.logout_rounded,
              title: "Log Out",
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardStatItem extends StatelessWidget {
  final String value;
  final String label;

  const _DashboardStatItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE7ECE8);
    const bodyColor = Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF12202F),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12.8,
              color: bodyColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE7ECE8);
    const titleColor = Color(0xFF12202F);
    const bodyColor = Color(0xFF6B7280);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: iconBg,
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.8,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13.2,
                    color: bodyColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12.5,
              color: bodyColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrowseFoodCard extends StatelessWidget {
  final String title;
  final String location;
  final String quantity;
  final String time;
  final String status;
  final String buttonText;
  final Color primaryColor;

  const _BrowseFoodCard({
    required this.title,
    required this.location,
    required this.quantity,
    required this.time,
    required this.status,
    required this.buttonText,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF12202F);
    const bodyColor = Color(0xFF6B7280);
    const borderColor = Color(0xFFE7ECE8);

    final bool isUrgent = status.toLowerCase() == "urgent";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isUrgent
                      ? const Color(0xFFFFF3E0)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isUrgent ? const Color(0xFFEF6C00) : const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            location,
            style: const TextStyle(fontSize: 13.2, color: bodyColor),
          ),
          const SizedBox(height: 6),
          Text(
            quantity,
            style: const TextStyle(fontSize: 13.2, color: bodyColor),
          ),
          const SizedBox(height: 6),
          Text(
            time,
            style: const TextStyle(fontSize: 13.2, color: bodyColor),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;

  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: Color(0xFF12202F),
      ),
    );
  }
}

class _DashboardInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;

  const _DashboardInputField({
    required this.hintText,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE7ECE8);
    const bodyColor = Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        decoration: InputDecoration(
          icon: Icon(icon, color: bodyColor),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ProfileTile({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF12202F);
    const borderColor = Color(0xFFE7ECE8);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: ListTile(
        leading: Icon(icon, color: titleColor),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      ),
    );
  }
}
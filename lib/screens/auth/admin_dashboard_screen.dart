import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_gate.dart';

const String kUsersCollection = 'users';
const String kRequestsCollection = 'requests';
const String kDonationsCollection = 'food_posts'; // proyojon hole change koro
const String kPickupsCollection = 'pickups';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF6F8FB);

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Exit App"),
            content: const Text("Do you want to exit the app?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Yes"),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          title: const Text(
            "Admin Dashboard",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminRequestsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            const SizedBox(width: 6),
            const Padding(
              padding: EdgeInsets.only(right: 14),
              child: CircleAvatar(
                backgroundColor: Color(0xFFE8F5EE),
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Color(0xFF0F766E),
                ),
              ),
            ),
          ],
        ),
        drawer: const _AdminDrawer(),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection(kUsersCollection)
              .snapshots(),
          builder: (context, usersSnap) {
            if (usersSnap.hasError) {
              return _ErrorState(message: usersSnap.error.toString());
            }
            if (!usersSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection(kRequestsCollection)
                  .snapshots(),
              builder: (context, requestsSnap) {
                if (requestsSnap.hasError) {
                  return _ErrorState(message: requestsSnap.error.toString());
                }
                if (!requestsSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection(kDonationsCollection)
                      .snapshots(),
                  builder: (context, donationsSnap) {
                    if (donationsSnap.hasError) {
                      return _ErrorState(message: donationsSnap.error.toString());
                    }
                    if (!donationsSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection(kPickupsCollection)
                          .snapshots(),
                      builder: (context, pickupsSnap) {
                        if (pickupsSnap.hasError) {
                          return _ErrorState(message: pickupsSnap.error.toString());
                        }
                        if (!pickupsSnap.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final usersDocs = usersSnap.data!.docs;
                        final requestDocs = requestsSnap.data!.docs;
                        final donationDocs = donationsSnap.data!.docs;
                        final pickupDocs = pickupsSnap.data!.docs;

                        final donorDocs = usersDocs.where((doc) {
                          final role = _normalizeRole(doc.data()['role']);
                          return role == 'donor';
                        }).toList();

                        final organizationDocs = usersDocs.where((doc) {
                          final role = _normalizeRole(doc.data()['role']);
                          return role == 'organization' ||
                              role == 'ngo' ||
                              role == 'org';
                        }).toList();

                        final adminDocs = usersDocs.where((doc) {
                          final role = _normalizeRole(doc.data()['role']);
                          return role == 'admin';
                        }).toList();

                        final openRequestDocs = requestDocs.where((doc) {
                          final status = _normalize(doc.data()['status']);
                          return status == 'pending' ||
                              status == 'open' ||
                              status == 'requested';
                        }).toList();

                        final completedPickupDocs = pickupDocs.where((doc) {
                          final status = _normalize(doc.data()['status']);
                          return status == 'completed';
                        }).toList();

                        final completedDonationDocs = donationDocs.where((doc) {
                          final status = _normalize(doc.data()['status']);
                          return status == 'accepted' ||
                              status == 'completed' ||
                              status == 'pickedup';
                        }).toList();

                        final weeklyUsers = usersDocs.where((doc) {
                          return _isThisWeek(doc.data()['createdAt']);
                        }).toList();

                        final weeklyDonations = donationDocs.where((doc) {
                          return _isThisWeek(doc.data()['createdAt']);
                        }).toList();

                        final weeklyRequests = requestDocs.where((doc) {
                          return _isThisWeek(doc.data()['createdAt']);
                        }).toList();

                        final weeklyCompleted = pickupDocs.where((doc) {
                          return _normalize(doc.data()['status']) == 'completed' &&
                              _isThisWeek(doc.data()['createdAt']);
                        }).toList();

                        final activities = _buildRecentActivities(
                          usersDocs: usersDocs,
                          requestDocs: requestDocs,
                          donationDocs: donationDocs,
                          pickupDocs: pickupDocs,
                        );

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _CompactHero(
                                totalUsers: usersDocs.length,
                                totalDonations: donationDocs.length,
                                totalRequests: openRequestDocs.length,
                              ),
                              const SizedBox(height: 18),

                              GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 1.18,
                                children: [
                                  _StatCard(
                                    title: "Total Users",
                                    value: usersDocs.length.toString(),
                                    subtitle:
                                        "Donors: ${donorDocs.length}, NGOs: ${organizationDocs.length}, Admins: ${adminDocs.length}",
                                    accentText:
                                        "+${weeklyUsers.length} last 7 days",
                                    accentColor: const Color(0xFF16A34A),
                                    icon: Icons.people_alt_rounded,
                                    iconColor: const Color(0xFF2563EB),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AdminUsersScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  _StatCard(
                                    title: "Donations",
                                    value: donationDocs.length.toString(),
                                    subtitle:
                                        "${completedDonationDocs.length} accepted or completed",
                                    accentText:
                                        "+${weeklyDonations.length} this week",
                                    accentColor: const Color(0xFF16A34A),
                                    icon: Icons.fastfood_rounded,
                                    iconColor: const Color(0xFF16A34A),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AdminDonationsScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  _StatCard(
                                    title: "Open Requests",
                                    value: openRequestDocs.length.toString(),
                                    subtitle:
                                        "${openRequestDocs.length} waiting for response",
                                    accentText: "Live requests",
                                    accentColor: const Color(0xFFEF4444),
                                    icon: Icons.assignment_late_rounded,
                                    iconColor: const Color(0xFFEF4444),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AdminRequestsScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  _StatCard(
                                    title: "Pickups",
                                    value: completedPickupDocs.length.toString(),
                                    subtitle:
                                        "${weeklyCompleted.length} completed this week",
                                    accentText: "Pickup monitoring",
                                    accentColor: const Color(0xFFA855F7),
                                    icon: Icons.local_shipping_rounded,
                                    iconColor: const Color(0xFFA855F7),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AdminPickupsScreen(
                                            statusFilter: 'completed',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              _SectionTitle("Weekly Summary"),
                              const SizedBox(height: 10),
                              _WeeklySummaryCard(
                                weeklyUsers: weeklyUsers.length,
                                weeklyDonations: weeklyDonations.length,
                                weeklyRequests: weeklyRequests.length,
                                weeklyCompleted: weeklyCompleted.length,
                              ),

                              const SizedBox(height: 18),

                              _SectionTitle("Recent Activities"),
                              const SizedBox(height: 10),
                              _RecentActivitiesCard(
                                activities: activities,
                              ),

                              const SizedBox(height: 18),

                              _SectionTitle("Quick Actions"),
                              const SizedBox(height: 10),

                              GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 1.55,
                                children: [
                                  _QuickActionCard(
                                    icon: Icons.people_alt_rounded,
                                    title: "Manage Users",
                                    color: const Color(0xFF2563EB),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AdminUsersScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  _QuickActionCard(
                                    icon: Icons.fastfood_rounded,
                                    title: "Manage Donations",
                                    color: const Color(0xFFEF4444),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AdminDonationsScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  _QuickActionCard(
                                    icon: Icons.assignment_rounded,
                                    title: "View Requests",
                                    color: const Color(0xFF4F46E5),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AdminRequestsScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  _QuickActionCard(
                                    icon: Icons.local_shipping_rounded,
                                    title: "Completed Pickups",
                                    color: const Color(0xFFF59E0B),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AdminPickupsScreen(
                                            statusFilter: 'completed',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
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
            color: Colors.black.withOpacity(.08),
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
              color: Colors.black.withOpacity(.15),
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
        color: Colors.white.withOpacity(.16),
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String accentText;
  final Color accentColor;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.accentText,
    required this.accentColor,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.blueGrey.shade700,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: iconColor.withOpacity(.12),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                accentText,
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.blueGrey.shade700,
                  fontSize: 14.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
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
                  backgroundColor: item.color.withOpacity(.12),
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
                backgroundColor: color.withOpacity(.12),
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
                  backgroundColor: Colors.white.withOpacity(.18),
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

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      ),
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
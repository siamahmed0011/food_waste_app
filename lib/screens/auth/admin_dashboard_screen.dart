import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF0F766E);
    const Color bg = Color(0xFFF6F8FB);

    final usersStream =
        FirebaseFirestore.instance.collection('users').snapshots();
    final requestsStream =
        FirebaseFirestore.instance.collection('requests').snapshots();
    final donationsStream =
        FirebaseFirestore.instance.collection('donations').snapshots();
    final pickupsStream =
        FirebaseFirestore.instance.collection('pickups').snapshots();

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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: primary.withOpacity(0.12),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                color: primary,
              ),
            ),
          ),
        ],
      ),
      drawer: _AdminDrawer(primary: primary),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: usersStream,
        builder: (context, usersSnap) {
          if (usersSnap.hasError) {
            return _ErrorBox(message: usersSnap.error.toString());
          }
          if (!usersSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: requestsStream,
            builder: (context, requestsSnap) {
              if (requestsSnap.hasError) {
                return _ErrorBox(message: requestsSnap.error.toString());
              }
              if (!requestsSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: donationsStream,
                builder: (context, donationsSnap) {
                  if (donationsSnap.hasError) {
                    return _ErrorBox(message: donationsSnap.error.toString());
                  }
                  if (!donationsSnap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: pickupsStream,
                    builder: (context, pickupsSnap) {
                      if (pickupsSnap.hasError) {
                        return _ErrorBox(message: pickupsSnap.error.toString());
                      }
                      if (!pickupsSnap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final usersDocs = usersSnap.data!.docs;
                      final requestDocs = requestsSnap.data!.docs;
                      final donationDocs = donationsSnap.data!.docs;
                      final pickupDocs = pickupsSnap.data!.docs;

                      final totalUsers = usersDocs.length;

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

                      final pendingRequestDocs = requestDocs.where((doc) {
                        final status = _normalize(doc.data()['status']);
                        return status == 'pending';
                      }).toList();

                      final pendingApprovalDocs = usersDocs.where((doc) {
                        final data = doc.data();
                        final approved = data['approved'];
                        return !(approved == true ||
                            approved.toString().toLowerCase() == 'true');
                      }).toList();

                      final completedPickupDocs = pickupDocs.where((doc) {
                        final status = _normalize(doc.data()['status']);
                        return status == 'completed';
                      }).toList();

                      final recentActivities = _buildRecentActivities(
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
                            const _AdminHeader(primary: primary),
                            const SizedBox(height: 20),

                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.05,
                              children: [
                                _StatCard(
                                  title: "Total Users",
                                  value: totalUsers.toString(),
                                  icon: Icons.people_alt_rounded,
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
                                _StatCard(
                                  title: "Total Donors",
                                  value: donorDocs.length.toString(),
                                  icon: Icons.volunteer_activism_rounded,
                                  color: const Color(0xFF16A34A),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AdminUsersScreen(
                                          roleFilter: 'donor',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                _StatCard(
                                  title: "Organizations",
                                  value: organizationDocs.length.toString(),
                                  icon: Icons.apartment_rounded,
                                  color: const Color(0xFFF59E0B),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AdminUsersScreen(
                                          roleFilter: 'organization',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                _StatCard(
                                  title: "Pending Requests",
                                  value: pendingRequestDocs.length.toString(),
                                  icon: Icons.pending_actions_rounded,
                                  color: const Color(0xFFDC2626),
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
                              ],
                            ),

                            const SizedBox(height: 22),

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
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AdminApprovalsScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _ActionButton(
                                  label: "Manage Donations",
                                  icon: Icons.fastfood_rounded,
                                  color: Colors.red,
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
                                _ActionButton(
                                  label: "View Requests",
                                  icon: Icons.assignment_rounded,
                                  color: Colors.indigo,
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
                                _ActionButton(
                                  label: "Completed Pickups",
                                  icon: Icons.local_shipping_rounded,
                                  color: Colors.orange,
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

                            const SizedBox(height: 22),

                            const Text(
                              "Pending Approvals",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (pendingApprovalDocs.isEmpty)
                              const _EmptySectionCard(
                                message: "No pending approvals.",
                              )
                            else
                              ...pendingApprovalDocs.take(5).map((doc) {
                                final data = doc.data();
                                final name = _userDisplayName(data);
                                final role = _normalizeRole(data['role']);
                                final subtitle = (role == 'organization' ||
                                        role == 'ngo' ||
                                        role == 'org')
                                    ? 'Organization verification pending'
                                    : 'Donor account approval needed';

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _PendingApprovalCard(
                                    name: name,
                                    subtitle: subtitle,
                                    time: _timeAgo(data['createdAt']),
                                    onReview: () {
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
                              }),

                            const SizedBox(height: 22),

                            const Text(
                              "Recent Activities",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (recentActivities.isEmpty)
                              const _EmptySectionCard(
                                message: "No recent activities found.",
                              )
                            else
                              ...recentActivities.map((item) {
                                return _ActivityTile(
                                  title: item.title,
                                  subtitle: item.subtitle,
                                  icon: item.icon,
                                  color: item.color,
                                  onTap: item.onTap == null
                                      ? null
                                      : () => item.onTap!(context),
                                );
                              }),

                            const SizedBox(height: 22),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "System Monitoring",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _MonitorRow(
                                    label: "Active Users",
                                    value: totalUsers.toString(),
                                    color: Colors.green,
                                  ),
                                  _MonitorRow(
                                    label: "Total Donations",
                                    value: donationDocs.length.toString(),
                                    color: Colors.blue,
                                  ),
                                  _MonitorRow(
                                    label: "Pending Requests",
                                    value: pendingRequestDocs.length.toString(),
                                    color: Colors.orange,
                                  ),
                                  _MonitorRow(
                                    label: "Completed Pickups",
                                    value: completedPickupDocs.length.toString(),
                                    color: Colors.purple,
                                  ),
                                ],
                              ),
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
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return _ErrorBox(message: snap.error.toString());
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = snap.data!.docs;

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
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final approved = data['approved'] == true ||
                  data['approved'].toString().toLowerCase() == 'true';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: approved
                        ? Colors.green.withOpacity(.12)
                        : Colors.orange.withOpacity(.12),
                    child: Icon(
                      approved ? Icons.verified : Icons.person,
                      color: approved ? Colors.green : Colors.orange,
                    ),
                  ),
                  title: Text(_userDisplayName(data)),
                  subtitle: Text(
                    "${data['email'] ?? 'No email'}\nRole: ${data['role'] ?? 'N/A'}",
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
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

class AdminApprovalsScreen extends StatelessWidget {
  const AdminApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pending Approvals")),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return _ErrorBox(message: snap.error.toString());
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs.where((doc) {
            final approved = doc.data()['approved'];
            return !(approved == true ||
                approved.toString().toLowerCase() == 'true');
          }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text("No pending approvals"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.withOpacity(.12),
                    child: const Icon(Icons.hourglass_top, color: Colors.orange),
                  ),
                  title: Text(_userDisplayName(data)),
                  subtitle: Text(
                    "Role: ${data['role'] ?? 'N/A'}\n${data['email'] ?? 'No email'}",
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
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
      appBar: AppBar(title: const Text("Pending Requests")),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('requests').snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return _ErrorBox(message: snap.error.toString());
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs.where((doc) {
            final status = _normalize(doc.data()['status']);
            return status == 'pending';
          }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text("No pending requests"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.withOpacity(.12),
                    child: const Icon(Icons.assignment, color: Colors.red),
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
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
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
        stream: FirebaseFirestore.instance.collection('donations').snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return _ErrorBox(message: snap.error.toString());
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = [...snap.data!.docs];
          docs.sort((a, b) {
            final aTime = _timestampToMillis(a.data()['createdAt']);
            final bTime = _timestampToMillis(b.data()['createdAt']);
            return bTime.compareTo(aTime);
          });

          if (docs.isEmpty) {
            return const Center(child: Text("No donations found"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.withOpacity(.12),
                    child: const Icon(Icons.fastfood, color: Colors.green),
                  ),
                  title: Text(
                    (data['foodTitle'] ??
                            data['title'] ??
                            data['foodName'] ??
                            'Untitled Donation')
                        .toString(),
                  ),
                  subtitle: Text(
                    "Donor: ${data['donorName'] ?? data['userName'] ?? 'Unknown'}\nStatus: ${data['status'] ?? 'N/A'}",
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
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
        stream: FirebaseFirestore.instance.collection('pickups').snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return _ErrorBox(message: snap.error.toString());
          }
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
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.withOpacity(.12),
                    child: const Icon(Icons.local_shipping,
                        color: Colors.purple),
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

  Future<void> _approveUser(BuildContext context) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'approved': true,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User approved successfully")),
    );
  }

  Future<void> _rejectUser(BuildContext context) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'approved': false,
      'status': 'rejected',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User marked as rejected")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final approved = data['approved'] == true ||
        data['approved'].toString().toLowerCase() == 'true';

    return Scaffold(
      appBar: AppBar(title: const Text("User Details")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _detailsCard(
            title: "Basic Information",
            children: [
              _detailRow("Name", _userDisplayName(data)),
              _detailRow("Email", data['email'] ?? 'N/A'),
              _detailRow("Phone", data['phone'] ?? 'N/A'),
              _detailRow("Role", data['role'] ?? 'N/A'),
              _detailRow("Address", data['address'] ?? 'N/A'),
              _detailRow("Approved", approved ? "Yes" : "No"),
              _detailRow("Created", _dateText(data['createdAt'])),
              _detailRow("User ID", userId),
            ],
          ),
          const SizedBox(height: 16),
          if (!approved)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _approveUser(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Approve"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rejectUser(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text("Reject"),
                  ),
                ),
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
          _detailsCard(
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
              _detailRow(
                "NGO Email",
                data['ngoEmail'] ?? data['email'] ?? 'N/A',
              ),
              _detailRow(
                "NGO Phone",
                data['ngoPhone'] ?? data['phone'] ?? 'N/A',
              ),
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
          _detailsCard(
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
                data['donorName'] ?? data['userName'] ?? 'N/A',
              ),
              _detailRow("Donor Email", data['donorEmail'] ?? 'N/A'),
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
          _detailsCard(
            title: "Pickup Information",
            children: [
              _detailRow(
                "Food Title",
                data['foodTitle'] ?? data['title'] ?? 'N/A',
              ),
              _detailRow(
                "NGO Name",
                data['ngoName'] ?? data['organizationName'] ?? 'N/A',
              ),
              _detailRow(
                "Donor Name",
                data['donorName'] ?? 'N/A',
              ),
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
            primary.withOpacity(0.82),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
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
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
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
              backgroundColor: color.withOpacity(0.12),
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
  final VoidCallback? onReview;

  const _PendingApprovalCard({
    required this.name,
    required this.subtitle,
    required this.time,
    this.onReview,
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
            backgroundColor: Colors.orange.withOpacity(0.12),
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
            onPressed: onReview,
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
  final VoidCallback? onTap;

  const _ActivityTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.12),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
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
              color: color.withOpacity(.12),
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

class _EmptySectionCard extends StatelessWidget {
  final String message;

  const _EmptySectionCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  final Color primary;
  const _AdminDrawer({required this.primary});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pop();
  }

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
          _drawerItem(
            Icons.dashboard_rounded,
            "Dashboard",
            () => Navigator.pop(context),
          ),
          _drawerItem(
            Icons.people_alt_rounded,
            "Manage Users",
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminUsersScreen(),
                ),
              );
            },
          ),
          _drawerItem(
            Icons.apartment_rounded,
            "Organizations",
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminUsersScreen(
                    roleFilter: 'organization',
                  ),
                ),
              );
            },
          ),
          _drawerItem(
            Icons.assignment_turned_in_rounded,
            "Approvals",
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminApprovalsScreen(),
                ),
              );
            },
          ),
          _drawerItem(
            Icons.receipt_long_rounded,
            "Requests",
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminRequestsScreen(),
                ),
              );
            },
          ),
          _drawerItem(
            Icons.fastfood_rounded,
            "Donations",
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminDonationsScreen(),
                ),
              );
            },
          ),
          _drawerItem(
            Icons.local_shipping_rounded,
            "Pickups",
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminPickupsScreen(),
                ),
              );
            },
          ),
          const Spacer(),
          const Divider(),
          _drawerItem(
            Icons.logout_rounded,
            "Logout",
            () => _logout(context),
          ),
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
    final data = doc.data();
    items.add({
      'type': 'user',
      'time': _timestampToMillis(data['createdAt']),
      'docId': doc.id,
      'data': data,
    });
  }

  for (final doc in requestDocs) {
    final data = doc.data();
    items.add({
      'type': 'request',
      'time': _timestampToMillis(data['createdAt']),
      'docId': doc.id,
      'data': data,
    });
  }

  for (final doc in donationDocs) {
    final data = doc.data();
    items.add({
      'type': 'donation',
      'time': _timestampToMillis(data['createdAt']),
      'docId': doc.id,
      'data': data,
    });
  }

  for (final doc in pickupDocs) {
    final data = doc.data();
    items.add({
      'type': 'pickup',
      'time': _timestampToMillis(data['createdAt']),
      'docId': doc.id,
      'data': data,
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
        title: isOrg
            ? "New organization registered"
            : "New donor registered",
        subtitle: isOrg
            ? "$name joined as an organization"
            : "$name joined as a donor",
        icon: isOrg ? Icons.apartment_rounded : Icons.person_add_alt_1_rounded,
        color: isOrg ? Colors.orange : Colors.green,
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
        icon: Icons.request_page_rounded,
        color: Colors.blue,
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
        color: Colors.red,
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
      color: Colors.purple,
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

Widget _detailsCard({
  required String title,
  required List<Widget> children,
}) {
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
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    ),
  );
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
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(value?.toString() ?? 'N/A'),
        ),
      ],
    ),
  );
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

String _timeAgo(dynamic value) {
  DateTime? dateTime;

  if (value is Timestamp) {
    dateTime = value.toDate();
  } else if (value is DateTime) {
    dateTime = value;
  }

  if (dateTime == null) return "Recently";

  final diff = DateTime.now().difference(dateTime);

  if (diff.inSeconds < 60) return "Just now";
  if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
  if (diff.inHours < 24) return "${diff.inHours} hour ago";
  if (diff.inDays < 7) return "${diff.inDays} day ago";
  return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
}
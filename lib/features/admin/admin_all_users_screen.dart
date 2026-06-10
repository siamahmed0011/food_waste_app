import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_waste_app/features/admin/admin_dashboard_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════
// FILE: admin_all_users_screen.dart
// Features: view profile, send alert, remove user
// ═══════════════════════════════════════════════════════════════════════════

class AdminAllUsersScreen extends StatefulWidget {
  final String? roleFilter;
  const AdminAllUsersScreen({super.key, this.roleFilter});

  @override
  State<AdminAllUsersScreen> createState() => _AdminAllUsersScreenState();
}

class _AdminAllUsersScreenState extends State<AdminAllUsersScreen> {
  String _filter = 'all';

  Color _roleColor(String role) {
    switch (role) {
      case 'donor': return const Color(0xFF2E7D32);
      case 'organization':
      case 'ngo':
      case 'org': return const Color(0xFF0288D1);
      case 'admin': return const Color(0xFF7B1FA2);
      default: return const Color(0xFF6B7280);
    }
  }

  Color _roleBg(String role) {
    switch (role) {
      case 'donor': return const Color(0xFFE8F5E9);
      case 'organization':
      case 'ngo':
      case 'org': return const Color(0xFFE3F2FD);
      case 'admin': return const Color(0xFFF3E5F5);
      default: return const Color(0xFFF4F6FA);
    }
  }

  String _normalizeRole(dynamic value) =>
      value?.toString().toLowerCase().trim() ?? '';

  String _displayName(Map<String, dynamic> data) =>
      (data['name'] ??
          data['fullName'] ??
          data['organizationName'] ??
          data['ngoName'] ??
          'Unnamed User')
          .toString();

  // ── Remove user (delete Firestore document) ──────────────────────────────
  Future<void> _removeUser(
      BuildContext context, String docId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remove User',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, color: const Color(0xFF1A1F36))),
        content: Text(
          'Are you sure you want to remove "$name"?\n\nThis will permanently delete their profile from the database.',
          style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: const Color(0xFF6B7280))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Remove',
                style: GoogleFonts.poppins(
                    color: const Color(0xFFE53935),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection(kUsersCollection)
            .doc(docId)
            .delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$name has been removed.',
                  style: GoogleFonts.poppins()),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove user: $e',
                  style: GoogleFonts.poppins()),
              backgroundColor: const Color(0xFFE53935),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  // ── Send alert to user (writes to Firestore notifications) ───────────────
  Future<void> _sendAlert(
      BuildContext context, String docId, String name) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Send Alert to $name',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: const Color(0xFF1A1F36))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This message will appear in the user\'s notifications.',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: const Color(0xFF6B7280))),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Type your alert message...',
                hintStyle: GoogleFonts.poppins(
                    fontSize: 13, color: const Color(0xFF9CA3AF)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFE5E7EB))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFFF8F00), width: 2)),
                contentPadding: const EdgeInsets.all(12),
              ),
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: const Color(0xFF6B7280))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Send',
                style: GoogleFonts.poppins(
                    color: const Color(0xFFFF8F00),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && controller.text.trim().isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('user_alerts')
            .add({
          'targetUserId': docId,
          'message': controller.text.trim(),
          'sentAt': FieldValue.serverTimestamp(),
          'sentBy': 'admin',
          'isRead': false,
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Alert sent to $name.',
                  style: GoogleFonts.poppins()),
              backgroundColor: const Color(0xFFFF8F00),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send alert: $e',
                  style: GoogleFonts.poppins()),
              backgroundColor: const Color(0xFFE53935),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
    controller.dispose();
  }

  // ── Verify NGO Verification (Approve / Reject) ───────────────────────────
  Future<void> _verifyNGO(BuildContext context, String docId, String name, bool approve) async {
    final status = approve ? 'approved' : 'rejected';
    try {
      await FirebaseFirestore.instance.collection(kUsersCollection).doc(docId).update({
        'isVerified': approve,
        'verificationStatus': status,
      });

      // Write notification for the NGO
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': docId,
        'title': approve ? 'Verification Approved!' : 'Verification Rejected',
        'body': approve
            ? 'Congratulations! Your NGO profile has been verified by the administrator. You can now request food donations.'
            : 'Your NGO verification request has been rejected by the administrator. Please check your registration details and try again.',
        'type': 'verification_update',
        'isRead': false,
        'createdAt': Timestamp.now(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve ? '$name has been verified!' : 'Verification for $name was rejected.',
                style: GoogleFonts.poppins()),
            backgroundColor: approve ? const Color(0xFF2E7D32) : const Color(0xFFE53935),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update verification status: $e',
                style: GoogleFonts.poppins()),
            backgroundColor: const Color(0xFFE53935),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  // ── Show 3-dot options menu ───────────────────────────────────────────────
  void _showOptions(BuildContext context, String docId, String name,
      Map<String, dynamic> data) {
    final role = _normalizeRole(data['role']);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Row(
                children: [
                  Text(name,
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1F36))),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.person_outline,
                  color: Color(0xFF0288D1)),
              title: Text('View Profile',
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: const Color(0xFF1A1F36))),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminUserProfileScreen(
                        userId: docId, data: data),
                  ),
                );
              },
            ),
            if (role == 'organization' || role == 'ngo' || role == 'org') ...[
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                title: Text('Approve NGO Verification',
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: const Color(0xFF1A1F36))),
                onTap: () {
                  Navigator.pop(context);
                  _verifyNGO(context, docId, name, true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.gpp_bad_outlined, color: Colors.red),
                title: Text('Reject NGO Verification',
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: const Color(0xFF1A1F36))),
                onTap: () {
                  Navigator.pop(context);
                  _verifyNGO(context, docId, name, false);
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.notifications_outlined,
                  color: Color(0xFFFF8F00)),
              title: Text('Send Alert',
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: const Color(0xFF1A1F36))),
              onTap: () {
                Navigator.pop(context);
                _sendAlert(context, docId, name);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  color: Color(0xFFE53935)),
              title: Text('Remove User',
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: const Color(0xFFE53935))),
              onTap: () {
                Navigator.pop(context);
                _removeUser(context, docId, name);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: Color(0xFF1A1F36)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.roleFilter == null
              ? 'All Users'
              : widget.roleFilter == 'donor'
                  ? 'All Donors'
                  : 'Organizations',
          style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1F36)),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(kUsersCollection)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Text('Error: ${snap.error}',
                  style: const TextStyle(color: Colors.red)),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snap.data!.docs;

          // Apply role filter from parent
          if (widget.roleFilter != null) {
            docs = docs.where((doc) {
              final role = _normalizeRole(doc.data()['role']);
              if (widget.roleFilter == 'organization') {
                return role == 'organization' || role == 'ngo' || role == 'org';
              }
              return role == widget.roleFilter;
            }).toList();
          }

          // Apply internal tab filter
          List<QueryDocumentSnapshot<Map<String, dynamic>>> filtered = docs;
          if (_filter != 'all') {
            filtered = docs.where((doc) {
              final role = _normalizeRole(doc.data()['role']);
              if (_filter == 'organization') {
                return role == 'organization' || role == 'ngo' || role == 'org';
              }
              return role == _filter;
            }).toList();
          }

          int countRole(String r) => r == 'all'
              ? docs.length
              : docs.where((d) {
                  final role = _normalizeRole(d.data()['role']);
                  if (r == 'organization') {
                    return role == 'organization' || role == 'ngo' || role == 'org';
                  }
                  return role == r;
                }).length;

          return Column(
            children: [
              // Stats + filter bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                child: Column(
                  children: [
                    Row(
                      children: ['donor', 'organization', 'admin'].map((r) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _roleBg(r),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(countRole(r).toString(),
                                    style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: _roleColor(r))),
                                Text(r,
                                    style: GoogleFonts.poppins(
                                        fontSize: 9, color: _roleColor(r))),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['all', 'donor', 'organization', 'admin']
                            .map((f) {
                          final sel = _filter == f;
                          return GestureDetector(
                            onTap: () => setState(() => _filter = f),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: sel
                                    ? const Color(0xFF7B1FA2)
                                    : const Color(0xFFF4F6FA),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                f[0].toUpperCase() + f.substring(1),
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: sel
                                        ? Colors.white
                                        : const Color(0xFF6B7280)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                  color: Color(0xFFF4F6FA),
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.people_outline,
                                  color: Color(0xFF9CA3AF), size: 40),
                            ),
                            const SizedBox(height: 12),
                            Text('No users found',
                                style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF6B7280))),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final doc = filtered[i];
                          final data = doc.data();
                          final role = _normalizeRole(data['role']);
                          final name = _displayName(data);

                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminUserProfileScreen(
                                    userId: doc.id, data: data),
                              ),
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3))
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                        color: _roleBg(role),
                                        borderRadius: BorderRadius.circular(12)),
                                    child: Icon(
                                      role == 'organization' ||
                                              role == 'ngo' ||
                                              role == 'org'
                                          ? Icons.corporate_fare_outlined
                                          : role == 'admin'
                                              ? Icons.admin_panel_settings_outlined
                                              : Icons.person_outline,
                                      color: _roleColor(role),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(name,
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                          0xFF1A1F36)),
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                  color: _roleBg(role),
                                                  borderRadius:
                                                      BorderRadius.circular(6)),
                                              child: Text(
                                                  role.isEmpty ? 'N/A' : role,
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                      color: _roleColor(role))),
                                            ),
                                          ],
                                        ),
                                        if (role == 'organization' || role == 'ngo' || role == 'org') ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: data['verificationStatus'] == 'approved'
                                                      ? Colors.green.shade50
                                                      : data['verificationStatus'] == 'rejected'
                                                          ? Colors.red.shade50
                                                          : Colors.amber.shade50,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      data['verificationStatus'] == 'approved'
                                                          ? Icons.verified_user_rounded
                                                          : data['verificationStatus'] == 'rejected'
                                                              ? Icons.gpp_bad_rounded
                                                              : Icons.hourglass_empty_rounded,
                                                      size: 11,
                                                      color: data['verificationStatus'] == 'approved'
                                                          ? Colors.green
                                                          : data['verificationStatus'] == 'rejected'
                                                              ? Colors.red
                                                              : Colors.amber.shade800,
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      data['verificationStatus'] == 'approved'
                                                          ? 'Approved'
                                                          : data['verificationStatus'] == 'rejected'
                                                              ? 'Rejected'
                                                              : 'Pending',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 9,
                                                        fontWeight: FontWeight.w700,
                                                        color: data['verificationStatus'] == 'approved'
                                                            ? Colors.green
                                                            : data['verificationStatus'] == 'rejected'
                                                                ? Colors.red
                                                                : Colors.amber.shade800,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (data['regNo'] != null) ...[
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    'Reg: ${data['regNo']}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 10,
                                                      color: const Color(0xFF6B7280),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.email_outlined,
                                                size: 12,
                                                color: Color(0xFF9CA3AF)),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                data['email'] ?? 'No email',
                                                style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    color:
                                                        const Color(0xFF6B7280)),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // 3-dot menu button
                                  IconButton(
                                    icon: const Icon(Icons.more_vert_rounded,
                                        color: Color(0xFF9CA3AF), size: 20),
                                    onPressed: () => _showOptions(
                                        context, doc.id, name, data),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Admin User Profile Screen — full detail view
// ═══════════════════════════════════════════════════════════════════════════

class AdminUserProfileScreen extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> data;
  const AdminUserProfileScreen(
      {super.key, required this.userId, required this.data});

  String _fmt(dynamic v) => v?.toString() ?? 'N/A';

  String _dateText(dynamic value) {
    if (value is Timestamp) {
      final d = value.toDate();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${d.day} ${months[d.month - 1]} ${d.year}  ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
    }
    return _fmt(value);
  }

  Widget _row(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: const Color(0xFF9CA3AF))),
                const SizedBox(height: 2),
                Text(value,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1F36))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1F36))),
          const Divider(height: 20, color: Color(0xFFF4F6FA)),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = data['role']?.toString() ?? 'N/A';
    final name = (data['name'] ??
            data['fullName'] ??
            data['organizationName'] ??
            data['ngoName'] ??
            'Unnamed User')
        .toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: Color(0xFF1A1F36)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('User Profile',
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1F36))),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF004D40), Color(0xFF00897B)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1F36))),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: role.toLowerCase() == 'donor'
                              ? const Color(0xFFE8F5E9)
                              : role.toLowerCase() == 'admin'
                                  ? const Color(0xFFF3E5F5)
                                  : const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(role,
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: role.toLowerCase() == 'donor'
                                    ? const Color(0xFF2E7D32)
                                    : role.toLowerCase() == 'admin'
                                        ? const Color(0xFF7B1FA2)
                                        : const Color(0xFF0288D1))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Basic info
          _card('Basic Information', [
            _row('Full Name', name, Icons.person_outline),
            _row('Email', _fmt(data['email']), Icons.email_outlined),
            _row('Phone', _fmt(data['phone']), Icons.phone_outlined),
            _row('Role', role, Icons.badge_outlined),
            _row('User ID', userId, Icons.fingerprint_outlined),
          ]),

          // Address / location
          if (data['address'] != null || data['location'] != null)
            _card('Location', [
              if (data['address'] != null)
                _row('Address', _fmt(data['address']),
                    Icons.location_on_outlined),
              if (data['location'] != null)
                _row('Location', _fmt(data['location']),
                    Icons.map_outlined),
            ]),

          // Organization-specific fields
          if (data['organizationName'] != null ||
              data['ngoName'] != null ||
              data['description'] != null)
            _card('Organization Info', [
              if (data['organizationName'] != null)
                _row('Organization', _fmt(data['organizationName']),
                    Icons.corporate_fare_outlined),
              if (data['ngoName'] != null)
                _row('NGO Name', _fmt(data['ngoName']),
                    Icons.corporate_fare_outlined),
              if (data['description'] != null)
                _row('Description', _fmt(data['description']),
                    Icons.info_outline),
            ]),

          // Account info
          _card('Account Details', [
            _row('Joined', _dateText(data['createdAt']),
                Icons.calendar_today_outlined),
            if (data['lastLogin'] != null)
              _row('Last Login', _dateText(data['lastLogin']),
                  Icons.login_outlined),
            if (data['banned'] != null)
              _row('Banned', _fmt(data['banned']), Icons.block_outlined),
          ]),

          // NGO Verification Info
          if (role.toLowerCase() == 'organization' ||
              role.toLowerCase() == 'ngo' ||
              role.toLowerCase() == 'org')
            _NGOVerificationCard(userId: userId, data: data),

          // Alerts history
          const SizedBox(height: 4),
          Text('Alerts Sent to This User',
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1F36))),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('user_alerts')
                .where('targetUserId', isEqualTo: userId)
                .orderBy('sentAt', descending: true)
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: Text('No alerts sent yet.',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: const Color(0xFF9CA3AF))),
                );
              }
              return Column(
                children: snap.data!.docs.map((d) {
                  final alertData = d.data() as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: const Color(0xFFFFF8E1), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.notifications_outlined,
                            color: Color(0xFFFF8F00), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(alertData['message']?.toString() ?? '',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: const Color(0xFF1A1F36))),
                              const SizedBox(height: 4),
                              Text(
                                _dateText(alertData['sentAt']),
                                style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: const Color(0xFF9CA3AF)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _NGOVerificationCard extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> data;
  const _NGOVerificationCard({required this.userId, required this.data});

  Future<void> _updateVerification(BuildContext context, bool approve) async {
    final status = approve ? 'approved' : 'rejected';
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isVerified': approve,
        'verificationStatus': status,
      });

      // Write notification for the NGO
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        'title': approve ? 'Verification Approved!' : 'Verification Rejected',
        'body': approve
            ? 'Congratulations! Your NGO profile has been verified by the administrator. You can now request food donations.'
            : 'Your NGO verification request has been rejected by the administrator. Please check your registration details and try again.',
        'type': 'verification_update',
        'isRead': false,
        'createdAt': Timestamp.now(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve ? 'NGO verified successfully' : 'NGO verification rejected',
                style: GoogleFonts.poppins()),
            backgroundColor: approve ? const Color(0xFF2E7D32) : const Color(0xFFE53935),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.poppins()),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final isVerified = userData['isVerified'] ?? false;
        final verificationStatus = userData['verificationStatus'] ?? 'pending';
        final regNo = userData['regNo'] ?? 'Not provided';

        Color statusColor = Colors.amber.shade800;
        IconData statusIcon = Icons.hourglass_top_rounded;
        String statusLabel = 'Pending Verification';

        if (verificationStatus == 'approved') {
          statusColor = const Color(0xFF2E7D32);
          statusIcon = Icons.verified_user_rounded;
          statusLabel = 'Approved / Verified';
        } else if (verificationStatus == 'rejected') {
          statusColor = const Color(0xFFE53935);
          statusIcon = Icons.gpp_bad_rounded;
          statusLabel = 'Rejected';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NGO Verification',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1F36),
                ),
              ),
              const Divider(height: 20, color: Color(0xFFF4F6FA)),
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    statusLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.badge_outlined, size: 16, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Govt. Registration No: $regNo',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1F36),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: verificationStatus == 'approved'
                          ? null
                          : () => _updateVerification(context, true),
                      icon: const Icon(Icons.check, size: 16),
                      label: Text(
                        'Approve',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.green.shade100,
                        disabledForegroundColor: Colors.green.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: verificationStatus == 'rejected'
                          ? null
                          : () => _updateVerification(context, false),
                      icon: const Icon(Icons.close, size: 16),
                      label: Text(
                        'Reject',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE53935),
                        side: const BorderSide(color: Color(0xFFE53935)),
                        disabledForegroundColor: Colors.red.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

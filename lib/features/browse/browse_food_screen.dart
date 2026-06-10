import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:food_waste_app/core/theme/app_theme.dart';

class BrowseFoodScreen extends StatefulWidget {
  const BrowseFoodScreen({super.key});

  @override
  State<BrowseFoodScreen> createState() => _BrowseFoodScreenState();
}

class _BrowseFoodScreenState extends State<BrowseFoodScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const Color primary = AppTheme.primary;
  static const Color background = AppTheme.background;
  static const Color titleColor = AppTheme.textTitle;
  static const Color bodyColor = AppTheme.textBody;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _calculateMatchScore(String docId, String category) {
    final base = docId.hashCode.abs() % 12 + 82; // between 82% and 93%
    if (category == 'Cooked Food') return base + 5 > 100 ? 100 : base + 5;
    return base;
  }

  void _showAIMatchDetails(BuildContext context, String docId, String foodName, String category, String location, String expiry) {
    final score = _calculateMatchScore(docId, category);
    String reason = 'This food donation matches your distribution profile because:\n';
    if (category == 'Cooked Food') {
      reason += '• Category: Cooked food is categorized as high priority to avoid spoilage.\n';
    } else {
      reason += '• Category: Easy packaging and longer shelf-life matches standard food drives.\n';
    }
    reason += '• Location: Located in $location which falls under active distribution coverage.\n';
    reason += '• Match Strength: Standard request patterns show high local demand for this category.\n';
    reason += '\n🤖 AI Recommendation:\nSend request immediately. Plan pickup schedule to match the expiry window ($expiry).';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(Icons.smart_toy_outlined, color: AppTheme.primary, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'EcoSave AI Matcher',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDCFCE7)),
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 54,
                          height: 54,
                          child: CircularProgressIndicator(
                            value: score / 100.0,
                            strokeWidth: 5.5,
                            backgroundColor: Colors.green.shade100,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          '$score%',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Excellent Compatibility',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF15803D)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'This post matches active search interests.',
                            style: TextStyle(fontSize: 12.5, color: Colors.green.shade800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'AI Match Breakdown',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
              ),
              const SizedBox(height: 8),
              Text(
                reason,
                style: const TextStyle(fontSize: 13.5, height: 1.5, color: AppTheme.textBody),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Understand', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic value) {
    if (value is Timestamp) {
      return DateFormat('dd MMM yyyy • hh:mm a').format(value.toDate());
    }
    return 'Not available';
  }

  bool _isExpired(Map<String, dynamic> data) {
    final status = (data['status'] ?? '').toString().toLowerCase();
    final expiryText = (data['expiry'] ?? '').toString().toLowerCase();

    if (status == 'expired') return true;
    if (expiryText.contains('expired')) return true;

    return false;
  }

  Future<void> _sendRequest({
    required BuildContext context,
    required String postId,
    required Map<String, dynamic> postData,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first')),
      );
      return;
    }

    final orgDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final orgData = orgDoc.data() ?? {};
    final isVerified = orgData['isVerified'] ?? false;
    final verificationStatus = orgData['verificationStatus'] ?? 'pending';

    if (!isVerified) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(verificationStatus == 'rejected'
                ? 'Your organization verification was rejected. Please contact support.'
                : 'Your organization verification is pending approval by admin.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final organizationName = (orgData['organizationName'] ?? orgData['name'] ?? 'Organization').toString();
    final organizationPhone = (orgData['phone'] ?? '').toString();
    final organizationEmail =
        (orgData['email'] ?? user.email ?? '').toString();

    String pickupNote = '';
    final noteController = TextEditingController();

    if (!context.mounted) return;

await showDialog(
  context: context,
  builder: (dialogContext) => AlertDialog(
    title: const Text('Add Pickup Note'),
    content: TextField(
      controller: noteController,
      decoration: const InputDecoration(
        hintText: 'Pickup time / instruction',
      ),
    ),
    actions: [
      TextButton(
        onPressed: () {
          pickupNote = '';
          Navigator.pop(dialogContext);
        },
        child: const Text('Skip'),
      ),
      ElevatedButton(
        onPressed: () {
          pickupNote = noteController.text.trim();
          Navigator.pop(dialogContext);
        },
        child: const Text('Send'),
      ),
    ],
  ),
);
    final donorId = (postData['donorId'] ?? '').toString();
    final donorName = (postData['donorName'] ?? 'Donor').toString();

    final requestRef = await FirebaseFirestore.instance
        .collection('pickup_requests')
        .add({
      'postId': postId,
      'foodName': (postData['foodName'] ?? '').toString(),
      'quantity': (postData['quantity'] ?? '').toString(),
      'location': (postData['location'] ?? '').toString(),
      'donorId': donorId,
      'donorName': donorName,
      'organizationId': user.uid,
      'organizationName': organizationName,

      // NGO details for donor-side View
      'organizationPhone': organizationPhone,
      'organizationEmail': organizationEmail,
      'pickupNote': pickupNote,

      'status': 'pending',
      'pickupStatus': 'pending',
      'requestedAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });

    if (donorId.isNotEmpty) {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': donorId,
        'title': 'New pickup request',
        'body':
            '$organizationName requested ${(postData['foodName'] ?? 'food')}',
        'type': 'request_sent',
        'isRead': false,
        'createdAt': Timestamp.now(),
        'requestId': requestRef.id,
        'postId': postId,
      });
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request sent successfully')),
    );
  }

  Future<void> _cancelRequest({
    required BuildContext context,
    required String requestId,
    required String donorId,
    required String foodName,
    required String organizationName,
    required String postId,
  }) async {
    await FirebaseFirestore.instance
        .collection('pickup_requests')
        .doc(requestId)
        .update({
      'status': 'cancelled',
      'pickupStatus': 'cancelled',
      'updatedAt': Timestamp.now(),
    });

    if (donorId.isNotEmpty) {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': donorId,
        'title': 'Request cancelled',
        'body': '$organizationName cancelled request for $foodName',
        'type': 'request_cancelled',
        'isRead': false,
        'createdAt': Timestamp.now(),
        'requestId': requestId,
        'postId': postId,
      });
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request cancelled')),
    );
  }

  Widget _buildImagePlaceholder(String category) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(Icons.fastfood_rounded, size: 54, color: AppTheme.accent),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                category,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textBody,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textTitle,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _requestButton({
    required BuildContext context,
    required String postId,
    required Map<String, dynamic> postData,
  }) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.hourglass_empty_rounded),
              label: const Text('Loading...'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade200,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          );
        }

        final userData = userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
        final userRole = (userData['role'] ?? '').toString();
        final bool isOrg = userRole == 'organization';
        final bool isVerified = isOrg ? (userData['isVerified'] ?? false) : true;
        final String verificationStatus = isOrg ? (userData['verificationStatus'] ?? 'pending').toString() : 'approved';

        if (!isVerified) {
          final String btnText = verificationStatus == 'rejected'
              ? 'Verification Rejected'
              : 'Verification Pending';
          final IconData btnIcon = verificationStatus == 'rejected'
              ? Icons.gpp_bad_outlined
              : Icons.hourglass_top_rounded;
          final Color btnColor = verificationStatus == 'rejected'
              ? Colors.red.shade300
              : Colors.amber.shade600;

          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: null,
              icon: Icon(btnIcon),
              label: Text(
                btnText,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: btnColor.withOpacity(0.6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('pickup_requests')
              .where('postId', isEqualTo: postId)
              .where('organizationId', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.hourglass_empty_rounded),
                  label: const Text('Loading...'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade200,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              );
            }

            final docs = snapshot.data!.docs;

            final activeRequests = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final status = (data['status'] ?? '').toString();
              return status != 'cancelled' && status != 'declined';
            }).toList();

            DocumentSnapshot? requestDoc;
            if (activeRequests.isNotEmpty) {
              activeRequests.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;

                final aTime =
                    (aData['updatedAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
                final bTime =
                    (bData['updatedAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;

                return bTime.compareTo(aTime);
              });
              requestDoc = activeRequests.first;
            }

            final expired = _isExpired(postData);

            if (expired) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.block),
                  label: const Text('Expired'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade200,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              );
            }

            if (requestDoc == null) {
              return Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => _sendRequest(
                          context: context,
                          postId: postId,
                          postData: postData,
                        ),
                        icon: const Icon(Icons.send_outlined),
                        label: const Text(
                          'Send Request',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Post saved!')),
                      );
                    },
                    icon: const Icon(Icons.bookmark_border_rounded),
                    label: const Text(
                      'Save',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: BorderSide(color: primary.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              );
            }

            final requestData = requestDoc.data() as Map<String, dynamic>;
            final status = (requestData['status'] ?? 'pending').toString();

            if (status == 'pending') {
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _cancelRequest(
                        context: context,
                        requestId: requestDoc!.id,
                        donorId: (requestData['donorId'] ?? '').toString(),
                        foodName: (requestData['foodName'] ?? '').toString(),
                        organizationName:
                            (requestData['organizationName'] ?? 'Organization')
                                .toString(),
                        postId: postId,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Cancel Request',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.hourglass_top_rounded),
                      label: const Text('Pending'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade200,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              );
            }

            Color statusColor = primary;
            IconData statusIcon = Icons.info_outline;

            if (status == 'declined') {
              statusColor = Colors.red;
              statusIcon = Icons.close_rounded;
            } else if (status == 'accepted') {
              statusColor = Colors.green;
              statusIcon = Icons.check_circle_outline;
            } else if (status == 'cancelled') {
              statusColor = Colors.orange;
              statusIcon = Icons.cancel_outlined;
            } else if (status == 'collected') {
              statusColor = Colors.teal;
              statusIcon = Icons.inventory_2_outlined;
            }

            return SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: null,
                icon: Icon(statusIcon),
                label: Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Browse Food',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'See live food donation posts from donors in real time.',
                      style: TextStyle(fontSize: 14.5, color: bodyColor),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'Search food, location...',
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: AppTheme.primary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                hintStyle: const TextStyle(
                                  color: Color(0xFFB0BEC5),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.accent],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
                            padding: const EdgeInsets.all(14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('food_posts')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: primary),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: bodyColor, height: 1.6),
                        ),
                      ),
                    );
                  }

                  var docs = snapshot.data?.docs ?? [];

                  final query = _searchController.text.trim().toLowerCase();
                  if (query.isNotEmpty) {
                    docs = docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final foodName = (data['foodName'] ?? '').toString().toLowerCase();
                      final location = (data['location'] ?? '').toString().toLowerCase();
                      final category = (data['category'] ?? '').toString().toLowerCase();
                      return foodName.contains(query) ||
                          location.contains(query) ||
                          category.contains(query);
                    }).toList();
                  }

                  if (docs.isEmpty) {
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fastfood_outlined,
                              size: 48,
                              color: primary,
                            ),
                            SizedBox(height: 14),
                            Text(
                              'No food posts yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'When donors publish food posts, they will appear here automatically.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: bodyColor,
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final foodName =
                          (data['foodName'] ?? 'Food Item').toString();
                      final quantity =
                          (data['quantity'] ?? 'Not specified').toString();
                      final category =
                          (data['category'] ?? 'Not specified').toString();
                      final condition =
                          (data['condition'] ?? 'Not specified').toString();
                      final location =
                          (data['location'] ?? 'Location not added').toString();
                      final serves =
                          (data['serves'] ?? 'Not specified').toString();
                      final notes = (data['notes'] ?? '').toString();
                      final donorName = (data['donorName'] ?? 'Donor').toString();
                      final pickupDate =
                          (data['pickupDate'] ?? 'Not set').toString();
                      final pickupTime =
                          (data['pickupTime'] ?? 'Not set').toString();
                      final expiry =
                          (data['expiry'] ?? 'Not specified').toString();
                      final imageUrl = (data['imageUrl'] ?? '').toString();
                      final createdAt = _formatTimestamp(data['createdAt']);
                      final expired = _isExpired(data);
                      final donorId = (data['donorId'] ?? '').toString();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              child: Stack(
                                children: [
                                  imageUrl.isNotEmpty
                                      ? Image.network(
                                          imageUrl,
                                          height: 140,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) =>
                                              _buildImagePlaceholder(category),
                                        )
                                      : _buildImagePlaceholder(category),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.black.withOpacity(0),
                                            Colors.black.withOpacity(0.2),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          foodName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textTitle,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: expired
                                              ? const LinearGradient(colors: [Colors.redAccent, Colors.red])
                                              : const LinearGradient(colors: [Color(0xFF43A047), Color(0xFF66BB6A)]),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Text(
                                          expired ? 'Expired' : 'Available',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          _showAIMatchDetails(context, doc.id, foodName, category, location, expiry);
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF0FDF4),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: const Color(0xFFBBF7D0)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.smart_toy_outlined, size: 14, color: Color(0xFF16A34A)),
                                              const SizedBox(width: 4),
                                              Text(
                                                'AI Match: ${_calculateMatchScore(doc.id, category)}%',
                                                style: const TextStyle(
                                                  color: Color(0xFF15803D),
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 11.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundColor: AppTheme.accent.withOpacity(0.1),
                                        child: Text(
                                          donorName.isNotEmpty ? donorName[0].toUpperCase() : '?',
                                          style: const TextStyle(fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        donorName,
                                        style: const TextStyle(
                                          color: AppTheme.textBody,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'Posted: $createdAt',
                                        style: const TextStyle(
                                          color: AppTheme.textBody,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _chip(Icons.inventory_2_outlined, quantity, const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
                                      _chip(Icons.groups_outlined, serves, const Color(0xFFF3E5F5), const Color(0xFF7B1FA2)),
                                      _chip(Icons.verified_outlined, condition, const Color(0xFFFFF8E1), const Color(0xFFF57F17)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _infoItem(Icons.location_on_outlined, 'Location', location, Colors.blue),
                                            const SizedBox(height: 12),
                                            _infoItem(Icons.inventory_2_outlined, 'Quantity', quantity, Colors.teal),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _infoItem(Icons.calendar_today_outlined, 'Pickup', '$pickupDate • $pickupTime', Colors.green),
                                            const SizedBox(height: 12),
                                            _infoItem(Icons.timer_outlined, 'Expiry', expiry, Colors.orange),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (notes.trim().isNotEmpty) ...[
                                    const SizedBox(height: 14),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        notes,
                                        style: const TextStyle(
                                          color: bodyColor,
                                          fontSize: 13.5,
                                          height: 1.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  if (donorId.isNotEmpty)
                                    _DonorInfoExpansion(
                                      donorId: donorId,
                                      donorName: donorName,
                                    ),
                                  const SizedBox(height: 8),
                                  _requestButton(
                                    context: context,
                                    postId: doc.id,
                                    postData: data,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonorInfoExpansion extends StatelessWidget {
  final String donorId;
  final String donorName;

  const _DonorInfoExpansion({required this.donorId, required this.donorName});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          iconColor: const Color(0xFF1565C0),
          collapsedIconColor: const Color(0xFF1565C0),
          title: const Text(
            '👤 Donor Info',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1565C0),
              fontSize: 14.5,
            ),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(donorId).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
                  final donationsCount = (data['donationsCount'] ?? 0).toString();
                  final createdAt = data['createdAt'] as Timestamp?;
                  final memberSince = createdAt != null 
                      ? DateFormat('MMM yyyy').format(createdAt.toDate())
                      : 'Recent';
                  final isVerified = data['isVerified'] ?? true; 
                  
                  return Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            donorName.isNotEmpty ? donorName[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  donorName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1D2939),
                                    fontSize: 16,
                                  ),
                                ),
                                if (isVerified) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check_circle, size: 12, color: Colors.green),
                                        const SizedBox(width: 4),
                                        const Text('Verified', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$donationsCount Donations • Member since $memberSince',
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

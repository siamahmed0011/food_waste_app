import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BrowseFoodScreen extends StatelessWidget {
  const BrowseFoodScreen({super.key});

  static const Color primary = Color(0xFF1565C0);
  static const Color background = Color(0xFFF6F7F9);
  static const Color titleColor = Color(0xFF1D2939);
  static const Color bodyColor = Color(0xFF6B7280);

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please sign in first')));
      return;
    }

    final orgDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final orgData = orgDoc.data() ?? {};
    final organizationName = (orgData['name'] ?? 'Organization').toString();

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
          'status': 'pending',
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Request sent successfully')));
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
        .update({'status': 'cancelled', 'updatedAt': Timestamp.now()});

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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Request cancelled')));
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 190,
      width: double.infinity,
      color: const Color(0xFFE8F1FD),
      child: const Center(
        child: Icon(Icons.fastfood_rounded, size: 54, color: primary),
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FD),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: primary,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: primary),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: bodyColor,
                fontSize: 13.5,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: value),
              ],
            ),
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
          return SizedBox(
            width: double.infinity,
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
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Browse Food',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'See live food donation posts from donors in real time.',
                    style: TextStyle(fontSize: 14.5, color: bodyColor),
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

                  final docs = snapshot.data?.docs ?? [];

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
                              color: Colors.black.withOpacity(0.04),
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

                      final foodName = (data['foodName'] ?? 'Food Item')
                          .toString();
                      final quantity = (data['quantity'] ?? 'Not specified')
                          .toString();
                      final category = (data['category'] ?? 'Not specified')
                          .toString();
                      final condition = (data['condition'] ?? 'Not specified')
                          .toString();
                      final location =
                          (data['location'] ?? 'Location not added').toString();
                      final serves = (data['serves'] ?? 'Not specified')
                          .toString();
                      final notes = (data['notes'] ?? '').toString();
                      final donorName = (data['donorName'] ?? 'Donor')
                          .toString();
                      final pickupDate = (data['pickupDate'] ?? 'Not set')
                          .toString();
                      final pickupTime = (data['pickupTime'] ?? 'Not set')
                          .toString();
                      final expiry = (data['expiry'] ?? 'Not specified')
                          .toString();
                      final imageUrl = (data['imageUrl'] ?? '').toString();
                      final createdAt = _formatTimestamp(data['createdAt']);
                      final expired = _isExpired(data);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      height: 190,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _buildImagePlaceholder(),
                                    )
                                  : _buildImagePlaceholder(),
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
                                            fontWeight: FontWeight.w800,
                                            color: titleColor,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: expired
                                              ? const Color(0xFFFFE5E5)
                                              : const Color(0xFFE8F1FD),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        child: Text(
                                          expired ? 'Expired' : 'Available',
                                          style: TextStyle(
                                            color: expired
                                                ? Colors.red
                                                : primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Posted by: $donorName',
                                    style: const TextStyle(
                                      color: bodyColor,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _chip(Icons.category_outlined, category),
                                      _chip(
                                        Icons.inventory_2_outlined,
                                        quantity,
                                      ),
                                      _chip(Icons.groups_outlined, serves),
                                      _chip(Icons.verified_outlined, condition),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _infoRow(
                                    Icons.location_on_outlined,
                                    'Location',
                                    location,
                                  ),
                                  const SizedBox(height: 10),
                                  _infoRow(
                                    Icons.calendar_today_outlined,
                                    'Pickup',
                                    '$pickupDate • $pickupTime',
                                  ),
                                  const SizedBox(height: 10),
                                  _infoRow(
                                    Icons.timer_outlined,
                                    'Expiry',
                                    expiry,
                                  ),
                                  const SizedBox(height: 10),
                                  _infoRow(
                                    Icons.access_time_outlined,
                                    'Posted',
                                    createdAt,
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

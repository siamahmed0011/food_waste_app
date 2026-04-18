import 'package:cloud_firestore/cloud_firestore.dart';
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
      final dt = value.toDate();
      return DateFormat('dd MMM yyyy • hh:mm a').format(dt);
    }
    return 'Not available';
  }

  bool _isExpired(Map<String, dynamic> data) {
    final expiryText = (data['expiry'] ?? '').toString().trim().toLowerCase();
    final status = (data['status'] ?? '').toString().trim().toLowerCase();

    if (status == 'expired') return true;
    if (expiryText.contains('expired')) return true;

    return false;
  }

  Color _statusBg(bool expired) {
    return expired ? const Color(0xFFFFE5E5) : const Color(0xFFE8F1FD);
  }

  Color _statusText(bool expired) {
    return expired ? Colors.red : primary;
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
                          'Something went wrong.\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: bodyColor),
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
                      final data = docs[index].data() as Map<String, dynamic>;

                      final foodName = (data['foodName'] ?? 'Food Item')
                          .toString();
                      final quantity = (data['quantity'] ?? 'Not specified')
                          .toString();
                      final category =
                          (data['category'] ?? 'Category not added').toString();
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
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return _buildImagePlaceholder();
                                          },
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
                                          color: _statusBg(expired),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        child: Text(
                                          expired ? 'Expired' : 'Available',
                                          style: TextStyle(
                                            color: _statusText(expired),
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
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: expired ? null : () {},
                                      icon: const Icon(Icons.send_outlined),
                                      label: Text(
                                        expired
                                            ? 'Request Unavailable'
                                            : 'Send Request',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primary,
                                        disabledBackgroundColor:
                                            Colors.blue.shade200,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                    ),
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

  Widget _buildImagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: const Color(0xFFEAF2FD),
      child: const Center(
        child: Icon(Icons.fastfood_rounded, size: 56, color: primary),
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

  Widget _infoRow(IconData icon, String title, String value) {
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
                  text: '$title: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: titleColor,
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
}

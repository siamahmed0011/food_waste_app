import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'edit_donation_screen.dart';

class MyDonationsScreen extends StatelessWidget {
  const MyDonationsScreen({super.key});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.orange;
      case 'requested':
        return Colors.blue;
      case 'accepted':
        return Colors.green;
      case 'completed':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Icons.inventory_2_outlined;
      case 'requested':
        return Icons.notifications_active_outlined;
      case 'accepted':
        return Icons.check_circle_outline;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  bool _canEditOrDelete(String status) {
    final s = status.toLowerCase();
    return s == 'available' || s == 'requested';
  }

  Future<void> _deleteDonation(
    BuildContext context,
    String docId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Donation'),
          content: const Text(
            'Are you sure you want to delete this donation post?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('food_posts')
          .doc(docId)
          .delete();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation deleted successfully')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    const Color background = Color(0xFFF6F7F9);
    const Color titleColor = Color(0xFF1D2939);
    const Color bodyColor = Color(0xFF6B7280);
    const Color borderColor = Color(0xFFE3E8E4);

    if (user == null) {
      return Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: background,
          elevation: 0,
          foregroundColor: titleColor,
          title: const Text(
            'My Donations',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: const Center(
          child: Text('Please sign in first'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        foregroundColor: titleColor,
        title: const Text(
          'My Donations',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('food_posts')
            .where('donorId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Something went wrong: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fastfood_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 14),
                    Text(
                      'No donations posted yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your food posts will appear here once you publish a donation.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: bodyColor, height: 1.5),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final foodName = (data['foodName'] ?? 'Unnamed Food').toString();
              final category = (data['category'] ?? 'Unknown').toString();
              final quantity = (data['quantity'] ?? 'Not specified').toString();
              final location = (data['location'] ?? 'No location').toString();
              final pickupDate = (data['pickupDate'] ?? 'No date').toString();
              final pickupTime = (data['pickupTime'] ?? 'No time').toString();
              final status = (data['status'] ?? 'available').toString();

              final statusColor = _statusColor(status);
              final canEditDelete = _canEditOrDelete(status);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
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
                            foodName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
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
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _statusIcon(status),
                                size: 16,
                                color: statusColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$category • $quantity',
                      style: const TextStyle(
                        color: bodyColor,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: bodyColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(
                              color: bodyColor,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 17,
                          color: bodyColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          pickupDate,
                          style: const TextStyle(
                            color: bodyColor,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Icon(
                          Icons.access_time_outlined,
                          size: 17,
                          color: bodyColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          pickupTime,
                          style: const TextStyle(
                            color: bodyColor,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                    if (canEditDelete) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditDonationScreen(
                                      docId: doc.id,
                                      donationData: data,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Edit'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _deleteDonation(context, doc.id);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Delete'),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 14),
                      const Text(
                        'This donation can no longer be edited or deleted.',
                        style: TextStyle(
                          color: bodyColor,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
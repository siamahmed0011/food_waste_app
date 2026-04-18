import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrganizationRequestsScreen extends StatefulWidget {
  const OrganizationRequestsScreen({super.key});

  @override
  State<OrganizationRequestsScreen> createState() =>
      _OrganizationRequestsScreenState();
}

class _OrganizationRequestsScreenState
    extends State<OrganizationRequestsScreen> {
  int selectedTab = 0;

  final List<String> tabs = const [
    'Pending',
    'Accepted',
    'Declined',
    'Cancelled',
    'Collected',
  ];

  static const Color background = Color(0xFFF6F7F9);
  static const Color primary = Color(0xFF1565C0);
  static const Color titleColor = Color(0xFF1D2939);
  static const Color bodyColor = Color(0xFF6B7280);

  String get selectedStatus => tabs[selectedTab].toLowerCase();

  String _formatTime(dynamic value) {
    if (value is Timestamp) {
      return DateFormat('dd MMM yyyy • hh:mm a').format(value.toDate());
    }
    return 'Not available';
  }

  Future<void> _markRead(String id) async {
    await FirebaseFirestore.instance.collection('notifications').doc(id).update(
      {'isRead': true},
    );
  }

  Future<void> _cancelPendingRequest({
    required String requestId,
    required Map<String, dynamic> data,
  }) async {
    await FirebaseFirestore.instance
        .collection('pickup_requests')
        .doc(requestId)
        .update({
        'status': 'cancelled',
        'pickupStatus': 'cancelled',
        'updatedAt': Timestamp.now(),
        'pickupUpdatedAt': Timestamp.now(),
      });

    final donorId = (data['donorId'] ?? '').toString();
    if (donorId.isNotEmpty) {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': donorId,
        'title': 'Request cancelled',
        'body':
            '${(data['organizationName'] ?? 'Organization')} cancelled request for ${(data['foodName'] ?? 'food')}',
        'type': 'request_cancelled',
        'isRead': false,
        'createdAt': Timestamp.now(),
        'requestId': requestId,
        'postId': (data['postId'] ?? '').toString(),
      });
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request cancelled successfully')),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'cancelled':
        return Colors.orange;
      case 'collected':
        return Colors.teal;
      default:
        return primary;
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'accepted':
        return const Color(0xFFE7F6EA);
      case 'declined':
        return const Color(0xFFFFE5E5);
      case 'cancelled':
        return const Color(0xFFFFF1E4);
      case 'collected':
        return const Color(0xFFE5F7F5);
      default:
        return const Color(0xFFE8F1FD);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'accepted':
        return Icons.check_circle_outline;
      case 'declined':
        return Icons.close_rounded;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'collected':
        return Icons.inventory_2_outlined;
      default:
        return Icons.hourglass_top_rounded;
    }
  }
Future<void> schedulePickup({
  required BuildContext context,
  required String requestId,
}) async {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  selectedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 30)),
  );

  if (selectedDate == null) return;

  selectedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (selectedTime == null) return;

  await FirebaseFirestore.instance
      .collection('pickup_requests')
      .doc(requestId)
      .update({
    'pickupStatus': 'scheduled',
    'pickupDate': DateFormat('dd MMM yyyy').format(selectedDate),
    'pickupTime': selectedTime.format(context),
    'updatedAt': Timestamp.now(),
    'pickupUpdatedAt': Timestamp.now(),
  });

  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Pickup scheduled')),
  );
}
Future<void> markOnTheWay(String requestId) async {
  await FirebaseFirestore.instance
      .collection('pickup_requests')
      .doc(requestId)
      .update({
    'pickupStatus': 'on_the_way',
    'updatedAt': Timestamp.now(),
    'pickupUpdatedAt': Timestamp.now(),
  });
}

Future<void> markCompleted(String requestId) async {
  await FirebaseFirestore.instance
      .collection('pickup_requests')
      .doc(requestId)
      .update({
    'pickupStatus': 'completed',
    'updatedAt': Timestamp.now(),
    'pickupUpdatedAt': Timestamp.now(),
  });
}
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(
          child: Text(
            'Please sign in first',
            style: TextStyle(color: bodyColor),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Requests',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Track all your pickup requests and live status updates.',
                    style: TextStyle(fontSize: 14.5, color: bodyColor),
                  ),
                  const SizedBox(height: 16),

                  // Notifications
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('notifications')
                        .where('userId', isEqualTo: user.uid)
                        .orderBy('createdAt', descending: true)
                        .limit(5)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const SizedBox.shrink();
                      }

                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 14,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Notifications',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...docs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final isRead = (data['isRead'] ?? false) as bool;
                              final title = (data['title'] ?? '').toString();
                              final body = (data['body'] ?? '').toString();

                              return InkWell(
                                onTap: () => _markRead(doc.id),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isRead
                                        ? const Color(0xFFF8FAFC)
                                        : const Color(0xFFE8F1FD),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        isRead
                                            ? Icons.notifications_none_rounded
                                            : Icons.notifications_active,
                                        color: primary,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: titleColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              body,
                                              style: const TextStyle(
                                                color: bodyColor,
                                                fontSize: 13.5,
                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),

                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: tabs.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final selected = selectedTab == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTab = index;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: selected ? primary : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              tabs[index],
                              style: TextStyle(
                                color: selected ? Colors.white : titleColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pickup_requests')
                    .where('organizationId', isEqualTo: user.uid)
                    .where('status', isEqualTo: selectedStatus)
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

                  final docs = snapshot.data?.docs.toList() ?? [];

                  docs.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;

                    final aTime =
                        (aData['updatedAt'] as Timestamp?)
                            ?.millisecondsSinceEpoch ??
                        0;
                    final bTime =
                        (bData['updatedAt'] as Timestamp?)
                            ?.millisecondsSinceEpoch ??
                        0;

                    return bTime.compareTo(aTime);
                  });

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No requests found in this section',
                        style: TextStyle(color: bodyColor, fontSize: 14.5),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final requestId = doc.id;
                      final foodName = (data['foodName'] ?? '').toString();
                      final donorName = (data['donorName'] ?? '').toString();
                      final location = (data['location'] ?? '').toString();
                      final quantity = (data['quantity'] ?? '').toString();
                      final status = (data['status'] ?? '').toString();
                      final updatedAt = _formatTime(data['updatedAt']);
                      final pickupStatus = (data['pickupStatus'] ?? '').toString();
                      final pickupTime = (data['pickupTime'] ?? '').toString();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 14,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: _statusBg(status),
                                  child: Icon(
                                    _statusIcon(status),
                                    color: _statusColor(status),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    foodName,
                                    style: const TextStyle(
                                      fontSize: 15.5,
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
                                    color: _statusBg(status),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    status == 'accepted' && pickupStatus == 'scheduled'
                                    ? 'Scheduled'
                                    : status == 'accepted' && pickupStatus == 'on_the_way'
                                        ? 'On the Way'
                                        : status == 'accepted' && pickupStatus == 'completed'
                                            ? 'Completed'
                                            : status[0].toUpperCase() + status.substring(1),
                                    style: TextStyle(
                                      color: _statusColor(status),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Donor: $donorName',
                              style: const TextStyle(
                                color: bodyColor,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Quantity: $quantity',
                              style: const TextStyle(
                                color: bodyColor,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              location,
                              style: const TextStyle(
                                color: bodyColor,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Updated: $updatedAt',
                              style: const TextStyle(
                                color: bodyColor,
                                fontSize: 13.5,
                              ),
                            ),
                            if (status == 'pending') ...[
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => _cancelPendingRequest(
                                    requestId: doc.id,
                                    data: data,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(
                                      color: Colors.redAccent,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel Request',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            if (status == 'accepted' && pickupStatus == 'accepted') ...[
                            const SizedBox(height: 14),
                            ElevatedButton(
                              onPressed: () {
                                schedulePickup(
                                  context: context,
                                  requestId: requestId,
                                );
                              },
                              child: const Text('Schedule Pickup'),
                            ),
                          ],

                          if (status == 'accepted' && pickupStatus == 'scheduled') ...[
                            const SizedBox(height: 14),
                            ElevatedButton(
                              onPressed: () => markOnTheWay(requestId),
                              child: const Text('On the Way'),
                            ),
                          ],

                          if (status == 'accepted' && pickupStatus == 'on_the_way') ...[
                            const SizedBox(height: 14),
                            ElevatedButton(
                              onPressed: () => markCompleted(requestId),
                              child: const Text('Completed'),
                            ),
                          ],
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

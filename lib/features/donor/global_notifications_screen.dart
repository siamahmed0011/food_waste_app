import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GlobalNotificationsScreen extends StatelessWidget {
  const GlobalNotificationsScreen({super.key});

  bool _isVisibleToUser(Map<String, dynamic> data, String uid) {
    final isGlobal = data['isGlobal'] == true;
    final targetUserId = (data['targetUserId'] ?? '').toString();
    return isGlobal || targetUserId == uid;
  }

  bool _isRead(Map<String, dynamic> data, String uid) {
    final readBy = List<String>.from(data['readBy'] ?? []);
    return readBy.contains(uid);
  }

  Future<void> _markAsRead(String docId, String uid) async {
    await FirebaseFirestore.instance.collection('notifications').doc(docId).set(
      {
        'readBy': FieldValue.arrayUnion([uid]),
      },
      SetOptions(merge: true),
    );
  }

  String _formatTime(dynamic value) {
    if (value is Timestamp) {
      return DateFormat('dd MMM yyyy • hh:mm a').format(value.toDate());
    }
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF1D2939);
    const bodyColor = Color(0xFF667085);
    const primary = Color(0xFF2E7D32);

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please sign in first')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(color: titleColor, fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: titleColor),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
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
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final docs = (snapshot.data?.docs ?? []).where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _isVisibleToUser(data, user.uid);
          }).toList();

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final isRead = _isRead(data, user.uid);

              final title = (data['title'] ?? 'Notification').toString();
              final body = (data['body'] ?? '').toString();
              final createdAt = data['createdAt'];

              return GestureDetector(
                onTap: () async {
                  await _markAsRead(doc.id, user.uid);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isRead ? Colors.white : const Color(0xFFEFF8F0),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isRead
                          ? const Color(0xFFE5E7EB)
                          : const Color(0xFFCDE8D0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: isRead
                            ? const Color(0xFFF1F5F9)
                            : const Color(0xFFDDF1E0),
                        child: Icon(
                          isRead
                              ? Icons.notifications_none_rounded
                              : Icons.notifications_active_rounded,
                          color: primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w800,
                                      color: titleColor,
                                    ),
                                  ),
                                ),
                                if (!isRead)
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              body,
                              style: const TextStyle(
                                fontSize: 13.5,
                                height: 1.45,
                                color: bodyColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _formatTime(createdAt),
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

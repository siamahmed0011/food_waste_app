import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_waste_app/features/admin/admin_dashboard_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════
// FILE: admin_pickups_screen.dart
// Wired to real Firestore pickup_requests collection
// ═══════════════════════════════════════════════════════════════════════════

class AdminPickupsScreen extends StatefulWidget {
  const AdminPickupsScreen({super.key});
  @override
  State<AdminPickupsScreen> createState() => _AdminPickupsScreenState();
}

class _AdminPickupsScreenState extends State<AdminPickupsScreen> {
  String _filter = 'all';

  Color _statusColor(String s) {
    switch (s) {
      case 'pending': return const Color(0xFFFF8F00);
      case 'accepted': return const Color(0xFF2E7D32);
      case 'declined':
      case 'rejected': return const Color(0xFFE53935);
      case 'cancelled': return const Color(0xFF6B7280);
      case 'collected':
      case 'completed': return const Color(0xFF0288D1);
      default: return const Color(0xFF6B7280);
    }
  }

  Color _statusBg(String s) {
    switch (s) {
      case 'pending': return const Color(0xFFFFF8E1);
      case 'accepted': return const Color(0xFFE8F5E9);
      case 'declined':
      case 'rejected': return const Color(0xFFFFEBEE);
      case 'cancelled': return const Color(0xFFF4F6FA);
      case 'collected':
      case 'completed': return const Color(0xFFE3F2FD);
      default: return const Color(0xFFF4F6FA);
    }
  }

  String _normalize(dynamic v) => v?.toString().toLowerCase().trim() ?? '';

  String _foodTitle(Map<String, dynamic> data) =>
      (data['foodTitle'] ?? data['title'] ?? data['donationTitle'] ?? 'Pickup').toString();

  String _ngo(Map<String, dynamic> data) =>
      (data['ngoName'] ?? data['organizationName'] ?? 'Unknown').toString();

  String _donor(Map<String, dynamic> data) =>
      (data['donorName'] ?? data['userName'] ?? data['name'] ?? 'Unknown').toString();

  String _location(Map<String, dynamic> data) =>
      (data['location'] ?? data['address'] ?? data['pickupLocation'] ?? '').toString();

  int _timestampToMillis(dynamic value) {
    if (value is Timestamp) return value.millisecondsSinceEpoch;
    if (value is DateTime) return value.millisecondsSinceEpoch;
    return 0;
  }

  String _dateLabel(Map<String, dynamic> data) {
    dynamic ts = data['createdAt'] ?? data['requestedAt'];
    if (ts is Timestamp) {
      final d = ts.toDate();
      const months = ['Jan','Feb','Mar','Apr','May','Jun',
                      'Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${months[d.month - 1]} ${d.day}';
    }
    return '';
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
        title: Text('All Pickups',
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1F36))),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(kPickupsCollection)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
                child: Text('Error: ${snap.error}',
                    style: const TextStyle(color: Colors.red)));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allDocs = [...snap.data!.docs];
          allDocs.sort((a, b) => _timestampToMillis(b.data()['createdAt'])
              .compareTo(_timestampToMillis(a.data()['createdAt'])));

          final filtered = _filter == 'all'
              ? allDocs
              : allDocs
                  .where((d) => _normalize(d.data()['status']) == _filter)
                  .toList();

          int countStatus(String s) => s == 'all'
              ? allDocs.length
              : allDocs
                  .where((d) => _normalize(d.data()['status']) == s)
                  .length;

          return Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                child: Column(
                  children: [
                    // Stats strip
                    Row(
                      children:
                          ['pending', 'accepted', 'collected', 'declined']
                              .map((s) => Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                          color: _statusBg(s),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        children: [
                                          Text(countStatus(s).toString(),
                                              style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: _statusColor(s))),
                                          Text(s,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 9,
                                                  color: _statusColor(s))),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList(),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'all',
                          'pending',
                          'collected',
                        ].map((f) {
                          final sel = _filter == f;
                          return GestureDetector(
                            onTap: () => setState(() => _filter = f),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: sel
                                    ? const Color(0xFF0288D1)
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text('${filtered.length} pickups',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0288D1))),
                  ],
                ),
              ),
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
                              child: const Icon(Icons.local_shipping_outlined,
                                  color: Color(0xFF9CA3AF), size: 40),
                            ),
                            const SizedBox(height: 12),
                            Text('No pickups found',
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
                          final status = _normalize(data['status']);
                          final foodTitle = _foodTitle(data);
                          final ngo = _ngo(data);
                          final donor = _donor(data);
                          final location = _location(data);
                          final date = _dateLabel(data);

                          return Container(
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
                                      color: _statusBg(status),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Icon(Icons.local_shipping_outlined,
                                      color: _statusColor(status), size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text('$foodTitle pickup',
                                                style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        const Color(0xFF1A1F36)),
                                                overflow: TextOverflow.ellipsis),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                                color: _statusBg(status),
                                                borderRadius:
                                                    BorderRadius.circular(6)),
                                            child: Text(
                                                status.isEmpty ? 'N/A' : status,
                                                style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        _statusColor(status))),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.corporate_fare_outlined,
                                              size: 12,
                                              color: Color(0xFF9CA3AF)),
                                          const SizedBox(width: 3),
                                          Text(ngo,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color:
                                                      const Color(0xFF6B7280))),
                                          if (location.isNotEmpty) ...[
                                            const SizedBox(width: 10),
                                            const Icon(Icons.location_on_outlined,
                                                size: 12,
                                                color: Color(0xFF9CA3AF)),
                                            const SizedBox(width: 3),
                                            Expanded(
                                              child: Text(location,
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 11,
                                                      color: const Color(
                                                          0xFF6B7280)),
                                                  overflow: TextOverflow.ellipsis),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.person_outline,
                                              size: 12,
                                              color: Color(0xFF9CA3AF)),
                                          const SizedBox(width: 3),
                                          Text('Donor: $donor',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  color:
                                                      const Color(0xFF9CA3AF))),
                                          if (date.isNotEmpty) ...[
                                            const SizedBox(width: 10),
                                            Text(date,
                                                style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    color: const Color(
                                                        0xFF9CA3AF))),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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

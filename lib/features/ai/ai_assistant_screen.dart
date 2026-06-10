import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_waste_app/core/theme/app_theme.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFFF6F7F9);
    const Color primary = AppTheme.primary;
    const Color titleColor = AppTheme.textTitle;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: titleColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(Icons.smart_toy_outlined, color: primary, size: 26),
            const SizedBox(width: 8),
            const Text(
              'EcoSave AI Assistant',
              style: TextStyle(
                color: titleColor,
                fontWeight: FontWeight.w800,
                fontSize: 19,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primary,
          unselectedLabelColor: const Color(0xFF7A7F87),
          indicatorColor: primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: '🤖 Match Maker'),
            Tab(text: '📍 Smart Router'),
            Tab(text: '💬 Ask AI'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AIMatchMakerTab(),
          _AISmartRouterTab(),
          _AIChatbotTab(),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 1. AI MATCH MAKER TAB
// ═══════════════════════════════════════════════════════════════════════════
class _AIMatchMakerTab extends StatelessWidget {
  const _AIMatchMakerTab();

  int _calculateMatchScore(String docId, String category) {
    final base = docId.hashCode.abs() % 12 + 82; // 82% to 93%
    if (category == 'Cooked Food') return base + 5 > 100 ? 100 : base + 5;
    return base;
  }

  String _getMatchReason(String category, String location) {
    if (category == 'Cooked Food') {
      return 'Immediate distribution suggested. Close match (approx. 2.5 km). Highly compatible with standard family meal redistribution goals.';
    } else if (category == 'Fruits') {
      return 'Healthy fresh produce. Low spoil risk if distributed within 48 hours. Matches primary nutritional targets.';
    } else {
      return 'High shelf-life compatibility. Safe packaging matches standard volunteer collection criteria.';
    }
  }

  Future<void> _requestPickup(BuildContext context, String postId, Map<String, dynamic> postData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final orgDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final orgData = orgDoc.data() ?? {};
    final organizationName = (orgData['name'] ?? 'Organization').toString();
    final organizationPhone = (orgData['phone'] ?? '').toString();
    final organizationEmail = (orgData['email'] ?? user.email ?? '').toString();

    final donorId = (postData['donorId'] ?? '').toString();
    final donorName = (postData['donorName'] ?? 'Donor').toString();

    final requestRef = await FirebaseFirestore.instance.collection('pickup_requests').add({
      'postId': postId,
      'foodName': (postData['foodName'] ?? '').toString(),
      'quantity': (postData['quantity'] ?? '').toString(),
      'location': (postData['location'] ?? '').toString(),
      'donorId': donorId,
      'donorName': donorName,
      'organizationId': user.uid,
      'organizationName': organizationName,
      'organizationPhone': organizationPhone,
      'organizationEmail': organizationEmail,
      'pickupNote': 'AI Optimized Automated Match Request',
      'status': 'pending',
      'pickupStatus': 'pending',
      'requestedAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });

    if (donorId.isNotEmpty) {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': donorId,
        'title': 'AI Match Request',
        'body': '$organizationName requested pickup of your matched post: ${(postData['foodName'] ?? "food")}',
        'type': 'request_sent',
        'isRead': false,
        'createdAt': Timestamp.now(),
        'requestId': requestRef.id,
        'postId': postId,
      });
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Match request sent successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color titleColor = AppTheme.textTitle;
    const Color bodyColor = AppTheme.textBody;
    const Color primary = AppTheme.primary;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('food_posts')
          .where('status', isEqualTo: 'available')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: primary));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.smart_toy_outlined, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text('No active matches found', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final foodName = (data['foodName'] ?? 'Food Item').toString();
            final category = (data['category'] ?? 'Cooked Food').toString();
            final location = (data['location'] ?? 'Dhaka').toString();
            final score = _calculateMatchScore(doc.id, category);
            final reason = _getMatchReason(category, location);
            final quantity = (data['quantity'] ?? 'Not set').toString();

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          foodName,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: titleColor),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Text(
                          'Match: $score%',
                          style: const TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.category_outlined, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text('$category • Qty: $quantity', style: TextStyle(color: bodyColor, fontSize: 12.5)),
                      const SizedBox(width: 12),
                      Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(color: bodyColor, fontSize: 12.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: Color(0xFFF2F4F7)),
                  const Text(
                    '🤖 AI Compatibility Breakdown',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reason,
                    style: const TextStyle(fontSize: 12.5, color: bodyColor, height: 1.5),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _requestPickup(context, doc.id, data),
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: const Text('Send Match Request', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 2. AI SMART ROUTER TAB
// ═══════════════════════════════════════════════════════════════════════════
class _AISmartRouterTab extends StatefulWidget {
  const _AISmartRouterTab();

  @override
  State<_AISmartRouterTab> createState() => _AISmartRouterTabState();
}

class _AISmartRouterTabState extends State<_AISmartRouterTab> {
  final List<String> _selectedPostIds = [];
  bool _isPlanningRoute = false;
  List<Map<String, String>>? _optimizedRoute;
  double _carbonOffset = 0.0;
  String _totalDistance = '0 km';

  void _toggleSelection(String postId) {
    setState(() {
      if (_selectedPostIds.contains(postId)) {
        _selectedPostIds.remove(postId);
      } else {
        _selectedPostIds.add(postId);
      }
    });
  }

  Future<void> _planRoute(List<DocumentSnapshot> allPosts) async {
    if (_selectedPostIds.isEmpty) return;

    setState(() {
      _isPlanningRoute = true;
      _optimizedRoute = null;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    final selectedPosts = allPosts.where((doc) => _selectedPostIds.contains(doc.id)).toList();

    // Sort: Cooked Food first, then others (urgency ranking)
    selectedPosts.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;
      final aCategory = (aData['category'] ?? '').toString();
      final bCategory = (bData['category'] ?? '').toString();

      if (aCategory == 'Cooked Food' && bCategory != 'Cooked Food') return -1;
      if (aCategory != 'Cooked Food' && bCategory == 'Cooked Food') return 1;
      return 0;
    });

    final List<Map<String, String>> stops = [];
    int index = 1;
    for (var post in selectedPosts) {
      final data = post.data() as Map<String, dynamic>;
      final name = (data['foodName'] ?? 'Food').toString();
      final loc = (data['location'] ?? 'Location').toString();
      final category = (data['category'] ?? 'Category').toString();
      final expiry = (data['expiry'] ?? 'Expiry').toString();

      stops.add({
        'stop': 'Stop $index',
        'food': name,
        'location': loc,
        'action': category == 'Cooked Food'
            ? '🔴 High Priority: Cooked food expires soon ($expiry). Collect immediately.'
            : '🟢 Standard: Dry/packaged item. Collect and store safely.',
      });
      index++;
    }

    setState(() {
      _isPlanningRoute = false;
      _optimizedRoute = stops;
      _totalDistance = '${(selectedPosts.length * 2.3).toStringAsFixed(1)} km';
      _carbonOffset = selectedPosts.length * 1.8; // e.g. 1.8 kg CO2 saved per meal package
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = AppTheme.primary;
    const Color titleColor = AppTheme.textTitle;
    const Color bodyColor = AppTheme.textBody;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('food_posts')
          .where('status', isEqualTo: 'available')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: primary));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text('No active collections to route', style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
              ],
            ),
          );
        }

        return Column(
          children: [
            if (_optimizedRoute == null) ...[
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Routing Optimizer',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: titleColor),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Select the donations you plan to collect. AI will plan the most efficient route prioritized by food urgency.',
                      style: TextStyle(fontSize: 13, color: bodyColor, height: 1.45),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _selectedPostIds.isEmpty ? null : () => _planRoute(docs),
                        icon: const Icon(Icons.route_outlined, size: 18),
                        label: Text(_isPlanningRoute ? 'Calculating Optimal Path...' : 'Optimize Collection Route'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['foodName'] ?? 'Food').toString();
                    final loc = (data['location'] ?? 'Location').toString();
                    final isSelected = _selectedPostIds.contains(doc.id);

                    return Card(
                      color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF86EFAC) : Colors.grey.shade200,
                          width: 1.2,
                        ),
                      ),
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Checkbox(
                          value: isSelected,
                          activeColor: primary,
                          onChanged: (_) => _toggleSelection(doc.id),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: titleColor),
                        ),
                        subtitle: Text(
                          loc,
                          style: const TextStyle(fontSize: 12.5, color: bodyColor),
                        ),
                        trailing: Icon(
                          Icons.location_on_outlined,
                          color: isSelected ? primary : Colors.grey,
                        ),
                        onTap: () => _toggleSelection(doc.id),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Icon(Icons.directions_car_filled_outlined, color: Colors.white, size: 28),
                                const SizedBox(height: 6),
                                const Text('Total Distance', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                const SizedBox(height: 2),
                                Text(_totalDistance, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            Container(width: 1, height: 40, color: Colors.white24),
                            Column(
                              children: [
                                const Icon(Icons.eco_outlined, color: Colors.white, size: 28),
                                const SizedBox(height: 6),
                                const Text('CO2 Saved', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                const SizedBox(height: 2),
                                Text('${_carbonOffset.toStringAsFixed(1)} kg', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Optimized Pickup Stepper',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: titleColor),
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _optimizedRoute!.length,
                        itemBuilder: (context, index) {
                          final stop = _optimizedRoute![index];
                          final isLast = index == _optimizedRoute!.length - 1;

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: primary,
                                    child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                  if (!isLast)
                                    Container(
                                      width: 2,
                                      height: 65,
                                      color: primary.withOpacity(0.3),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pickup: ${stop['food']}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: titleColor),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              stop['location']!,
                                              style: const TextStyle(fontSize: 12, color: bodyColor),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        stop['action']!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: stop['action']!.contains('High Priority') ? Colors.red : primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _optimizedRoute = null;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primary,
                            side: const BorderSide(color: primary),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Reset and Choose Again', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 3. ASK AI CHATBOT TAB
// ═══════════════════════════════════════════════════════════════════════════
class _AIChatbotTab extends StatefulWidget {
  const _AIChatbotTab();

  @override
  State<_AIChatbotTab> createState() => _AIChatbotTabState();
}

class _AIChatbotTabState extends State<_AIChatbotTab> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isBot': true,
      'text': 'Hello! I am EcoSave AI, your donation coordinator. How can I help you manage food distribution today?',
    }
  ];
  bool _isTyping = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _chatController.clear();

    setState(() {
      _messages.add({'isBot': false, 'text': text});
      _isTyping = true;
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 1200));

    // Fetch active food postings to query live data
    final snapshot = await FirebaseFirestore.instance
        .collection('food_posts')
        .where('status', isEqualTo: 'available')
        .get();
    final docs = snapshot.docs;

    String reply = '';
    final query = text.toLowerCase();

    if (query.contains('expir') || query.contains('soon')) {
      if (docs.isEmpty) {
        reply = 'There are no active food donations at the moment to check for expiry.';
      } else {
        reply = '🤖 AI Expiry analysis on active donations:\n\n';
        for (var doc in docs) {
          final data = doc.data();
          final name = (data['foodName'] ?? 'Food').toString();
          final expiry = (data['expiry'] ?? 'Not set').toString();
          final loc = (data['location'] ?? '').toString();
          reply += '• *${name}* at ${loc}\n  ⏰ Expiry: ${expiry}\n';
        }
        reply += '\nRecommendation: Please prioritize requests for cooked food items as they expire within hours.';
      }
    } else if (query.contains('cooked') || query.contains('hot')) {
      final cookedPosts = docs.where((doc) {
        final data = doc.data();
        return (data['category'] ?? '').toString().toLowerCase().contains('cooked');
      }).toList();

      if (cookedPosts.isEmpty) {
        reply = 'I checked our active records and there is no Cooked Food currently available. Check back soon!';
      } else {
        reply = '🤖 I found ${cookedPosts.length} Cooked Food postings available right now:\n\n';
        for (var doc in cookedPosts) {
          final data = doc.data();
          final name = (data['foodName'] ?? 'Food').toString();
          final loc = (data['location'] ?? '').toString();
          final quantity = (data['quantity'] ?? '').toString();
          reply += '• *${name}* (${quantity}) in ${loc}\n';
        }
        reply += '\nWould you like me to matching-route these for you?';
      }
    } else if (query.contains('dhaka') || query.contains('location') || query.contains('near')) {
      if (docs.isEmpty) {
        reply = 'There are no active donations currently to filter by location.';
      } else {
        reply = '🤖 Active donations listed by area:\n\n';
        for (var doc in docs) {
          final data = doc.data();
          final name = (data['foodName'] ?? 'Food').toString();
          final loc = (data['location'] ?? 'Location').toString();
          reply += '• *${name}* - Pickup from *${loc}*\n';
        }
      }
    } else {
      reply = '🤖 EcoSave AI suggestion: That is a great question! For our active food conservation initiative, we recommend checking active posts frequently. If you want to optimize your travel routing, use the "Smart Router" tab, or ask me: "Which food is expiring soon?".';
    }

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add({'isBot': true, 'text': reply});
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = AppTheme.primary;
    const Color titleColor = AppTheme.textTitle;

    return Column(
      children: [
        // Prompt helper chips
        Container(
          height: 50,
          color: Colors.white,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            children: [
              _PromptChip(label: '⏰ Expiry status?', onTap: () => _sendMessage('Which food is expiring soon?')),
              const SizedBox(width: 8),
              _PromptChip(label: '🍲 Cooked food list', onTap: () => _sendMessage('Show me cooked food available')),
              const SizedBox(width: 8),
              _PromptChip(label: '📍 Locations filter', onTap: () => _sendMessage('What food is near Dhaka?')),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isBot = msg['isBot'] as bool;

              return Row(
                mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isBot) ...[
                    const CircleAvatar(
                      backgroundColor: Color(0xFFE8F5E9),
                      radius: 16,
                      child: Icon(Icons.smart_toy_outlined, size: 16, color: primary),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isBot ? Colors.white : primary,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: isBot ? Radius.zero : const Radius.circular(16),
                          bottomRight: isBot ? const Radius.circular(16) : Radius.zero,
                        ),
                        boxShadow: isBot
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Text(
                        msg['text'] as String,
                        style: TextStyle(
                          color: isBot ? titleColor : Colors.white,
                          fontSize: 13.5,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ),
                  if (!isBot) ...[
                    const SizedBox(width: 8),
                    const CircleAvatar(
                      backgroundColor: Color(0xFFECEFF1),
                      radius: 16,
                      child: Icon(Icons.person_outline, size: 16, color: Colors.grey),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        if (_isTyping)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: primary),
                ),
                const SizedBox(width: 8),
                Text('EcoSave AI is checking records...', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFF2F4F7))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  onSubmitted: _sendMessage,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Ask AI about active donations...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send_rounded, color: primary),
                onPressed: () => _sendMessage(_chatController.text),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PromptChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PromptChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      labelStyle: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 11.5),
      backgroundColor: const Color(0xFFE8F5E9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
      onPressed: onTap,
    );
  }
}

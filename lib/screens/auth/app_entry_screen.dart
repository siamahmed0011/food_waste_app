import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'welcome_screen.dart';
import 'admin_dashboard_screen.dart';
import 'donor_dashboard_screen.dart';
import 'organization_dashboard_screen.dart';

class AppEntryScreen extends StatelessWidget {
  const AppEntryScreen({super.key});

  Future<Widget> _getHomeForUser(User user) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      return const WelcomeScreen();
    }

    final data = doc.data() ?? {};
    final role = (data['role'] ?? '').toString().toLowerCase().trim();

    if (role == 'admin') {
      return const AdminDashboardScreen();
    } else if (role == 'organization' || role == 'ngo' || role == 'org') {
      return const OrganizationDashboardScreen();
    } else {
      return const DonorDashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const WelcomeScreen();
        }

        return FutureBuilder<Widget>(
          future: _getHomeForUser(user),
          builder: (context, roleSnap) {
            if (roleSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (roleSnap.hasData) {
              return roleSnap.data!;
            }

            return const WelcomeScreen();
          },
        );
      },
    );
  }
}
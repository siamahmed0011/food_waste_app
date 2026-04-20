import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'admin_dashboard_screen.dart';
import 'donor_dashboard_screen.dart';
import 'organization_dashboard_screen.dart';
import 'sign_in_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Widget> _getHome(User user) async {
    // role check করার জন্য চাইলে Firestore থেকেও role আনতে পারো
    // আপাতত email দিয়ে demo logic দিলাম

    final email = user.email ?? "";

    if (email.contains("admin")) {
      return const AdminDashboardScreen();
    } else if (email.contains("org")) {
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

        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<Widget>(
            future: _getHome(snapshot.data!),
            builder: (context, roleSnap) {
              if (!roleSnap.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return roleSnap.data!;
            },
          );
        }

        return const SignInScreen();
      },
    );
  }
}
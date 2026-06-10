import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'package:food_waste_app/features/donor/donor_dashboard_screen.dart';
import 'package:food_waste_app/features/organization/organization_dashboard_screen.dart';
import 'package:food_waste_app/features/auth/app_entry_screen.dart';

import 'package:food_waste_app/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prevent runtime font fetching — use cached/bundled fonts only
  // This fixes broken tofu icons/text when network is unavailable
  GoogleFonts.config.allowRuntimeFetching = false;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AppEntryScreen(),
      routes: {
        '/donorDashboard': (context) => const DonorDashboardScreen(),
        '/organizationDashboard': (context) =>
            const OrganizationDashboardScreen(),
      },
    );
  }
}
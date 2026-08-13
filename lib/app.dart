import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';
import 'features/scanner/screens/scan_screen.dart';
import 'features/triage/screens/symptom_checklist_screen.dart';
import 'features/triage/screens/triage_result_screen.dart';
import 'features/hospital/screens/hospital_radar_screen.dart';

class VenomShieldApp extends StatelessWidget {
  const VenomShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/scan',
          builder: (context, state) => const ScanScreen(),
        ),
        GoRoute(
          path: '/triage-checklist',
          builder: (context, state) => const SymptomChecklistScreen(),
        ),
        GoRoute(
          path: '/triage-result',
          builder: (context, state) => const TriageResultScreen(),
        ),
        GoRoute(
          path: '/hospital-radar',
          builder: (context, state) => const HospitalRadarScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'VenomShield AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';
import 'features/scanner/screens/scan_screen.dart';
import 'features/triage/screens/symptom_checklist_screen.dart';
import 'features/triage/screens/triage_result_screen.dart';
import 'features/hospital/screens/hospital_radar_screen.dart';
import 'features/bite_assessment/screens/bite_assessment_screen.dart';
import 'features/bite_assessment/screens/bite_assessment_result_screen.dart';

class VenomShieldApp extends StatelessWidget {
  const VenomShieldApp({super.key});

  CustomTransitionPage<void> _fadeRoute({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => _fadeRoute(
            state: state,
            child: const HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/scan',
          pageBuilder: (context, state) => _fadeRoute(
            state: state,
            child: const ScanScreen(),
          ),
        ),
        GoRoute(
          path: '/triage-checklist',
          pageBuilder: (context, state) => _fadeRoute(
            state: state,
            child: const SymptomChecklistScreen(),
          ),
        ),
        GoRoute(
          path: '/triage-result',
          pageBuilder: (context, state) => _fadeRoute(
            state: state,
            child: const TriageResultScreen(),
          ),
        ),
        GoRoute(
          path: '/hospital-radar',
          pageBuilder: (context, state) => _fadeRoute(
            state: state,
            child: const HospitalRadarScreen(),
          ),
        ),
        GoRoute(
          path: '/bite-assessment',
          pageBuilder: (context, state) => _fadeRoute(
            state: state,
            child: const BiteAssessmentScreen(),
          ),
        ),
        GoRoute(
          path: '/bite-assessment-result',
          pageBuilder: (context, state) => _fadeRoute(
            state: state,
            child: const BiteAssessmentResultScreen(),
          ),
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

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/database/database_helper.dart';
import 'core/providers/locale_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Run a clean, premium loading splash app instantly
  runApp(const VenomShieldSplashApp());

  String? savedLanguage;
  bool isFirstLaunch = true;

  try {
    // Warm up database and await pending fonts in parallel
    final List<Future<dynamic>> warmUpFutures = [
      GoogleFonts.pendingFonts([GoogleFonts.hindSiliguri()]),
    ];
    if (!kIsWeb) {
      warmUpFutures.add(DatabaseHelper.instance.database);
    }
    await Future.wait<dynamic>(warmUpFutures);

    // Read language settings
    savedLanguage = await DatabaseHelper.instance.getSetting('user_language');
    final hasSelected = await DatabaseHelper.instance.getSetting('has_selected_language');
    isFirstLaunch = hasSelected != 'true';
  } catch (e) {
    print('Startup initialization error: $e');
  }

  // Swap to the real app when fully ready
  runApp(
    ProviderScope(
      overrides: [
        localeProvider.overrideWith((ref) => LocaleNotifier(
          initialLanguage: savedLanguage == 'en' ? AppLanguage.english : AppLanguage.bengali,
          initialIsFirstLaunch: isFirstLaunch,
        )),
      ],
      child: const VenomShieldApp(),
    ),
  );
}

class VenomShieldSplashApp extends StatelessWidget {
  const VenomShieldSplashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF003527), // AppColors.primary
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'VenomShield AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'sans-serif',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Initializing Secure Connection...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'sans-serif',
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

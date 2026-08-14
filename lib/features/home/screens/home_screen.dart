import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../hospital/providers/hospital_provider.dart';
import '../providers/history_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _makeCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hospitalState = ref.watch(hospitalProvider);
    final historyState = ref.watch(historyProvider);

    final inStockHospitals = hospitalState.hospitals
        .where((h) => h.antivenomStatus == 'in_stock' || h.antivenomStatus == 'limited')
        .toList();
    final nearestCount = inStockHospitals.length;
    final nearestCountText = _toBengaliDigits('$nearestCount');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopBar(context),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Emergency Protocol Banner
                    _buildEmergencyBanner(context),
                    const SizedBox(height: 24),
                    // Dashboard Stats Row
                    _buildStatsRow(historyState.assessments),
                    const SizedBox(height: 24),
                    // Bento Grid
                    _buildBentoGrid(context, historyState.assessments, nearestCount, nearestCountText),
                    const SizedBox(height: 24),
                    // Assessment History Log
                    _buildHistoryList(historyState),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.note_alt_outlined, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              const Text(
                'VenomShield AI',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Bilingual Toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.outlineVariant, width: 1),
                ),
                child: Row(
                  children: [
                    const Text(
                      'ENG',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryContainer,
                        letterSpacing: 0.08,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: AppColors.outlineVariant,
                    ),
                    const Text(
                      'BN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 0.08,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Offline Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'অফলাইন',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.08,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.emergency, color: AppColors.onTertiaryContainer, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'জরুরী প্রটোকল',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'জাতীয় হেল্পライン - দ্রুত প্রতিক্রিয়া',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onTertiaryContainer,
                    letterSpacing: 0.05,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _makeCall('999'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.phone_in_talk, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'জরুরী কল',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(List<Map<String, dynamic>> history) {
    final total = history.length;
    final highRisk = history.where((a) => a['risk_level'] == 'উচ্চ ঝুঁকি' || a['risk_level'] == 'অত্যন্ত উচ্চ ঝুঁকি' || a['venomous'] == 1).length;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'মোট মূল্যায়ন',
            value: _toBengaliDigits('$total'),
            icon: Icons.analytics_outlined,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'উচ্চ ঝুঁকি কেস',
            value: _toBengaliDigits('$highRisk'),
            icon: Icons.gpp_maybe_outlined,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBentoGrid(BuildContext context, List<Map<String, dynamic>> history, int nearestCount, String nearestCountText) {
    return Column(
      children: [
        // Hero Card: Quick Scan
        _buildQuickScanCard(context),
        const SizedBox(height: 16),
        // Side Cards Row
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildSymptomLogCard(context, history),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildHospitalRadarCard(context, nearestCount, nearestCountText),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickScanCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/scan'),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'এআই সক্রিয়',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onPrimaryContainer,
                      letterSpacing: 0.05,
                    ),
                  ),
                ),
                const Icon(Icons.camera_enhance, color: AppColors.primary, size: 48),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'দ্রুত স্ক্যান',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'সাপের কামড়ের চিহ্ন বা ধরণ তাৎক্ষণিকভাবে বিশ্লেষণ করুন।',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.document_scanner, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'স্ক্যান শুরু করুন',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomLogCard(BuildContext context, List<Map<String, dynamic>> history) {
    List<String> tags = ['ফণা তোলা', 'ফোলাভাব', 'তীব্র ব্যথা'];
    if (history.isNotEmpty) {
      final last = history.first;
      if (last['symptoms'] != null) {
        try {
          final List<dynamic> decoded = json.decode(last['symptoms']);
          if (decoded.isNotEmpty) {
            tags = decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {}
      }
    }

    return GestureDetector(
      onTap: () => context.push('/triage-checklist'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.assignment, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'লক্ষণ তালিকা',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'ভাইটাল সাইন এবং স্নায়বিক লক্ষণগুলো রেকর্ড করুন।',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: tags.take(3).map((t) => _buildTag(t)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalRadarCard(BuildContext context, int nearestCount, String nearestCountText) {
    return GestureDetector(
      onTap: () => context.push('/hospital-radar'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.local_hospital, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'হাসপাতাল রাডার',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'নিকটস্থ অ্যান্টি-ভেনম মজুদ কেন্দ্রগুলো খুঁজুন।',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      nearestCount > 0 ? Icons.check_circle : Icons.warning,
                      color: nearestCount > 0 ? AppColors.primary : AppColors.error,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      nearestCount > 0 ? '$nearestCountTextটি নিকটতম মজুদ' : 'কোনো মজুদ নেই',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: nearestCount > 0 ? AppColors.primary : AppColors.error,
                        letterSpacing: 0.08,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_forward, color: AppColors.onSurfaceVariant, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
          letterSpacing: 0.05,
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.only(bottom: 8, top: 8),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.outlineVariant, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, Icons.home, 'হোম', true, () => {}),
            _buildNavItem(context, Icons.settings_overscan, 'স্ক্যানার', false, () => context.push('/scan')),
            _buildNavItem(context, Icons.assignment, 'মূল্যায়ন', false, () => context.push('/triage-checklist')),
            _buildNavItem(context, Icons.local_hospital, 'হাসপাতাল', false, () => context.push('/hospital-radar')),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.onPrimaryContainer : AppColors.onSecondaryContainer,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isActive ? AppColors.onPrimaryContainer : AppColors.onSecondaryContainer,
                letterSpacing: 0.08,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(HistoryState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer));
    }

    final history = state.assessments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'সাম্প্রতিক মূল্যায়ন ইতিহাস',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        if (history.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: const Center(
              child: Text(
                'কোনো পূর্ববর্তী মূল্যায়ন পাওয়া যায়নি।',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: math.min(history.length, 5),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = history[index];
              final bool venomous = item['venomous'] == 1;
              final date = DateTime.tryParse(item['timestamp'] ?? '') ?? DateTime.now();
              final dateStr = '${date.day}/${date.month}/${date.year}';
              
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item['type'] ?? 'মূল্যায়ন'} - ${item['risk_level'] ?? 'কম ঝুঁকি'}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: venomous ? AppColors.error : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'তারিখ: ${_toBengaliDigits(dateStr)} • ঝুঁকি: ${_toBengaliDigits(item['risk_percentage'].toStringAsFixed(0))}%',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      venomous ? Icons.gpp_maybe_outlined : Icons.verified_user_outlined,
                      color: venomous ? AppColors.error : AppColors.primary,
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  String _toBengaliDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bengali = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    String result = input;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], bengali[i]);
    }
    return result;
  }
}

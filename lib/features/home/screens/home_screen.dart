import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../core/widgets/language_toggle.dart';
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

  void _showLanguageSelectionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Column(
              children: [
                Icon(
                  Icons.language,
                  color: AppColors.primary,
                  size: 40,
                ),
                SizedBox(height: 12),
                Text(
                  'Choose your language\nভাষা নির্বাচন করুন',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(localeProvider.notifier).setLanguage(AppLanguage.bengali);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '🇧🇩 বাংলা',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(localeProvider.notifier).setLanguage(AppLanguage.english);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '🇬🇧 English',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hospitalState = ref.watch(hospitalProvider);
    final historyState = ref.watch(historyProvider);
    final lang = ref.watch(localeProvider);

    final isFirst = ref.watch(localeProvider.notifier).isFirstLaunch;
    if (isFirst) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLanguageSelectionDialog(context, ref);
      });
    }

    final inStockHospitals = hospitalState.hospitals
        .where((h) => h.antivenomStatus == 'in_stock' || h.antivenomStatus == 'limited')
        .toList();
    final nearestCount = inStockHospitals.length;
    final nearestCountText = _formatNumber('$nearestCount', lang);

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
                    _buildEmergencyBanner(context, lang),
                    const SizedBox(height: 24),
                    // Dashboard Stats Row
                    _buildStatsRow(historyState.assessments, lang),
                    const SizedBox(height: 24),
                    // Bento Grid
                    _buildBentoGrid(context, historyState.assessments, nearestCount, nearestCountText, lang),
                    const SizedBox(height: 24),
                    // Assessment History Log
                    _buildHistoryList(historyState, lang),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const VenomShieldBottomNav(currentIndex: 0),
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
          const BilingualLanguageToggle(),
        ],
      ),
    );
  }

  Widget _buildEmergencyBanner(BuildContext context, AppLanguage lang) {
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
                Text(
                  lang.t('জরুরী প্রটোকল', 'Emergency Protocol'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lang.t('জাতীয় হেল্পলাইন - দ্রুত প্রতিক্রিয়া', 'National Helpline - Rapid Response'),
                  style: const TextStyle(
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
              child: Row(
                children: [
                  const Icon(Icons.phone_in_talk, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    lang.t('জরুরী কল', 'Emergency Call'),
                    style: const TextStyle(
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

  Widget _buildStatsRow(List<Map<String, dynamic>> history, AppLanguage lang) {
    final total = history.length;
    final highRisk = history.where((a) => a['risk_level'] == 'উচ্চ ঝুঁকি' || a['risk_level'] == 'High Risk' || a['risk_level'] == 'অত্যন্ত উচ্চ ঝুঁকি' || a['venomous'] == 1).length;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: lang.t('মোট মূল্যায়ন', 'Total Assessments'),
            value: _formatNumber('$total', lang),
            icon: Icons.analytics_outlined,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: lang.t('উচ্চ ঝুঁকি কেস', 'High Risk Cases'),
            value: _formatNumber('$highRisk', lang),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
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
          ),
        ],
      ),
    );
  }

  Widget _buildBentoGrid(BuildContext context, List<Map<String, dynamic>> history, int nearestCount, String nearestCountText, AppLanguage lang) {
    return Column(
      children: [
        // Hero Card: Quick Scan
        _buildQuickScanCard(context, lang),
        const SizedBox(height: 16),
        // Side Cards Row
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildSymptomLogCard(context, lang),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildHospitalRadarCard(context, nearestCount, nearestCountText, lang),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickScanCard(BuildContext context, AppLanguage lang) {
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
                  child: Text(
                    lang.t('এআই সক্রিয়', 'AI Active'),
                    style: const TextStyle(
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
            Text(
              lang.t('দ্রুত স্ক্যান', 'Quick Scan'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              lang.t('সাপের কামড়ের চিহ্ন বা ধরণ তাৎক্ষণিকভাবে বিশ্লেষণ করুন।', 'Instantly analyze snake bite marks or patterns.'),
              style: const TextStyle(
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.document_scanner, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    lang.t('স্ক্যান শুরু করুন', 'Start Scan'),
                    style: const TextStyle(
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

  Widget _buildSymptomLogCard(BuildContext context, AppLanguage lang) {
    final List<String> tagsBn = ['ফণা তোলা', 'ফোলাভাব', 'তীব্র ব্যথা'];
    final List<String> tagsEn = ['Hood Raised', 'Swelling', 'Severe Pain'];

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
            Row(
              children: [
                const Icon(Icons.assignment, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  lang.t('লক্ষণ তালিকা', 'Checklist'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              lang.t('ভাইটাল সাইন এবং স্নায়বিক লক্ষণগুলো রেকর্ড করুন।', 'Record vital signs and neurological symptoms.'),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: List.generate(3, (index) {
                return _buildTag(lang.t(tagsBn[index], tagsEn[index]));
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalRadarCard(BuildContext context, int nearestCount, String nearestCountText, AppLanguage lang) {
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
            Row(
              children: [
                const Icon(Icons.local_hospital, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  lang.t('হাসপাতাল রাডার', 'Hospital Radar'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              lang.t('নিকটস্থ অ্যান্টি-ভেনম মজুদ কেন্দ্রগুলো খুঁজুন।', 'Locate nearest anti-venom stock centers.'),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        nearestCount > 0 ? Icons.check_circle : Icons.warning,
                        color: nearestCount > 0 ? AppColors.primary : AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          nearestCount > 0 
                              ? lang.t('$nearestCountTextটি নিকটতম মজুদ', '$nearestCount nearest stock') 
                              : lang.t('কোনো মজুদ নেই', 'No stock available'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: nearestCount > 0 ? AppColors.primary : AppColors.error,
                            letterSpacing: 0.05,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: AppColors.onSurfaceVariant, size: 16),
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
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
          letterSpacing: 0.05,
        ),
      ),
    );
  }

  Widget _buildHistoryList(HistoryState state, AppLanguage lang) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer));
    }

    final history = state.assessments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.t('সাম্প্রতিক মূল্যায়ন ইতিহাস', 'Recent Assessment History'),
          style: const TextStyle(
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
            child: Center(
              child: Text(
                lang.t('কোনো পূর্ববর্তী মূল্যায়ন পাওয়া যায়নি।', 'No previous assessments found.'),
                style: const TextStyle(color: AppColors.textSecondary),
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
              
              // Map types and risk levels
              final rawType = item['type'] ?? 'Assessment';
              final String typeStr = rawType == 'সাপ সনাক্তকরণ' || rawType == 'Snake Identification'
                  ? lang.t('সাপ সনাক্তকরণ', 'Snake Identification')
                  : (rawType == 'লক্ষণ মূল্যায়ন' || rawType == 'Symptom Assessment'
                      ? lang.t('লক্ষণ মূল্যায়ন', 'Symptom Assessment')
                      : lang.t('ক্ষত মূল্যায়ন', 'Bite Assessment'));

              final rawRisk = item['risk_level'] ?? 'Low Risk';
              final String riskStr = rawRisk == 'উচ্চ ঝুঁকি' || rawRisk == 'High Risk'
                  ? lang.t('উচ্চ ঝুঁকি', 'High Risk')
                  : lang.t('কম ঝুঁকি', 'Low Risk');

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
                          '$typeStr - $riskStr',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: venomous ? AppColors.error : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lang.t(
                            'তারিখ: ${_toBengaliDigits(dateStr)} • ঝুঁকি: ${_toBengaliDigits(item['risk_percentage'].toStringAsFixed(0))}%', 
                            'Date: $dateStr • Risk: ${item['risk_percentage'].toStringAsFixed(0)}%'
                          ),
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

  String _formatNumber(String input, AppLanguage lang) {
    if (lang == AppLanguage.bengali) {
      return _toBengaliDigits(input);
    }
    return input;
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

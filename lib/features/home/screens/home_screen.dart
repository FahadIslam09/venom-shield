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
import '../../scanner/screens/snake_search_sheet.dart';
import '../../scanner/services/snake_database.dart';
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
        if (ref.read(localeProvider.notifier).isFirstLaunch) {
          ref.read(localeProvider.notifier).markDialogShown();
          _showLanguageSelectionDialog(context, ref);
        }
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
            _buildTopBar(context, ref, lang),
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

  Widget _buildTopBar(BuildContext context, WidgetRef ref, AppLanguage lang) {
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
              const Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
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
              IconButton(
                icon: const Icon(Icons.search, color: AppColors.primary, size: 24),
                tooltip: lang.t('সাপ অনুসন্ধান করুন', 'Search Snake Database'),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const SnakeSearchSheet(),
                  );
                },
              ),
              const SizedBox(width: 4),
              const BilingualLanguageToggle(),
            ],
          ),
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
                    fontSize: 14,
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
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
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
                      fontSize: 13,
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
                fontSize: 15,
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
                  lang.t('লক্ষণ ও তালিকা', 'Symptoms & List'),
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
            const Spacer(),
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
          fontSize: 12,
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
              final String typeStr = rawType == 'সাপ স্ক্যান' || rawType == 'সাপ সনাক্তকরণ' || rawType == 'Snake Identification'
                  ? lang.t('সাপ সনাক্তকরণ', 'Snake Identification')
                  : (rawType == 'লক্ষণ তালিকা' || rawType == 'লক্ষণ মূল্যায়ন' || rawType == 'Symptom Assessment'
                      ? lang.t('লক্ষণ মূল্যায়ন', 'Symptom Assessment')
                      : lang.t('ক্ষত মূল্যায়ন', 'Bite Assessment'));

              final rawRisk = item['risk_level'] ?? 'Low Risk';
              final String riskStr = rawRisk == 'উচ্চ ঝুঁকি' || rawRisk == 'High Risk'
                  ? lang.t('উচ্চ ঝুঁকি', 'High Risk')
                  : lang.t('কম ঝুঁকি', 'Low Risk');

              final double riskPct = (item['risk_percentage'] as num?)?.toDouble() ?? 0.0;

              return Card(
                elevation: 0,
                color: AppColors.surfaceContainerLowest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: venomous ? AppColors.error.withOpacity(0.3) : AppColors.outlineVariant,
                    width: 1,
                  ),
                ),
                child: InkWell(
                  onTap: () => _showHistoryDetail(context, item, lang),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: venomous ? AppColors.errorContainer : AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            venomous ? Icons.gpp_maybe_outlined : Icons.verified_user_outlined,
                            color: venomous ? AppColors.error : AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '$typeStr - $riskStr',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: venomous ? AppColors.error : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    lang.t(
                                      '${_toBengaliDigits(riskPct.toStringAsFixed(0))}% ঝুঁকি', 
                                      '${riskPct.toStringAsFixed(0)}% Risk'
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: venomous ? AppColors.error : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    lang.t('তারিখ: ${_toBengaliDigits(dateStr)}', 'Date: $dateStr'),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  if (item['matched_species'] != null && item['matched_species'].toString().isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '• ${item['matched_species']}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right, color: AppColors.outline, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  void _showHistoryDetail(BuildContext context, Map<String, dynamic> item, AppLanguage lang) {
    final String? matchedSpecies = item['matched_species'];
    if (matchedSpecies != null && matchedSpecies.isNotEmpty) {
      final species = SnakeDatabase.getSpeciesDetails(matchedSpecies, matchedSpecies);
      if (species != null) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => SnakeDetailModal(snake: species, lang: lang),
        );
        return;
      }
    }

    // Default Assessment Detail Modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AssessmentDetailModal(item: item, lang: lang),
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

class _AssessmentDetailModal extends StatelessWidget {
  final Map<String, dynamic> item;
  final AppLanguage lang;

  const _AssessmentDetailModal({required this.item, required this.lang});

  String _toBengaliDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bengali = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    String result = input;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], bengali[i]);
    }
    return result;
  }

  Future<void> _makeCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool venomous = item['venomous'] == 1;
    final date = DateTime.tryParse(item['timestamp'] ?? '') ?? DateTime.now();
    final String dateFormatted = '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    final rawType = item['type'] ?? 'Assessment';
    final String typeStr = rawType == 'সাপ স্ক্যান' || rawType == 'সাপ সনাক্তকরণ' || rawType == 'Snake Identification'
        ? lang.t('সাপ শনাক্তকরণ স্ক্যান', 'Snake Identification Scan')
        : (rawType == 'লক্ষণ তালিকা' || rawType == 'লক্ষণ মূল্যায়ন' || rawType == 'Symptom Assessment'
            ? lang.t('লক্ষণ ও তালিকা মূল্যায়ন', 'Symptoms & List Assessment')
            : lang.t('জরুরি কামড় মূল্যায়ন', 'Emergency Bite Assessment'));

    final double riskPct = (item['risk_percentage'] as num?)?.toDouble() ?? (venomous ? 85.0 : 15.0);
    final String riskPctStr = lang.isBengali
        ? '${_toBengaliDigits(riskPct.toStringAsFixed(0))}%'
        : '${riskPct.toStringAsFixed(0)}%';

    final String? matchedSpecies = item['matched_species'];

    List<String> rawSymptoms = [];
    if (item['symptoms'] != null) {
      try {
        if (item['symptoms'] is List) {
          rawSymptoms = List<String>.from(item['symptoms']);
        } else if (item['symptoms'] is String) {
          final decoded = json.decode(item['symptoms']);
          if (decoded is List) {
            rawSymptoms = List<String>.from(decoded);
          }
        }
      } catch (_) {}
    }

    final Map<String, String> symptomNamesBn = {
      'hood_seen': 'সাপের ফণা দেখা গেছে',
      'triangular_head': 'ত্রিকোণাকার মাথা ও সরু ঘাড়',
      'distinct_pattern': 'স্পষ্ট ডোরাকাটা বা শিকল ছোপ',
      'paddle_tail': 'বৈঠার মতো চ্যাপ্টা লেজ (সামুদ্রিক)',
      'night_sleeping_bite': 'রাতে বিছানায় বা ঘুমের মধ্যে কামড় (কালাচ)',
      'two_punctures': 'দুটি বিষদাঁতের ক্ষতচিহ্ন',
      'bleeding_wound': 'ক্ষতস্থান থেকে অবিরাম রক্তপাত',
      'severe_pain': 'তীব্র জ্বালাপোড়া ও ব্যথা',
      'swelling': 'ক্ষতস্থান ও অঙ্গ দ্রুত ফুলে যাওয়া',
      'blistering_necrosis': 'কালচে ফোস্কা বা চামড়া পচে যাওয়া',
      'eyelid_droop': 'চোখের পাতা ঝুলে পড়া (Ptosis)',
      'speech_swallowing_difficulty': 'কথা জড়িয়ে যাওয়া বা গিলতে কষ্ট',
      'difficulty_breathing': 'শ্বাসকষ্ট ও দম বন্ধ ভাব',
      'flaccid_paralysis': 'ঘাড় সোজা রাখতে না পারা ও পেশির অসাড়তা',
      'spontaneous_bleeding': 'মাড়ি, নাক বা প্রস্রাবে রক্তপাত',
      'abdominal_vomiting': 'তীব্র পেটব্যথা ও ক্রমাগত বমি',
      'myalgia_dark_urine': 'সারা গায়ে তীব্র পেশি ব্যথা বা কালো প্রস্রাব',
      'dizziness_shock': 'অতিরিক্ত ঘাম, মাথা ঘোরা বা জ্ঞান হারানো (শক)',
    };

    final Map<String, String> symptomNamesEn = {
      'hood_seen': 'Snake raised head hood',
      'triangular_head': 'Triangular head with narrow neck',
      'distinct_pattern': 'Distinct bands or chain patterns',
      'paddle_tail': 'Paddle-shaped flat tail (Sea snake)',
      'night_sleeping_bite': 'Night bite while sleeping (Krait hallmark)',
      'two_punctures': 'Two distinct fang punctures',
      'bleeding_wound': 'Continuous wound bleeding',
      'severe_pain': 'Severe local burning pain',
      'swelling': 'Rapidly spreading edema/swelling',
      'blistering_necrosis': 'Dark blistering or tissue necrosis',
      'eyelid_droop': 'Drooping eyelids or double vision (Ptosis)',
      'speech_swallowing_difficulty': 'Slurred speech or difficulty swallowing',
      'difficulty_breathing': 'Difficulty breathing (Respiratory distress)',
      'flaccid_paralysis': 'Broken neck sign & flaccid paralysis',
      'spontaneous_bleeding': 'Spontaneous bleeding (gums, urine, nose)',
      'abdominal_vomiting': 'Severe abdominal colic & persistent vomiting',
      'myalgia_dark_urine': 'Severe muscle pain or dark cola urine',
      'dizziness_shock': 'Cold sweating, severe dizziness or shock',
    };

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      venomous ? Icons.gpp_maybe_outlined : Icons.verified_user_outlined,
                      color: venomous ? AppColors.error : AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      lang.t('মূল্যায়নের বিবরণ', 'Assessment Details'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Type & Timestamp Card
                  Container(
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
                              typeStr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lang.t('মূল্যায়নের সময়: ${_toBengaliDigits(dateFormatted)}', 'Time: $dateFormatted'),
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: venomous ? AppColors.errorContainer : AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            venomous ? lang.t('বিষধর', 'Venomous') : lang.t('অবিষধর', 'Non-Venomous'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: venomous ? AppColors.error : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Risk Banner Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: venomous ? AppColors.errorContainer.withOpacity(0.4) : AppColors.primaryFixed.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: venomous ? AppColors.error.withOpacity(0.4) : AppColors.primary.withOpacity(0.4),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          venomous ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                          color: venomous ? AppColors.error : AppColors.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                venomous
                                    ? lang.t('উচ্চ ঝুঁকি - বিষধর সাপের বিষক্রিয়া', 'High Risk - Probable Envenomation')
                                    : lang.t('কম ঝুঁকি - অবিষধর মূল্যায়ন', 'Low Risk - Non-Venomous Evaluation'),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: venomous ? AppColors.error : AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lang.t('গণনাকৃত বিষাক্ততার ঝুঁকি: $riskPctStr', 'Calculated Toxicity Risk: $riskPctStr'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (matchedSpecies != null && matchedSpecies.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.pets, color: AppColors.primary, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang.t('শনাক্তকৃত সাপের প্রজাতি', 'Identified Snake Species'),
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  matchedSpecies,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (rawSymptoms.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      lang.t('মূল্যায়নকৃত শারীরিক লক্ষণসমূহ', 'Evaluated Clinical Symptoms'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...rawSymptoms.map((key) {
                      final title = lang.t(symptomNamesBn[key] ?? key, symptomNamesEn[key] ?? key);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.error, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 18),

                  // First Aid Steps
                  Text(
                    lang.t('জরুরী প্রাথমিক পদক্ষেপ', 'Emergency First Aid Protocols'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        _buildStepItem(lang.t('ধাপ ১: রোগীকে শান্ত রাখুন এবং সম্পূর্ণ স্থির অবস্থায় শুইয়ে রাখুন যাতে বিষ দ্রুত না ছড়ায়।', 'Step 1: Keep the patient calm and completely still to delay venom spread.')),
                        const Divider(height: 16),
                        _buildStepItem(lang.t('ধাপ ২: আক্রান্ত হাত বা পা কার্ড বা স্কেল দিয়ে স্প্লিন্ট করে আলতো করে ব্যান্ডেজ দিয়ে বেঁধে স্থির রাখুন।', 'Step 2: Splint the affected limb and immobilize it with gentle bandaging.')),
                        const Divider(height: 16),
                        _buildStepItem(lang.t('ধাপ ৩: ক্ষতস্থান কাটা, বিষ চোষা, বরফ দেওয়া বা শক্ত দড়ি/টরনিকেট দিয়ে বাঁধা সম্পূর্ণ নিষেধ!', 'Step 3: Strictly NO cutting, suction, herbal remedies, or tight tourniquets!'), isWarning: true),
                        const Divider(height: 16),
                        _buildStepItem(lang.t('ধাপ ৪: কালবিলম্ব না করে রোগীকে দ্রুত অ্যান্টি-ভেনম সুবিধাসম্পন্ন হাসপাতালে নিয়ে যান।', 'Step 4: Transport immediately to the nearest antivenom-equipped hospital.')),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action buttons
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/hospital-radar');
                    },
                    icon: const Icon(Icons.local_hospital_outlined, size: 20),
                    label: Text(
                      lang.t('কাছের অ্যান্টি-ভেনম হাসপাতাল খুঁজুন', 'Find Nearest Antivenom Hospital'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error, width: 1.5),
                      foregroundColor: AppColors.error,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _makeCall('999'),
                    icon: const Icon(Icons.phone_in_talk, size: 20),
                    label: Text(
                      lang.t('জরুরী হেল্পলাইন ৯৯৯ কল করুন', 'Call Emergency Helpline 999'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String text, {bool isWarning = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isWarning ? Icons.cancel_outlined : Icons.check_circle_outline,
          color: isWarning ? AppColors.error : AppColors.primary,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isWarning ? FontWeight.w600 : FontWeight.normal,
              color: isWarning ? AppColors.error : AppColors.onSurface,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

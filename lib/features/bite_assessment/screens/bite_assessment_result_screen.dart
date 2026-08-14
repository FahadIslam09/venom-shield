import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/widgets/language_toggle.dart';
import '../providers/bite_assessment_provider.dart';

class BiteAssessmentResultScreen extends ConsumerWidget {
  const BiteAssessmentResultScreen({super.key});

  Future<void> _makeCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(biteAssessmentProvider);
    final result = state.result;
    final lang = ref.watch(localeProvider);

    if (result == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(lang.t('ঝুঁকি মূল্যায়ন ফলাফল', 'Risk Assessment Results')),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: Center(
          child: Text(lang.t('কোনো মূল্যায়নের তথ্য পাওয়া যায়নি।', 'No assessment information found.')),
        ),
      );
    }

    bool isUrgent = result.riskLevel == 'উচ্চ ঝুঁকি' || result.riskLevel == 'অত্যন্ত উচ্চ ঝুঁকি';

    final String riskLevelText = result.riskLevel == 'উচ্চ ঝুঁকি' || result.riskLevel == 'High Risk'
        ? lang.t('উচ্চ ঝুঁকি', 'High Risk')
        : (result.riskLevel == 'অত্যন্ত উচ্চ ঝুঁকি' || result.riskLevel == 'Extremely High Risk'
            ? lang.t('অত্যন্ত উচ্চ ঝুঁকি', 'Extremely High Risk')
            : (result.riskLevel == 'মাঝারি ঝুঁকি' || result.riskLevel == 'Medium Risk'
                ? lang.t('মাঝারি ঝুঁকি', 'Medium Risk')
                : lang.t('কম ঝুঁকি', 'Low Risk')));

    final String riskDescriptionText = result.riskDescription == 'জীবন-ঝুঁকিপূর্ণ লক্ষণ রয়েছে। অবিলম্বে জরুরি চিকিৎসা প্রয়োজন।'
        ? lang.t('জীবন-ঝুঁকিপূর্ণ লক্ষণ রয়েছে। অবিলম্বে জরুরি চিকিৎসা প্রয়োজন।', 'Life-threatening symptoms detected. Urgent medical attention required.')
        : (result.riskDescription == 'একাধিক গুরুতর লক্ষণ পাওয়া গেছে। দ্রুত হাসপাতালে যান।'
            ? lang.t('একাধিক গুরুতর লক্ষণ পাওয়া গেছে। দ্রুত হাসপাতালে যান।', 'Multiple severe symptoms detected. Go to a hospital quickly.')
            : (result.riskDescription == 'কিছু উদ্বেগজনক লক্ষণ আছে। ডাক্তারী পর্যবেক্ষণ প্রয়োজন।'
                ? lang.t('কিছু উদ্বেগজনক লক্ষণ আছে। ডাক্তারী পর্যবেক্ষণ প্রয়োজন।', 'Some concerning symptoms detected. Medical observation required.')
                : lang.t('গুরুতর লক্ষণ পাওয়া যায়নি। তবে সতর্ক থাকুন এবং পর্যবেক্ষণ করুন।', 'No severe symptoms detected. Monitor closely and remain cautious.')));

    final List<String> firstAidStepsEn = result.riskPercentage >= 50.0 ? [
      'Keep the affected limb immobilized below heart level.',
      'Do not apply ice, cut the wound, or tie any tight tourniquets.',
      'Transport the patient to the nearest hospital stocked with anti-venom as quickly as possible.',
      'Do not waste the precious "golden hour" by taking the patient to a traditional healer.'
    ] : [
      'Do not panic. Remain calm.',
      'Do not move the bitten limb. Keep it immobilized using a splint (e.g. piece of wood or bamboo) if it is a hand or leg.',
      'Wash the wound gently with soap and clean water.',
      'Do not apply any tight tourniquet or bandage (this can block blood flow and lead to limb damage).',
      'Do not cut the wound to bleed it or waste time visiting a traditional healer.'
    ];

    final firstAidSteps = lang.isBengali ? result.firstAidBn : firstAidStepsEn;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopBar(context, ref),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Action Required Banner
                    if (isUrgent) ...[
                      _buildActionBanner(lang),
                      const SizedBox(height: 16),
                    ],
                    // Risk Score
                    _buildRiskScoreGauge(result, riskLevelText, riskDescriptionText, lang),
                    const SizedBox(height: 16),
                    // Case Details
                    _buildSymptomSummary(result, lang),
                    const SizedBox(height: 16),
                    // First Aid Protocol
                    _buildFirstAidProtocol(firstAidSteps, lang),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildEmergencyCTA(context, lang),
    );
  }

  Widget _buildTopBar(BuildContext context, WidgetRef ref) {
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
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
              ),
              const SizedBox(width: 4),
              const Text(
                'VenomShield AI',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const BilingualLanguageToggle(),
        ],
      ),
    );
  }

  Widget _buildActionBanner(AppLanguage lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceContainerHighest, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(Icons.warning, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.t('অবিলম্বে চিকিৎসা নিন', 'Get Urgent Medical Care'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lang.t(
                    'রোগীকে দ্রুততম সময়ের মধ্যে নিকটস্থ হাসপাতালে স্থানান্তর করা প্রয়োজন।', 
                    'The patient must be transferred to the nearest hospital as quickly as possible.'
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskScoreGauge(dynamic result, String riskLevelText, String riskDescriptionText, AppLanguage lang) {
    final formattedPercentage = lang.isBengali 
        ? _toBengaliDigits('${result.riskPercentage.toStringAsFixed(0)}%')
        : '${result.riskPercentage.toStringAsFixed(0)}%';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceContainerHighest, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            lang.t('ঝুঁকি মূল্যায়ন', 'Risk Assessment'),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
              letterSpacing: 0.08,
            ),
          ),
          const SizedBox(height: 16),
          // Gauge
          SizedBox(
            width: 192,
            height: 192,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                const SizedBox(
                  width: 192,
                  height: 192,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 8,
                    color: AppColors.surfaceContainerHigh,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                // Progress circle
                SizedBox(
                  width: 192,
                  height: 192,
                  child: CircularProgressIndicator(
                    value: result.riskPercentage / 100,
                    strokeWidth: 8,
                    color: AppColors.error,
                    backgroundColor: Colors.transparent,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Center text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formattedPercentage,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            riskLevelText,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            riskDescriptionText,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomSummary(dynamic result, AppLanguage lang) {
    final List<dynamic> reasons = result.observedReasons;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceContainerHighest, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
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
              Text(
                lang.t('লক্ষণ ও পর্যবেক্ষণ রিপোর্ট', 'Symptoms & Observation Report'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const Icon(Icons.monitor_heart, color: AppColors.secondary, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          if (reasons.isEmpty)
            Text(
              lang.t('কোনো লক্ষণ চিহ্নিত করা হয়নি।', 'No symptoms identified.'),
              style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
            )
          else
            ...reasons.map((reason) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.surfaceContainerHighest, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _translateReason(reason, lang),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildFirstAidProtocol(List<String> firstAidSteps, AppLanguage lang) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceContainerHighest, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
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
              Text(
                lang.t('প্রাথমিক করণীয়', 'First Aid Guidelines'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  lang.t('সক্রিয়', 'Active'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.08,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...firstAidSteps.asMap().entries.map((entry) {
            final idx = entry.key;
            final step = entry.value;
            final isWarning = step.contains('ওঝা') || step.contains('কেটে') || step.contains('টর্নিকেট') || step.contains('healer') || step.contains('tourniquet') || step.contains('cut');
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: idx == 0 ? AppColors.surfaceContainerLow : AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: idx == 0 ? AppColors.primaryContainer : AppColors.surfaceContainerHighest,
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isWarning ? AppColors.error : AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        isWarning ? Icons.close : Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isWarning ? AppColors.error : AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmergencyCTA(BuildContext context, AppLanguage lang) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.outlineVariant, width: 1),
          ),
        ),
        child: GestureDetector(
          onTap: () => _makeCall('999'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.tertiaryContainer, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.t('জাতীয় হেল্পলাইন', 'National Helpline'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onTertiaryContainer,
                        letterSpacing: 0.05,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lang.t('৯৯৯ এ কল করুন', 'Call 999'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(Icons.emergency, color: Colors.white, size: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _translateReason(String reason, AppLanguage lang) {
    if (lang == AppLanguage.bengali) return reason;
    
    // Replace growing/stable status
    String status = '';
    String base = reason;
    if (reason.endsWith(' (ক্রমবর্ধমান)')) {
      status = ' (Progressing)';
      base = reason.replaceAll(' (ক্রমবর্ধমান)', '');
    } else if (reason.endsWith(' (স্থিতিশীল)')) {
      status = ' (Stable)';
      base = reason.replaceAll(' (স্থিতিশীল)', '');
    }

    // Map base symptoms
    final Map<String, String> symptomTranslations = {
      'তীব্র ব্যথা': 'Severe pain',
      'ফোলাভাব': 'Swelling',
      'লালচে ভাব': 'Redness',
      'রক্তপাত': 'Bleeding',
      'ক্ষতচিহ্ন/কালশিটে': 'Bruising',
      'চোখের পাতা ঝুলে পড়া': 'Drooping eyelids',
      'কথা বলতে সমস্যা': 'Difficulty speaking',
      'শ্বাসকষ্ট': 'Difficulty breathing',
      'কামড়ের ৩০ মিনিটের মধ্যে লক্ষণসমূহ দ্রুত বৃদ্ধি পাচ্ছে': 'Symptoms rapidly increasing within 30 minutes of bite',
      'কামড়ের পর দীর্ঘ সময় (>৬ ঘণ্টা) পার হয়েছে এবং লক্ষণ বিদ্যমান': 'Long time elapsed (>6 hours) since bite with active symptoms',
      'চোখের পাতা ঝুলে পড়া (স্নায়বিক)': 'Drooping eyelids (Neurological)',
      'কথা বলতে সমস্যা (স্নায়বিক)': 'Difficulty speaking (Neurological)',
      'গিলতে সমস্যা (স্নায়বিক)': 'Difficulty swallowing (Neurological)',
      'অস্বাভাবিক শারীরিক দুর্বলতা': 'Unusual physical weakness',
      'শ্বাসকষ্ট হওয়া (জীবন-ঝুঁকি)': 'Difficulty breathing (Life-threatening)',
      'কামড়ের ক্ষতস্থান থেকে রক্তপাত': 'Bleeding from bite wound',
      'নাক বা মাড়ি থেকে রক্তপাত': 'Bleeding from nose or gums',
      'ত্বকে অস্বাভাবিক কালশিটে': 'Unusual bruising on skin',
      'মাথা ঘোরানো': 'Dizziness',
      'অজ্ঞান হয়ে যাওয়া (জীবন-ঝুঁকি)': 'Fainting (Life-threatening)',
      'বমি হওয়া': 'Vomiting',
      'গাঢ় রঙের প্রস্রাব': 'Dark urine',
    };

    return (symptomTranslations[base] ?? base) + status;
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

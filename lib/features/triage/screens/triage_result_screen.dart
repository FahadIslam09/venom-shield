import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/locale_provider.dart';
import '../providers/triage_provider.dart';
import '../../scanner/providers/scanner_provider.dart';
import '../../scanner/services/snake_database.dart';

class TriageResultScreen extends ConsumerWidget {
  const TriageResultScreen({super.key});

  Future<void> _makeCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final triageState = ref.watch(triageProvider);
    final result = triageState.result;
    final lang = ref.watch(localeProvider);

    if (result == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(lang.t('শনাক্তকরণ ফলাফল', 'Identification Results')),
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

    final bool isVenomous = result.venomous;
    final bool isChecklist = result.fallbackLayer != 1;
    final double confidenceVal = result.confidence ?? (isVenomous ? 0.85 : 0.15);
    final String confidencePctBn = _formatNumber('${(confidenceVal * 100).toStringAsFixed(0)}%', lang);
    
    // Dynamic Envenomation Risk calculation
    double riskVal;
    if (isVenomous) {
      riskVal = 0.85 + (confidenceVal * 0.10);
    } else {
      riskVal = 0.10 + ((1.0 - confidenceVal) * 0.50);
    }
    final String riskPctBn = _formatNumber('${(riskVal * 100).toStringAsFixed(0)}%', lang);

    // Dynamic symptoms display list
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

    final selectedSymptoms = triageState.symptomAnswers.entries
        .where((e) => e.value)
        .map((e) => lang.t(symptomNamesBn[e.key] ?? e.key, symptomNamesEn[e.key] ?? e.key))
        .toList();

    final speciesMatch = SnakeDatabase.getSpeciesDetails(
      result.matchedSpeciesEn ?? '',
      result.matchedSpeciesBn ?? '',
    );
    final List<String> rawFirstAid = lang.isBengali
        ? (speciesMatch != null && speciesMatch.firstAidBn.isNotEmpty ? speciesMatch.firstAidBn : result.firstAidBn)
        : (speciesMatch != null && speciesMatch.firstAidEn.isNotEmpty ? speciesMatch.firstAidEn : result.firstAidEn);
    final firstAidSteps = rawFirstAid.isNotEmpty ? rawFirstAid : (lang.isBengali ? result.firstAidBn : result.firstAidEn);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.go('/'),
        ),
        title: Text(
          lang.t('শনাক্তকরণ ফলাফল', 'Identification Results'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Assessment Type & Result Card
            _buildPrimaryResultCard(result, isVenomous, isChecklist, riskPctBn, lang),
            const SizedBox(height: 20),

            // 2. Snake Image Card (if image scan path)
            if (!isChecklist) ...[
              _buildSnakeImageCard(result, isVenomous, ref.watch(scannerProvider).imagePath, lang),
              const SizedBox(height: 20),
              _buildConfidenceIndicator(confidenceVal, confidencePctBn, lang),
              const SizedBox(height: 20),
            ],

            // 3. Clinical Symptoms or Bite Risks Card
            isChecklist
                ? _buildClinicalWarningsCard(result, isVenomous, isChecklist, selectedSymptoms, lang)
                : _buildBiteRisksCard(result, isVenomous, lang),
            const SizedBox(height: 20),

            // 4. First Aid Instructions Card
            _buildFirstAidCard(firstAidSteps, lang),
            const SizedBox(height: 24),

            // 5. Action Buttons (Visual Focus: Primary first, secondary later)
            _buildActionButtons(context, result, lang),
            const SizedBox(height: 24),

            // Safety Warning
            _buildSafetyWarning(lang),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryResultCard(dynamic result, bool isVenomous, bool isChecklist, String riskPctBn, AppLanguage lang) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVenomous ? AppColors.error.withOpacity(0.3) : AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Assessment Type
          Text(
            isChecklist 
                ? lang.t('লক্ষণ-ভিত্তিক বিষক্রিয়া ঝুঁকি মূল্যায়ন', 'Symptom-Based Envenomation Risk Assessment')
                : lang.t('সাপ সনাক্তকরণ ও বিষক্রিয়া ঝুঁকি মূল্যায়ন', 'Snake Identification & Envenomation Assessment'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Empty state title if checklist
          if (isChecklist) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.help_outline, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 6),
                Text(
                  lang.t('সাপ সনাক্ত করা যায়নি', 'Snake not identified'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Large Risk Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isVenomous ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                color: isVenomous ? AppColors.error : AppColors.primary,
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                isVenomous ? lang.t('উচ্চ ঝুঁকি', 'High Risk') : lang.t('কম ঝুঁকি', 'Low Risk'),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: isVenomous ? AppColors.error : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Divider(),
          const SizedBox(height: 16),

          // Estimated Envenomation Risk %
          Text(
            lang.t('আনুমানিক বিষক্রিয়ার ঝুঁকি — $riskPctBn', 'Estimated Envenomation Risk — $riskPctBn'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isVenomous ? AppColors.error : AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isChecklist
                ? lang.t(
                    'এই শতাংশটি আপনার দেওয়া লক্ষণসমূহের ওপর ভিত্তি করে বিষক্রিয়ার আনুমানিক ঝুঁকি নির্দেশ করে, সাপের প্রজাতি বিষধর হওয়ার নিশ্চয়তা নয়।',
                    'This percentage indicates the estimated risk of envenomation based on your symptoms, not the certainty of the snake species being venomous.'
                  )
                : lang.t(
                    'এই শতাংশটি সনাক্তকৃত সাপের প্রজাতি এবং এর বিষধর হওয়ার নিশ্চিততার ওপর ভিত্তি করে আনুমানিক বিষক্রিয়ার ঝুঁকি নির্দেশ করে। কোনো প্রকার উপসর্গ দেখা দেওয়ার অপেক্ষা না করে অবিলম্বে জরুরি সাহায্য নিন।',
                    'This percentage indicates the estimated risk of envenomation based on the identified snake species and its venomous classification. Seek immediate medical attention without waiting for symptoms.'
                  ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnakeImageCard(dynamic result, bool isVenomous, String? imagePath, AppLanguage lang) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          imagePath != null
              ? (kIsWeb
                  ? Image.network(imagePath, fit: BoxFit.cover)
                  : Image.file(File(imagePath), fit: BoxFit.cover))
              : Image.network(
                  'https://images.unsplash.com/photo-1531386151447-fd76ad50012f?w=800',
                  fit: BoxFit.cover,
                ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
          // Bottom Text
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.t(result.matchedSpeciesBn ?? 'অজ্ঞাত প্রজাতি', result.matchedSpeciesEn ?? 'Unknown Species'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.matchedSpeciesEn ?? 'Unknown Species',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                if (isVenomous)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          lang.t('বিষধর', 'Venomous'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.08,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceIndicator(double confidenceVal, String confidencePctBn, AppLanguage lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
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
              color: AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(Icons.memory, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.t('সাপ সনাক্তকরণে এআই আত্মবিশ্বাস', 'AI Confidence in Identification'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lang.t('(ছবি দেখে প্রজাতি চেনার নির্ভরযোগ্যতা)', '(Reliability of identifying species from image)'),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  confidencePctBn,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: confidenceVal,
                    minHeight: 8,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalWarningsCard(dynamic result, bool isVenomous, bool isChecklist, List<String> selectedSymptoms, AppLanguage lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isVenomous ? AppColors.errorContainer.withOpacity(0.5) : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVenomous ? AppColors.error.withOpacity(0.2) : AppColors.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_services_outlined,
                color: isVenomous ? AppColors.error : AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                lang.t('সনাক্তকৃত শারীরিক লক্ষণসমূহ', 'Detected Physical Symptoms'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isVenomous ? AppColors.error : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (selectedSymptoms.isEmpty)
            Text(
              lang.t('কোনো গুরুতর লক্ষণ সনাক্ত করা যায়নি।', 'No severe symptoms detected.'),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: selectedSymptoms.map((symptom) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          symptom,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Medical Disclaimer
          () {
            if (isChecklist) {
              // Checklist Path (Symptom based assessment)
              return Text(
                isVenomous
                    ? lang.t(
                        'বিষক্রিয়ার লক্ষণ পাওয়া গেছে। আপনার দেওয়া উপসর্গগুলো গুরুতর হওয়ায় দ্রুত নিকটস্থ হাসপাতালে যান।',
                        'Signs of envenomation detected. Since the reported symptoms are severe, please go to the nearest hospital immediately.'
                      )
                    : lang.t(
                        'বিষক্রিয়ার কোনো স্পষ্ট লক্ষণ পাওয়া যায়নি। যেকোনো নতুন বা মৃদু লক্ষণ দেখা দিলে সতর্ক থাকুন এবং ডাক্তারের পরামর্শ নিন।',
                        'No clear signs of envenomation detected. Watch closely for any new or mild symptoms and seek medical advice.'
                      ),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isVenomous ? AppColors.error : AppColors.textPrimary,
                  height: 1.4,
                ),
              );
            } else {
              // Image Scan Path
              final bool isUnidentified = result.matchedSpeciesEn == 'Unknown Species' || result.matchedSpeciesBn == 'অজানা প্রজাতি';
              if (isUnidentified) {
                return Text(
                  lang.t(
                    'সাপটি নিশ্চিতভাবে শনাক্ত করা যায়নি। নিরাপত্তার জন্য এটিকে বিষাক্ত ধরে নিয়ে সতর্ক থাকুন এবং যেকোনো লক্ষণ দেখা দিলে হাসপাতালে যোগাযোগ করুন।',
                    'The snake could not be identified with certainty. For safety, assume it may be venomous, watch for symptoms, and consult a medical professional.'
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                    height: 1.4,
                  ),
                );
              } else if (isVenomous) {
                return Text(
                  lang.t(
                    'শনাক্তকৃত সাপটি বিষধর (${result.matchedSpeciesBn} / ${result.matchedSpeciesEn})। বিষক্রিয়ার ঝুঁকি এড়াতে দ্রুত নিকটস্থ অ্যান্টি-ভেনমযুক্ত হাসপাতালে যান।',
                    'The identified snake (${result.matchedSpeciesEn}) is venomous. To avoid envenomation, transport the patient to the nearest hospital stocked with anti-venom immediately.'
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                    height: 1.4,
                  ),
                );
              } else {
                return Text(
                  lang.t(
                    'শনাক্তকৃত সাপটি অবিষধর বা বিষহীন (${result.matchedSpeciesBn} / ${result.matchedSpeciesEn})। কামড়ের ক্ষতস্থান পরিষ্কার রাখুন এবং কোনো অস্বাভাবিক লক্ষণ দেখা দিলে চিকিৎসকের পরামর্শ নিন।',
                    'The identified snake (${result.matchedSpeciesEn}) is non-venomous. Keep the wound clean and consult a physician if any unusual symptoms develop.'
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    height: 1.4,
                  ),
                );
              }
            }
          }(),

          if (isChecklist) ...[
            const SizedBox(height: 8),
            Text(
              lang.t('সাপ সনাক্ত করা সম্ভব হয়নি। উপসর্গের ভিত্তিতে ঝুঁকি মূল্যায়ন করা হয়েছে। মনে রাখবেন, সাপ সনাক্ত করতে না পারার অর্থ এই নয় যে সাপটি অবিষধর ছিল।', 'The snake was not identified. Risk evaluated based on symptoms. Remember, failure to identify the snake does not mean it was non-venomous.'),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBiteRisksCard(dynamic result, bool isVenomous, AppLanguage lang) {
    final speciesDetails = SnakeDatabase.getSpeciesDetails(
      result.matchedSpeciesEn ?? '',
      result.matchedSpeciesBn ?? '',
    );

    // Default messages if species not found in database or unidentified
    final isUnidentified = result.matchedSpeciesEn == 'Unknown Species' || result.matchedSpeciesBn == 'অজানা প্রজাতি';
    
    final biteEffects = speciesDetails?.biteEffectsBn != null 
        ? lang.t(speciesDetails!.biteEffectsBn, speciesDetails.biteEffectsEn)
        : (isUnidentified
            ? lang.t('সাপের প্রজাতি অজানা হওয়ায় বিষক্রিয়ার প্রকৃতি সুনির্দিষ্ট করা যায়নি।', 'Since the species is unknown, specific venom effects cannot be determined.')
            : lang.t('প্রজাতির বিষক্রিয়ার ধরণ নির্ভরযোগ্য চিকিৎসা উৎস থেকে যাচাই করুন।', 'Verify venom effects for this species from reliable medical sources.'));
            
    final symptoms = speciesDetails?.symptomsBn != null
        ? lang.t(speciesDetails!.symptomsBn, speciesDetails.symptomsEn)
        : (isUnidentified
            ? lang.t('বিষাক্ত সাপের কামড়ে সাধারণত তীব্র ব্যথা, ফোলাভাব, রক্তপাত বা স্নায়বিক অসাড়তা দেখা দেয়।', 'Venomous bites typically cause severe pain, swelling, bleeding, or numbness.')
            : lang.t('ক্ষতস্থান লাল হওয়া, ফোলা ও ব্যথার অনুভূতি হতে পারে।', 'Local redness, swelling, and pain may occur.'));
            
    final progression = speciesDetails?.progressionBn != null
        ? lang.t(speciesDetails!.progressionBn, speciesDetails.progressionEn)
        : (isUnidentified
            ? lang.t('নিরাপত্তার স্বার্থে যেকোনো সাপ কামড়ানোর পর দ্রুত বিষক্রিয়া ছড়িয়ে পড়তে পারে বলে বিবেচনা করতে হবে।', 'For safety, any snakebite must be considered capable of rapid systemic progression.')
            : lang.t('বিষ ছড়ানোর আশঙ্কা কম, তবে ক্ষতস্থানে সংক্রমণের দিকে নজর রাখা জরুরি।', 'Low risk of systemic spread, but monitor the wound for infection.'));
            
    final fatality = speciesDetails?.fatalityBn != null
        ? lang.t(speciesDetails!.fatalityBn, speciesDetails.fatalityEn)
        : (isUnidentified
            ? lang.t('কিছু সাপের কামড় প্রাণঘাতী হতে পারে। দ্রুত চিকিৎসা গ্রহণ প্রাণ রক্ষা করতে পারে।', 'Bites from unidentified snakes can be highly dangerous and potentially fatal. Prompt treatment saves lives.')
            : lang.t('অবিষধর সাপের ক্ষেত্রে সাধারণত মৃত্যুর বা গুরুতর ঝুঁকির কোনো আশঙ্কা নেই।', 'Non-venomous bites carry no risk of systemic toxicity or fatality.'));

    final actions = speciesDetails?.actionsBn != null
        ? lang.t(speciesDetails!.actionsBn, speciesDetails.actionsEn)
        : lang.t('আক্রান্ত অঙ্গটি নড়াচড়া না করে হৃদপিণ্ডের সমতলের নিচে স্থির রাখুন। ক্ষত কাটবেন না বা শক্ত বাঁধবেন না।', 'Immobilize the bitten limb and keep it below heart level. Do not cut or apply tight tourniquets.');

    final emergency = speciesDetails?.emergencyBn != null
        ? lang.t(speciesDetails!.emergencyBn, speciesDetails.emergencyEn)
        : (isUnidentified
            ? lang.t('যদি সাপে কামড় দিয়ে থাকে, তবে কোনো লক্ষণের অপেক্ষা না করে অবিলম্বে নিকটস্থ হাসপাতালে যান।', 'If bitten, transport the patient to the nearest hospital immediately without waiting for symptoms.')
            : lang.t('কোনো অস্বাভাবিক জটিলতা দেখা দিলে বা কামড় খেয়ে থাকলে চিকিৎসকের সাথে পরামর্শ করুন।', 'Consult a physician if any unusual complications develop.'));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isVenomous ? AppColors.errorContainer.withOpacity(0.15) : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVenomous ? AppColors.error.withOpacity(0.3) : AppColors.outlineVariant,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: isVenomous ? AppColors.error : AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                lang.t('সাপের বিবরণ ও কামড়ের ঝুঁকি', 'Snake Details & Bite Risks'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isVenomous ? AppColors.error : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildInfoRow(lang.t('বিষক্রিয়ার ধরণ ও প্রভাব', 'Venom Toxicity & Effects'), biteEffects, isVenomous),
          const Divider(height: 24),
          _buildInfoRow(lang.t('সম্ভাবনা ও লক্ষণসমূহ', 'Possible Symptoms'), symptoms, isVenomous),
          const Divider(height: 24),
          _buildInfoRow(lang.t('অগ্রগতি ও সময়কাল', 'Progression & Timeline'), progression, isVenomous),
          const Divider(height: 24),
          _buildInfoRow(lang.t('ঝুঁকির মাত্রা ও প্রাণঘাতীতা', 'Severity & Fatality Risk'), fatality, isVenomous),
          const Divider(height: 24),
          _buildInfoRow(lang.t('তাৎক্ষণিক করণীয়', 'Immediate First Aid'), actions, isVenomous),
          const Divider(height: 24),
          _buildInfoRow(lang.t('জরুরি চিকিৎসার নির্দেশনা', 'Emergency Medical Guidance'), emergency, isVenomous),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String description, bool isVenomous) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isVenomous ? AppColors.error : AppColors.primary,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildFirstAidCard(List<String> firstAidSteps, AppLanguage lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.healing, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                lang.t('জরুরী প্রাথমিক পদক্ষেপ', 'Emergency First Aid'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: firstAidSteps.asMap().entries.map((entry) {
              final step = entry.value;
              final isWarning = step.contains('ওঝা') || step.contains('কেটে') || step.contains('টর্নিকেট') || step.contains('healer') || step.contains('tourniquet') || step.contains('cut');
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: isWarning ? AppColors.errorContainer : AppColors.primaryFixed,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isWarning ? Icons.close : Icons.check,
                        color: isWarning ? AppColors.error : AppColors.primary,
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        step,
                        style: TextStyle(
                          fontSize: 14,
                          color: isWarning ? AppColors.error : AppColors.textPrimary,
                          fontWeight: isWarning ? FontWeight.bold : FontWeight.normal,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, dynamic result, AppLanguage lang) {
    final hasDescription = lang.isBengali ? result.descriptionBn != null : result.descriptionEn != null;

    return Column(
      children: [
        // Primary CTA - Visual Focus
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => context.push('/hospital-radar'),
            icon: const Icon(Icons.local_hospital, color: Colors.white),
            label: Text(
              lang.t('কাছের অ্যান্টি-ভেনম হাসপাতাল খুঁজুন', 'Find Nearest Anti-venom Hospital'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Emergency Call
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () => _makeCall('999'),
            icon: const Icon(Icons.phone_in_talk, color: AppColors.error),
            label: Text(
              lang.t('জরুরী হেল্পলাইন ৯৯৯ কল করুন', 'Call Emergency Helpline 999'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.error),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Secondary Action - Diagnostic Assessment
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/bite-assessment'),
            icon: const Icon(Icons.health_and_safety, color: AppColors.primary),
            label: Text(
              lang.t('ক্ষত স্থান এআই মূল্যায়ন শুরু করুন', 'Start Wound AI Assessment'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.outlineVariant, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // Snake details if available
        if (hasDescription) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _showSnakeDetailsSheet(context, result, lang),
              icon: const Icon(Icons.menu_book, color: AppColors.primary),
              label: Text(
                lang.t('সাপটি সম্পর্কে বিস্তারিত জানুন', 'Learn More About the Snake'),
                style: const TextStyle(fontSize: 15, color: AppColors.primary),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.outlineVariant, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSafetyWarning(AppLanguage lang) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.tertiary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pan_tool, color: AppColors.onTertiaryContainer, size: 20),
          const SizedBox(width: 8),
          Text(
            lang.t('সাপের কাছে যাবেন না। নিরাপদ দূরত্ব বজায় রাখুন।', 'Do not approach the snake. Keep a safe distance.'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onTertiaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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

  void _showSnakeDetailsSheet(BuildContext context, dynamic result, AppLanguage lang) {
    final name = lang.t(result.matchedSpeciesBn ?? 'অজ্ঞাত প্রজাতি', result.matchedSpeciesEn ?? 'Unknown Species');
    final desc = lang.isBengali 
        ? (result.descriptionBn ?? 'এই প্রজাতি সম্পর্কে কোনো বিস্তারিত বিবরণ পাওয়া যায়নি।')
        : (result.descriptionEn ?? 'No detailed description available for this species.');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.matchedSpeciesEn ?? 'Unknown Species',
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

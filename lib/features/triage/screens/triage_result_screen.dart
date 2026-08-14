import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/triage_provider.dart';
import '../../scanner/providers/scanner_provider.dart';

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

    if (result == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('শনাক্তকরণ ফলাফল'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: const Center(
          child: Text('কোনো মূল্যায়নের তথ্য পাওয়া যায়নি।'),
        ),
      );
    }

    final bool isVenomous = result.venomous;
    final bool isChecklist = result.fallbackLayer != 1;
    final double confidenceVal = result.confidence ?? (isVenomous ? 0.85 : 0.15);
    final String confidencePctBn = _toBengaliDigits('${(confidenceVal * 100).toStringAsFixed(0)}%');

    // Dynamic symptoms display list
    final Map<String, String> symptomNamesBn = {
      'hood_seen': 'সাপের ফণা দেখা গেছে',
      'eyelid_droop': 'চোখের পাতা ঝুলে যাওয়া (Ptosis)',
      'bleeding_wound': 'ক্ষতস্থান থেকে ক্রমাগত রক্তপাত',
      'difficulty_breathing': 'শ্বাসকষ্ট ও গিলতে সমস্যা',
      'two_punctures': 'দুটি বিষদাঁতের ক্ষতচিহ্ন',
      'severe_pain': 'তীব্র ব্যথা',
      'swelling': 'ক্ষতস্থান ফুলে যাওয়া',
    };
    final selectedSymptoms = triageState.symptomAnswers.entries
        .where((e) => e.value)
        .map((e) => symptomNamesBn[e.key] ?? e.key)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.go('/'),
        ),
        title: const Text(
          'শনাক্তকরণ ফলাফল',
          style: TextStyle(
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
            _buildPrimaryResultCard(result, isVenomous, isChecklist, confidencePctBn),
            const SizedBox(height: 20),

            // 2. Snake Image Card (if image scan path)
            if (!isChecklist) ...[
              _buildSnakeImageCard(result, isVenomous, ref.watch(scannerProvider).imagePath),
              const SizedBox(height: 20),
              _buildConfidenceIndicator(confidenceVal, confidencePctBn),
              const SizedBox(height: 20),
            ],

            // 3. Clinical Symptoms & Warnings Card
            _buildClinicalWarningsCard(isVenomous, isChecklist, selectedSymptoms),
            const SizedBox(height: 20),

            // 4. First Aid Instructions Card
            _buildFirstAidCard(result.firstAidBn),
            const SizedBox(height: 24),

            // 5. Action Buttons (Visual Focus: Primary first, secondary later)
            _buildActionButtons(context, result),
            const SizedBox(height: 24),

            // Safety Warning
            _buildSafetyWarning(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryResultCard(dynamic result, bool isVenomous, bool isChecklist, String confidencePctBn) {
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
                ? 'লক্ষণ-ভিত্তিক বিষক্রিয়া ঝুঁকি মূল্যায়ন' 
                : 'সাপ সনাক্তকরণ ও বিষক্রিয়া ঝুঁকি মূল্যায়ন',
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.help_outline, color: AppColors.textSecondary, size: 20),
                SizedBox(width: 6),
                Text(
                  'সাপ সনাক্ত করা যায়নি',
                  style: TextStyle(
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
                isVenomous ? 'উচ্চ ঝুঁকি' : 'কম ঝুঁকি',
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
            'আনুমানিক বিষক্রিয়ার ঝুঁকি — $confidencePctBn',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isVenomous ? AppColors.error : AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'এই শতাংশটি আপনার দেওয়া লক্ষণসমূহের ওপর ভিত্তি করে বিষক্রিয়ার আনুমানিক ঝুঁকি নির্দেশ করে, সাপের প্রজাতি বিষধর হওয়ার নিশ্চয়তা নয়।',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnakeImageCard(dynamic result, bool isVenomous, String? imagePath) {
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
                  result.matchedSpeciesBn ?? 'অজ্ঞাত প্রজাতি',
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
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'বিষধর',
                          style: TextStyle(
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

  Widget _buildConfidenceIndicator(double confidenceVal, String confidencePctBn) {
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
                const Text(
                  'সাপ সনাক্তকরণে এআই আত্মবিশ্বাস',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '(ছবি দেখে প্রজাতি চেনার নির্ভরযোগ্যতা)',
                  style: TextStyle(
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

  Widget _buildClinicalWarningsCard(bool isVenomous, bool isChecklist, List<String> selectedSymptoms) {
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
                'সনাক্তকৃত শারীরিক লক্ষণসমূহ',
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
            const Text(
              'কোনো গুরুতর লক্ষণ সনাক্ত করা যায়নি।',
              style: TextStyle(
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
          Text(
            isVenomous 
                ? 'বিষক্রিয়া নিশ্চিত করা যাচ্ছে না, তবে আপনার দেওয়া উপসর্গগুলো গুরুতর হওয়ায় দ্রুত নিকটস্থ হাসপাতালে যান।'
                : 'সাপটি বিষাক্ত ছিল কিনা তা নিশ্চিত হওয়া যায়নি। যেকোনো নতুন বা মৃদু লক্ষণ দেখা দিলে সতর্ক থাকুন এবং ডাক্তারের পরামর্শ নিন।',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isVenomous ? AppColors.error : AppColors.textPrimary,
              height: 1.4,
            ),
          ),

          if (isChecklist) ...[
            const SizedBox(height: 8),
            const Text(
              'সাপ সনাক্ত করা সম্ভব হয়নি। উপসর্গের ভিত্তিতে ঝুঁকি মূল্যায়ন করা হয়েছে। মনে রাখবেন, সাপ সনাক্ত করতে না পারার অর্থ এই নয় যে সাপটি অবিষধর ছিল।',
              style: TextStyle(
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

  Widget _buildFirstAidCard(List<String> firstAidSteps) {
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
          const Row(
            children: [
              Icon(Icons.healing, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'জরুরী প্রাথমিক পদক্ষেপ',
                style: TextStyle(
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
              final idx = entry.key;
              final step = entry.value;
              final isWarning = step.contains('ওঝা') || step.contains('কেটে') || step.contains('টর্নিকেট') || step.contains('বাঁধুন');
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

  Widget _buildActionButtons(BuildContext context, dynamic result) {
    return Column(
      children: [
        // Primary CTA - Visual Focus
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => context.push('/hospital-radar'),
            icon: const Icon(Icons.local_hospital, color: Colors.white),
            label: const Text(
              'কাছের অ্যান্টি-ভেনম হাসপাতাল খুঁজুন',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
            label: const Text(
              'জরুরী হেল্পলাইন ৯৯৯ কল করুন',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.error),
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
            label: const Text(
              'ক্ষত স্থান এআই মূল্যায়ন শুরু করুন',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary),
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
        if (result.descriptionBn != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _showSnakeDetailsSheet(context, result),
              icon: const Icon(Icons.menu_book, color: AppColors.primary),
              label: const Text(
                'সাপটি সম্পর্কে বিস্তারিত জানুন',
                style: TextStyle(fontSize: 15, color: AppColors.primary),
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

  Widget _buildSafetyWarning() {
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
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pan_tool, color: AppColors.onTertiaryContainer, size: 20),
          SizedBox(width: 8),
          Text(
            'সাপের কাছে যাবেন না। নিরাপদ দূরত্ব বজায় রাখুন।',
            style: TextStyle(
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

  String _toBengaliDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bengali = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    String result = input;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], bengali[i]);
    }
    return result;
  }

  void _showSnakeDetailsSheet(BuildContext context, dynamic result) {
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
                          result.matchedSpeciesBn ?? 'অজ্ঞাত প্রজাতি',
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
                result.descriptionBn ?? 'এই প্রজাতি সম্পর্কে কোনো বিস্তারিত বিবরণ পাওয়া যায়নি।',
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

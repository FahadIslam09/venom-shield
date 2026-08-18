import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/locale_provider.dart';
import '../providers/bite_assessment_provider.dart';

class BiteAssessmentScreen extends ConsumerStatefulWidget {
  const BiteAssessmentScreen({super.key});

  @override
  ConsumerState<BiteAssessmentScreen> createState() => _BiteAssessmentScreenState();
}

class _BiteAssessmentScreenState extends ConsumerState<BiteAssessmentScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(biteAssessmentProvider.notifier).clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(biteAssessmentProvider);
    final notifier = ref.read(biteAssessmentProvider.notifier);
    final lang = ref.watch(localeProvider);

    final localSymptoms = {
      'pain': lang.t('তীব্র ব্যথা', 'Severe pain'),
      'swelling': lang.t('ফোলাভাব', 'Swelling'),
      'redness': lang.t('লালচে ভাব', 'Redness'),
      'bleeding': lang.t('রক্তপাত', 'Bleeding'),
      'bruising': lang.t('ক্ষতচিহ্ন/কালশিটে', 'Bruising'),
    };

    final neuroSymptoms = {
      'eyelid_droop': lang.t('চোখের পাতা ঝুলে পড়া', 'Drooping eyelids'),
      'speech_difficulty': lang.t('কথা বলতে সমস্যা', 'Difficulty speaking'),
      'breathing_difficulty': lang.t('শ্বাসকষ্ট বা দম বন্ধ ভাব', 'Difficulty breathing'),
    };

    final timeOptions = [
      lang.t('< ১৫ মি', '< 15 mins'),
      lang.t('১৫ - ৩০ মি', '15 - 30 mins'),
      lang.t('৩০ - ৬০ মি', '30 - 60 mins'),
      lang.t('> ১ ঘণ্টা', '> 1 hour'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            notifier.clear();
            context.pop();
          },
        ),
        title: Row(
          children: [
            const Icon(Icons.note_alt_outlined, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
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
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              lang.t('অফলাইন', 'Offline'),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.08,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Indicator
                Builder(
                  builder: (context) {
                    int currentStep = 1;
                    if (state.imagePath != null || state.timeSinceBite > 0) {
                      currentStep = 2;
                    }
                    final hasActiveSymptom = state.symptoms.values.any((status) => status > 0);
                    if (hasActiveSymptom) {
                      currentStep = 3;
                    }
                    return _buildProgressIndicator(currentStep, lang);
                  }
                ),
                const SizedBox(height: 32),

                // Section Header
                Text(
                  lang.t('কামড় মূল্যায়ন', 'Bite Assessment'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lang.t(
                    'এআই বিশ্লেষণের জন্য স্থানীয় এবং পদ্ধতিগত অগ্রগতি নথিভুক্ত করুন।', 
                    'Document local and systemic progression for AI analysis.'
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Bite Site Image Selection Card
                _buildGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.camera_alt, color: AppColors.secondary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            lang.t('ক্ষতস্থানের ছবি (ঐচ্ছিক)', 'Bite Wound Image (Optional)'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lang.t(
                          'ক্ষতস্থানের ছবি দিলে এআই ক্ষত পর্যবেক্ষণ করতে পারবে (যেমন: ফোলা বা রক্তপাত)।', 
                          'Providing a photo allows AI to observe wound details like swelling or active bleeding.'
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (state.imagePath != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              kIsWeb
                                  ? Image.network(state.imagePath!, height: 200, width: double.infinity, fit: BoxFit.cover)
                                  : Image.file(File(state.imagePath!), height: 200, width: double.infinity, fit: BoxFit.cover),
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.white, size: 28),
                                onPressed: () => notifier.removeImage(),
                              ),
                            ],
                          ),
                        ),
                        if (state.aiObservations.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang.t('এআই পর্যবেক্ষণ:', 'AI Observations:'),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                                ),
                                const SizedBox(height: 4),
                                ...state.aiObservations.map((obs) => Text('• $obs', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                              ],
                            ),
                          ),
                        ],
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => notifier.pickImage(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library),
                                label: Text(lang.t('গ্যালারি', 'Gallery')),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => notifier.pickImage(ImageSource.camera),
                                icon: const Icon(Icons.photo_camera),
                                label: Text(lang.t('ছবি তুলুন', 'Take Photo')),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Time Since Bite Section
                _buildGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.schedule, color: AppColors.secondary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            lang.t('কামড়ের সময়', 'Time Since Bite'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.5,
                        ),
                        itemCount: timeOptions.length,
                        itemBuilder: (context, idx) {
                          final isSelected = state.timeSinceBite == idx;
                          return GestureDetector(
                            onTap: () => notifier.updateTimeSinceBite(idx),
                            child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primaryContainer : AppColors.outlineVariant,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    timeOptions[idx],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? Colors.white : AppColors.onSurface,
                                      letterSpacing: 0.05,
                                    ),
                                  ),
                                ),
                              ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Local Symptoms Section
                _buildGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.visibility, color: AppColors.secondary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                lang.t('স্থানীয় লক্ষণ', 'Local Symptoms'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: const Color(0xFFFDE68A), width: 1),
                            ),
                            child: Text(
                              lang.t('স্থিতিশীল', 'Stable'),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF92400E),
                                letterSpacing: 0.08,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...localSymptoms.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildSymptomCheckItem(
                            key: entry.key,
                            label: entry.value,
                            state: state,
                            notifier: notifier,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Neurological Symptoms Section
                _buildGlassCard(
                  borderColor: AppColors.error.withOpacity(0.3),
                  accentColor: AppColors.error,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.psychology, color: AppColors.secondary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                lang.t('স্নায়বিক লক্ষণ', 'Systemic Symptoms'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.errorContainer,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  lang.t('বাড়ছে', 'Progressing'),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onErrorContainer,
                                    letterSpacing: 0.08,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...neuroSymptoms.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildNeuroSymptomItem(
                            key: entry.key,
                            label: entry.value,
                            state: state,
                            notifier: notifier,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          notifier.clear();
                          context.pop();
                        },
                        child: Text(lang.t('বাতিল করুন', 'Cancel')),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          notifier.calculateRisk();
                          context.push('/bite-assessment-result');
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(lang.t('বিশ্লেষণ শুরু করুন', 'Start Analysis')),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),

          // Loading Overlay
          if (state.isAnalyzingImage)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 48),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant, width: 1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: AppColors.primaryContainer),
                      const SizedBox(height: 24),
                      Text(
                        lang.t('এআই ক্ষতস্থান বিশ্লেষণ চলছে...', 'AI Wound Analysis in Progress...'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lang.t(
                          'ক্ষতের ফোলা বা কামড়ের দাগ পর্যবেক্ষণ করা হচ্ছে।', 
                          'Observing swelling or bite mark characteristics.'
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(int currentStep, AppLanguage lang) {
    return Row(
      children: [
        _buildStepCircle(1, lang.t('রোগী', 'Patient'), currentStep >= 1, currentStep == 1),
        Expanded(
          child: Container(
            height: 2,
            color: currentStep >= 2 ? AppColors.primaryContainer : AppColors.outlineVariant,
          ),
        ),
        _buildStepCircle(2, lang.t('লক্ষণ', 'Symptoms'), currentStep >= 2, currentStep == 2),
        Expanded(
          child: Container(
            height: 2,
            color: currentStep >= 3 ? AppColors.primaryContainer : AppColors.outlineVariant,
          ),
        ),
        _buildStepCircle(3, lang.t('বিশ্লেষণ', 'Analyze'), currentStep >= 3, currentStep == 3),
      ],
    );
  }

  Widget _buildStepCircle(int step, String label, bool isActive, bool isCurrent) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isActive ? AppColors.primaryContainer : AppColors.outlineVariant,
              width: 1,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppColors.primaryContainer.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : AppColors.onSurfaceVariant,
                letterSpacing: 0.05,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isActive ? AppColors.onSurface : AppColors.onSurfaceVariant,
            letterSpacing: 0.08,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child, Color? borderColor, Color? accentColor}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? AppColors.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (accentColor != null)
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              width: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16,
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomCheckItem({
    required String key,
    required String label,
    required BiteAssessmentState state,
    required BiteAssessmentNotifier notifier,
  }) {
    final isSelected = state.symptoms[key] != null && state.symptoms[key]! > 0;
    return GestureDetector(
      onTap: () => notifier.updateSymptom(key, isSelected ? 0 : 1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryContainer : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? AppColors.primaryContainer : AppColors.outlineVariant,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeuroSymptomItem({
    required String key,
    required String label,
    required BiteAssessmentState state,
    required BiteAssessmentNotifier notifier,
  }) {
    final isSelected = state.symptoms[key] != null && state.symptoms[key]! > 0;
    return GestureDetector(
      onTap: () => notifier.updateSymptom(key, isSelected ? 0 : 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Icon(Icons.psychology, color: AppColors.secondary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.error : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? AppColors.error : AppColors.outlineVariant,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

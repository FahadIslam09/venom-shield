import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/bite_assessment_provider.dart';

class BiteAssessmentScreen extends ConsumerStatefulWidget {
  const BiteAssessmentScreen({super.key});

  @override
  ConsumerState<BiteAssessmentScreen> createState() => _BiteAssessmentScreenState();
}

class _BiteAssessmentScreenState extends ConsumerState<BiteAssessmentScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(biteAssessmentProvider);
    final notifier = ref.read(biteAssessmentProvider.notifier);

    // Grouping symptoms for cleaner layout
    final localSymptoms = {
      'swelling': 'ক্ষতস্থানে ফোলাভাব',
      'swelling_increasing': 'ফোলা ক্রমশ বৃদ্ধি পাচ্ছে',
      'severe_pain': 'তীব্র ব্যথা',
      'skin_change': 'ত্বকের রঙ পরিবর্তন (কালচে/নীল)',
    };

    final neuroSymptoms = {
      'drooping_eyelids': 'চোখের পাতা ঝুলে যাচ্ছে',
      'blurred_vision': 'ঝাপসা বা দ্বৈত দৃষ্টি (ডাবল ভিশন)',
      'speech_difficulty': 'কথা বলতে জড়তা বা সমস্যা',
      'swallowing_difficulty': 'লালা বা খাবার গিলতে সমস্যা',
      'weakness': 'অস্বাভাবিক শারীরিক দুর্বলতা',
      'breathing_difficulty': 'শ্বাসকষ্ট বা দম বন্ধ অনুভূতি',
    };

    final systemicSymptoms = {
      'wound_bleeding': 'কামড়ের ক্ষতস্থান থেকে রক্তপাত',
      'nose_gum_bleeding': 'নাক বা মাড়ি থেকে রক্ত ক্ষরণ',
      'unusual_bruising': 'ত্বকে লাল বা কালো কালশিটে দাগ',
      'dizziness': 'মাথা ঘোরানো বা ঝিমঝিম করা',
      'fainting': 'অজ্ঞান হয়ে যাওয়া বা চেতনা হারানো',
      'vomiting': 'অতিরিক্ত বমি বমি ভাব বা বমি হওয়া',
      'dark_urine': 'কোকা-কোলা বা লালচে প্রস্রাব',
    };

    final timeOptions = [
      '৩০ মিনিটের কম',
      '৩০ মিনিট - ২ ঘন্টা',
      '২ - ৬ ঘন্টা',
      '৬ ঘন্টার বেশি',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('কামড়ের স্থান ও লক্ষণ মূল্যায়ন'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            notifier.clear();
            context.pop();
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primaryDark),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'সাপের ছবি না থাকলে এই মূল্যায়নের মাধ্যমে রোগীর বিষক্রিয়ার আনুমানিক ঝুঁকি নির্ণয় করুন। কামড়ের ক্ষতস্থানের ছবি দেওয়া ঐচ্ছিক।',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryDark,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 1. Image section
                const Text(
                  '১. কামড়ের স্থানের ছবি (ঐচ্ছিক)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: state.imagePath != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              state.imagePath!,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              right: 12,
                              top: 12,
                              child: Row(
                                children: [
                                  IconButton(
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      elevation: 4,
                                    ),
                                    icon: const Icon(Icons.delete, color: AppColors.danger),
                                    onPressed: () => notifier.removeImage(),
                                  ),
                                ],
                              ),
                            ),
                            if (state.aiObservations.isNotEmpty)
                              Positioned(
                                left: 12,
                                bottom: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'এআই পর্যবেক্ষণ: ${state.aiObservations.join(", ")}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'কামড়ের স্থান পরিষ্কারভাবে দেখানোর জন্য ছবি তুলুন',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => notifier.pickImage(ImageSource.camera),
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text('ক্যামেরা'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton.icon(
                                  onPressed: () => notifier.pickImage(ImageSource.gallery),
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('গ্যালারি'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
                if (state.aiFailedOrUnclear) ...[
                  const SizedBox(height: 8),
                  const Text(
                    '⚠️ ছবি পরিষ্কার নয় বা ক্ষতস্থান সনাক্ত করা সম্ভব হয়নি। তবুও নিচে লক্ষণ ফর্ম পূরণ করে এগিয়ে যান।',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 28),

                // 2. Time since bite
                const Text(
                  '২. কত সময় আগে কামড় লেগেছে?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.8,
                  ),
                  itemCount: timeOptions.length,
                  itemBuilder: (context, idx) {
                    final isSelected = state.timeSinceBite == idx;
                    return InkWell(
                      onTap: () => notifier.updateTimeSinceBite(idx),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            timeOptions[idx],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),

                // 3. Symptoms
                const Text(
                  '৩. রোগীর উপসর্গ ও অগ্রগতি',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'প্রতিটি উপসর্গের ক্ষেত্রে বর্তমান অবস্থা সিলেক্ট করুন।',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                _buildSymptomGroupCard('স্থানীয় উপসর্গ (Local Symptoms)', localSymptoms, state, notifier),
                const SizedBox(height: 16),
                _buildSymptomGroupCard('স্নায়বিক উপসর্গ (Neurological)', neuroSymptoms, state, notifier),
                const SizedBox(height: 16),
                _buildSymptomGroupCard('রক্ত ও সিস্টেমিক উপসর্গ (Systemic)', systemicSymptoms, state, notifier),

                const SizedBox(height: 36),

                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    notifier.calculateRisk();
                    context.push('/bite-assessment-result');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'ঝুঁকি মূল্যায়ন করুন',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
          if (state.isAnalyzingImage)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 48),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 24),
                        Text(
                          'এআই ক্ষতস্থান বিশ্লেষণ চলছে...',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'ক্ষতের ফোলা বা কামড়ের দাগ পর্যবেক্ষণ করা হচ্ছে। অনুগ্রহ করে অপেক্ষা করুন।',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSymptomGroupCard(
    String title,
    Map<String, String> symptoms,
    BiteAssessmentState state,
    BiteAssessmentNotifier notifier,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const Divider(height: 24),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: symptoms.keys.length,
              separatorBuilder: (context, idx) => const Divider(height: 16, color: AppColors.border),
              itemBuilder: (context, index) {
                final key = symptoms.keys.elementAt(index);
                final name = symptoms[key]!;
                final currentStatus = state.symptoms[key] ?? 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildStatusOption(
                          label: 'নেই',
                          isSelected: currentStatus == 0,
                          color: Colors.grey.shade400,
                          activeBgColor: Colors.grey.shade200,
                          activeTextColor: Colors.grey.shade800,
                          onTap: () => notifier.updateSymptom(key, 0),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusOption(
                          label: 'স্থিতিশীল',
                          isSelected: currentStatus == 1,
                          color: AppColors.warning,
                          activeBgColor: AppColors.warning.withOpacity(0.15),
                          activeTextColor: AppColors.warning,
                          onTap: () => notifier.updateSymptom(key, 1),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusOption(
                          label: 'ক্রমাগত বাড়ছে',
                          isSelected: currentStatus == 2,
                          color: AppColors.accent,
                          activeBgColor: AppColors.accentLight,
                          activeTextColor: AppColors.accent,
                          onTap: () => notifier.updateSymptom(key, 2),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption({
    required String label,
    required bool isSelected,
    required Color color,
    required Color activeBgColor,
    required Color activeTextColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeBgColor : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: 1.2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeTextColor : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

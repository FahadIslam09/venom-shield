import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../providers/triage_provider.dart';

class SymptomChecklistScreen extends ConsumerStatefulWidget {
  const SymptomChecklistScreen({super.key});

  @override
  ConsumerState<SymptomChecklistScreen> createState() => _SymptomChecklistScreenState();
}

class _SymptomChecklistScreenState extends ConsumerState<SymptomChecklistScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(triageProvider.notifier).clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(triageProvider);
    final lang = ref.watch(localeProvider);

    final List<Map<String, dynamic>> symptomList = [
      {
        'key': 'hood_seen',
        'title': lang.t('সাপের মাথায় ফণা দেখা গেছে', 'Snake raising head hood'),
        'description': lang.t('যেমন: গোখরা বা কেউটে সাপের মতো ফণা তোলা।', 'Example: Cobra or Krait raising a hood posture.'),
        'icon': Icons.visibility,
      },
      {
        'key': 'two_punctures',
        'title': lang.t('কামড়ের স্থানে দুটি সুনির্দিষ্ট গভীর ক্ষত', 'Two distinct fang puncture wounds'),
        'description': lang.t('বিষদাঁতের কারণে হওয়া দুটি ছোট ফুটো বা রক্তবিন্দু।', 'Two small punctures or blood spots from fangs.'),
        'icon': Icons.colorize,
      },
      {
        'key': 'eyelid_droop',
        'title': lang.t('চোখের পাতা ঝুলে পড়া বা ঝাপসা দেখা', 'Drooping eyelids or blurred vision'),
        'description': lang.t('চোখ মেলতে কষ্ট হওয়া বা একটি জিনিস দুটি দেখা (দ্বি-দৃষ্টি)।', 'Difficulty opening eyes or double vision (diplopia).'),
        'icon': Icons.remove_red_eye_outlined,
      },
      {
        'key': 'difficulty_breathing',
        'title': lang.t('শ্বাসকষ্ট বা গিলতে/কথা বলতে সমস্যা', 'Difficulty breathing or swallowing/speaking'),
        'description': lang.t('গলায় কিছু আটকে থাকার অনুভূতি বা দম বন্ধ হয়ে আসা।', 'Feeling of throat obstruction or suffocation.'),
        'icon': Icons.air,
      },
      {
        'key': 'bleeding_wound',
        'title': lang.t('ক্ষতস্থান থেকে অবিরাম রক্তক্ষরণ', 'Continuous bleeding from the wound'),
        'description': lang.t('রক্ত জমাট বাঁধছে না এবং অনবরত চুইয়ে রক্ত পড়ছে।', 'Blood not clotting and continuously oozing from the bite.'),
        'icon': Icons.opacity,
      },
      {
        'key': 'severe_pain',
        'title': lang.t('কামড়ের স্থানে তীব্র জ্বালাপোড়া বা ব্যথা', 'Severe pain or burning at the bite site'),
        'description': lang.t('কামড় খাওয়ার সঙ্গে সঙ্গে মারাত্মক যন্ত্রণা শুরু হওয়া।', 'Intense pain starting immediately after the bite.'),
        'icon': Icons.flash_on,
      },
      {
        'key': 'swelling',
        'title': lang.t('কামড়ের চারপাশ দ্রুত ফুলে লাল হওয়া', 'Rapid swelling and redness around the bite'),
        'description': lang.t('ক্ষতস্থান এবং তার আশেপাশের অংশ কালচে হয়ে ফুলে যাওয়া।', 'The bite site and surrounding area swelling and turning dark.'),
        'icon': Icons.report_problem_outlined,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(lang.t('লক্ষণ পরীক্ষা তালিকা', 'Symptom Checklist')),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            lang.t(
                              'সাপের বিবরণ এবং রোগীর বর্তমান শারীরিক লক্ষণগুলোর পাশে টিক চিহ্ন দিন। সঠিক মূল্যায়নের জন্য প্রতিটি তথ্য গুরুত্ব বহন করে।', 
                              'Check the boxes next to the snake description and active symptoms. Each detail is critical for accurate assessment.'
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    lang.t('লক্ষণ সমূহ নির্বাচন করুন', 'Select Symptoms'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Symptom items list
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: symptomList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final symptom = symptomList[index];
                      final String key = symptom['key'];
                      final bool isSelected = state.symptomAnswers[key] ?? false;
                      
                      return InkWell(
                        onTap: () => ref.read(triageProvider.notifier).toggleSymptom(key),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryLight.withOpacity(0.5) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : AppColors.background,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  symptom['icon'],
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      symptom['title'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      symptom['description'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Checkbox(
                                value: isSelected,
                                activeColor: AppColors.primary,
                                onChanged: (val) {
                                  ref.read(triageProvider.notifier).toggleSymptom(key);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom button
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.border),
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  ref.read(triageProvider.notifier).submitChecklist();
                  context.pushReplacement('/triage-result');
                },
                child: Text(lang.t('তাত্ক্ষণিক ফলাফল দেখুন', 'View Instant Results')),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const VenomShieldBottomNav(currentIndex: 2),
    );
  }
}

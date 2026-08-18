import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../core/widgets/language_toggle.dart';
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

    final List<Map<String, dynamic>> snakeFeatures = [
      {
        'key': 'hood_seen',
        'title': lang.t('সাপের মাথায় ফণা দেখা গেছে', 'Snake raised head hood'),
        'description': lang.t('গোখরা বা কেউটে সাপের মতো মাথা চওড়া করে ফণা তোলা বা হিসহিস শব্দ।', 'Cobra or Krait raising a distinct hood posture or hissing loudly.'),
        'icon': Icons.visibility,
        'isCritical': true,
      },
      {
        'key': 'triangular_head',
        'title': lang.t('ত্রিকোণাকার মাথা ও সরু ঘাড়', 'Triangular / Arrow-shaped head'),
        'description': lang.t('ভাইপারের মতো মাথাটি তীরের ফলার মতো চওড়া এবং ঘাড় স্পষ্ট সরু।', 'Arrowhead/triangular broad head with a distinctly narrow neck (Viper).'),
        'icon': Icons.change_history,
        'isCritical': false,
      },
      {
        'key': 'distinct_pattern',
        'title': lang.t('স্পষ্ট ডোরাকাটা বা শিকল ছোপ', 'Distinct bands or chain patterns'),
        'description': lang.t('কালো-সাদা স্পষ্ট রিং বা ডোরা (কেউটে) অথবা গোল গোল শিকল ছোপ (রাসেলস ভাইপার)।', 'Strong alternating bands (Krait) or circular chain blotches (Russell\'s Viper).'),
        'icon': Icons.texture,
        'isCritical': false,
      },
      {
        'key': 'paddle_tail',
        'title': lang.t('বৈঠার মতো চ্যাপ্টা লেজ (সামুদ্রিক)', 'Paddle-shaped flat tail'),
        'description': lang.t('লেজের শেষ অংশটি চ্যাপ্টা বৈঠার মতো (সামুদ্রিক বিষধর সাপের চিহ্ন)।', 'Laterally compressed flat tail adapted for swimming (Sea snake).'),
        'icon': Icons.waves,
        'isCritical': true,
      },
      {
        'key': 'night_sleeping_bite',
        'title': lang.t('রাতে বিছানায় বা ঘুমের মধ্যে কামড়', 'Night bite while sleeping in bed'),
        'description': lang.t('কালাচ / কেউটের কামড়ের প্রধান ধরণ (কামড়ে কোনো দাগ বা তীব্র ব্যথা নাও থাকতে পারে)।', 'Hallmark of Common Krait bites (often painless with minimal local bite marks).'),
        'icon': Icons.bedtime_outlined,
        'isCritical': true,
      },
    ];

    final List<Map<String, dynamic>> localWoundSymptoms = [
      {
        'key': 'two_punctures',
        'title': lang.t('কামড়ের স্থানে দুটি সুনির্দিষ্ট গভীর ক্ষত', 'Two distinct fang puncture wounds'),
        'description': lang.t('বিষদাঁতের কারণে পাশাপাশি হওয়া দুটি গভীর ফুটো বা রক্তবিন্দু।', 'Paired distinct puncture marks from venom fangs.'),
        'icon': Icons.colorize,
        'isCritical': false,
      },
      {
        'key': 'bleeding_wound',
        'title': lang.t('ক্ষতস্থান থেকে অবিরাম রক্তক্ষরণ', 'Continuous bleeding from the wound'),
        'description': lang.t('রক্ত কিছুতেই জমাট বাঁধছে না এবং অনবরত চুইয়ে রক্ত পড়ছে (ভাইপারের বিষক্রিয়া)।', 'Blood failing to clot, continuously oozing from the bite (Viper coagulopathy).'),
        'icon': Icons.opacity,
        'isCritical': true,
      },
      {
        'key': 'severe_pain',
        'title': lang.t('কামড়ের স্থানে তীব্র জ্বালাপোড়া বা ব্যথা', 'Immediate severe burning pain'),
        'description': lang.t('কামড় খাওয়ার সঙ্গে সঙ্গে মারাত্মক জ্বলুনি বা তীব্র যন্ত্রণা শুরু হওয়া।', 'Intense local pain starting immediately after the bite.'),
        'icon': Icons.flash_on,
        'isCritical': false,
      },
      {
        'key': 'swelling',
        'title': lang.t('কামড়ের চারপাশ দ্রুত ফুলে ছড়িয়ে পড়া', 'Rapidly spreading swelling and redness'),
        'description': lang.t('ক্ষতস্থান ছাড়িয়ে দ্রুত পুরো হাত বা পায়ের গিঁট অতিক্রম করে ফুলে যাওয়া।', 'Edema rapidly spreading across major joints (e.g. wrist to elbow/knee).'),
        'icon': Icons.report_problem_outlined,
        'isCritical': false,
      },
      {
        'key': 'blistering_necrosis',
        'title': lang.t('কালচে ফোস্কা বা চামড়া পচে যাওয়া', 'Dark blistering or tissue necrosis'),
        'description': lang.t('কামড়ের চারপাশের চামড়া কালো হওয়া বা রক্তযুক্ত ফোস্কা পড়া।', 'Blood-filled blisters or blackening of skin indicating tissue death.'),
        'icon': Icons.warning_amber_rounded,
        'isCritical': true,
      },
    ];

    final List<Map<String, dynamic>> neuroSymptoms = [
      {
        'key': 'eyelid_droop',
        'title': lang.t('চোখের পাতা ঝুলে পড়া বা ঝাপসা দেখা (Ptosis)', 'Drooping eyelids or blurred vision (Ptosis)'),
        'description': lang.t('চোখ খুলতে কষ্ট হওয়া, চোখের পাতা ভারী হয়ে নিচে পড়ে যাওয়া বা দ্বি-দৃষ্টি (১ম নিউরোটক্সিক লক্ষণ)।', 'Inability to keep eyelids open or double vision (earliest hallmark of neurotoxicity).'),
        'icon': Icons.remove_red_eye_outlined,
        'isCritical': true,
      },
      {
        'key': 'speech_swallowing_difficulty',
        'title': lang.t('কথা জড়িয়ে যাওয়া বা গিলতে কষ্ট', 'Slurred speech or difficulty swallowing'),
        'description': lang.t('মুখের লালা গিলতে না পারা বা গলার আওয়াজ ভারী হয়ে কথা জড়িয়ে যাওয়া।', 'Inability to swallow saliva, choking sensation, or slurred heavy speech.'),
        'icon': Icons.record_voice_over_outlined,
        'isCritical': true,
      },
      {
        'key': 'difficulty_breathing',
        'title': lang.t('শ্বাসকষ্ট ও দম বন্ধ হয়ে আসা', 'Difficulty breathing (Respiratory distress)'),
        'description': lang.t('বুকে তীব্র চাপ, দ্রুত হাঁপানো বা শ্বাস নিতে না পারা (চরম জীবনসংশয়কারী জরুরি অবস্থা!)।', 'Severe dyspnea or respiratory muscle paralysis (Critical medical emergency!).'),
        'icon': Icons.air,
        'isCritical': true,
      },
      {
        'key': 'flaccid_paralysis',
        'title': lang.t('ঘাড় সোজা রাখতে না পারা ও পেশির অসাড়তা', 'Broken neck sign & flaccid muscle weakness'),
        'description': lang.t('মাথা সোজা রাখতে না পেরে হেলে পড়া, হাত-পা নড়াচড়া করতে না পারা।', 'Inability to hold the head upright (broken neck sign) and flaccid limb weakness.'),
        'icon': Icons.accessibility_new_outlined,
        'isCritical': true,
      },
    ];

    final List<Map<String, dynamic>> systemicSymptoms = [
      {
        'key': 'spontaneous_bleeding',
        'title': lang.t('মাড়ি, নাক বা প্রস্রাবে রক্তপাত', 'Spontaneous bleeding (gums, nose, urine)'),
        'description': lang.t('দাঁতের মাড়ি দিয়ে রক্ত পড়া, লালচে/কালো প্রস্রাব বা কাশির সাথে রক্ত আসা।', 'Spontaneous gingival bleeding, epistaxis, or hematuria (blood in urine).'),
        'icon': Icons.bloodtype_outlined,
        'isCritical': true,
      },
      {
        'key': 'abdominal_vomiting',
        'title': lang.t('তীব্র পেটব্যথা ও ক্রমাগত বমি', 'Severe abdominal colic & persistent vomiting'),
        'description': lang.t('পেটে মোচড় দেওয়া অসহ্য ব্যথা এবং বারবার বমি হওয়া (কালাচ বিষক্রিয়ার সংকেত)।', 'Severe cramping abdominal pain and recurrent vomiting (systemic envenomation).'),
        'icon': Icons.sick_outlined,
        'isCritical': true,
      },
      {
        'key': 'myalgia_dark_urine',
        'title': lang.t('সারা গায়ে তীব্র পেশি ব্যথা ও কালো প্রস্রাব', 'Severe generalized muscle pain / Cola-colored urine'),
        'description': lang.t('পেশি শক্ত হয়ে ব্যথা করা বা কোকাকোলার মতো গাঢ় কালো প্রস্রাব (কিডনি জটিলতার ঝুঁকি)।', 'Profound myalgia or myoglobinuria (dark tea/cola urine indicating kidney risk).'),
        'icon': Icons.water_drop_outlined,
        'isCritical': true,
      },
      {
        'key': 'dizziness_shock',
        'title': lang.t('অতিরিক্ত ঘাম, মাথা ঘোরা বা অজ্ঞান হওয়া', 'Cold sweating, severe dizziness or collapse (Shock)'),
        'description': lang.t('শরীর অস্বাভাবিক ঠান্ডা ও ঘর্মাক্ত হওয়া, রক্তচাপ কমে জ্ঞান হারিয়ে ফেলা।', 'Profuse cold diaphoresis, profound hypotension, and sudden fainting.'),
        'icon': Icons.sentiment_very_dissatisfied_outlined,
        'isCritical': true,
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
        title: Text(
          lang.t('লক্ষণ ও তালিকা মূল্যায়ন', 'Symptoms & List Evaluation'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: BilingualLanguageToggle(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Important Medical Advisory Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.2),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.security, color: AppColors.primary, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.t('চিকিৎসা নির্দেশিকা ও জরুরি সতর্কতা', 'Clinical Guidelines & Safety Rules'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lang.t(
                                  'সঠিক মূল্যায়নের জন্য সাপের বৈশিষ্ট্য এবং রোগীর বর্তমান প্রতিটি লক্ষণ সতর্কতার সাথে চিহ্নিত করুন। কোনো একটি জরুরি লক্ষণ দেখা দিলে অবিলম্বে নিকটস্থ হাসপাতালে যান।', 
                                  'Carefully check all observed snake features and active symptoms. If any critical emergency sign is present, proceed immediately to the nearest hospital.'
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section 1: Snake Characteristics
                  _buildSectionHeader(
                    title: lang.t('১. সাপের শারীরিক বৈশিষ্ট্য ও আচরণ', '1. Snake Physical Features & Encounter'),
                    icon: Icons.pest_control_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 10),
                  ...snakeFeatures.map((item) => _buildSymptomCard(item, state, lang)),

                  const SizedBox(height: 20),

                  // Section 2: Bite Wound & Local Signs
                  _buildSectionHeader(
                    title: lang.t('২. কামড়ের ক্ষত ও স্থানীয় লক্ষণ', '2. Bite Wound & Local Symptoms'),
                    icon: Icons.healing,
                    color: const Color(0xFFC05621),
                  ),
                  const SizedBox(height: 10),
                  ...localWoundSymptoms.map((item) => _buildSymptomCard(item, state, lang)),

                  const SizedBox(height: 20),

                  // Section 3: Neurotoxic Symptoms
                  _buildSectionHeader(
                    title: lang.t('৩. স্নায়বিক বা নিউরোটক্সিক উপসর্গ (জরুরি)', '3. Neurotoxic Symptoms (Critical Emergency)'),
                    icon: Icons.psychology_outlined,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 10),
                  ...neuroSymptoms.map((item) => _buildSymptomCard(item, state, lang)),

                  const SizedBox(height: 20),

                  // Section 4: Systemic, Hemotoxic & Shock Signs
                  _buildSectionHeader(
                    title: lang.t('৪. রক্তক্ষরণ ও শারীরিক বিষক্রিয়া', '4. Systemic, Hemotoxic & Shock Signs'),
                    icon: Icons.medical_services_outlined,
                    color: AppColors.tertiaryContainer,
                  ),
                  const SizedBox(height: 10),
                  ...systemicSymptoms.map((item) => _buildSymptomCard(item, state, lang)),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          // Bottom submit button
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.outlineVariant),
                ),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  ref.read(triageProvider.notifier).submitChecklist();
                  context.pushReplacement('/triage-result');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.analytics_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      lang.t('সম্পূর্ণ মূল্যায়ন ও ফলাফল দেখুন', 'Submit & View Comprehensive Evaluation'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const VenomShieldBottomNav(currentIndex: 2),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomCard(Map<String, dynamic> item, TriageState state, AppLanguage lang) {
    final String key = item['key'];
    final bool isSelected = state.symptomAnswers[key] ?? false;
    final bool isCritical = item['isCritical'] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => ref.read(triageProvider.notifier).toggleSymptom(key),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isCritical ? AppColors.errorContainer.withOpacity(0.3) : AppColors.primaryFixed.withOpacity(0.4))
                : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? (isCritical ? AppColors.error : AppColors.primary)
                  : AppColors.outlineVariant,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isCritical ? AppColors.error : AppColors.primary)
                      : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item['icon'],
                  color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['title'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? (isCritical ? AppColors.error : AppColors.primary)
                                  : AppColors.onSurface,
                            ),
                          ),
                        ),
                        if (isCritical)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.errorContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              lang.t('জরুরি', 'Critical'),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item['description'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Checkbox(
                value: isSelected,
                activeColor: isCritical ? AppColors.error : AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: (val) {
                  ref.read(triageProvider.notifier).toggleSymptom(key);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

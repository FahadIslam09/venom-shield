import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/bite_assessment_result.dart';
import '../services/bite_analysis_service.dart';

class BiteAssessmentState {
  final bool isAnalyzingImage;
  final String? base64Image;
  final String? imagePath;
  final List<String> aiObservations;
  final bool aiFailedOrUnclear;
  final Map<String, int> symptoms; // symptom_key -> status (0 = নেই, 1 = স্থিতিশীল, 2 = ক্রমাগত বাড়ছে)
  final int timeSinceBite; // 0 = <30m, 1 = 30m-2h, 2 = 2h-6h, 3 = >6h
  final BiteAssessmentResult? result;

  BiteAssessmentState({
    this.isAnalyzingImage = false,
    this.base64Image,
    this.imagePath,
    this.aiObservations = const [],
    this.aiFailedOrUnclear = false,
    required this.symptoms,
    this.timeSinceBite = 0,
    this.result,
  });

  BiteAssessmentState copyWith({
    bool? isAnalyzingImage,
    String? base64Image,
    String? imagePath,
    List<String>? aiObservations,
    bool? aiFailedOrUnclear,
    Map<String, int>? symptoms,
    int? timeSinceBite,
    BiteAssessmentResult? result,
  }) {
    return BiteAssessmentState(
      isAnalyzingImage: isAnalyzingImage ?? this.isAnalyzingImage,
      base64Image: base64Image ?? this.base64Image,
      imagePath: imagePath ?? this.imagePath,
      aiObservations: aiObservations ?? this.aiObservations,
      aiFailedOrUnclear: aiFailedOrUnclear ?? this.aiFailedOrUnclear,
      symptoms: symptoms ?? this.symptoms,
      timeSinceBite: timeSinceBite ?? this.timeSinceBite,
      result: result ?? this.result,
    );
  }
}

class BiteAssessmentNotifier extends StateNotifier<BiteAssessmentState> {
  final BiteAnalysisService _analysisService = BiteAnalysisService();
  final ImagePicker _picker = ImagePicker();

  static final Map<String, int> defaultSymptoms = {
    // Local
    'swelling': 0,
    'swelling_increasing': 0,
    'severe_pain': 0,
    'skin_change': 0,
    // Neurological
    'drooping_eyelids': 0,
    'blurred_vision': 0,
    'speech_difficulty': 0,
    'swallowing_difficulty': 0,
    'weakness': 0,
    'breathing_difficulty': 0,
    // Systemic/Bleeding
    'wound_bleeding': 0,
    'nose_gum_bleeding': 0,
    'unusual_bruising': 0,
    'dizziness': 0,
    'fainting': 0,
    'vomiting': 0,
    'dark_urine': 0,
  };

  BiteAssessmentNotifier()
      : super(BiteAssessmentState(symptoms: Map.from(defaultSymptoms)));

  void clear() {
    state = BiteAssessmentState(symptoms: Map.from(defaultSymptoms));
  }

  void updateSymptom(String key, int status) {
    final Map<String, int> updated = Map.from(state.symptoms);
    updated[key] = status;
    state = state.copyWith(symptoms: updated);
  }

  void updateTimeSinceBite(int val) {
    state = state.copyWith(timeSinceBite: val);
  }

  Future<void> pickImage(ImageSource source) async {
    state = state.copyWith(isAnalyzingImage: true, aiFailedOrUnclear: false, aiObservations: []);

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) {
        state = state.copyWith(isAnalyzingImage: false);
        return;
      }

      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);

      state = state.copyWith(
        base64Image: base64String,
        imagePath: image.path,
      );

      // Perform AI Analysis on the bite site
      final aiResult = await _analysisService.analyzeBiteSite(base64String);

      if (aiResult == null || aiResult['unclear'] == true) {
        state = state.copyWith(
          isAnalyzingImage: false,
          aiFailedOrUnclear: true,
          aiObservations: aiResult != null && aiResult['unclear'] == true ? ['ছবি পরিষ্কার নয়'] : [],
        );
      } else {
        final List<dynamic> obsList = aiResult['observations'] ?? [];
        state = state.copyWith(
          isAnalyzingImage: false,
          aiFailedOrUnclear: false,
          aiObservations: obsList.map((e) => e.toString()).toList(),
        );
      }
    } catch (e) {
      state = state.copyWith(
        isAnalyzingImage: false,
        aiFailedOrUnclear: true,
      );
    }
  }

  void removeImage() {
    state = state.copyWith(
      base64Image: null,
      imagePath: null,
      aiObservations: [],
      aiFailedOrUnclear: false,
    );
  }

  void calculateRisk() {
    double score = 0.0;
    final List<String> reasons = [];

    // 1. Add AI Observations to score and reasons
    if (state.aiObservations.isNotEmpty && !state.aiFailedOrUnclear) {
      score += 8.0;
      reasons.add('কামড়ের স্থানে বাহ্যিক অস্বাভাবিকতা (এআই পর্যবেক্ষণ): ${state.aiObservations.join(", ")}');
    }

    // Define categories of symptoms for weighted scoring
    final criticalKeys = [
      'breathing_difficulty',
      'fainting',
      'nose_gum_bleeding',
      'swallowing_difficulty',
      'speech_difficulty'
    ];
    final severeKeys = [
      'drooping_eyelids',
      'blurred_vision',
      'wound_bleeding',
      'unusual_bruising',
      'dark_urine',
      'vomiting',
      'dizziness',
      'weakness'
    ];
    final localKeys = [
      'swelling',
      'swelling_increasing',
      'severe_pain',
      'skin_change'
    ];

    // Local Bangla names for reasons
    final Map<String, String> symptomNamesBn = {
      'swelling': 'ক্ষতস্থানে ফোলাভাব',
      'swelling_increasing': 'ফোলা ক্রমশ বৃদ্ধি পাওয়া',
      'severe_pain': 'তীব্র ব্যথা অনুভব',
      'skin_change': 'ত্বকের রঙ পরিবর্তন',
      'drooping_eyelids': 'চোখের পাতা ঝুলে যাওয়া (স্নায়বিক)',
      'blurred_vision': 'ঝাপসা বা দ্বৈত দৃষ্টি (স্নায়বিক)',
      'speech_difficulty': 'কথা বলতে সমস্যা (স্নায়বিক)',
      'swallowing_difficulty': 'গিলতে সমস্যা (স্নায়বিক)',
      'weakness': 'অস্বাভাবিক শারীরিক দুর্বলতা',
      'breathing_difficulty': 'শ্বাসকষ্ট হওয়া (জীবন-ঝুঁকি)',
      'wound_bleeding': 'কামড়ের ক্ষতস্থান থেকে রক্তপাত',
      'nose_gum_bleeding': 'নাক বা মাড়ি থেকে রক্তপাত',
      'unusual_bruising': 'ত্বকে অস্বাভাবিক কালশিটে',
      'dizziness': 'মাথা ঘোরানো',
      'fainting': 'অজ্ঞান হয়ে যাওয়া (জীবন-ঝুঁকি)',
      'vomiting': 'বমি হওয়া',
      'dark_urine': 'গাঢ় রঙের প্রস্রাব',
    };

    // Calculate score
    bool hasCriticalProgressing = false;
    bool hasSevereProgressing = false;

    state.symptoms.forEach((key, status) {
      if (status == 0) return; // not present

      double contribution = 0.0;
      String statusText = status == 2 ? ' (ক্রমবর্ধমান)' : ' (স্থিতিশীল)';
      reasons.add('${symptomNamesBn[key] ?? key}$statusText');

      if (criticalKeys.contains(key)) {
        if (status == 2) {
          contribution = 25.0;
          hasCriticalProgressing = true;
        } else {
          contribution = 15.0;
        }
      } else if (severeKeys.contains(key)) {
        if (status == 2) {
          contribution = 18.0;
          hasSevereProgressing = true;
        } else {
          contribution = 10.0;
        }
      } else if (localKeys.contains(key)) {
        if (status == 2) {
          contribution = 10.0;
        } else {
          contribution = 5.0;
        }
      }

      score += contribution;
    });

    // Time multiplier/adjustments
    // 0 = <30m, 1 = 30m-2h, 2 = 2h-6h, 3 = >6h
    if (state.timeSinceBite == 0 && (hasCriticalProgressing || hasSevereProgressing)) {
      // Rapid onset of progressive symptoms is extremely dangerous
      score *= 1.25;
      reasons.add('কামড়ের ৩০ মিনিটের মধ্যে লক্ষণসমূহ দ্রুত বৃদ্ধি পাচ্ছে');
    } else if (state.timeSinceBite == 3 && score > 15.0) {
      // Long time elapsed with active symptoms indicates prolonged envenomation
      score *= 1.15;
      reasons.add('কামড়ের পর দীর্ঘ সময় (>৬ ঘণ্টা) পার হয়েছে এবং লক্ষণ বিদ্যমান');
    }

    // Force high or critical risk if critical symptoms are progressing
    if (hasCriticalProgressing && score < 80.0) {
      score = 85.0;
    } else if (criticalKeys.any((k) => state.symptoms[k] == 1) && score < 50.0) {
      score = 55.0;
    }

    // Cap and floor
    if (score > 99.0) score = 99.0;
    if (score < 5.0) score = 5.0;

    // Determine Risk Level & Description
    String level;
    String description;

    if (score >= 80.0) {
      level = 'অত্যন্ত উচ্চ ঝুঁকি';
      description = 'জীবন-ঝুঁকিপূর্ণ লক্ষণ রয়েছে। অবিলম্বে জরুরি চিকিৎসা প্রয়োজন।';
    } else if (score >= 50.0) {
      level = 'উচ্চ ঝুঁকি';
      description = 'একাধিক গুরুতর লক্ষণ পাওয়া গেছে। দ্রুত হাসপাতালে যান।';
    } else if (score >= 20.0) {
      level = 'মাঝারি ঝুঁকি';
      description = 'কিছু উদ্বেগজনক লক্ষণ আছে। ডাক্তারী পর্যবেক্ষণ প্রয়োজন।';
    } else {
      level = 'কম ঝুঁকি';
      description = 'গুরুতর লক্ষণ পাওয়া যায়নি। তবে সতর্ক থাকুন এবং পর্যবেক্ষণ করুন।';
    }

    final safetyRules = [
      'কখনো নিশ্চিতভাবে বিষধর/অবিষধর বলা সম্ভব নয়।',
      'শুধুমাত্র ছবি দেখে শতভাগ নিশ্চিত হওয়া যায় না।',
      'কম ঝুঁকি মানেই সম্পূর্ণ নিরাপদ নয়, লক্ষণ যেকোনো সময় বাড়তে পারে।',
      'গুরুতর উপসর্গ দেখা দিলে দেরি না করে তাৎক্ষণিক হাসপাতালে যান।',
      'কোনো প্রকার কবিরাজি, ঝাড়ফুঁক বা ওঝার চিকিৎসা সম্পূর্ণ নিষিদ্ধ।',
      'ক্ষত কাটা, চোষা বা অতিরিক্ত শক্ত বাঁধন দেওয়া নিষেধ (অঙ্গহানি হতে পারে)।'
    ];

    state = state.copyWith(
      result: BiteAssessmentResult(
        riskPercentage: score,
        riskLevel: level,
        riskDescription: description,
        observations: state.aiObservations,
        observedReasons: reasons,
        warningMessages: safetyRules,
      ),
    );
  }
}

final biteAssessmentProvider =
    StateNotifierProvider<BiteAssessmentNotifier, BiteAssessmentState>((ref) {
  return BiteAssessmentNotifier();
});

import '../../scanner/models/scan_result.dart';
import '../models/triage_result.dart';

class TriageEngine {
  static const List<String> standardFirstAidBn = [
    'আতঙ্কিত হবেন না। শান্ত থাকুন।',
    'কামড় খাওয়া অঙ্গটি নড়াচড়া করবেন না। হাত বা পা হলে স্প্লিন্ট (যেমন কাঠ বা বাঁশের টুকরো) দিয়ে স্থির করে রাখুন।',
    'ক্ষতস্থান সাবান ও হালকা জল দিয়ে পরিষ্কার করুন।',
    'ক্ষতস্থানের ওপর কোনো শক্ত বাঁধন বা টর্নিকেট দেবেন না (এটি রক্ত চলাচল বন্ধ করে অঙ্গহানির কারণ হতে পারে)।',
    'ব্লেড দিয়ে কেটে রক্ত বের করার চেষ্টা করবেন না বা ওঝার কাছে গিয়ে সময় নষ্ট করবেন না।'
  ];

  static const List<String> venomousFirstAidBn = [
    'আক্রান্ত অঙ্গটি হৃদপিণ্ডের সমতলের নিচে স্থির রাখুন।',
    'ক্ষতস্থানে বরফ, ব্লেড বা কোনো শক্ত বাঁধন লাগাবেন না।',
    'যত দ্রুত সম্ভব নিকটস্থ অ্যান্টি-ভেনমযুক্ত হাসপাতালে রোগীকে নিয়ে যান।',
    'রোগীকে ওঝার কাছে নিয়ে মূল্যবান "গোল্ডেন আওয়ার" নষ্ট করবেন না।'
  ];

  static const List<String> standardFirstAidEn = [
    'Do not panic. Remain calm.',
    'Do not move the bitten limb. Keep it immobilized using a splint (e.g. piece of wood or bamboo) if it is a hand or leg.',
    'Wash the wound gently with soap and clean water.',
    'Do not apply any tight tourniquet or bandage (this can block blood flow and lead to limb damage).',
    'Do not cut the wound to bleed it or waste time visiting a traditional healer.'
  ];

  static const List<String> venomousFirstAidEn = [
    'Keep the affected limb immobilized below heart level.',
    'Do not apply ice, cut the wound, or tie any tight tourniquets.',
    'Transport the patient to the nearest hospital stocked with anti-venom as quickly as possible.',
    'Do not waste the precious "golden hour" by taking the patient to a traditional healer.'
  ];

  TriageResult processTriage({
    ScanResult? scanResult,
    Map<String, bool>? symptomAnswers,
  }) {
    // Layer 1: Image Scan (Snake detection)
    if (scanResult != null && scanResult.confidence >= 0.65) {
      return TriageResult(
        venomous: scanResult.venomous,
        severity: scanResult.dangerLevel,
        reasonBn: scanResult.venomous
            ? 'ছবি স্ক্যানের মাধ্যমে বিষাক্ত সাপ (${scanResult.speciesBn} / ${scanResult.speciesEn}) শনাক্ত করা হয়েছে।'
            : 'ছবি স্ক্যানের মাধ্যমে বিষহীন সাপ (${scanResult.speciesBn} / ${scanResult.speciesEn}) শনাক্ত করা হয়েছে।',
        reasonEn: scanResult.venomous
            ? 'Venomous snake (${scanResult.speciesEn}) identified via image scan.'
            : 'Non-venomous snake (${scanResult.speciesEn}) identified via image scan.',
        firstAidBn: scanResult.venomous ? venomousFirstAidBn : standardFirstAidBn,
        firstAidEn: scanResult.venomous ? venomousFirstAidEn : standardFirstAidEn,
        matchedSpeciesBn: scanResult.speciesBn,
        matchedSpeciesEn: scanResult.speciesEn,
        fallbackLayer: 1,
        confidence: scanResult.confidence,
        descriptionBn: scanResult.descriptionBn,
        descriptionEn: scanResult.descriptionEn,
      );
    }

    // Layer 2: Interactive Comprehensive Symptom & Characteristics Evaluation
    if (symptomAnswers != null && symptomAnswers.isNotEmpty) {
      double score = 0.0;
      final List<String> detectedRedFlagsBn = [];
      final List<String> detectedRedFlagsEn = [];

      // 1. Critical Red Flags (Direct life-threatening indicators)
      if (symptomAnswers['eyelid_droop'] == true) {
        score += 6.0;
        detectedRedFlagsBn.add('চোখের পাতা ঝুলে পড়া (Ptosis)');
        detectedRedFlagsEn.add('Drooping eyelids (Ptosis)');
      }
      if (symptomAnswers['difficulty_breathing'] == true) {
        score += 7.0;
        detectedRedFlagsBn.add('শ্বাসকষ্ট');
        detectedRedFlagsEn.add('Respiratory distress');
      }
      if (symptomAnswers['speech_swallowing_difficulty'] == true) {
        score += 6.0;
        detectedRedFlagsBn.add('কথা জড়ানো বা গিলতে না পারা');
        detectedRedFlagsEn.add('Slurred speech / swallowing difficulty');
      }
      if (symptomAnswers['flaccid_paralysis'] == true) {
        score += 6.5;
        detectedRedFlagsBn.add('ঘাড় সোজা রাখতে না পারা ও পেশির অসাড়তা');
        detectedRedFlagsEn.add('Broken neck sign / flaccid paralysis');
      }
      if (symptomAnswers['spontaneous_bleeding'] == true) {
        score += 6.5;
        detectedRedFlagsBn.add('অস্বাভাবিক রক্তক্ষরণ (মাড়ি/প্রস্রাবে রক্ত)');
        detectedRedFlagsEn.add('Spontaneous bleeding / Hematuria');
      }
      if (symptomAnswers['myalgia_dark_urine'] == true) {
        score += 5.5;
        detectedRedFlagsBn.add('তীব্র পেশি ব্যথা বা কালো প্রস্রাব');
        detectedRedFlagsEn.add('Severe myalgia / Dark cola urine');
      }
      if (symptomAnswers['dizziness_shock'] == true) {
        score += 5.5;
        detectedRedFlagsBn.add('শকের লক্ষণ বা জ্ঞান হারানো');
        detectedRedFlagsEn.add('Signs of shock / Loss of consciousness');
      }
      if (symptomAnswers['hood_seen'] == true) {
        score += 5.0;
        detectedRedFlagsBn.add('ফণা তোলা বিষধর সাপের উপস্থিতি');
        detectedRedFlagsEn.add('Hooded venomous snake observed');
      }
      if (symptomAnswers['paddle_tail'] == true) {
        score += 5.0;
        detectedRedFlagsBn.add('সামুদ্রিক বিষধর সাপের লেজ');
        detectedRedFlagsEn.add('Paddle-tailed sea snake');
      }
      if (symptomAnswers['night_sleeping_bite'] == true && symptomAnswers['abdominal_vomiting'] == true) {
        score += 6.0;
        detectedRedFlagsBn.add('রাতে ঘুমানোর সময় কামড় ও পেটব্যথা (কালাচ/কেউটের নিশ্চিত লক্ষণ)');
        detectedRedFlagsEn.add('Night sleeping bite with abdominal colic (Krait pattern)');
      }

      // 2. High-Risk Local & Encounter Indicators
      if (symptomAnswers['two_punctures'] == true) score += 3.5;
      if (symptomAnswers['bleeding_wound'] == true) score += 4.0;
      if (symptomAnswers['triangular_head'] == true) score += 3.5;
      if (symptomAnswers['distinct_pattern'] == true) score += 2.5;
      if (symptomAnswers['blistering_necrosis'] == true) score += 3.5;
      if (symptomAnswers['swelling'] == true) score += 3.0;
      if (symptomAnswers['severe_pain'] == true) score += 2.0;
      if (symptomAnswers['abdominal_vomiting'] == true && symptomAnswers['night_sleeping_bite'] != true) score += 2.5;
      if (symptomAnswers['night_sleeping_bite'] == true && symptomAnswers['abdominal_vomiting'] != true) score += 2.0;

      final bool hasCriticalFlag = detectedRedFlagsBn.isNotEmpty;

      if (hasCriticalFlag || score >= 3.5) {
        final severity = (hasCriticalFlag || score >= 7.0) ? 'high' : 'medium';
        final flagSummaryBn = hasCriticalFlag ? ' (সনাক্তকৃত জরুরি লক্ষণ: ${detectedRedFlagsBn.join(", ")})' : '';
        final flagSummaryEn = hasCriticalFlag ? ' (Critical signs: ${detectedRedFlagsEn.join(", ")})' : '';

        return TriageResult(
          venomous: true,
          severity: severity,
          reasonBn: 'শারীরিক লক্ষণ ও সাপের বৈশিষ্ট্য বিশ্লেষণ অনুযায়ী এটি বিষাক্ত সাপের কামড় (স্কোর: ${score.toStringAsFixed(1)})$flagSummaryBn। অবিলম্বে অ্যান্টিভেনমযুক্ত জরুরি হাসপাতালে যান।',
          reasonEn: 'Based on clinical symptoms and snake characteristics, this indicates a venomous snakebite (Score: ${score.toStringAsFixed(1)})$flagSummaryEn. Immediate hospital care is required.',
          firstAidBn: venomousFirstAidBn,
          firstAidEn: venomousFirstAidEn,
          fallbackLayer: 2,
          confidence: hasCriticalFlag ? 0.95 : (score >= 7.0 ? 0.90 : 0.80),
        );
      } else {
        final bool hasAnyInput = symptomAnswers.values.any((val) => val == true);
        return TriageResult(
          venomous: false,
          severity: 'low',
          reasonBn: hasAnyInput
              ? 'লক্ষণ ও বৈশিষ্ট্যে বিষক্রিয়ার সুস্পষ্ট সংকেত পাওয়া যায়নি (স্কোর: ${score.toStringAsFixed(1)})। সতর্কতা: কালাচ বা কিছু ভাইপারের লক্ষণ বিলম্বে (১২-২৪ ঘণ্টার মধ্যে) দেখা দিতে পারে। রোগীকে সার্বক্ষণিক পর্যবেক্ষণে রাখুন।'
              : 'কোনো বিষাক্ত লক্ষণ বা শারীরিক জটিলতা পাওয়া যায়নি। সতর্কতা: পরবর্তী ২৪ ঘণ্টা রোগীকে সতর্ক পর্যবেক্ষণে রাখুন।',
          reasonEn: hasAnyInput
              ? 'Clinical symptoms and features do not show overt envenomation (Score: ${score.toStringAsFixed(1)}). Note: Krait/Viper symptoms may be delayed up to 12-24 hours. Keep patient under close observation.'
              : 'No venomous characteristics or active symptoms reported. Observe the patient closely for the next 24 hours.',
          firstAidBn: standardFirstAidBn,
          firstAidEn: standardFirstAidEn,
          fallbackLayer: 2,
          confidence: hasAnyInput ? 0.85 : 0.90,
        );
      }
    }

    // Layer 3: Fail-Safe Default Rule
    // No data or ambiguous inputs -> Safety First: assume venomous, route to hospital
    return TriageResult(
      venomous: true,
      severity: 'high',
      reasonBn: 'পর্যাপ্ত তথ্য পাওয়া যায়নি। জাতীয় প্রটোকল অনুযায়ী জরুরি সতর্কতাবশত কামড়টিকে বিষাক্ত বিবেচনা করে হাসপাতালে রেফার করা হচ্ছে।',
      reasonEn: 'Insufficient data available. Following medical safety guidelines, the bite is conservatively treated as venomous and referred to hospital.',
      firstAidBn: venomousFirstAidBn,
      firstAidEn: venomousFirstAidEn,
      fallbackLayer: 3,
      confidence: 0.50,
    );
  }
}

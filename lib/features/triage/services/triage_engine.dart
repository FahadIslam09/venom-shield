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

  TriageResult processTriage({
    ScanResult? scanResult,
    Map<String, bool>? symptomAnswers,
    bool isBiteMarkScan = false,
  }) {
    // Layer 1: Image Scan (Snake detection)
    if (scanResult != null && scanResult.confidence >= 0.65) {
      return TriageResult(
        venomous: scanResult.venomous,
        severity: scanResult.dangerLevel,
        reasonBn: scanResult.venomous
            ? 'ছবি স্ক্যানের মাধ্যমে বিষাক্ত সাপ (${scanResult.speciesBn} / ${scanResult.speciesEn}) শনাক্ত করা হয়েছে।'
            : 'ছবি স্ক্যানের মাধ্যমে বিষহীন সাপ (${scanResult.speciesBn} / ${scanResult.speciesEn}) শনাক্ত করা হয়েছে।',
        firstAidBn: scanResult.venomous ? venomousFirstAidBn : standardFirstAidBn,
        matchedSpeciesBn: scanResult.speciesBn,
        matchedSpeciesEn: scanResult.speciesEn,
        fallbackLayer: 1,
      );
    }

    // Layer 1.5: Bite Mark Scan fallback if image is specified as a bite mark
    if (isBiteMarkScan && scanResult != null && scanResult.venomous) {
      return TriageResult(
        venomous: true,
        severity: 'high',
        reasonBn: 'কামড়ের স্থানের ছবি বিশ্লেষণ করে বিষদাঁতের গভীর ক্ষতের লক্ষণ পাওয়া গেছে।',
        firstAidBn: venomousFirstAidBn,
        fallbackLayer: 1,
      );
    }

    // Layer 2: Interactive Symptom Checklist
    if (symptomAnswers != null && symptomAnswers.isNotEmpty) {
      double score = 0.0;
      
      // Calculate weighted score
      if (symptomAnswers['hood_seen'] == true) score += 4.0;       // head hood (Cobra/Krait)
      if (symptomAnswers['eyelid_droop'] == true) score += 4.5;    // neurotoxic symptom
      if (symptomAnswers['bleeding_wound'] == true) score += 3.5;  // hemotoxic symptom
      if (symptomAnswers['difficulty_breathing'] == true) score += 5.0; // respiratory failure
      if (symptomAnswers['two_punctures'] == true) score += 3.0;   // fang punctures
      if (symptomAnswers['severe_pain'] == true) score += 2.0;     // local envenomation
      if (symptomAnswers['swelling'] == true) score += 2.5;        // local swelling

      if (score >= 4.0) {
        return TriageResult(
          venomous: true,
          severity: score >= 8.0 ? 'high' : 'medium',
          reasonBn: 'শারীরিক লক্ষণ ও সাপের বিবরণ অনুযায়ী এটি বিষাক্ত সাপের কামড় হওয়ার সম্ভাবনা রয়েছে (স্কোর: ${score.toStringAsFixed(1)})।',
          firstAidBn: venomousFirstAidBn,
          fallbackLayer: 2,
        );
      } else {
        return TriageResult(
          venomous: false,
          severity: 'low',
          reasonBn: 'লক্ষণ বিশ্লেষণ করে বিষক্রিয়ার তেমন কোনো চিহ্ন পাওয়া যায়নি (স্কোর: ${score.toStringAsFixed(1)})। তবুও সতর্ক থাকুন।',
          firstAidBn: standardFirstAidBn,
          fallbackLayer: 2,
        );
      }
    }

    // Layer 3: Fail-Safe Default Rule
    // No data or ambiguous inputs -> Safety First: assume venomous, route to hospital
    return TriageResult(
      venomous: true,
      severity: 'high',
      reasonBn: 'পর্যপ্ত তথ্য পাওয়া যায়নি। জাতীয় গাইডলাইন অনুযায়ী জরুরি সতর্কতাবশত কামড়টিকে বিষাক্ত হিসেবে বিবেচনা করে হাসপাতালে রেফার করা হচ্ছে।',
      firstAidBn: venomousFirstAidBn,
      fallbackLayer: 3,
    );
  }
}

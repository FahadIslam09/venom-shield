import 'package:flutter_test/flutter_test.dart';
import 'package:venomshield/features/triage/services/triage_engine.dart';
import 'package:venomshield/features/scanner/models/scan_result.dart';

void main() {
  group('TriageEngine Tests', () {
    final engine = TriageEngine();

    test('High confidence venomous scan result yields venomous triage', () {
      final scanResult = ScanResult(
        status: 'identified',
        speciesBn: 'খৈয়া গোখরা',
        speciesEn: 'Spectacled Cobra',
        venomous: true,
        confidence: 0.85,
        dangerLevel: 'high',
        firstAidBn: [],
        firstAidEn: [],
        descriptionBn: '',
        descriptionEn: '',
      );

      final result = engine.processTriage(scanResult: scanResult);

      expect(result.venomous, isTrue);
      expect(result.fallbackLayer, equals(1));
      expect(result.matchedSpeciesBn, equals('খৈয়া গোখরা'));
    });

    test('Symptom answers checklist scoring above threshold yields venomous triage', () {
      final symptomAnswers = {
        'hood_seen': true,          // +4.0
        'eyelid_droop': false,
        'bleeding_wound': false,
        'difficulty_breathing': false,
        'two_punctures': false,
        'severe_pain': false,
        'swelling': false,
      };

      final result = engine.processTriage(symptomAnswers: symptomAnswers);

      expect(result.venomous, isTrue);
      expect(result.fallbackLayer, equals(2));
    });

    test('Empty symptoms checklist yields venomous default fail-safe triage', () {
      final result = engine.processTriage();

      expect(result.venomous, isTrue);
      expect(result.fallbackLayer, equals(3));
    });
  });
}

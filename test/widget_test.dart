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
        'hood_seen': true,
        'eyelid_droop': false,
        'bleeding_wound': false,
      };

      final result = engine.processTriage(symptomAnswers: symptomAnswers);

      expect(result.venomous, isTrue);
      expect(result.fallbackLayer, equals(2));
    });

    test('Critical Neurotoxic sign (ptosis) yields venomous emergency triage', () {
      final symptomAnswers = {
        'eyelid_droop': true,
      };

      final result = engine.processTriage(symptomAnswers: symptomAnswers);

      expect(result.venomous, isTrue);
      expect(result.severity, equals('high'));
      expect(result.confidence, greaterThanOrEqualTo(0.90));
    });

    test('Night sleeping bite with abdominal colic (Krait pattern) yields venomous triage', () {
      final symptomAnswers = {
        'night_sleeping_bite': true,
        'abdominal_vomiting': true,
      };

      final result = engine.processTriage(symptomAnswers: symptomAnswers);

      expect(result.venomous, isTrue);
      expect(result.severity, equals('high'));
    });

    test('All symptoms false yields non-venomous low risk triage with observation warning', () {
      final symptomAnswers = {
        'hood_seen': false,
        'eyelid_droop': false,
        'two_punctures': false,
        'bleeding_wound': false,
      };

      final result = engine.processTriage(symptomAnswers: symptomAnswers);

      expect(result.venomous, isFalse);
      expect(result.severity, equals('low'));
    });

    test('Empty symptoms checklist yields venomous default fail-safe triage', () {
      final result = engine.processTriage();

      expect(result.venomous, isTrue);
      expect(result.fallbackLayer, equals(3));
    });
  });
}

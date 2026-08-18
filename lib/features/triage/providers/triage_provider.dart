import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/triage_result.dart';
import '../services/triage_engine.dart';
import '../../scanner/models/scan_result.dart';
import '../../../core/database/database_helper.dart';
import '../../home/providers/history_provider.dart';

class TriageState {
  final Map<String, bool> symptomAnswers;
  final TriageResult? result;

  TriageState({
    required this.symptomAnswers,
    this.result,
  });

  TriageState copyWith({
    Map<String, bool>? symptomAnswers,
    TriageResult? result,
  }) {
    return TriageState(
      symptomAnswers: symptomAnswers ?? this.symptomAnswers,
      result: result ?? this.result,
    );
  }
}

class TriageNotifier extends StateNotifier<TriageState> {
  final TriageEngine _engine = TriageEngine();
  final Ref _ref;

  static final Map<String, bool> defaultSymptoms = {
    // Snake Characteristics & Encounter Context
    'hood_seen': false,
    'triangular_head': false,
    'distinct_pattern': false,
    'paddle_tail': false,
    'night_sleeping_bite': false,

    // Bite Wound & Local Symptoms
    'two_punctures': false,
    'bleeding_wound': false,
    'severe_pain': false,
    'swelling': false,
    'blistering_necrosis': false,

    // Neurotoxic Symptoms
    'eyelid_droop': false,
    'speech_swallowing_difficulty': false,
    'difficulty_breathing': false,
    'flaccid_paralysis': false,

    // Hemotoxic, Systemic & Myotoxic Symptoms
    'spontaneous_bleeding': false,
    'abdominal_vomiting': false,
    'myalgia_dark_urine': false,
    'dizziness_shock': false,
  };

  TriageNotifier(this._ref) : super(TriageState(symptomAnswers: Map.from(defaultSymptoms)));

  void clear() {
    state = TriageState(symptomAnswers: Map.from(defaultSymptoms));
  }

  void toggleSymptom(String key) {
    final Map<String, bool> updated = Map.from(state.symptomAnswers);
    updated[key] = !(updated[key] ?? false);
    state = state.copyWith(symptomAnswers: updated);
  }

  void submitChecklist() {
    final result = _engine.processTriage(symptomAnswers: state.symptomAnswers);
    state = state.copyWith(result: result);
    // Dynamic history save
    DatabaseHelper.instance.saveAssessment(
      type: 'লক্ষণ তালিকা',
      venomous: result.venomous,
      riskPercentage: result.venomous ? 85.0 : 15.0,
      riskLevel: result.venomous ? 'উচ্চ ঝুঁকি' : 'কম ঝুঁকি',
      symptoms: state.symptomAnswers.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList(),
    ).then((_) {
      _ref.read(historyProvider.notifier).loadHistory();
    });
  }

  void submitImageResult(ScanResult scanResult, {bool isBiteMark = false}) {
    final result = _engine.processTriage(
      scanResult: scanResult,
      isBiteMarkScan: isBiteMark,
    );
    state = state.copyWith(result: result);
    // Dynamic history save
    DatabaseHelper.instance.saveAssessment(
      type: 'সাপ স্ক্যান',
      venomous: result.venomous,
      riskPercentage: (scanResult.confidence * 100),
      riskLevel: result.venomous ? 'উচ্চ ঝুঁকি' : 'কম ঝুঁকি',
      matchedSpecies: '${scanResult.speciesBn} (${scanResult.speciesEn})',
    ).then((_) {
      _ref.read(historyProvider.notifier).loadHistory();
    });
  }

  void submitFailSafe() {
    final result = _engine.processTriage();
    state = state.copyWith(result: result);
  }
}

final triageProvider = StateNotifierProvider<TriageNotifier, TriageState>((ref) {
  return TriageNotifier(ref);
});

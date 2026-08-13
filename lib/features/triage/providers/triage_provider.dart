import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/triage_result.dart';
import '../services/triage_engine.dart';
import '../../scanner/models/scan_result.dart';

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

  static final Map<String, bool> defaultSymptoms = {
    'hood_seen': false,
    'eyelid_droop': false,
    'bleeding_wound': false,
    'difficulty_breathing': false,
    'two_punctures': false,
    'severe_pain': false,
    'swelling': false,
  };

  TriageNotifier() : super(TriageState(symptomAnswers: Map.from(defaultSymptoms)));

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
  }

  void submitImageResult(ScanResult scanResult, {bool isBiteMark = false}) {
    final result = _engine.processTriage(
      scanResult: scanResult,
      isBiteMarkScan: isBiteMark,
    );
    state = state.copyWith(result: result);
  }

  void submitFailSafe() {
    final result = _engine.processTriage();
    state = state.copyWith(result: result);
  }
}

final triageProvider = StateNotifierProvider<TriageNotifier, TriageState>((ref) {
  return TriageNotifier();
});

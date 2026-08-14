import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_helper.dart';

class HistoryState {
  final List<Map<String, dynamic>> assessments;
  final bool isLoading;

  HistoryState({this.assessments = const [], this.isLoading = true});
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier() : super(HistoryState()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final history = await DatabaseHelper.instance.getAssessments();
      state = HistoryState(assessments: history, isLoading: false);
    } catch (_) {
      state = HistoryState(assessments: [], isLoading: false);
    }
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier();
});

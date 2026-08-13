class TriageResult {
  final bool venomous;
  final String severity; // high, medium, low
  final String reasonBn;
  final List<String> firstAidBn;
  final String? matchedSpeciesBn;
  final String? matchedSpeciesEn;
  final int fallbackLayer; // 1 = Image Scan, 2 = Symptom checklist, 3 = Fail-safe default

  TriageResult({
    required this.venomous,
    required this.severity,
    required this.reasonBn,
    required this.firstAidBn,
    this.matchedSpeciesBn,
    this.matchedSpeciesEn,
    required this.fallbackLayer,
  });
}

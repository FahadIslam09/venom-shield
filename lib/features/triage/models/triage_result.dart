class TriageResult {
  final bool venomous;
  final String severity; // high, medium, low
  final String reasonBn;
  final String reasonEn;
  final List<String> firstAidBn;
  final List<String> firstAidEn;
  final String? matchedSpeciesBn;
  final String? matchedSpeciesEn;
  final int fallbackLayer; // 1 = Image Scan, 2 = Symptom checklist, 3 = Fail-safe default
  final double? confidence;
  final String? descriptionBn;
  final String? descriptionEn;

  TriageResult({
    required this.venomous,
    required this.severity,
    required this.reasonBn,
    required this.reasonEn,
    required this.firstAidBn,
    required this.firstAidEn,
    this.matchedSpeciesBn,
    this.matchedSpeciesEn,
    required this.fallbackLayer,
    this.confidence,
    this.descriptionBn,
    this.descriptionEn,
  });
}

class BiteAssessmentResult {
  final double riskPercentage;
  final String riskLevel; // কম ঝুঁকি, মাঝারি ঝুঁকি, উচ্চ ঝুঁকি, অত্যন্ত উচ্চ ঝুঁকি
  final String riskDescription;
  final List<String> observations; // Observations from AI (if any)
  final List<String> observedReasons; // List of matched reasons
  final List<String> warningMessages;
  final List<String> firstAidBn;

  BiteAssessmentResult({
    required this.riskPercentage,
    required this.riskLevel,
    required this.riskDescription,
    required this.observations,
    required this.observedReasons,
    required this.warningMessages,
    required this.firstAidBn,
  });
}

class ScanResult {
  final String status; // identified, unidentified, not_detected
  final String speciesBn;
  final String speciesEn;
  final bool venomous;
  final double confidence;
  final String dangerLevel; // high, medium, low
  final List<String> firstAidBn;
  final List<String> firstAidEn;
  final String descriptionBn;
  final String descriptionEn;

  ScanResult({
    required this.status,
    required this.speciesBn,
    required this.speciesEn,
    required this.venomous,
    required this.confidence,
    required this.dangerLevel,
    required this.firstAidBn,
    required this.firstAidEn,
    required this.descriptionBn,
    required this.descriptionEn,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      status: json['status'] as String? ?? 'identified',
      speciesBn: json['species_bn'] as String? ?? 'অজানা প্রজাতি',
      speciesEn: json['species_en'] as String? ?? 'Unknown Species',
      venomous: json['venomous'] == true || json['venomous'] == 1,
      confidence: (json['confidence'] as num? ?? 0.0).toDouble(),
      dangerLevel: json['danger_level'] as String? ?? 'medium',
      firstAidBn: (json['first_aid_bn'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      firstAidEn: (json['first_aid_en'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      descriptionBn: json['description_bn'] as String? ?? '',
      descriptionEn: json['description_en'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'species_bn': speciesBn,
      'species_en': speciesEn,
      'venomous': venomous ? 1 : 0,
      'confidence': confidence,
      'danger_level': dangerLevel,
      'first_aid_bn': firstAidBn,
      'first_aid_en': firstAidEn,
      'description_bn': descriptionBn,
      'description_en': descriptionEn,
    };
  }
}

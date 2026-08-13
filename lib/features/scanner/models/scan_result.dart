class ScanResult {
  final String speciesBn;
  final String speciesEn;
  final bool venomous;
  final double confidence;
  final String dangerLevel; // high, medium, low
  final List<String> firstAidBn;
  final String descriptionBn;

  ScanResult({
    required this.speciesBn,
    required this.speciesEn,
    required this.venomous,
    required this.confidence,
    required this.dangerLevel,
    required this.firstAidBn,
    required this.descriptionBn,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      speciesBn: json['species_bn'] as String? ?? 'অজানা প্রজাতি',
      speciesEn: json['species_en'] as String? ?? 'Unknown Species',
      venomous: json['venomous'] == true || json['venomous'] == 1,
      confidence: (json['confidence'] as num? ?? 0.0).toDouble(),
      dangerLevel: json['danger_level'] as String? ?? 'medium',
      firstAidBn: (json['first_aid_bn'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      descriptionBn: json['description_bn'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'species_bn': speciesBn,
      'species_en': speciesEn,
      'venomous': venomous ? 1 : 0,
      'confidence': confidence,
      'danger_level': dangerLevel,
      'first_aid_bn': firstAidBn,
      'description_bn': descriptionBn,
    };
  }
}

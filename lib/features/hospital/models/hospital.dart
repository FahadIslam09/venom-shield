class Hospital {
  final int id;
  final String nameBn;
  final String nameEn;
  final String district;
  final String upazila;
  final double lat;
  final double lng;
  final String phone;
  final String type; // medical_college, district, upazila, general
  final String antivenomStatus; // in_stock, limited, out_of_stock
  final bool hasEmergency;

  Hospital({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.district,
    required this.upazila,
    required this.lat,
    required this.lng,
    required this.phone,
    required this.type,
    required this.antivenomStatus,
    required this.hasEmergency,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'] as int,
      nameBn: json['name_bn'] as String,
      nameEn: json['name_en'] as String,
      district: json['district'] as String? ?? '',
      upazila: json['upazila'] as String? ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      phone: json['phone'] as String? ?? '',
      type: json['type'] as String? ?? 'general',
      antivenomStatus: json['antivenom_status'] as String? ?? 'out_of_stock',
      hasEmergency: json['has_emergency'] == 1 || json['has_emergency'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_bn': nameBn,
      'name_en': nameEn,
      'district': district,
      'upazila': upazila,
      'lat': lat,
      'lng': lng,
      'phone': phone,
      'type': type,
      'antivenom_status': antivenomStatus,
      'has_emergency': hasEmergency ? 1 : 0,
    };
  }
}

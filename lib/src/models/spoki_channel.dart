num? _parseQualityScore(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String)
    return int.tryParse(value) ?? num.tryParse(value)?.toInt();
  return null;
}

class SpokiChannel {
  final int? id;
  final String? name;
  final String? phone;
  final String? phoneStatus;
  final num? qualityScore;
  final dynamic qualityReasons;
  final bool? hasOfficialVerification;
  final int? dailyLimit;
  final int? accountType;
  final bool? isActive;

  SpokiChannel({
    this.id,
    this.name,
    this.phone,
    this.phoneStatus,
    this.qualityScore,
    this.qualityReasons,
    this.hasOfficialVerification,
    this.dailyLimit,
    this.accountType,
    this.isActive,
  });

  factory SpokiChannel.fromJson(Map<String, dynamic> json) => SpokiChannel(
        id: _asInt(json['id']),
        name: json['name'] as String?,
        phone: json['phone'] as String?,
        phoneStatus: json['phone_status'] as String?,
        qualityScore: _parseQualityScore(json['quality_score']),
        qualityReasons: json['quality_reasons'],
        hasOfficialVerification: json['has_official_verification'] as bool?,
        dailyLimit: _asInt(json['daily_limit']),
        accountType: _asInt(json['account_type']),
        isActive: json['is_active'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'phone_status': phoneStatus,
        'quality_score': qualityScore,
        'quality_reasons': qualityReasons,
        'has_official_verification': hasOfficialVerification,
        'daily_limit': dailyLimit,
        'account_type': accountType,
        'is_active': isActive,
      };

  @override
  String toString() => toJson().toString();
}

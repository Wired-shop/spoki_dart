import 'spoki_channel.dart';

num? _parseQualityScore(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? num.tryParse(value)?.toInt();
  }
  return null;
}

num? _asNum(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

class SpokiAccount {
  final int id;
  final String? name;
  final int? currentCreditMillis;
  final String? status;
  final String? defaultLanguage;
  final String? phone;
  final bool? hasOfficialVerification;
  final int? dailyLimit;
  final String? phoneStatus;
  final num? qualityScore;
  final dynamic qualityReasons;
  final bool? isActive;
  final String? countryCode;
  final int? accountType;
  final num? defaultPricingDelta;
  final int? lowCreditThreshold;
  final bool? hasLowCreditAlert;
  final int? minCreditBalanceMillicents;
  final String? defaultPrefix;
  final String? defaultCountryCode;
  final String? timezone;
  final int? contactedIn24h;
  final int? contactedIn7d;
  final int? primaryChannelId;
  final int? estimatedAvailableConversations;
  final List<SpokiChannel> channels;

  SpokiAccount({
    required this.id,
    this.name,
    this.currentCreditMillis,
    this.status,
    this.defaultLanguage,
    this.phone,
    this.hasOfficialVerification,
    this.dailyLimit,
    this.phoneStatus,
    this.qualityScore,
    this.qualityReasons,
    this.isActive,
    this.countryCode,
    this.accountType,
    this.defaultPricingDelta,
    this.lowCreditThreshold,
    this.hasLowCreditAlert,
    this.minCreditBalanceMillicents,
    this.defaultPrefix,
    this.defaultCountryCode,
    this.timezone,
    this.contactedIn24h,
    this.contactedIn7d,
    this.primaryChannelId,
    this.estimatedAvailableConversations,
    this.channels = const [],
  });

  double? get currentCreditEuros =>
      currentCreditMillis != null ? currentCreditMillis! / 1000 : null;

  bool get isLowCredit =>
      hasLowCreditAlert == true ||
      (currentCreditMillis != null &&
          lowCreditThreshold != null &&
          currentCreditMillis! <= lowCreditThreshold!);

  int? estimatedMessagesAtPrice(double pricePerMessageEuros) {
    final euros = currentCreditEuros;
    if (euros == null || pricePerMessageEuros <= 0) return null;
    return (euros / pricePerMessageEuros).floor();
  }

  factory SpokiAccount.fromJson(Map<String, dynamic> json) => SpokiAccount(
        id: _asInt(json['id']) ?? 0,
        name: json['name'] as String?,
        currentCreditMillis: _asInt(json['current_credit']),
        status: json['status'] as String?,
        defaultLanguage: json['default_language'] as String?,
        phone: json['phone'] as String?,
        hasOfficialVerification: json['has_official_verification'] as bool?,
        dailyLimit: _asInt(json['daily_limit']),
        phoneStatus: json['phone_status'] as String?,
        qualityScore: _parseQualityScore(json['quality_score']),
        qualityReasons: json['quality_reasons'],
        isActive: json['is_active'] as bool?,
        countryCode: json['country_code'] as String?,
        accountType: _asInt(json['account_type']),
        defaultPricingDelta: _asNum(json['default_pricing_delta']),
        lowCreditThreshold: _asInt(json['low_credit_threshold']),
        hasLowCreditAlert: json['has_low_credit_alert'] as bool?,
        minCreditBalanceMillicents:
            _asInt(json['min_credit_balance_millicents']),
        defaultPrefix: json['default_prefix'] as String?,
        defaultCountryCode: json['default_country_code'] as String?,
        timezone: json['timezone'] as String?,
        contactedIn24h: _asInt(json['contacted_in_24h']),
        contactedIn7d: _asInt(json['contacted_in_7d']),
        primaryChannelId: _asInt(json['primary_channel_id']),
        estimatedAvailableConversations:
            _asInt(json['estimated_available_conversations']),
        channels: (json['channels'] as List<dynamic>? ?? [])
            .map((e) => SpokiChannel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'current_credit': currentCreditMillis,
        'status': status,
        'default_language': defaultLanguage,
        'phone': phone,
        'has_official_verification': hasOfficialVerification,
        'daily_limit': dailyLimit,
        'phone_status': phoneStatus,
        'quality_score': qualityScore,
        'quality_reasons': qualityReasons,
        'is_active': isActive,
        'country_code': countryCode,
        'account_type': accountType,
        'default_pricing_delta': defaultPricingDelta,
        'low_credit_threshold': lowCreditThreshold,
        'has_low_credit_alert': hasLowCreditAlert,
        'min_credit_balance_millicents': minCreditBalanceMillicents,
        'default_prefix': defaultPrefix,
        'default_country_code': defaultCountryCode,
        'timezone': timezone,
        'contacted_in_24h': contactedIn24h,
        'contacted_in_7d': contactedIn7d,
        'primary_channel_id': primaryChannelId,
        'estimated_available_conversations': estimatedAvailableConversations,
        'channels': channels.map((c) => c.toJson()).toList(),
      };

  @override
  String toString() => toJson().toString();
}

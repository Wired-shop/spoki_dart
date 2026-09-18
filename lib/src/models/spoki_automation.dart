class SpokiAutomation {
  final int id;
  final String? name;
  final bool? isActive;
  final bool? isFavorite;
  final List<Map<String, dynamic>> webhookSet;

  SpokiAutomation({
    required this.id,
    this.name,
    this.isActive,
    this.isFavorite,
    this.webhookSet = const [],
  });

  String? get firstWebhookUrl =>
      webhookSet.isNotEmpty ? webhookSet.first['link'] as String? : null;

  factory SpokiAutomation.fromJson(Map<String, dynamic> json) =>
      SpokiAutomation(
        id: json['id'] as int,
        name: json['name'] as String?,
        isActive: json['is_active'] as bool?,
        isFavorite: json['is_favorite'] as bool?,
        webhookSet: (json['webhook_set'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'is_active': isActive,
        'is_favorite': isFavorite,
        'webhook_set': webhookSet,
      };

  @override
  String toString() => toJson().toString();
}

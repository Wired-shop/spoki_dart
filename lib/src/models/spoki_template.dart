import '../enums/spoki_template_category.dart';
import '../enums/spoki_template_status.dart';
import 'template_localization.dart';

class SpokiTemplate {
  final int? id;
  final String name;
  final SpokiTemplateCategory category;
  final String subcategory;
  final bool isApproved;
  final bool isFavorite;
  final List<String> customFieldSet;
  final List<TemplateLocalization> localizations;

  SpokiTemplate({
    this.id,
    required this.name,
    this.category = SpokiTemplateCategory.marketing,
    this.subcategory = 'CLASSIC',
    this.isApproved = false,
    this.isFavorite = false,
    this.customFieldSet = const [],
    this.localizations = const [],
  });

  SpokiTemplateStatus get overallStatus {
    if (isApproved) return SpokiTemplateStatus.approved;
    if (localizations.any((l) => l.status == SpokiTemplateStatus.rejected)) {
      return SpokiTemplateStatus.rejected;
    }
    if (localizations.any((l) => l.status == SpokiTemplateStatus.pending)) {
      return SpokiTemplateStatus.pending;
    }
    return localizations.isNotEmpty
        ? localizations.first.status
        : SpokiTemplateStatus.unknown;
  }

  TemplateLocalization? localizationFor(String language) {
    try {
      return localizations.firstWhere((l) => l.language == language);
    } catch (_) {
      return null;
    }
  }

  factory SpokiTemplate.fromJson(Map<String, dynamic> json) => SpokiTemplate(
        id: json['id'] as int?,
        name: json['name'] as String? ?? '',
        category:
            SpokiTemplateCategory.fromString(json['category'] as String?),
        subcategory: json['subcategory'] as String? ?? 'CLASSIC',
        isApproved: json['is_approved'] as bool? ?? false,
        isFavorite: json['is_favorite'] as bool? ?? false,
        customFieldSet: (json['customfield_set'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        localizations:
            (json['templatelocalization_set'] as List<dynamic>? ?? [])
                .map((e) =>
                    TemplateLocalization.fromJson(e as Map<String, dynamic>))
                .toList(),
      );

  Map<String, dynamic> toCreatePayload(
          {required TemplateLocalization localization}) =>
      {
        'name': name,
        'category': category.apiValue,
        'subcategory': subcategory,
        'templatelocalization_set': [localization.toCreatePayload()],
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.apiValue,
        'subcategory': subcategory,
        'is_approved': isApproved,
        'is_favorite': isFavorite,
        'customfield_set': customFieldSet,
        'templatelocalization_set':
            localizations.map((l) => l.toJson()).toList(),
      };

  @override
  String toString() => toJson().toString();
}

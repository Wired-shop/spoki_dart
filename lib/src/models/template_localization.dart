import '../enums/spoki_template_status.dart';
import 'template_button.dart';
import 'template_component.dart';
import 'template_media.dart';

class TemplateLocalization {
  final int? id;
  final String language;
  final SpokiTemplateStatus status;
  final String? rejectionReason;
  final String? rejectionDetail;
  final String? rejectionRecommendation;
  final DateTime? statusUpdatedAt;
  final TemplateComponent? header;
  final TemplateComponent body;
  final TemplateComponent? footer;
  final List<TemplateButton> buttons;
  final TemplateMedia? defaultHeaderMedia;
  final Map<String, String> exampleCustomFields;

  TemplateLocalization({
    this.id,
    required this.language,
    this.status = SpokiTemplateStatus.unknown,
    this.rejectionReason,
    this.rejectionDetail,
    this.rejectionRecommendation,
    this.statusUpdatedAt,
    this.header,
    required this.body,
    this.footer,
    this.buttons = const [],
    this.defaultHeaderMedia,
    this.exampleCustomFields = const {},
  });

  factory TemplateLocalization.fromJson(Map<String, dynamic> json) =>
      TemplateLocalization(
        id: json['id'] as int?,
        language: json['language'] as String? ?? '',
        status: SpokiTemplateStatus.fromString(json['status'] as String?),
        rejectionReason: json['rejection_reason'] as String?,
        rejectionDetail: json['rejection_detail'] as String?,
        rejectionRecommendation: json['rejection_recommendation'] as String?,
        statusUpdatedAt: json['status_updated_at'] != null
            ? DateTime.tryParse(json['status_updated_at'] as String)
            : null,
        header: json['header_template_component'] != null
            ? TemplateComponent.fromJson(
                json['header_template_component'] as Map<String, dynamic>)
            : null,
        body: TemplateComponent.fromJson(
          (json['body_template_component'] ?? json['body'] ?? {})
              as Map<String, dynamic>,
        ),
        footer: json['footer_template_component'] != null
            ? TemplateComponent.fromJson(
                json['footer_template_component'] as Map<String, dynamic>)
            : null,
        buttons: (json['templatebuttoncomponent_set'] as List<dynamic>? ?? [])
            .map((e) => TemplateButton.fromJson(e as Map<String, dynamic>))
            .toList(),
        defaultHeaderMedia: json['default_header_media'] != null
            ? TemplateMedia.fromJson(
                json['default_header_media'] as Map<String, dynamic>)
            : null,
        exampleCustomFields:
            (json['example_custom_fields'] as Map<String, dynamic>? ?? {})
                .map((k, v) => MapEntry(k, v.toString())),
      );

  Map<String, dynamic> toCreatePayload() => {
        'language': language,
        if (header != null) 'header_template_component': header!.toJson(),
        'body_template_component': body.toJson(),
        'footer_template_component': footer?.toJson(),
        'templatebuttoncomponent_set':
            buttons.map((b) => b.toJson()).toList(),
        'example_custom_fields': exampleCustomFields,
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'language': language,
        'status': status.name,
        'rejection_reason': rejectionReason,
        'rejection_detail': rejectionDetail,
        'rejection_recommendation': rejectionRecommendation,
        'status_updated_at': statusUpdatedAt?.toIso8601String(),
        'header_template_component': header?.toJson(),
        'body_template_component': body.toJson(),
        'footer_template_component': footer?.toJson(),
        'templatebuttoncomponent_set':
            buttons.map((b) => b.toJson()).toList(),
        'default_header_media': defaultHeaderMedia?.toJson(),
        'example_custom_fields': exampleCustomFields,
      };

  @override
  String toString() => toJson().toString();
}

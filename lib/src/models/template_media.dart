class TemplateMedia {
  final int? id;
  final String? title;
  final String? mediaUrl;
  final String? contentType;
  final String? formatType;
  final String? externalUrl;
  final String? externalId;
  final bool? isDeleted;

  TemplateMedia({
    this.id,
    this.title,
    this.mediaUrl,
    this.contentType,
    this.formatType,
    this.externalUrl,
    this.externalId,
    this.isDeleted,
  });

  factory TemplateMedia.fromJson(Map<String, dynamic> json) => TemplateMedia(
        id: json['id'] as int?,
        title: json['title'] as String?,
        mediaUrl: json['media'] as String?,
        contentType: json['content_type'] as String?,
        formatType: json['format_type'] as String?,
        externalUrl: json['external_url'] as String?,
        externalId: json['external_id'] as String?,
        isDeleted: json['is_deleted'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'media': mediaUrl,
        'content_type': contentType,
        'format_type': formatType,
        'external_url': externalUrl,
        'external_id': externalId,
        'is_deleted': isDeleted,
      };

  @override
  String toString() => toJson().toString();
}

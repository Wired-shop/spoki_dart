class SpokiCustomField {
  final int? id;
  final String label;
  final String code;
  final int fieldType;
  final String? example;

  SpokiCustomField({
    this.id,
    required this.label,
    required this.code,
    required this.fieldType,
    this.example,
  });

  factory SpokiCustomField.fromJson(Map<String, dynamic> json) =>
      SpokiCustomField(
        id: json['id'] as int?,
        label: json['label'] as String? ?? '',
        code: json['code'] as String? ?? '',
        fieldType: json['field_type'] as int? ?? 1,
        example: json['example'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'code': code,
        'field_type': fieldType,
        'example': example,
      };

  @override
  String toString() => toJson().toString();
}

class TemplateComponent {
  final String componentType;
  final String? format;
  final String? text;
  final List<dynamic> parameters;

  TemplateComponent({
    required this.componentType,
    this.format,
    this.text,
    this.parameters = const [],
  });

  factory TemplateComponent.fromJson(Map<String, dynamic> json) =>
      TemplateComponent(
        componentType: json['component_type'] as String? ?? '',
        format: json['format'] as String?,
        text: json['text'] as String?,
        parameters: json['parameters'] as List<dynamic>? ?? const [],
      );

  Map<String, dynamic> toJson() => {
        'component_type': componentType,
        'format': format,
        'text': text,
        'parameters': parameters,
      };

  @override
  String toString() => toJson().toString();
}

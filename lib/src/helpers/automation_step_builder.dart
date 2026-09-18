class AutomationStepBuilder {
  static Map<String, dynamic> templateMessage({
    required int templateId,
    Map<String, String>? customFieldValues,
    int? position,
  }) {
    return {
      'step_type': 'TemplateMessage',
      'template': templateId,
      if (customFieldValues != null) 'custom_field_values': customFieldValues,
      if (position != null) 'position': position,
    };
  }

  static Map<String, dynamic> freeMessage({
    required String text,
    int? position,
  }) {
    return {
      'step_type': 'FreeMessage',
      'text': text,
      if (position != null) 'position': position,
    };
  }

  static Map<String, dynamic> delay({
    required int delaySeconds,
    int? position,
  }) {
    return {
      'step_type': 'Delay',
      'delay_seconds': delaySeconds,
      if (position != null) 'position': position,
    };
  }

  static Map<String, dynamic> addTag({
    required List<int> tags,
    int? position,
  }) {
    return {
      'step_type': 'AddTag',
      'tags': tags,
      if (position != null) 'position': position,
    };
  }

  static Map<String, dynamic> webhookTrigger({required String name}) {
    return {'name': name, 'platform': 'api'};
  }
}

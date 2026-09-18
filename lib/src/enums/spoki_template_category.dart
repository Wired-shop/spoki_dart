enum SpokiTemplateCategory {
  utility,
  marketing,
  authentication;

  String get apiValue {
    switch (this) {
      case SpokiTemplateCategory.utility:
        return 'UTILITY';
      case SpokiTemplateCategory.marketing:
        return 'MARKETING';
      case SpokiTemplateCategory.authentication:
        return 'AUTHENTICATION';
    }
  }

  static SpokiTemplateCategory fromString(String? value) {
    switch ((value ?? '').toUpperCase()) {
      case 'UTILITY':
        return SpokiTemplateCategory.utility;
      case 'AUTHENTICATION':
        return SpokiTemplateCategory.authentication;
      case 'MARKETING':
      default:
        return SpokiTemplateCategory.marketing;
    }
  }
}

class TemplatePlaceholders {
  static final RegExp _placeholderPattern = RegExp(r'%%[A-Z0-9_]+%%');

  static List<String> extract(String text) {
    final matches = _placeholderPattern
        .allMatches(text)
        .map((m) => m.group(0)!.replaceAll('%%', ''))
        .toList();
    final seen = <String>{};
    return matches.where((name) => seen.add(name)).toList();
  }

  static bool looksRiskyRatio(String bodyText) {
    final placeholderCount = extract(bodyText).length;
    if (placeholderCount == 0) return false;

    final totalWords = bodyText
        .replaceAll(_placeholderPattern, 'X')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    final staticWords = totalWords - placeholderCount;

    return staticWords < placeholderCount * 2;
  }
}

class SpokiSendResult {
  final bool accepted;
  final Map<String, dynamic> raw;

  SpokiSendResult({required this.accepted, required this.raw});

  factory SpokiSendResult.fromJson(Map<String, dynamic> json) =>
      SpokiSendResult(
        accepted: json['accepted'] as bool? ?? false,
        raw: json,
      );
}

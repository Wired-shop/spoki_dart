class SpokiAuthToken {
  final String token;
  final String uid;

  SpokiAuthToken({required this.token, required this.uid});

  factory SpokiAuthToken.fromJson(Map<String, dynamic> json) =>
      SpokiAuthToken(
        token: json['token'] as String,
        uid: json['uid'] as String,
      );

  String buildIframeUrl({String pageSlug = 'chats', String language = 'it'}) {
    return 'https://spoki.app/$pageSlug?auth_token=$token&auth_uid=$uid&language=$language';
  }
}

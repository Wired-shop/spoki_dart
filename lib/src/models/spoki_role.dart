class SpokiRole {
  final int? id;
  final String? name;
  final String? email;
  final String? role;
  final bool? isServiceUser;

  SpokiRole({
    this.id,
    this.name,
    this.email,
    this.role,
    this.isServiceUser,
  });

  factory SpokiRole.fromJson(Map<String, dynamic> json) => SpokiRole(
        id: json['id'] as int?,
        name: json['name'] as String?,
        email: json['email'] as String?,
        role: json['role'] as String?,
        isServiceUser: json['is_service_user'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'is_service_user': isServiceUser,
      };

  @override
  String toString() => toJson().toString();
}

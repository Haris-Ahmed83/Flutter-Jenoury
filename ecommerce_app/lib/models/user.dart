class AppUser {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String? phone;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.phone,
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AppUser copyWith({
    String? fullName,
    String? avatarUrl,
    String? phone,
  }) {
    return AppUser(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      createdAt: createdAt,
    );
  }
}

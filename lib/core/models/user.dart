class User {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? profileImage;
  final String verificationLevel;
  final String authProvider;
  final bool isProfileComplete;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.profileImage,
    this.verificationLevel = 'unverified',
    this.authProvider = 'local',
    this.isProfileComplete = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'],
      profileImage: json['profile_image'],
      verificationLevel: json['verification_level'] ?? 'unverified',
      authProvider: json['auth_provider'] ?? 'local',
      isProfileComplete: json['is_profile_complete'] ?? true,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'profile_image': profileImage,
      'verification_level': verificationLevel,
      'auth_provider': authProvider,
      'is_profile_complete': isProfileComplete,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

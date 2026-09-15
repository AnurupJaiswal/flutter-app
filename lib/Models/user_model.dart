class UserModel {
  final String id;
  final String email;
  final String name;
  final String? role;
  final String? status;
  final bool accountSetupCompleted;
  final int? creatorProfileId;
  final String? token;
  final String? refreshToken;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.role,
    this.status,
    this.accountSetupCompleted = false,
    this.creatorProfileId,
    this.token,
    this.refreshToken,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['fullName']?.toString() ?? json['name']?.toString() ?? '',
      role: json['role']?.toString(),
      status: json['status']?.toString(),
      accountSetupCompleted: json['accountSetupCompleted'] == true,
      creatorProfileId: json['creatorProfileId'] != null ? int.tryParse(json['creatorProfileId'].toString()) : null,
      token: json['token']?.toString() ?? json['accessToken']?.toString(),
      refreshToken: json['refreshToken']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': name,
      'name': name,
      'role': role,
      'status': status,
      'accountSetupCompleted': accountSetupCompleted,
      'creatorProfileId': creatorProfileId,
      'token': token,
      'refreshToken': refreshToken,
      'avatarUrl': avatarUrl,
    };
  }

  // Helper method to create a copy with new tokens (useful for token refresh updates)
  UserModel copyWith({
    String? token,
    String? refreshToken,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name,
      role: role,
      status: status,
      accountSetupCompleted: accountSetupCompleted,
      creatorProfileId: creatorProfileId,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      avatarUrl: avatarUrl,
    );
  }
}

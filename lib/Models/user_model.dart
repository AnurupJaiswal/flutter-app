class UserModel {
  final String id;
  final String email;
  final String name;
  final String? fullName;
  final String? displayName;
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
    this.fullName,
    this.displayName,
    this.role,
    this.status,
    this.accountSetupCompleted = false,
    this.creatorProfileId,
    this.token,
    this.refreshToken,
    this.avatarUrl,
  });

  /// Resolved display name: uses displayName if non-empty, otherwise falls back to fullName/name.
  String get effectiveDisplayName {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!.trim();
    }
    if (fullName != null && fullName!.trim().isNotEmpty) {
      return fullName!.trim();
    }
    if (name.trim().isNotEmpty) {
      return name.trim();
    }
    return "Creator";
  }

  /// Resolved full name: uses fullName if non-empty, otherwise falls back to name.
  String get effectiveFullName {
    if (fullName != null && fullName!.trim().isNotEmpty) {
      return fullName!.trim();
    }
    if (name.trim().isNotEmpty) {
      return name.trim();
    }
    return effectiveDisplayName;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawDisplayName = json['displayName']?.toString().trim();
    final rawFullName = json['fullName']?.toString().trim() ?? json['name']?.toString().trim();
    final preferredName = (rawDisplayName != null && rawDisplayName.isNotEmpty)
        ? rawDisplayName
        : ((rawFullName != null && rawFullName.isNotEmpty) ? rawFullName : '');

    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: preferredName,
      fullName: rawFullName,
      displayName: rawDisplayName,
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
      'fullName': fullName ?? name,
      'displayName': displayName ?? name,
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
    String? name,
    String? fullName,
    String? displayName,
    String? token,
    String? refreshToken,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      displayName: displayName ?? this.displayName,
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

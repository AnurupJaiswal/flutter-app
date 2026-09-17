class CreatorProfileModel {
  final int? id;
  final String? displayName;
  final String? bio;
  final String? niche;
  final String? audienceDescription;
  final dynamic goals;
  final String? avatarUrl;
  final int? streakDays;

  CreatorProfileModel({
    this.id,
    this.displayName,
    this.bio,
    this.niche,
    this.audienceDescription,
    this.goals,
    this.avatarUrl,
    this.streakDays,
  });

  /// Formatted string of goals (e.g. "GROWTH, MONETIZATION")
  String get goalsFormatted {
    if (goals is List) {
      return (goals as List).map((e) => e.toString()).join(', ');
    }
    return goals?.toString() ?? '';
  }

  factory CreatorProfileModel.fromJson(Map<String, dynamic> json) {
    return CreatorProfileModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      displayName: json['displayName']?.toString() ?? json['fullName']?.toString(),
      bio: json['bio']?.toString(),
      niche: json['niche']?.toString(),
      audienceDescription: json['audienceDescription']?.toString(),
      goals: json['goals'],
      avatarUrl: json['avatarUrl']?.toString(),
      streakDays: json['streakDays'] != null ? int.tryParse(json['streakDays'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'bio': bio,
      'niche': niche,
      'audienceDescription': audienceDescription,
      'goals': goals,
      'avatarUrl': avatarUrl,
      'streakDays': streakDays,
    };
  }
}

class ConnectedAccountItem {
  final bool connected;
  final String? handle;

  ConnectedAccountItem({
    required this.connected,
    this.handle,
  });

  factory ConnectedAccountItem.fromJson(dynamic json) {
    if (json is Map) {
      return ConnectedAccountItem(
        connected: json['connected'] == true,
        handle: json['handle']?.toString(),
      );
    }
    return ConnectedAccountItem(connected: false);
  }

  Map<String, dynamic> toJson() {
    return {
      'connected': connected,
      'handle': handle,
    };
  }
}

class ConnectedAccountsModel {
  final ConnectedAccountItem? youtube;
  final ConnectedAccountItem? instagram;
  final ConnectedAccountItem? tiktok;
  final ConnectedAccountItem? linkedin;
  final ConnectedAccountItem? twitter;

  ConnectedAccountsModel({
    this.youtube,
    this.instagram,
    this.tiktok,
    this.linkedin,
    this.twitter,
  });

  bool get hasAnyConnected =>
      (youtube?.connected == true && (youtube?.handle?.isNotEmpty ?? false)) ||
      (instagram?.connected == true && (instagram?.handle?.isNotEmpty ?? false)) ||
      (tiktok?.connected == true && (tiktok?.handle?.isNotEmpty ?? false)) ||
      (linkedin?.connected == true && (linkedin?.handle?.isNotEmpty ?? false)) ||
      (twitter?.connected == true && (twitter?.handle?.isNotEmpty ?? false));

  factory ConnectedAccountsModel.fromJson(Map<String, dynamic> json) {
    return ConnectedAccountsModel(
      youtube: json['youtube'] != null ? ConnectedAccountItem.fromJson(json['youtube']) : null,
      instagram: json['instagram'] != null ? ConnectedAccountItem.fromJson(json['instagram']) : null,
      tiktok: json['tiktok'] != null ? ConnectedAccountItem.fromJson(json['tiktok']) : null,
      linkedin: json['linkedin'] != null ? ConnectedAccountItem.fromJson(json['linkedin']) : null,
      twitter: json['twitter'] != null ? ConnectedAccountItem.fromJson(json['twitter']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'youtube': youtube?.toJson(),
      'instagram': instagram?.toJson(),
      'tiktok': tiktok?.toJson(),
      'linkedin': linkedin?.toJson(),
      'twitter': twitter?.toJson(),
    };
  }
}

class CreatorStatsModel {
  final int scriptsMade;
  final int timeSavedHours;
  final int channelGrowth;

  CreatorStatsModel({
    this.scriptsMade = 42,
    this.timeSavedHours = 18,
    this.channelGrowth = 24,
  });

  factory CreatorStatsModel.fromJson(Map<String, dynamic> json) {
    return CreatorStatsModel(
      scriptsMade: json['scriptsMade'] != null ? int.tryParse(json['scriptsMade'].toString()) ?? 42 : 42,
      timeSavedHours: json['timeSavedHours'] != null ? int.tryParse(json['timeSavedHours'].toString()) ?? 18 : 18,
      channelGrowth: json['channelGrowth'] != null ? int.tryParse(json['channelGrowth'].toString()) ?? 24 : 24,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scriptsMade': scriptsMade,
      'timeSavedHours': timeSavedHours,
      'channelGrowth': channelGrowth,
    };
  }
}

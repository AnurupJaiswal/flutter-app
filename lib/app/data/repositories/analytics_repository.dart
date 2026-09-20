import 'package:flutter/foundation.dart';
import 'package:lala_ai/networking/api_endpoints.dart';
import 'package:lala_ai/networking/api_service.dart';

// --- Analytics Models matching Milestone 2 Unified Schema ---

class KeyMetricItem {
  final String label;
  final String value;
  final String trend;
  final bool isPositive;

  KeyMetricItem({
    required this.label,
    required this.value,
    required this.trend,
    required this.isPositive,
  });

  factory KeyMetricItem.fromJson(Map<String, dynamic> json) {
    final trendStr = json['trend']?.toString() ?? json['change']?.toString() ?? '';
    final isExplicitNeg = json['positive'] == false || json['isPositive'] == false || json['isUp'] == false;
    final isExplicitPos = json['positive'] == true || json['isPositive'] == true || json['isUp'] == true;
    final isNegative = isExplicitNeg || trendStr.trim().startsWith('-');
    final isPos = isExplicitPos ? !trendStr.trim().startsWith('-') : !isNegative;

    return KeyMetricItem(
      label: json['label']?.toString() ?? json['title']?.toString() ?? '',
      value: json['value']?.toString() ?? '0',
      trend: trendStr,
      isPositive: isPos,
    );
  }
}

class AnalyticsOverviewData {
  final dynamic connectedAccountId;
  final String platform;
  final String handle;
  final String? avatarUrl;
  final int channelScore;
  final List<KeyMetricItem> keyMetrics;

  AnalyticsOverviewData({
    this.connectedAccountId,
    required this.platform,
    required this.handle,
    this.avatarUrl,
    required this.channelScore,
    required this.keyMetrics,
  });

  factory AnalyticsOverviewData.fromJson(Map<String, dynamic> json) {
    final account = json['account'] is Map ? json['account'] as Map : {};
    final metricsList = json['keyMetrics'] is List ? json['keyMetrics'] as List : [];

    return AnalyticsOverviewData(
      connectedAccountId: account['connectedAccountId'] ?? json['connectedAccountId'],
      platform: account['platform']?.toString().toUpperCase() ?? json['platform']?.toString().toUpperCase() ?? 'YOUTUBE',
      handle: account['handle']?.toString() ?? json['handle']?.toString() ?? '',
      avatarUrl: account['avatarUrl']?.toString() ?? json['avatarUrl']?.toString(),
      channelScore: (json['channelScore'] as num?)?.toInt() ?? 0,
      keyMetrics: metricsList
          .map((m) => KeyMetricItem.fromJson(Map<String, dynamic>.from(m as Map)))
          .toList(),
    );
  }
}

class GrowthMetricData {
  final String current;
  final String trend;
  final bool isPositive;
  final List<String> timeLabels;
  final List<double> points;

  GrowthMetricData({
    required this.current,
    required this.trend,
    required this.isPositive,
    required this.timeLabels,
    required this.points,
  });

  factory GrowthMetricData.fromJson(Map<String, dynamic> json) {
    final labels = json['timeLabels'] is List
        ? (json['timeLabels'] as List).map((e) => e.toString()).toList()
        : <String>[];
    final pts = json['points'] is List
        ? (json['points'] as List).map((e) => (e as num).toDouble()).toList()
        : <double>[];
    final trendStr = json['trend']?.toString() ?? json['change']?.toString() ?? '';
    final isExplicitNeg = json['positive'] == false || json['isPositive'] == false || json['isUp'] == false;
    final isExplicitPos = json['positive'] == true || json['isPositive'] == true || json['isUp'] == true;
    final isNegative = isExplicitNeg || trendStr.trim().startsWith('-');
    final isPos = isExplicitPos ? !trendStr.trim().startsWith('-') : !isNegative;

    return GrowthMetricData(
      current: json['current']?.toString() ?? '0',
      trend: trendStr,
      isPositive: isPos,
      timeLabels: labels,
      points: pts,
    );
  }
}

class AnalyticsGrowthData {
  final GrowthMetricData? audienceGrowth;
  final GrowthMetricData? viewsOverTime;

  AnalyticsGrowthData({
    this.audienceGrowth,
    this.viewsOverTime,
  });

  factory AnalyticsGrowthData.fromJson(Map<String, dynamic> json) {
    return AnalyticsGrowthData(
      audienceGrowth: json['audienceGrowth'] is Map
          ? GrowthMetricData.fromJson(Map<String, dynamic>.from(json['audienceGrowth'] as Map))
          : null,
      viewsOverTime: json['viewsOverTime'] is Map
          ? GrowthMetricData.fromJson(Map<String, dynamic>.from(json['viewsOverTime'] as Map))
          : null,
    );
  }
}

class AnalyticsEngagementData {
  final String avgRate;
  final String likesCount;
  final String commentsCount;
  final List<String> timeLabels;
  final List<double> likesPoints;
  final List<double> commentsPoints;

  AnalyticsEngagementData({
    required this.avgRate,
    required this.likesCount,
    required this.commentsCount,
    required this.timeLabels,
    required this.likesPoints,
    required this.commentsPoints,
  });

  factory AnalyticsEngagementData.fromJson(Map<String, dynamic> json) {
    final labels = json['timeLabels'] is List
        ? (json['timeLabels'] as List).map((e) => e.toString()).toList()
        : <String>[];
    final likes = json['likesPoints'] is List
        ? (json['likesPoints'] as List).map((e) => (e as num).toDouble()).toList()
        : <double>[];
    final comments = json['commentsPoints'] is List
        ? (json['commentsPoints'] as List).map((e) => (e as num).toDouble()).toList()
        : <double>[];

    return AnalyticsEngagementData(
      avgRate: json['avgRate']?.toString() ?? '0%',
      likesCount: json['likesCount']?.toString() ?? '0',
      commentsCount: json['commentsCount']?.toString() ?? '0',
      timeLabels: labels,
      likesPoints: likes,
      commentsPoints: comments,
    );
  }
}

class AnalyticsActivityData {
  final String totalContentText;
  final String avgPacingText;
  final String bestWeekText;
  final List<int> weeklyBars;

  AnalyticsActivityData({
    required this.totalContentText,
    required this.avgPacingText,
    required this.bestWeekText,
    required this.weeklyBars,
  });

  factory AnalyticsActivityData.fromJson(Map<String, dynamic> json) {
    final bars = json['weeklyBars'] is List
        ? (json['weeklyBars'] as List).map((e) => (e as num).toInt()).toList()
        : <int>[];

    return AnalyticsActivityData(
      totalContentText: json['totalContentText']?.toString() ?? '',
      avgPacingText: json['avgPacingText']?.toString() ?? '',
      bestWeekText: json['bestWeekText']?.toString() ?? '',
      weeklyBars: bars,
    );
  }
}

class AnalyticsTopContentItem {
  final int rank;
  final String videoId;
  final String title;
  final String platform;
  final int views;
  final int likes;
  final int comments;
  final double engagementRate;
  final String? thumbnailUrl;
  final String? publishedAt;

  AnalyticsTopContentItem({
    required this.rank,
    required this.videoId,
    required this.title,
    required this.platform,
    required this.views,
    required this.likes,
    required this.comments,
    required this.engagementRate,
    this.thumbnailUrl,
    this.publishedAt,
  });

  factory AnalyticsTopContentItem.fromJson(Map<String, dynamic> json) {
    return AnalyticsTopContentItem(
      rank: (json['rank'] as num?)?.toInt() ?? 1,
      videoId: json['videoId']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      platform: json['platform']?.toString().toUpperCase() ?? 'YOUTUBE',
      views: (json['views'] as num?)?.toInt() ?? 0,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      engagementRate: (json['engagementRate'] as num?)?.toDouble() ?? 0.0,
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      publishedAt: json['publishedAt']?.toString(),
    );
  }
}

abstract class AnalyticsRepository {
  Future<AnalyticsOverviewData?> getOverview(String platform, {String period = '30d'});
  Future<AnalyticsGrowthData?> getGrowth(String platform, {String period = '30d'});
  Future<AnalyticsEngagementData?> getEngagement(String platform, {String period = '30d'});
  Future<AnalyticsActivityData?> getActivity(String platform, {String period = '30d'});
  Future<List<AnalyticsTopContentItem>> getTopContent(String platform, {String period = '30d', int limit = 5});
}

class ApiAnalyticsRepository implements AnalyticsRepository {
  @override
  Future<AnalyticsOverviewData?> getOverview(String platform, {String period = '30d'}) async {
    try {
      final response = await ApiService.get(ApiEndpoints.analyticsOverview(platform, period));
      if (response.isSuccess && response.data is Map) {
        return AnalyticsOverviewData.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
    } catch (e) {
      debugPrint("getOverview error for $platform: $e");
    }
    return null;
  }

  @override
  Future<AnalyticsGrowthData?> getGrowth(String platform, {String period = '30d'}) async {
    try {
      final response = await ApiService.get(ApiEndpoints.analyticsGrowth(platform, period));
      if (response.isSuccess && response.data is Map) {
        return AnalyticsGrowthData.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
    } catch (e) {
      debugPrint("getGrowth error for $platform: $e");
    }
    return null;
  }

  @override
  Future<AnalyticsEngagementData?> getEngagement(String platform, {String period = '30d'}) async {
    try {
      final response = await ApiService.get(ApiEndpoints.analyticsEngagement(platform, period));
      if (response.isSuccess && response.data is Map) {
        return AnalyticsEngagementData.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
    } catch (e) {
      debugPrint("getEngagement error for $platform: $e");
    }
    return null;
  }

  @override
  Future<AnalyticsActivityData?> getActivity(String platform, {String period = '30d'}) async {
    try {
      final response = await ApiService.get(ApiEndpoints.analyticsActivity(platform, period));
      if (response.isSuccess && response.data is Map) {
        return AnalyticsActivityData.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
    } catch (e) {
      debugPrint("getActivity error for $platform: $e");
    }
    return null;
  }

  @override
  Future<List<AnalyticsTopContentItem>> getTopContent(String platform, {String period = '30d', int limit = 5}) async {
    try {
      final response = await ApiService.get(ApiEndpoints.analyticsTopContent(platform, period, limit));
      if (response.isSuccess && response.data is Map) {
        final items = (response.data as Map)['items'];
        if (items is List) {
          return items
              .map((item) => AnalyticsTopContentItem.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
        }
      }
    } catch (e) {
      debugPrint("getTopContent error for $platform: $e");
    }
    return [];
  }
}

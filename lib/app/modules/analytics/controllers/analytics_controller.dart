import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/data/repositories/analytics_repository.dart';
import 'package:lala_ai/app/data/repositories/dashboard_repository.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';
import 'package:lala_ai/app/modules/home/controllers/home_controller.dart';
import 'package:lala_ai/networking/api_service.dart';
import 'package:lala_ai/utils/app_toast.dart';

class AnalyticsController extends GetxController {
  final AnalyticsRepository analyticsRepository;
  final DashboardRepository dashboardRepository;
  final AuthRepository authRepository;

  AnalyticsController({
    AnalyticsRepository? analyticsRepository,
    DashboardRepository? dashboardRepository,
    AuthRepository? authRepository,
  })  : analyticsRepository = analyticsRepository ?? ApiAnalyticsRepository(),
        dashboardRepository = dashboardRepository ?? ApiDashboardRepository(),
        authRepository = authRepository ??
            (Get.isRegistered<AuthRepository>()
                ? Get.find<AuthRepository>()
                : ApiAuthRepository());

  // Multi-Channel & Selection States
  final availableChannels = <ChannelOption>[].obs;
  final selectedChannel = Rxn<ChannelOption>();
  final selectedPlatform = "YouTube".obs; // "YouTube" | "Instagram"
  final selectedDateRange = "30 Days".obs; // "7 Days" | "30 Days" | "90 Days"
  final dateRangeOptions = const ["7 Days", "30 Days", "90 Days"];

  // Loading & Data States
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final overviewData = Rxn<AnalyticsOverviewData>();
  final growthData = Rxn<AnalyticsGrowthData>();
  final engagementDataRx = Rxn<AnalyticsEngagementData>();
  final activityData = Rxn<AnalyticsActivityData>();
  final topContentItems = <AnalyticsTopContentItem>[].obs;

  bool get hasAnyChannels => availableChannels.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadChannelsAndAnalytics();
  }

  Future<void> loadChannelsAndAnalytics({dynamic targetAccountId}) async {
    isLoading.value = true;
    try {
      // 1. Refresh user session
      await authRepository.fetchAndSaveMe();

      // 2. PRIMARY: Query connections list API (GET /api/v1/creators/me/connections)
      final connectionsRes = await dashboardRepository.getConnectionsWithEntitlements();
      final channels = connectionsRes?.connections ?? await dashboardRepository.getConnectedChannels();

      final options = <ChannelOption>[];

      if (channels.isNotEmpty) {
        for (final c in channels) {
          options.add(ChannelOption(
            id: c.id,
            platform: c.platform,
            handle: c.platformAccountName.isNotEmpty ? c.platformAccountName : c.platform,
            name: c.platformAccountName.isNotEmpty ? c.platformAccountName : c.platform,
            status: c.status,
          ));
        }
      }

      // 3. FALLBACK: If connections API was empty, inspect auth/me
      if (options.isEmpty) {
        final accounts = ApiService.currentConnectedAccounts;
        if (accounts?.youtube != null && accounts!.youtube!.connected) {
          options.add(ChannelOption(
            id: accounts.youtube!.id ?? 1,
            platform: 'YOUTUBE',
            handle: accounts.youtube!.handle ?? 'YouTube Channel',
            name: accounts.youtube!.handle ?? 'YouTube Channel',
            status: 'ACTIVE',
          ));
        }
        if (accounts?.instagram != null && accounts!.instagram!.connected) {
          options.add(ChannelOption(
            id: accounts.instagram!.id ?? 2,
            platform: 'INSTAGRAM',
            handle: accounts.instagram!.handle ?? 'Instagram Profile',
            name: accounts.instagram!.handle ?? 'Instagram Profile',
            status: 'ACTIVE',
          ));
        }
      }

      availableChannels.assignAll(options);

      // 4. Select initial or target channel
      ChannelOption? active;
      if (targetAccountId != null) {
        active = options.firstWhereOrNull((o) => o.id.toString() == targetAccountId.toString());
      } else if (selectedChannel.value != null) {
        active = options.firstWhereOrNull((o) => o.id.toString() == selectedChannel.value!.id.toString());
      }
      active ??= options.firstWhereOrNull((o) => o.isActive) ?? options.firstOrNull;

      if (active != null) {
        selectedChannel.value = active;
        selectedPlatform.value = active.platform == 'INSTAGRAM' ? 'Instagram' : 'YouTube';
        await _fetchAnalyticsData();
      } else {
        _resetAnalyticsState();
      }
    } catch (e) {
      debugPrint("loadChannelsAndAnalytics error: $e");
      _resetAnalyticsState();
    } finally {
      isLoading.value = false;
    }
  }

  void selectChannel(ChannelOption channel) {
    selectedChannel.value = channel;
    selectedPlatform.value = channel.platform == 'INSTAGRAM' ? 'Instagram' : 'YouTube';
    loadAnalytics();
  }

  String get _periodParam {
    switch (selectedDateRange.value) {
      case "7 Days":
        return "7d";
      case "90 Days":
        return "90d";
      case "30 Days":
      default:
        return "30d";
    }
  }

  Future<void> loadAnalytics() async {
    isLoading.value = true;
    try {
      await _fetchAnalyticsData();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshAnalytics() async {
    if (isRefreshing.value) return;
    isRefreshing.value = true;
    try {
      // 1. Refresh user session & connections list
      await authRepository.fetchAndSaveMe();
      final connectionsRes = await dashboardRepository.getConnectionsWithEntitlements();
      if (connectionsRes == null) {
        AppToast.error("Unable to refresh analytics. Server error (502).");
        return;
      }
      final channels = connectionsRes.connections;

      final options = <ChannelOption>[];
      if (channels.isNotEmpty) {
        for (final c in channels) {
          options.add(ChannelOption(
            id: c.id,
            platform: c.platform,
            handle: c.platformAccountName.isNotEmpty ? c.platformAccountName : c.platform,
            name: c.platformAccountName.isNotEmpty ? c.platformAccountName : c.platform,
            status: c.status,
          ));
        }
      }

      if (options.isNotEmpty) {
        availableChannels.assignAll(options);

        // Preserve selected channel
        ChannelOption? active;
        if (selectedChannel.value != null) {
          active = options.firstWhereOrNull((o) => o.id.toString() == selectedChannel.value!.id.toString());
        }
        active ??= options.firstWhereOrNull((o) => o.isActive) ?? options.firstOrNull;

        if (active != null) {
          selectedChannel.value = active;
          selectedPlatform.value = active.platform == 'INSTAGRAM' ? 'Instagram' : 'YouTube';
          await _fetchAnalyticsData();
        } else {
          _resetAnalyticsState();
        }
      } else {
        availableChannels.clear();
        selectedChannel.value = null;
        _resetAnalyticsState();
      }

      AppToast.success("Analytics refreshed!");
    } catch (e) {
      debugPrint("refreshAnalytics error: $e");
      AppToast.error("Unable to refresh analytics. Please try again.");
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> _fetchAnalyticsData() async {
    final platform = selectedPlatform.value.toLowerCase();
    final period = _periodParam;

    try {
      final results = await Future.wait([
        analyticsRepository.getOverview(platform, period: period),
        analyticsRepository.getGrowth(platform, period: period),
        analyticsRepository.getEngagement(platform, period: period),
        analyticsRepository.getActivity(platform, period: period),
        analyticsRepository.getTopContent(platform, period: period, limit: 5),
      ]);

      overviewData.value = results[0] as AnalyticsOverviewData?;
      growthData.value = results[1] as AnalyticsGrowthData?;
      engagementDataRx.value = results[2] as AnalyticsEngagementData?;
      activityData.value = results[3] as AnalyticsActivityData?;
      topContentItems.assignAll((results[4] as List<AnalyticsTopContentItem>?) ?? []);
    } catch (e) {
      debugPrint("Error fetching analytics data: $e");
    }
  }

  void _resetAnalyticsState() {
    overviewData.value = null;
    growthData.value = null;
    engagementDataRx.value = null;
    activityData.value = null;
    topContentItems.clear();
  }

  void setDateRange(String range) {
    if (selectedDateRange.value != range) {
      selectedDateRange.value = range;
      loadAnalytics();
    }
  }

  // Connected Account Details
  Map<String, dynamic> get accountDetails {
    final creatorName = ApiService.effectiveDisplayName;
    final current = selectedChannel.value;
    final isIg = selectedPlatform.value == "Instagram";

    final channelName = current?.name ?? overviewData.value?.handle ?? creatorName;
    final rawHandle = current?.handle ?? overviewData.value?.handle ?? channelName;
    final handle = rawHandle.startsWith('@') ? rawHandle : "@$rawHandle";

    return {
      "name": channelName,
      "handle": handle,
      "platform": isIg ? "Instagram" : "YouTube",
      "platformTag": isIg ? "Instagram Reel" : "YouTube Shorts",
      "avatar": overviewData.value?.avatarUrl ?? (isIg ? "assets/icons/img_instagram.png" : "assets/icons/img_youtube.png"),
      "isVerified": true,
    };
  }

  // 1. Overall Channel Score
  Map<String, dynamic> get channelScoreData {
    final score = overviewData.value?.channelScore ?? 0;
    String status = "Needs Audit";
    if (score >= 80) {
      status = "Excellent";
    } else if (score >= 60) {
      status = "Good";
    } else if (score > 0) {
      status = "Average";
    }

    return {
      "score": score,
      "status": status,
      "subtitle": score > 0
          ? "Overall channel performance calculated from channel engagement, views, and audience pacing."
          : "Connect your channel and sync your latest data to calculate your channel health score.",
    };
  }

  // 2. Key Performance Metrics
  List<Map<String, dynamic>> get keyMetrics {
    final metrics = overviewData.value?.keyMetrics;
    if (metrics != null && metrics.isNotEmpty) {
      return metrics.map((m) {
        final trendStr = m.trend.trim();
        final isNegative = trendStr.startsWith('-') || !m.isPositive;
        return {
          "title": m.label,
          "value": m.value,
          "change": m.trend,
          "isUp": !isNegative,
        };
      }).toList();
    }
    return [];
  }

  // 3. Audience Growth Graph Data
  Map<String, dynamic> get audienceGrowthData {
    final g = growthData.value?.audienceGrowth;
    if (g != null && g.points.isNotEmpty) {
      final trendStr = g.trend.trim();
      final isNegative = trendStr.startsWith('-') || !g.isPositive;
      return {
        "start": g.points.first.toString(),
        "end": g.current,
        "gain": g.trend,
        "isUp": !isNegative,
        "timeLabels": g.timeLabels,
        "points": g.points,
      };
    }
    return {
      "start": "0",
      "end": "0",
      "gain": "0%",
      "isUp": true,
      "timeLabels": <String>[],
      "points": <double>[],
    };
  }

  // 4. Views Graph Data
  Map<String, dynamic> get viewsData {
    final v = growthData.value?.viewsOverTime;
    if (v != null && v.points.isNotEmpty) {
      final trendStr = v.trend.trim();
      final isNegative = trendStr.startsWith('-') || !v.isPositive;
      return {
        "totalViews": v.current,
        "avgViews": v.current,
        "change": v.trend,
        "isUp": !isNegative,
        "insight": "Views trend ${v.trend} over the selected period.",
        "timeLabels": v.timeLabels,
        "points": v.points,
      };
    }
    return {
      "totalViews": "0",
      "avgViews": "0",
      "change": "0%",
      "isUp": true,
      "insight": "No view trends recorded for this period.",
      "timeLabels": <String>[],
      "points": <double>[],
    };
  }

  // 5. Engagement Graph Data
  Map<String, dynamic> get engagementData {
    final e = engagementDataRx.value;
    if (e != null) {
      return {
        "avgRate": e.avgRate,
        "likesCount": e.likesCount,
        "commentsCount": e.commentsCount,
        "timeLabels": e.timeLabels,
        "likesPoints": e.likesPoints,
        "commentsPoints": e.commentsPoints,
      };
    }
    return {
      "avgRate": "0%",
      "likesCount": "0",
      "commentsCount": "0",
      "timeLabels": <String>[],
      "likesPoints": <double>[],
      "commentsPoints": <double>[],
    };
  }

  // 6. Content Activity Data
  Map<String, dynamic> get contentActivityData {
    final a = activityData.value;
    if (a != null) {
      String totalText = a.totalContentText;
      if (totalText.startsWith("1 ") && totalText.contains("videos")) {
        totalText = totalText.replaceFirst("videos", "video");
      }
      String bestText = a.bestWeekText;
      if (bestText.contains("1 videos")) {
        bestText = bestText.replaceFirst("1 videos", "1 video");
      }

      final weeklyBars = a.weeklyBars.asMap().entries.map((entry) => {
        "week": "Week ${entry.key + 1}",
        "count": entry.value,
        "label": "${entry.value} ${entry.value == 1 ? 'item' : 'items'}",
      }).toList();

      return {
        "total": totalText,
        "avg": a.avgPacingText,
        "best": bestText,
        "weeklyBars": weeklyBars,
      };
    }
    return {
      "total": "0 videos",
      "avg": "0.0 videos / week",
      "best": "N/A",
      "weeklyBars": <Map<String, dynamic>>[],
    };
  }

  // 7. Top Performing Content
  List<Map<String, dynamic>> get topPerformingContent {
    return topContentItems.map((item) => {
      "rank": "0${item.rank}",
      "title": item.title,
      "platform": item.platform,
      "views": item.views,
      "likes": item.likes,
      "comments": item.comments,
      "engagement": "${item.engagementRate.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}%",
      "thumbnail": item.thumbnailUrl ?? "",
    }).toList();
  }
}

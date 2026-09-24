import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/data/repositories/trend_repository.dart';
import 'package:lala_ai/app/data/repositories/dashboard_repository.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';
import 'package:lala_ai/networking/api_service.dart';
import 'package:lala_ai/utils/app_toast.dart';
import 'package:lala_ai/utils/extensions.dart';

enum DashboardTab { overview, audit, todos }

class ChannelOption {
  final dynamic id;
  final String platform; // "YOUTUBE" | "INSTAGRAM"
  final String handle;
  final String name;
  final String status; // "ACTIVE" | "DISCONNECTED" | "REAUTH_REQUIRED"

  ChannelOption({
    required this.id,
    required this.platform,
    required this.handle,
    required this.name,
    this.status = 'ACTIVE',
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isDisconnected => status.toUpperCase() == 'DISCONNECTED';
  bool get isReauthRequired =>
      status.toUpperCase() == 'REAUTH_REQUIRED' ||
      status.toUpperCase() == 'EXPIRED';
}

class HomeController extends GetxController {
  final TrendRepository trendRepository;
  final DashboardRepository dashboardRepository;
  final AuthRepository authRepository;

  HomeController({
    required this.trendRepository,
    DashboardRepository? dashboardRepository,
    AuthRepository? authRepository,
  })  : dashboardRepository = dashboardRepository ?? ApiDashboardRepository(),
        authRepository = authRepository ??
            (Get.isRegistered<AuthRepository>()
                ? Get.find<AuthRepository>()
                : ApiAuthRepository());

  final activeTab = DashboardTab.overview.obs;
  
  // Loading & Data State Flags
  final isDashboardLoading = true.obs;
  final isRefreshing = false.obs;
  final hasAuditData = false.obs;
  final isYoutubeConnected = false.obs;
  final isInstagramConnected = false.obs;
  final hasRecentContent = false.obs;
  final hasRealAnalytics = false.obs;
  final isAuditing = false.obs;
  final isSyncing = false.obs;
  final lastSyncedText = "".obs;

  // Live Connected Accounts & Active Selection
  final creatorName = "".obs;
  final youtubeHandle = "".obs;
  final instagramHandle = "".obs;
  final connectedChannels = <ChannelConnection>[].obs;
  final availableChannels = <ChannelOption>[].obs;
  final selectedChannel = Rxn<ChannelOption>();
  final activeConnectedAccountId = Rxn<dynamic>();

  // Health & Sub-Scores (Pure API data - starts at 0, no mock defaults)
  final healthScore = 0.obs;
  final engagementScore = 0.obs;
  final consistencyScore = 0.obs;
  final growthScore = 0.obs;
  final reachScore = 0.obs;
  final auditStatus = "".obs;
  final lastAuditId = Rxn<dynamic>();

  // Live Channel Metrics (Pure API data)
  final subscribersCount = "".obs;
  final viewsCount = "".obs;
  final engagementRate = "".obs;
  final videoCount = "".obs;

  // SWOT Audit Category
  final selectedSwotCategory = "Strengths".obs;

  // Dynamic SWOT Data (Populated strictly from API audit)
  final swotItems = <String, List<Map<String, dynamic>>>{
    "Strengths": [],
    "Weaknesses": [],
    "Opportunities": [],
    "Threats": [],
  }.obs;

  // Real Creator To-Do items (Populated strictly from API)
  final toDoItems = <Map<String, dynamic>>[].obs;

  int get completedToDosCount =>
      toDoItems.where((item) => item['isDone'] == true).length;

  bool get hasAnyChannels =>
      availableChannels.isNotEmpty || connectedChannels.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    syncWithSavedConnections();
    loadDashboardData();
  }

  /// Refreshes dashboard data non-destructively in place
  Future<void> refreshDashboard() async {
    await loadDashboardData(isRefresh: true);
  }

  /// Master orchestrator for initial load & pull-to-refresh
  Future<void> loadDashboardData({bool isRefresh = false, dynamic specificAccountId}) async {
    if (isRefresh) {
      if (isRefreshing.value) return;
      isRefreshing.value = true;
    } else {
      isDashboardLoading.value = true;
    }

    try {
      // 1. Fetch live connections list
      await fetchConnections(specificAccountId: specificAccountId);

      // 2. If a channel is active, fetch its Audit and To-Dos in parallel
      final current = selectedChannel.value;
      if (current != null) {
        await Future.wait([
          fetchAuditOverview(current.id, isRefresh: isRefresh),
          fetchTodos(current.id),
        ]);
      } else {
        hasAuditData.value = false;
        _resetSwot();
        toDoItems.clear();
      }
    } catch (e) {
      debugPrint("loadDashboardData error: $e");
      if (isRefresh) {
        AppToast.error("Unable to refresh dashboard. Please try again.");
      }
    } finally {
      if (isRefresh) {
        isRefreshing.value = false;
      } else {
        isDashboardLoading.value = false;
      }
    }
  }

  /// 1. Individual API: Fetch Creator Connections List
  Future<void> fetchConnections({dynamic specificAccountId}) async {
    try {
      final connectionsRes = await dashboardRepository.getConnectionsWithEntitlements();
      final channels = connectionsRes?.connections ?? await dashboardRepository.getConnectedChannels();

      final options = <ChannelOption>[];

      if (channels.isNotEmpty) {
        connectedChannels.assignAll(channels);
        for (final c in channels) {
          options.add(ChannelOption(
            id: c.id,
            platform: c.platform,
            handle: c.platformAccountName.isNotEmpty ? c.platformAccountName : c.platform,
            name: c.platformAccountName.isNotEmpty ? c.platformAccountName : c.platform,
            status: c.status,
          ));
        }
      } else {
        connectedChannels.clear();
      }

      availableChannels.assignAll(options);

      // Resolve active channel (prioritize active, otherwise requested or previously selected)
      ChannelOption? active;
      if (options.isNotEmpty) {
        if (specificAccountId != null) {
          active = options.firstWhereOrNull((o) => o.id.toString() == specificAccountId.toString());
        } else if (selectedChannel.value != null) {
          active = options.firstWhereOrNull((o) => o.id.toString() == selectedChannel.value!.id.toString());
        }
        active ??= options.firstWhereOrNull((o) => o.isActive) ?? options.firstOrNull;
      }

      if (active != null) {
        selectedChannel.value = active;
        activeConnectedAccountId.value = active.id;
        isYoutubeConnected.value = active.platform == 'YOUTUBE';
        isInstagramConnected.value = active.platform == 'INSTAGRAM';
        if (active.platform == 'YOUTUBE') youtubeHandle.value = active.handle;
        if (active.platform == 'INSTAGRAM') instagramHandle.value = active.handle;
      } else {
        selectedChannel.value = null;
        activeConnectedAccountId.value = null;
        isYoutubeConnected.value = false;
        isInstagramConnected.value = false;
        youtubeHandle.value = '';
        instagramHandle.value = '';
        hasAuditData.value = false;
        _resetSwot();
        toDoItems.clear();
      }
    } catch (e) {
      debugPrint("fetchConnections error: $e");
    }
  }

  /// 2. Individual API: Fetch Channel Audit Overview & SWOT
  Future<void> fetchAuditOverview(dynamic channelId, {bool isRefresh = false}) async {
    try {
      final audit = await dashboardRepository.getDashboardOverview(channelId);
      if (audit != null) {
        hasAuditData.value = true;
        healthScore.value = audit.healthScore;
        engagementScore.value = audit.engagementScore;
        consistencyScore.value = audit.consistencyScore;
        growthScore.value = audit.growthScore;
        reachScore.value = audit.reachScore;
        auditStatus.value = audit.auditStatus.isNotEmpty ? audit.auditStatus : (audit.healthScore > 0 ? "AUDITED" : "Needs Audit");
        lastAuditId.value = audit.auditId;
        lastSyncedText.value = audit.dataAsOf != null && audit.dataAsOf!.isNotEmpty
            ? "Data as of ${audit.dataAsOf!.formatSyncDate}"
            : "Synced recently";

        _populateSwotFromAudit(audit);
      } else if (!isRefresh) {
        hasAuditData.value = false;
        _resetSwot();
      }
    } catch (e) {
      debugPrint("fetchAuditOverview error: $e");
      if (!isRefresh) {
        hasAuditData.value = false;
      }
    }
  }

  /// 3. Individual API: Fetch Creator To-Dos
  Future<void> fetchTodos(dynamic channelId) async {
    try {
      final todos = await dashboardRepository.getTodos(connectedAccountId: channelId);
      toDoItems.assignAll(todos.map((t) => {
        "id": t.id,
        "title": t.title,
        "subtitle": t.subtitle ?? (t.expectedOutcome.isNotEmpty ? t.expectedOutcome : "Recommended by AI"),
        "details": t.details ?? t.expectedOutcome,
        "isDone": t.isDone,
        "tag": t.tag,
        "source": "Channel Audit",
        "impact": t.expectedOutcome,
        "priority": t.priority,
        "dueDate": t.dueDate ?? "This Week",
      }).toList());
    } catch (e) {
      debugPrint("fetchTodos error: $e");
    }
  }

  /// Swaps the active channel and fetches its audit & todos independently
  void selectChannel(ChannelOption channel) {
    selectedChannel.value = channel;
    activeConnectedAccountId.value = channel.id;
    isYoutubeConnected.value = channel.platform == 'YOUTUBE';
    isInstagramConnected.value = channel.platform == 'INSTAGRAM';
    if (channel.platform == 'YOUTUBE') youtubeHandle.value = channel.handle;
    if (channel.platform == 'INSTAGRAM') instagramHandle.value = channel.handle;

    fetchAuditOverview(channel.id);
    fetchTodos(channel.id);
  }

  void _resetSwot() {
    swotItems.assignAll({
      "Strengths": [],
      "Weaknesses": [],
      "Opportunities": [],
      "Threats": [],
    });
  }

  void _populateSwotFromAudit(ChannelAuditData audit) {
    final Map<String, List<Map<String, dynamic>>> newSwot = {
      "Strengths": [],
      "Weaknesses": [],
      "Opportunities": [],
      "Threats": [],
    };

    final recs = audit.recommendations;
    int recIndex = 0;

    for (final key in audit.swot.keys) {
      final categoryName = key[0].toUpperCase() + key.substring(1);
      final list = audit.swot[key] ?? [];
      final items = <Map<String, dynamic>>[];

      for (int i = 0; i < list.length; i++) {
        final text = list[i];
        String actionable = text;
        String tag = "Audit";
        if (recIndex < recs.length) {
          actionable = recs[recIndex]['title']?.toString() ?? text;
          tag = recs[recIndex]['priority']?.toString() ?? "Audit";
          recIndex++;
        }

        items.add({
          "id": "${key}_$i",
          "title": text,
          "desc": "Identified from your channel audit metrics.",
          "icon": key == 'strengths'
              ? "thumb_up"
              : (key == 'weaknesses'
                  ? "warning"
                  : (key == 'opportunities' ? "trending_up" : "shield")),
          "actionable": actionable,
          "tag": tag,
        });
      }
      if (newSwot.containsKey(categoryName)) {
        newSwot[categoryName] = items;
      }
    }
    swotItems.assignAll(newSwot);
  }

  void syncWithSavedConnections() {
    creatorName.value = ApiService.effectiveDisplayName;
    final accounts = ApiService.currentConnectedAccounts;
    if (accounts != null) {
      if (accounts.youtube != null) {
        isYoutubeConnected.value = accounts.youtube!.connected;
        if (accounts.youtube!.handle != null && accounts.youtube!.handle!.isNotEmpty) {
          youtubeHandle.value = accounts.youtube!.handle!;
        }
      }
      if (accounts.instagram != null) {
        isInstagramConnected.value = accounts.instagram!.connected;
        if (accounts.instagram!.handle != null && accounts.instagram!.handle!.isNotEmpty) {
          instagramHandle.value = accounts.instagram!.handle!;
        }
      }
    }
    hasRealAnalytics.value = isYoutubeConnected.value || isInstagramConnected.value;
  }

  void toggleYoutubeConnection() {
    isYoutubeConnected.value = !isYoutubeConnected.value;
  }

  void toggleInstagramConnection() {
    isInstagramConnected.value = !isInstagramConnected.value;
  }

  /// Converts an audit recommendation into an actionable Creator To-Do item
  Future<void> convertRecommendationToToDo({
    required String title,
    required String subtitle,
    required String tag,
    String? details,
    String? source,
    String? impact,
    String? priority,
    String? dueDate,
  }) async {
    // Check if task already exists
    final alreadyExists = toDoItems.any((item) => item['title'] == title);
    if (alreadyExists) {
      AppToast.info("Task is already in your To-Do list!");
      return;
    }

    final newId = DateTime.now().millisecondsSinceEpoch;
    toDoItems.insert(0, {
      "id": newId,
      "title": title,
      "subtitle": subtitle,
      "details": details ?? subtitle,
      "isDone": false,
      "tag": tag,
      "source": source ?? "Channel Audit Recommendation",
      "impact": impact ?? "+15% Channel Reach",
      "priority": priority ?? "High",
      "dueDate": dueDate ?? "This Week",
    });
    AppToast.success("Added to Creator To-Dos!");

    // Persist to server if active connection exists
    final accountId = activeConnectedAccountId.value;
    final auditId = lastAuditId.value;
    if (accountId != null && auditId != null) {
      String p = (priority ?? "ORANGE").toUpperCase();
      if (!['RED', 'ORANGE', 'YELLOW'].contains(p)) {
        p = 'ORANGE';
      }
      await dashboardRepository.convertRecommendationToTodo(
        connectedAccountId: accountId,
        channelAuditId: auditId,
        title: title,
        priority: p,
        expectedOutcome: impact ?? subtitle,
      );
    }
  }

  Future<void> toggleToDoItem(dynamic id) async {
    final index = toDoItems.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      final current = toDoItems[index]['isDone'] as bool;
      final newStatus = !current;
      toDoItems[index] = {
        ...toDoItems[index],
        'isDone': newStatus,
      };
      toDoItems.refresh();
      if (newStatus) {
        AppToast.success("Action item marked as completed!");
      }

      // Sync with server
      await dashboardRepository.updateTodoStatus(id, newStatus);
    }
  }

  Future<void> removeToDoItem(dynamic id) async {
    toDoItems.removeWhere((item) => item['id'] == id);
    AppToast.info("Task removed");

    // Sync deletion with server
    await dashboardRepository.deleteTodo(id);
  }

  Future<void> runChannelAudit() async {
    isAuditing.value = true;
    try {
      final accountId = activeConnectedAccountId.value;
      if (accountId != null) {
        final started = await dashboardRepository.triggerAudit(accountId);
        if (started) {
          await loadDashboardData(isRefresh: true);
          AppToast.success("Channel audit triggered! Updating Health Score...");
        } else {
          AppToast.error("Failed to run audit on this channel.");
        }
      } else {
        AppToast.error("No active connected channel found.");
      }
    } catch (_) {
      AppToast.error("Failed to run channel audit. Please try again.");
    } finally {
      isAuditing.value = false;
    }
  }

  Future<void> syncChannelData() async {
    isSyncing.value = true;
    try {
      await loadDashboardData(isRefresh: true);
      AppToast.success("Channel data & audit refreshed!");
    } catch (_) {
      AppToast.error("Channel sync failed.");
    } finally {
      isSyncing.value = false;
    }
  }
}

import 'package:get/get.dart';
import 'package:lala_ai/app/data/repositories/trend_repository.dart';
import 'package:lala_ai/utils/app_toast.dart';

enum DashboardTab { overview, connect }

class HomeController extends GetxController {
  final TrendRepository trendRepository;

  HomeController({required this.trendRepository});

  final activeTab = DashboardTab.overview.obs;
  
  // Data State Flags (can be toggled for UI testing)
  final isYoutubeConnected = true.obs;
  final isInstagramConnected = true.obs;
  final hasRecentContent = true.obs;

  // Sync state
  final isSyncing = false.obs;
  final lastSyncedText = "Synced 5m ago".obs;

  // Health Score & Stats
  final healthScore = 88.obs;
  final subscribersCount = "12.4K".obs;
  final viewsCount = "4.2K".obs;
  final engagementRate = "6.8%".obs;

  // SWOT Audit Category
  final selectedSwotCategory = "Strengths".obs;

  // Creator To-Do Items
  final toDoItems = <Map<String, dynamic>>[
    {
      "id": 1,
      "title": "Add 3 trending hashtags to your next Reel",
      "subtitle": "#AIInspiration, #CreatorEconomy, #Reels2026",
      "isDone": false,
      "tag": "SEO",
    },
    {
      "id": 2,
      "title": "Optimize video title for search intent",
      "subtitle": "Include key phrase 'AI Tools 2026' in first 30 chars",
      "isDone": false,
      "tag": "Audit",
    },
    {
      "id": 3,
      "title": "Schedule next upload for Friday at 6:00 PM EST",
      "subtitle": "Identified as your peak audience active time window",
      "isDone": false,
      "tag": "Timing",
    },
    {
      "id": 4,
      "title": "Connect YouTube & Instagram accounts",
      "subtitle": "Enable multi-channel cross-platform analytics",
      "isDone": true,
      "tag": "Setup",
    },
  ].obs;

  void toggleYoutubeConnection() {
    isYoutubeConnected.value = !isYoutubeConnected.value;
  }

  void toggleInstagramConnection() {
    isInstagramConnected.value = !isInstagramConnected.value;
  }

  void toggleToDoItem(int id) {
    final index = toDoItems.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      final current = toDoItems[index]['isDone'] as bool;
      toDoItems[index] = {
        ...toDoItems[index],
        'isDone': !current,
      };
      toDoItems.refresh();
      if (!current) {
        AppToast.success("Action item marked as completed!");
      }
    }
  }

  Future<void> syncChannelData() async {
    isSyncing.value = true;
    await Future.delayed(const Duration(milliseconds: 1200));
    isSyncing.value = false;
    lastSyncedText.value = "Synced just now";
    AppToast.success("Channel data & audit refreshed!");
  }
}

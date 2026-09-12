import 'package:get/get.dart';
import 'package:lala_ai/utils/app_toast.dart';
import 'package:lala_ai/app/data/models/trend_model.dart';
import 'package:lala_ai/app/data/repositories/trend_repository.dart';

class TrendingController extends GetxController {
  final TrendRepository trendRepository;

  TrendingController({required this.trendRepository});

  final activeTab = 0.obs; // 0 = Discover, 1 = Alerts
  final selectedPlatform = "All Platforms".obs;
  final selectedNiche = "Tech & Creator AI".obs;
  final selectedScope = "Global".obs;

  final trends = <TrendModel>[].obs;
  final isLoading = false.obs;
  final lastUpdated = "5 mins ago".obs;

  // Alerts Management
  final alerts = <Map<String, dynamic>>[
    {"title": "Global AI Video Generators", "type": "Global", "sensitivity": "Instant (+30%)", "enabled": true, "unread": true},
    {"title": "YouTube Shorts Monetization", "type": "Niche", "sensitivity": "Daily Digest", "enabled": true, "unread": false},
    {"title": "Keyword: #PixoAI", "type": "Keyword", "sensitivity": "Instant (+30%)", "enabled": false, "unread": false},
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadTrends();
  }

  Future<void> loadTrends() async {
    isLoading.value = true;
    final result = await trendRepository.getTrendingTopics();
    trends.assignAll(result);
    isLoading.value = false;
  }

  void toggleAlert(int index) {
    alerts[index]["enabled"] = !(alerts[index]["enabled"] as bool);
    alerts.refresh();
  }

  void deleteAlert(int index) {
    alerts.removeAt(index);
    AppToast.info("Alert removed");
  }

  void addAlert({
    required String title,
    required String type,
    String sensitivity = "Instant (+30%)",
  }) {
    alerts.insert(0, {
      "title": title,
      "type": type,
      "sensitivity": sensitivity,
      "enabled": true,
      "unread": false,
    });
    alerts.refresh();
    AppToast.success("Trend alert created for '$title'");
  }

  void saveAsAlert(String topic) {
    addAlert(title: topic, type: "Keyword");
  }
}

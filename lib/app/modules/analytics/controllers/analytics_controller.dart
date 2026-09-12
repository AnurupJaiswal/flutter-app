import 'package:get/get.dart';
import 'package:lala_ai/app/data/models/analytics_model.dart';
import 'package:lala_ai/app/data/repositories/analytics_repository.dart';
import 'package:lala_ai/app/modules/chat/controllers/chat_controller.dart';
import 'package:lala_ai/app/modules/main_container/controllers/main_container_controller.dart';

class AnalyticsController extends GetxController {
  final AnalyticsRepository analyticsRepository;

  AnalyticsController({required this.analyticsRepository});

  final timeRanges = ["Today", "7 Days", "30 Days", "3 Months", "6 Months", "1 Year"].obs;
  final selectedTimeRange = "7 Days".obs;

  final metrics = <AnalyticsMetricModel>[].obs;
  final popularTopics = <TopicPopularityModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    isLoading.value = true;
    final mList = await analyticsRepository.getAnalyticsMetrics(timeRange: selectedTimeRange.value);
    final pList = await analyticsRepository.getPopularTopics(timeRange: selectedTimeRange.value);
    metrics.assignAll(mList);
    popularTopics.assignAll(pList);
    isLoading.value = false;
  }

  void selectTimeRange(String range) {
    selectedTimeRange.value = range;
    loadAnalytics();
  }

  void askAiAboutAnalytics(AnalyticsMetricModel metric) {
    final chatController = Get.find<ChatController>();
    final mainController = Get.find<MainContainerController>();

    final prompt =
        "Explain the analytics trend for \"${metric.title}\" (${metric.metricValue}, +${metric.changePercentage}%) over the past ${selectedTimeRange.value}. What caused this change?";

    mainController.changeTab(1);
    chatController.sendMessage(prompt);
  }
}

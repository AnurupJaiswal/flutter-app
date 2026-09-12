import 'package:lala_ai/app/data/models/analytics_model.dart';

abstract class AnalyticsRepository {
  Future<List<AnalyticsMetricModel>> getAnalyticsMetrics({String timeRange = "7 Days"});
  Future<List<TopicPopularityModel>> getPopularTopics({String timeRange = "7 Days"});
}

class MockAnalyticsRepository implements AnalyticsRepository {
  @override
  Future<List<AnalyticsMetricModel>> getAnalyticsMetrics({String timeRange = "7 Days"}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      AnalyticsMetricModel(
        id: "metric_1",
        title: "AI Ecosystem Velocity",
        metricValue: "94.2k",
        changePercentage: 34.6,
        periodLabel: timeRange,
        chartPoints: [20, 32, 45, 60, 78, 85, 94.2],
        category: "AI",
        aiInsight: "Developer query volume for autonomous agents grew 34.6% in the selected period.",
      ),
      AnalyticsMetricModel(
        id: "metric_2",
        title: "Mobile Architecture Sentiment",
        metricValue: "88.4%",
        changePercentage: 18.2,
        periodLabel: timeRange,
        chartPoints: [60, 65, 72, 79, 82, 86, 88.4],
        category: "Technology",
        aiInsight: "GetX & BLoC modular decoupling remain the top preference in production codebases.",
      ),
      AnalyticsMetricModel(
        id: "metric_3",
        title: "Cloud Infrastructure Activity",
        metricValue: "1.4M",
        changePercentage: 12.8,
        periodLabel: timeRange,
        chartPoints: [100, 110, 118, 125, 132, 138, 140],
        category: "Cloud",
        aiInsight: "Serverless container deployments increased steadily across major enterprise regions.",
      ),
    ];
  }

  @override
  Future<List<TopicPopularityModel>> getPopularTopics({String timeRange = "7 Days"}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      TopicPopularityModel(topicName: "Autonomous Agents", score: 95.0, category: "AI"),
      TopicPopularityModel(topicName: "Flutter Impeller", score: 82.0, category: "Technology"),
      TopicPopularityModel(topicName: "Small LLMs (3B)", score: 76.0, category: "AI"),
      TopicPopularityModel(topicName: "Open Banking API", score: 64.0, category: "Finance"),
      TopicPopularityModel(topicName: "Deep Geothermal", score: 58.0, category: "Science"),
    ];
  }
}

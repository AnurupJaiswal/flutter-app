class AnalyticsMetricModel {
  final String id;
  final String title;
  final String metricValue;
  final double changePercentage;
  final String periodLabel;
  final List<double> chartPoints;
  final String category;
  final String aiInsight;

  AnalyticsMetricModel({
    required this.id,
    required this.title,
    required this.metricValue,
    required this.changePercentage,
    required this.periodLabel,
    required this.chartPoints,
    required this.category,
    required this.aiInsight,
  });
}

class TopicPopularityModel {
  final String topicName;
  final double score;
  final String category;

  TopicPopularityModel({
    required this.topicName,
    required this.score,
    required this.category,
  });
}

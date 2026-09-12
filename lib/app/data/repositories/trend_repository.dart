import 'package:lala_ai/app/data/models/trend_model.dart';

abstract class TrendRepository {
  Future<List<TrendModel>> getTrendingTopics({String? category});
  Future<TrendDetailModel?> getTrendDetails(String trendId);
}

class MockTrendRepository implements TrendRepository {
  final List<TrendModel> _mockTrends = [
    TrendModel(
      id: "trend_1",
      rank: 1,
      title: "Autonomous AI Agents",
      category: "AI",
      changePercentage: 84.5,
      summary: "Multi-agent frameworks and autonomous execution systems gain massive enterprise adoption.",
      source: "Tech Crunch / Industry Report",
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    TrendModel(
      id: "trend_2",
      rank: 2,
      title: "Flutter 3.29 & Impeller Engine",
      category: "Technology",
      changePercentage: 42.1,
      summary: "Flutter's new Impeller rendering pipeline delivers 60fps locked animations across Android & iOS.",
      source: "Flutter Official Release",
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    TrendModel(
      id: "trend_3",
      rank: 3,
      title: "On-Device Small LLMs",
      category: "AI",
      changePercentage: 38.9,
      summary: "High-efficiency 3B parameters models running locally on mobile hardware with zero latency.",
      source: "AI Research Quarterly",
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    TrendModel(
      id: "trend_4",
      rank: 4,
      title: "Quantum Computing Algorithms",
      category: "Science",
      changePercentage: 29.4,
      summary: "Breakthrough error mitigation techniques enable practical chemistry simulation.",
      source: "Nature Physics",
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    TrendModel(
      id: "trend_5",
      rank: 5,
      title: "Global FinTech API Protocols",
      category: "Finance",
      changePercentage: 24.8,
      summary: "Open banking regulations accelerate cross-border real-time payment settlement networks.",
      source: "Global Finance Review",
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
    ),
    TrendModel(
      id: "trend_6",
      rank: 6,
      title: "Geothermal Renewable Energy",
      category: "Business",
      changePercentage: 19.3,
      summary: "Next-gen deep drilling technology doubles clean base-load energy capacity.",
      source: "Energy Insights",
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Future<List<TrendModel>> getTrendingTopics({String? category}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (category == null || category.isEmpty || category == "All") {
      return List.from(_mockTrends);
    }
    return _mockTrends.where((t) => t.category.toLowerCase() == category.toLowerCase()).toList();
  }

  @override
  Future<TrendDetailModel?> getTrendDetails(String trendId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final trend = _mockTrends.firstWhere(
      (t) => t.id == trendId,
      orElse: () => _mockTrends.first,
    );

    return TrendDetailModel(
      trend: trend,
      overview:
          "${trend.title} has seen a ${trend.changePercentage}% spike in search volume and developer activity over the last 7 days. This growth is driven by enterprise demand for scale, efficiency, and automated workflows.",
      historicalScores: [42, 48, 55, 68, 79, 88, 96],
      whyTrending:
          "Recent advancements in hardware acceleration combined with open-source developer tooling have lowered the barrier to entry, triggering rapid industry adoption.",
      relatedTopics: [
        "Machine Learning",
        "Developer Productivity",
        "System Architecture",
        "Cloud Infrastructure",
      ],
      keyInsights: [
        "Enterprise adoption grew by 84% in Q3",
        "Reduction in operational latency by up to 60%",
        "Over 12,000 active GitHub repositories created this month",
      ],
    );
  }
}

import 'package:lala_ai/app/data/models/discover_model.dart';

abstract class DiscoverRepository {
  Future<List<DiscoverItemModel>> getDiscoverItems({String query = "", String category = "All"});
}

class MockDiscoverRepository implements DiscoverRepository {
  final List<DiscoverItemModel> _items = [
    DiscoverItemModel(
      id: "disc_1",
      title: "Building Multi-Agent Frameworks in 2026",
      description: "A comprehensive analysis on state persistence, task routing, and autonomous error recovery.",
      type: DiscoverType.article,
      category: "AI",
      source: "AI Architecture Journal",
      publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    DiscoverItemModel(
      id: "disc_2",
      title: "Flutter 3.29 Production Optimization Guide",
      description: "How to eliminate frame drops, optimize widget trees, and minimize memory footprint.",
      type: DiscoverType.topic,
      category: "Technology",
      source: "Flutter Weekly",
      publishedAt: DateTime.now().subtract(const Duration(hours: 10)),
    ),
    DiscoverItemModel(
      id: "disc_3",
      title: "Open Banking Protocol v4 Specifications Released",
      description: "Global standards for secure tokenized financial data transfer and Instant Pay API.",
      type: DiscoverType.news,
      category: "Finance",
      source: "FinTech Standard",
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    DiscoverItemModel(
      id: "disc_4",
      title: "Breakthrough in Room-Temperature Superconductors",
      description: "Peer-reviewed findings demonstrate stable electrical conduction at ambient pressures.",
      type: DiscoverType.insight,
      category: "Science",
      source: "Physical Review Letters",
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<List<DiscoverItemModel>> getDiscoverItems({String query = "", String category = "All"}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    var results = _items;

    if (category != "All" && category.isNotEmpty) {
      results = results.where((item) => item.category.toLowerCase() == category.toLowerCase()).toList();
    }

    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where((item) {
        return item.title.toLowerCase().contains(q) ||
            item.description.toLowerCase().contains(q) ||
            item.category.toLowerCase().contains(q);
      }).toList();
    }

    return results;
  }
}

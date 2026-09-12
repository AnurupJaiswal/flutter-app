import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// CategoryInsightsModel — Data structure for category-level shared insights.
/// ─────────────────────────────────────────────────────────────────────────────
class CategoryInsightsModel {
  final String categoryName;
  final String updatedTime;
  final List<String> trendingNow;
  final List<String> popularTopics;
  final List<CategoryInsightItem> sharedInsights;

  CategoryInsightsModel({
    required this.categoryName,
    required this.updatedTime,
    required this.trendingNow,
    required this.popularTopics,
    required this.sharedInsights,
  });
}

class CategoryInsightItem {
  final String tag;
  final String title;
  final String description;
  final IconData icon;

  CategoryInsightItem({
    required this.tag,
    required this.title,
    required this.description,
    required this.icon,
  });
}

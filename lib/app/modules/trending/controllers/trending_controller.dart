import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/data/models/trend_model.dart';
import 'package:lala_ai/app/data/repositories/trend_repository.dart';

class TrendingController extends GetxController {
  final TrendRepository trendRepository;

  TrendingController({required this.trendRepository});

  final selectedPlatform = "All Platforms".obs;
  final selectedNiche = "Tech & Creator AI".obs;
  final selectedScope = "Global".obs;

  final trends = <TrendModel>[].obs;
  final isLoading = false.obs;
  final lastUpdated = "5 mins ago".obs;

  late TextEditingController searchController;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    loadTrends();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  List<TrendModel> get filteredTrends {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return trends;
    }
    return trends.where((t) {
      final titleMatch = t.title.toLowerCase().contains(query);
      final categoryMatch = t.category.toLowerCase().contains(query);
      final summaryMatch = t.summary.toLowerCase().contains(query);
      final sourceMatch = t.source.toLowerCase().contains(query);
      return titleMatch || categoryMatch || summaryMatch || sourceMatch;
    }).toList();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  final isRefreshing = false.obs;

  Future<void> loadTrends({bool isRefresh = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
    } else if (trends.isEmpty) {
      isLoading.value = true;
    }

    try {
      final result = await trendRepository.getTrendingTopics();
      trends.assignAll(result);
      lastUpdated.value = "Just now";
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }
}

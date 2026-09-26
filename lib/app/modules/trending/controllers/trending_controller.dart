import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/data/models/trend_model.dart';
import 'package:lala_ai/app/data/repositories/trend_repository.dart';

class TrendingController extends GetxController {
  final TrendRepository trendRepository;

  TrendingController({required this.trendRepository});

  final selectedPlatform = "All".obs;
  final selectedCategory = "All".obs;

  final trends = <TrendModel>[].obs;
  final isLoading = false.obs;
  final lastUpdated = "Just now".obs;

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

  List<String> get availableCategories {
    final set = <String>{"All"};
    for (final t in trends) {
      if (t.category.trim().isNotEmpty) {
        set.add(t.category.trim());
      }
    }
    return set.toList();
  }

  List<TrendModel> get filteredTrends {
    final query = searchQuery.value.trim().toLowerCase();
    final cat = selectedCategory.value.trim().toLowerCase();
    final plat = selectedPlatform.value.trim().toLowerCase();

    return trends.where((t) {
      if (cat != "all" && t.category.toLowerCase() != cat) return false;
      if (plat != "all" && t.platform.toLowerCase() != plat) return false;

      if (query.isEmpty) return true;

      final titleMatch = t.title.toLowerCase().contains(query);
      final categoryMatch = t.category.toLowerCase().contains(query);
      final summaryMatch = t.summary.toLowerCase().contains(query);
      final sourceMatch = t.source.toLowerCase().contains(query);
      final lifecycleMatch = t.lifecycleStage.toLowerCase().contains(query);
      return titleMatch || categoryMatch || summaryMatch || sourceMatch || lifecycleMatch;
    }).toList();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  void setPlatform(String platform) {
    selectedPlatform.value = platform;
  }

  final isRefreshing = false.obs;

  Future<void> loadTrends({bool isRefresh = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
      HapticFeedback.lightImpact();
    } else if (trends.isEmpty) {
      isLoading.value = true;
    }

    try {
      final startTime = DateTime.now();
      final result = await trendRepository.getTrendingTopics();

      // Smooth pacing so pull-to-refresh spinner animates fluidly without abrupt snaps
      if (isRefresh) {
        final elapsed = DateTime.now().difference(startTime).inMilliseconds;
        if (elapsed < 500) {
          await Future.delayed(Duration(milliseconds: 500 - elapsed));
        }
      }

      trends.assignAll(result);
      lastUpdated.value = "Just now";
    } catch (_) {
      // Gracefully preserve existing trend items on network failure
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }
}

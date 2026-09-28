import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/data/models/category_model.dart';
import 'package:lala_ai/app/data/models/trend_model.dart';
import 'package:lala_ai/app/data/repositories/trend_repository.dart';

class TrendingController extends GetxController {
  final TrendRepository trendRepository;

  TrendingController({required this.trendRepository});

  final selectedPlatform = "All".obs;
  final selectedCategory = "All".obs;

  final platforms = const ["All", "YouTube", "Instagram"];

  final userCategories = <CategoryItemModel>[].obs;
  final isCategoriesLoading = false.obs;

  final trends = <TrendModel>[].obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final lastUpdated = "Just now".obs;

  late TextEditingController searchController;
  final searchQuery = ''.obs;
  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    loadMyCategories();
    loadTrends();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  /// Dynamically resolve category displayName from userCategories API payload
  String getCategoryDisplayName(String codeOrName) {
    if (codeOrName.isEmpty || codeOrName.toUpperCase() == 'ALL') return 'All';
    for (final cat in userCategories) {
      if (cat.code.toLowerCase() == codeOrName.toLowerCase() ||
          cat.name.toLowerCase() == codeOrName.toLowerCase()) {
        return cat.name;
      }
    }
    return codeOrName;
  }

  /// List of category filter options: "All" followed by the user's subscribed categories
  List<String> get availableCategories {
    final list = <String>["All"];
    for (final cat in userCategories) {
      final name = cat.name.isNotEmpty ? cat.name : cat.code;
      if (name.isNotEmpty && !list.any((e) => e.toLowerCase() == name.toLowerCase())) {
        list.add(name);
      }
    }
    return list;
  }

  /// Backend filtered trends feed
  List<TrendModel> get filteredTrends => trends;

  /// Fetch user's subscribed categories from API
  Future<void> loadMyCategories() async {
    try {
      isCategoriesLoading.value = true;
      final result = await trendRepository.getMyCategories();
      userCategories.assignAll(result);
    } catch (_) {
      // Gracefully maintain current categories
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      loadTrends();
    });
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _searchDebounce?.cancel();
    loadTrends();
  }

  void setCategory(String category) {
    if (selectedCategory.value.toLowerCase() != category.toLowerCase()) {
      selectedCategory.value = category;
      loadTrends();
    }
  }

  void setPlatform(String platform) {
    if (selectedPlatform.value.toLowerCase() != platform.toLowerCase()) {
      selectedPlatform.value = platform;
      loadTrends();
    }
  }

  /// Map display category name to category code if available
  String _resolveCategoryCode(String categoryName) {
    if (categoryName.toLowerCase() == "all") return "ALL";
    for (final cat in userCategories) {
      if (cat.name.toLowerCase() == categoryName.toLowerCase() ||
          cat.code.toLowerCase() == categoryName.toLowerCase()) {
        return cat.code.isNotEmpty ? cat.code : cat.name;
      }
    }
    return categoryName;
  }

  Future<void> loadTrends({bool isRefresh = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
      HapticFeedback.lightImpact();
      // On full pull-to-refresh, also refresh user's categories in the background
      loadMyCategories();
    } else {
      isLoading.value = true;
    }

    try {
      final startTime = DateTime.now();

      final categoryParam = _resolveCategoryCode(selectedCategory.value);
      final platformParam = selectedPlatform.value;

      final result = await trendRepository.getTrendingTopics(
        platform: platformParam,
        category: categoryParam,
        search: searchQuery.value,
      );

      // Smooth pacing so animations feel fluid without jarring snaps
      if (isRefresh) {
        final elapsed = DateTime.now().difference(startTime).inMilliseconds;
        if (elapsed < 400) {
          await Future.delayed(Duration(milliseconds: 400 - elapsed));
        }
      }

      trends.assignAll(result);
      lastUpdated.value = "Just now";
    } catch (_) {
      // Preserve existing state on network error
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }
}

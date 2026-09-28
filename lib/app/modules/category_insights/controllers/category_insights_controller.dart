import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/data/models/category_model.dart';
import 'package:lala_ai/networking/api_endpoints.dart';
import 'package:lala_ai/networking/api_service.dart';
import 'package:lala_ai/utils/app_toast.dart';

class CategoryInsightsController extends GetxController {
  // Pure Live API state - Zero static/hardcoded dummy data
  final RxList<CategoryItemModel> allAvailableCategories = <CategoryItemModel>[].obs;
  final RxSet<String> selectedCategoryIds = <String>{}.obs;
  final Set<String> _initialSelectedIds = <String>{};

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  bool isCategorySelected(CategoryItemModel category) {
    final code = _getCanonicalCode(category);
    return selectedCategoryIds.contains(code);
  }

  String _getCanonicalCode(CategoryItemModel category) {
    if (category.code.isNotEmpty) return category.code.trim();
    if (category.id.isNotEmpty) return category.id.trim();
    return category.name.trim();
  }

  final RxMap<String, bool> togglingCodes = <String, bool>{}.obs;

  Future<void> toggleCategory(CategoryItemModel category) async {
    final code = _getCanonicalCode(category);
    if (code.isEmpty) return;

    HapticFeedback.selectionClick();
    final wasSelected = selectedCategoryIds.contains(code);

    // Optimistic UI state toggle
    if (wasSelected) {
      selectedCategoryIds.remove(code);
    } else {
      selectedCategoryIds.add(code);
    }
    selectedCategoryIds.refresh();
    togglingCodes[code] = true;

    try {
      if (wasSelected) {
        // Direct Unsubscribe API
        final response = await ApiService.post(
          ApiEndpoints.unsubscribeCategory,
          body: [code],
        );
        if (response.isSuccess) {
          _initialSelectedIds.remove(code);
        } else {
          // Revert on error
          selectedCategoryIds.add(code);
          selectedCategoryIds.refresh();
          AppToast.error(response.message.isNotEmpty ? response.message : "Failed to unsubscribe category");
        }
      } else {
        // Direct Subscribe API
        final response = await ApiService.post(
          ApiEndpoints.subscribeCategory,
          body: {
            "categoryCodes": [code],
          },
        );
        if (response.isSuccess) {
          _initialSelectedIds.add(code);
        } else {
          // Revert on error
          selectedCategoryIds.remove(code);
          selectedCategoryIds.refresh();
          AppToast.error(response.message.isNotEmpty ? response.message : "Failed to subscribe category");
        }
      }
    } catch (e) {
      debugPrint("toggleCategory error: $e");
      // Revert on error
      if (wasSelected) {
        selectedCategoryIds.add(code);
      } else {
        selectedCategoryIds.remove(code);
      }
      selectedCategoryIds.refresh();
      AppToast.error("Failed to update category");
    } finally {
      togglingCodes[code] = false;
    }
  }

  Future<void> fetchCategories({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        isRefreshing.value = true;
      } else if (allAvailableCategories.isEmpty) {
        isLoading.value = true;
      }

      final Set<String> initialSubs = {};

      // 1. Fetch all system categories from GET /api/v1/categories
      try {
        final allResponse = await ApiService.get(ApiEndpoints.categories);
        if (allResponse.isSuccess && allResponse.data != null) {
          dynamic raw = allResponse.data;
          if (raw is Map) {
            raw = raw['data'] ?? raw['categories'] ?? raw['items'];
          }
          if (raw is List) {
            final List<CategoryItemModel> list = [];
            for (final item in raw) {
              final parsed = CategoryItemModel.fromJson(item);
              if (parsed.name.isNotEmpty || parsed.code.isNotEmpty) {
                list.add(parsed);
                if (parsed.isSubscribed) {
                  final code = _getCanonicalCode(parsed);
                  if (code.isNotEmpty) initialSubs.add(code);
                }
              }
            }
            if (list.isNotEmpty) {
              allAvailableCategories.assignAll(list);
            }
          }
        }
      } catch (e) {
        debugPrint("fetchCategories /categories error: $e");
      }

      // 2. Fetch creator's subscribed categories from GET /api/v1/categories/my
      try {
        final myResponse = await ApiService.get(ApiEndpoints.myCategories);
        if (myResponse.isSuccess && myResponse.data != null) {
          dynamic myRaw = myResponse.data;
          if (myRaw is Map) {
            myRaw = myRaw['data'] ?? myRaw['categories'] ?? myRaw['items'];
          }
          if (myRaw is List) {
            for (final item in myRaw) {
              if (item is String && item.trim().isNotEmpty) {
                initialSubs.add(item.trim());
              } else if (item is Map) {
                final parsed = CategoryItemModel.fromJson(item);
                final code = _getCanonicalCode(parsed);
                if (code.isNotEmpty) initialSubs.add(code);
              }
            }
          }
        }
      } catch (e) {
        debugPrint("fetchCategories /categories/my error (ignoring non-blocking): $e");
      }

      // Filter initialSubs strictly against available categories
      final availableCodes = allAvailableCategories.map((c) => _getCanonicalCode(c)).toSet();
      final validSubs = initialSubs.where((code) => availableCodes.contains(code)).toSet();

      selectedCategoryIds.assignAll(validSubs);
      _initialSelectedIds.clear();
      _initialSelectedIds.addAll(validSubs);
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  IconData getCategoryIcon(String cat) {
    final lower = cat.toLowerCase();
    if (lower.contains('entertain') || lower.contains('comedy')) return Icons.theater_comedy_rounded;
    if (lower.contains('gaming') || lower.contains('esport')) return Icons.sports_esports_rounded;
    if (lower.contains('fitness') || lower.contains('health') || lower.contains('wellness')) return Icons.fitness_center_rounded;
    if (lower.contains('beauty') || lower.contains('fashion') || lower.contains('style')) return Icons.style_rounded;
    if (lower.contains('food') || lower.contains('cook') || lower.contains('culinary')) return Icons.restaurant_rounded;
    if (lower.contains('travel') || lower.contains('adventure')) return Icons.explore_rounded;
    if (lower.contains('education') || lower.contains('knowledge')) return Icons.school_rounded;
    if (lower.contains('finance') || lower.contains('business') || lower.contains('career')) return Icons.account_balance_wallet_rounded;
    if (lower.contains('technology') || lower.contains('digital') || lower.contains('tech')) return Icons.devices_rounded;
    if (lower.contains('lifestyle') || lower.contains('home') || lower.contains('family')) return Icons.home_rounded;
    if (lower.contains('automotive') || lower.contains('machine') || lower.contains('car')) return Icons.directions_car_rounded;
    if (lower.contains('art') || lower.contains('creativ') || lower.contains('making')) return Icons.palette_rounded;
    if (lower.contains('music') || lower.contains('performing')) return Icons.music_note_rounded;
    if (lower.contains('animal') || lower.contains('pet') || lower.contains('nature')) return Icons.pets_rounded;
    if (lower.contains('commentary') || lower.contains('news') || lower.contains('culture')) return Icons.newspaper_rounded;
    return Icons.category_rounded;
  }
}

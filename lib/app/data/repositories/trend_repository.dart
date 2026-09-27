import 'package:flutter/foundation.dart';
import 'package:lala_ai/app/data/models/category_model.dart';
import 'package:lala_ai/app/data/models/trend_model.dart';
import 'package:lala_ai/networking/api_endpoints.dart';
import 'package:lala_ai/networking/api_service.dart';

abstract class TrendRepository {
  Future<List<TrendModel>> getTrendingTopics({
    String? category,
    String? platform,
    String? search,
    int? page,
    int? limit,
  });
  Future<TrendDetailModel?> getTrendDetails(String trendId);
  Future<List<CategoryItemModel>> getMyCategories();
}

class ApiTrendRepository implements TrendRepository {
  @override
  Future<List<TrendModel>> getTrendingTopics({
    String? category,
    String? platform,
    String? search,
    int? page,
    int? limit,
  }) async {
    try {
      String url = ApiEndpoints.trends;
      final queryParams = <String>[];
      if (platform != null && platform.isNotEmpty && platform.toUpperCase() != 'ALL') {
        queryParams.add("platform=${Uri.encodeComponent(platform.toUpperCase())}");
      }
      if (category != null && category.isNotEmpty) {
        queryParams.add("category=${Uri.encodeComponent(category.toUpperCase())}");
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams.add("search=${Uri.encodeComponent(search.trim())}");
      }
      if (page != null) {
        queryParams.add("page=$page");
      }
      if (limit != null) {
        queryParams.add("limit=$limit");
      }
      if (queryParams.isNotEmpty) {
        url += "?${queryParams.join('&')}";
      }

      final response = await ApiService.get(url);

      if (response.isSuccess && response.data != null) {
        dynamic rawList = response.data;
        if (rawList is Map) {
          rawList = rawList['data'] ?? rawList['trends'] ?? rawList['items'];
        }

        if (rawList is List) {
          final List<TrendModel> trends = [];
          for (int i = 0; i < rawList.length; i++) {
            final item = rawList[i];
            if (item is Map) {
              trends.add(
                TrendModel.fromJson(
                  Map<String, dynamic>.from(item),
                  defaultRank: i + 1,
                ),
              );
            }
          }
          // Directly return server response without local filtering
          return trends;
        }
      }
    } catch (e) {
      debugPrint("ApiTrendRepository getTrendingTopics error: $e");
    }

    return [];
  }

  @override
  Future<TrendDetailModel?> getTrendDetails(String trendId) async {
    try {
      final response = await ApiService.get(ApiEndpoints.trendDetails(trendId));
      if (response.isSuccess && response.data != null) {
        final data = response.data is Map && response.data['data'] is Map
            ? response.data['data']
            : response.data;
        if (data is Map) {
          return TrendDetailModel.fromJson(Map<String, dynamic>.from(data));
        }
      }
    } catch (e) {
      debugPrint("ApiTrendRepository getTrendDetails error: $e");
    }

    return null;
  }

  @override
  Future<List<CategoryItemModel>> getMyCategories() async {
    try {
      final response = await ApiService.get(ApiEndpoints.myCategories);
      if (response.isSuccess && response.data != null) {
        dynamic raw = response.data;
        if (raw is Map) {
          raw = raw['data'] ?? raw['categories'] ?? raw['items'];
        }
        if (raw is List) {
          return raw
              .whereType<Map>()
              .map((item) => CategoryItemModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    } catch (e) {
      debugPrint("ApiTrendRepository getMyCategories error: $e");
    }
    return [];
  }
}

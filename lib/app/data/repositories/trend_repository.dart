import 'package:flutter/foundation.dart';
import 'package:lala_ai/app/data/models/trend_model.dart';
import 'package:lala_ai/networking/api_endpoints.dart';
import 'package:lala_ai/networking/api_service.dart';

abstract class TrendRepository {
  Future<List<TrendModel>> getTrendingTopics({String? category});
  Future<TrendDetailModel?> getTrendDetails(String trendId);
}

class ApiTrendRepository implements TrendRepository {
  @override
  Future<List<TrendModel>> getTrendingTopics({String? category}) async {
    try {
      final response = await ApiService.get(ApiEndpoints.trends);

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

          if (category != null && category.isNotEmpty && category.toLowerCase() != "all") {
            return trends.where((t) => t.category.toLowerCase() == category.toLowerCase()).toList();
          }
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
}

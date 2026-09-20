import 'package:flutter/foundation.dart';
import 'package:lala_ai/app/data/models/public_document_model.dart';
import 'package:lala_ai/networking/api_endpoints.dart';
import 'package:lala_ai/networking/api_service.dart';

abstract class PublicRepository {
  Future<PublicDocumentModel?> getPrivacyPolicy();
  Future<PublicDocumentModel?> getTermsAndConditions();
  Future<PublicDocumentModel?> getDocument(String slug);
  Future<List<PublicFaqModel>> getFaqs();
}

class ApiPublicRepository implements PublicRepository {
  @override
  Future<PublicDocumentModel?> getPrivacyPolicy() async {
    try {
      final response = await ApiService.get(ApiEndpoints.publicPrivacy);
      if (response.isSuccess && response.data != null) {
        final data = response.data is Map && response.data['data'] is Map
            ? response.data['data']
            : response.data;
        if (data is Map) {
          return PublicDocumentModel.fromJson(Map<String, dynamic>.from(data));
        }
      }
    } catch (e) {
      debugPrint("getPrivacyPolicy error: $e");
    }
    return null;
  }

  @override
  Future<PublicDocumentModel?> getTermsAndConditions() async {
    try {
      final response = await ApiService.get(ApiEndpoints.publicTerms);
      if (response.isSuccess && response.data != null) {
        final data = response.data is Map && response.data['data'] is Map
            ? response.data['data']
            : response.data;
        if (data is Map) {
          return PublicDocumentModel.fromJson(Map<String, dynamic>.from(data));
        }
      }
    } catch (e) {
      debugPrint("getTermsAndConditions error: $e");
    }
    return null;
  }

  @override
  Future<PublicDocumentModel?> getDocument(String slug) async {
    if (slug.toLowerCase() == 'privacy' || slug.toLowerCase() == 'privacy-policy') {
      return getPrivacyPolicy();
    }
    if (slug.toLowerCase() == 'terms' || slug.toLowerCase() == 'terms-conditions') {
      return getTermsAndConditions();
    }
    try {
      final response = await ApiService.get('/api/v1/public/documents/$slug');
      if (response.isSuccess && response.data != null) {
        final data = response.data is Map && response.data['data'] is Map
            ? response.data['data']
            : response.data;
        if (data is Map) {
          return PublicDocumentModel.fromJson(Map<String, dynamic>.from(data));
        }
      }
    } catch (e) {
      debugPrint("getDocument error: $e");
    }
    return null;
  }

  @override
  Future<List<PublicFaqModel>> getFaqs() async {
    try {
      final response = await ApiService.get(ApiEndpoints.publicFaqs);
      if (response.isSuccess && response.data != null) {
        final data = response.data;
        final list = data is List
            ? data
            : (data is Map && data['faqs'] is List
                ? data['faqs'] as List
                : (data is Map && data['data'] is List ? data['data'] as List : []));
        return list
            .map((item) => PublicFaqModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    } catch (e) {
      debugPrint("getFaqs error: $e");
    }
    return [];
  }
}

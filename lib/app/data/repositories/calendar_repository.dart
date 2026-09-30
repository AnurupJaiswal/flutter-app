import 'package:flutter/foundation.dart';
import 'package:lala_ai/app/data/models/content_draft_model.dart';
import 'package:lala_ai/networking/api_endpoints.dart';
import 'package:lala_ai/networking/api_service.dart';

class CalendarResult<T> {
  final bool isSuccess;
  final T? data;
  final String message;
  final String? errorCode;

  CalendarResult({
    required this.isSuccess,
    this.data,
    this.message = '',
    this.errorCode,
  });
}

abstract class CalendarRepository {
  Future<CalendarResult<List<ContentDraftModel>>> getDrafts({
    dynamic accountId,
    DateTime? startDate,
    DateTime? endDate,
    int? year,
    int? month,
    String? status,
    String? contentType,
  });

  Future<CalendarResult<ContentDraftModel>> createDraft({
    required dynamic accountId,
    required String title,
    required String contentType, // SHORT, LONG_FORM, REEL
    String? scriptData,
    dynamic copilotPlanId,
  });

  Future<CalendarResult<ContentDraftModel>> scheduleDraft({
    required dynamic draftId,
    required DateTime scheduledAt, // Converts local DateTime to UTC ISO string
  });

  Future<CalendarResult<ContentDraftModel>> updateDraftStatus({
    required dynamic draftId,
    required String status, // POSTED or DRAFT
  });
}

class ApiCalendarRepository implements CalendarRepository {
  @override
  Future<CalendarResult<List<ContentDraftModel>>> getDrafts({
    dynamic accountId,
    DateTime? startDate,
    DateTime? endDate,
    int? year,
    int? month,
    String? status,
    String? contentType,
  }) async {
    try {
      final endpoint = ApiEndpoints.calendarDraftsList(
        accountId: accountId,
        startDate: startDate,
        endDate: endDate,
        year: year,
        month: month,
        status: status,
        contentType: contentType,
      );
      final response = await ApiService.get(endpoint);

      if (response.isSuccess && response.data != null) {
        final data = response.data;
        List rawList = [];
        if (data is Map && data['drafts'] is List) {
          rawList = data['drafts'] as List;
        } else if (data is Map && data['data'] is List) {
          rawList = data['data'] as List;
        } else if (data is Map &&
            data['data'] is Map &&
            data['data']['drafts'] is List) {
          rawList = data['data']['drafts'] as List;
        } else if (data is List) {
          rawList = data;
        }

        final list = rawList
            .map(
              (item) => ContentDraftModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();

        return CalendarResult(
          isSuccess: true,
          data: list,
          message: response.message,
        );
      } else {
        return CalendarResult(
          isSuccess: false,
          message: response.message.isNotEmpty
              ? response.message
              : 'Failed to fetch content drafts.',
          errorCode: response.errorCode,
        );
      }
    } catch (e) {
      debugPrint("CalendarRepository.getDrafts error: $e");
      return CalendarResult(isSuccess: false, message: e.toString());
    }
  }

  @override
  Future<CalendarResult<ContentDraftModel>> createDraft({
    required dynamic accountId,
    required String title,
    required String contentType,
    String? scriptData,
    dynamic copilotPlanId,
  }) async {
    try {
      final body = <String, dynamic>{
        'accountId': accountId,
        'title': title,
        'contentType': contentType.toUpperCase(),
      };
      if (scriptData != null && scriptData.isNotEmpty) {
        body['scriptData'] = scriptData;
      }
      if (copilotPlanId != null) {
        body['copilotPlanId'] = copilotPlanId;
      }

      final response = await ApiService.post(
        ApiEndpoints.calendarDrafts,
        body: body,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data;
        Map<String, dynamic>? itemMap;
        if (data is Map && data['draft'] is Map) {
          itemMap = Map<String, dynamic>.from(data['draft'] as Map);
        } else if (data is Map && data['data'] is Map) {
          itemMap = Map<String, dynamic>.from(data['data'] as Map);
        } else if (data is Map) {
          itemMap = Map<String, dynamic>.from(data);
        }

        if (itemMap != null) {
          return CalendarResult(
            isSuccess: true,
            data: ContentDraftModel.fromJson(itemMap),
            message: response.message,
          );
        }
      }

      return CalendarResult(
        isSuccess: false,
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to create content draft.',
        errorCode: response.errorCode,
      );
    } catch (e) {
      debugPrint("CalendarRepository.createDraft error: $e");
      return CalendarResult(isSuccess: false, message: e.toString());
    }
  }

  @override
  Future<CalendarResult<ContentDraftModel>> scheduleDraft({
    required dynamic draftId,
    required DateTime scheduledAt,
  }) async {
    try {
      final utcIso = scheduledAt.toUtc().toIso8601String();

      final response = await ApiService.put(
        ApiEndpoints.calendarDraftSchedule(draftId),
        body: {'scheduledAt': utcIso},
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data;
        Map<String, dynamic>? itemMap;
        if (data is Map && data['draft'] is Map) {
          itemMap = Map<String, dynamic>.from(data['draft'] as Map);
        } else if (data is Map && data['data'] is Map) {
          itemMap = Map<String, dynamic>.from(data['data'] as Map);
        } else if (data is Map) {
          itemMap = Map<String, dynamic>.from(data);
        }

        if (itemMap != null) {
          return CalendarResult(
            isSuccess: true,
            data: ContentDraftModel.fromJson(itemMap),
            message: response.message,
          );
        }
      }

      return CalendarResult(
        isSuccess: false,
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to schedule draft.',
        errorCode: response.errorCode,
      );
    } catch (e) {
      debugPrint("CalendarRepository.scheduleDraft error: $e");
      return CalendarResult(isSuccess: false, message: e.toString());
    }
  }

  @override
  Future<CalendarResult<ContentDraftModel>> updateDraftStatus({
    required dynamic draftId,
    required String status,
  }) async {
    try {
      final response = await ApiService.put(
        ApiEndpoints.calendarDraftStatus(draftId),
        body: {'status': status.toUpperCase()},
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data;
        Map<String, dynamic>? itemMap;
        if (data is Map && data['draft'] is Map) {
          itemMap = Map<String, dynamic>.from(data['draft'] as Map);
        } else if (data is Map && data['data'] is Map) {
          itemMap = Map<String, dynamic>.from(data['data'] as Map);
        } else if (data is Map) {
          itemMap = Map<String, dynamic>.from(data);
        }

        if (itemMap != null) {
          return CalendarResult(
            isSuccess: true,
            data: ContentDraftModel.fromJson(itemMap),
            message: response.message,
          );
        }
      }

      return CalendarResult(
        isSuccess: false,
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to update draft status.',
        errorCode: response.errorCode,
      );
    } catch (e) {
      debugPrint("CalendarRepository.updateDraftStatus error: $e");
      return CalendarResult(isSuccess: false, message: e.toString());
    }
  }
}

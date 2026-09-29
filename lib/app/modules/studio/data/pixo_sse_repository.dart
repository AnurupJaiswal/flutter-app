import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lala_ai/Models/chat_model.dart';
import 'package:lala_ai/app/modules/studio/data/pixo_event.dart';
import 'package:lala_ai/networking/api_endpoints.dart';
import 'package:lala_ai/networking/api_service.dart';

/// Handles the Pixo AI streaming protocol.
///
/// Key constraints (from M10 spec):
/// - Flutter **never** sends duplicate `/stream` requests during recovery.
/// - Flutter **never** connects to LLM providers directly.
/// - Cancellation uses the dedicated cancel endpoint (Option B), not HTTP abort.
class PixoSseRepository {
  static final Dio _streamDio = _buildStreamDio();

  static Dio _buildStreamDio() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl.trim(),
      // SSE connections must not time-out on receive — set to 0 (infinite).
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: Duration.zero,
      responseType: ResponseType.stream,
    ));
    return dio;
  }

  // ── Streaming ─────────────────────────────────────────────────────────────

  /// Opens the SSE stream for a single user turn.
  ///
  /// [conversationId] is null for new conversations; the backend creates one
  /// and sends the id back in the START event.
  ///
  /// Returns a [Stream<PixoEvent>] that the controller dispatches on.
  Stream<PixoEvent> stream({
    int? conversationId,
    required String message,
    CancelToken? cancelToken,
  }) async* {
    final token = ApiService.token;
    if (token == null || token.isEmpty) {
      yield PixoErrorEvent(message: 'Not authenticated');
      return;
    }

    final body = <String, dynamic>{
      'message': message,
      if (conversationId != null) 'conversationId': conversationId,
    };

    Response<ResponseBody> response;
    try {
      response = await _streamDio.post<ResponseBody>(
        ApiEndpoints.pixoStream,
        data: jsonEncode(body),
        cancelToken: cancelToken,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
          },
          responseType: ResponseType.stream,
          validateStatus: (_) => true,
        ),
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        yield const PixoCancelledEvent();
        return;
      }
      yield PixoErrorEvent(message: e.message ?? 'Network error');
      return;
    } catch (e) {
      yield PixoErrorEvent(message: e.toString());
      return;
    }

    if (response.statusCode != 200) {
      yield PixoErrorEvent(
          message: 'HTTP ${response.statusCode}: ${response.statusMessage}');
      return;
    }

    // Parse the raw byte stream as SSE frames.
    final stream = response.data!.stream;
    final buffer = StringBuffer();

    String currentEvent = '';
    String currentData = '';

    await for (final bytes in stream) {
      buffer.write(utf8.decode(bytes, allowMalformed: true));

      // Process complete lines separated by '\n'
      final raw = buffer.toString();
      final lines = raw.split('\n');

      // Keep any incomplete last line in the buffer
      buffer
        ..clear()
        ..write(lines.last);

      for (final line in lines.sublist(0, lines.length - 1)) {
        final trimmed = line.trimRight();

        if (trimmed.isEmpty) {
          // Empty line = dispatch accumulated event
          if (currentEvent.isNotEmpty || currentData.isNotEmpty) {
            final event = _parseFrame(currentEvent.trim(), currentData.trim());
            if (event != null) yield event;
            currentEvent = '';
            currentData = '';
          }
          continue;
        }

        if (trimmed.startsWith('event:')) {
          currentEvent = trimmed.substring('event:'.length).trim();
        } else if (trimmed.startsWith('data:')) {
          // data can be multi-line; append
          final chunk = trimmed.substring('data:'.length).trim();
          currentData = currentData.isEmpty ? chunk : '$currentData\n$chunk';
        }
        // id: and retry: fields are intentionally ignored
      }
    }

    // Flush any remaining buffer content
    final remaining = buffer.toString().trimRight();
    if (remaining.isNotEmpty) {
      for (final line in remaining.split('\n')) {
        final trimmed = line.trimRight();
        if (trimmed.startsWith('event:')) {
          currentEvent = trimmed.substring('event:'.length).trim();
        } else if (trimmed.startsWith('data:')) {
          currentData = trimmed.substring('data:'.length).trim();
        }
      }
      final event = _parseFrame(currentEvent.trim(), currentData.trim());
      if (event != null) yield event;
    }
  }

  PixoEvent? _parseFrame(String eventType, String rawData) {
    if (eventType.isEmpty) return null;
    Map<String, dynamic> data = {};
    if (rawData.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is Map) {
          data = Map<String, dynamic>.from(decoded);
        }
      } catch (e) {
        debugPrint('[Pixo SSE] JSON parse error for event "$eventType": $e');
      }
    }
    try {
      return PixoEvent.fromParsed(eventType, data);
    } catch (e) {
      debugPrint('[Pixo SSE] Unknown event "$eventType": $e');
      return PixoUnknownEvent(eventType: eventType);
    }
  }

  // ── Recovery ──────────────────────────────────────────────────────────────

  /// Fetch the persisted conversation history for reconciliation after a
  /// network disconnect.  Uses `messageId` to skip already-rendered messages.
  ///
  /// Rule: **never** resend the original /stream request.  Always use this.
  Future<List<ChatMessageModel>> fetchHistory(int conversationId) async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: ApiEndpoints.baseUrl.trim(),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
      ));
      final response = await dio.get(
        ApiEndpoints.pixoConversationMessages(conversationId),
        options: Options(headers: {
          'Authorization': 'Bearer ${ApiService.token}',
        }),
      );
      if (response.statusCode == 200 && response.data != null) {
        final dynamic raw = response.data;
        List<dynamic>? list;
        if (raw is List) {
          list = raw;
        } else if (raw is Map) {
          list = raw['messages'] as List? ??
              raw['data'] as List? ??
              raw['items'] as List?;
        }
        if (list != null) {
          return list
              .whereType<Map>()
              .map((e) =>
                  ChatMessageModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('[Pixo] fetchHistory error: $e');
    }
    return [];
  }

  // ── Cancellation (Option B) ───────────────────────────────────────────────

  /// Sends the dedicated cancel request to halt backend LLM consumption.
  ///
  /// Flutter must call this rather than merely dropping the HTTP connection,
  /// to prevent orphaned LLM calls on the Java side.
  Future<void> cancelMessage({
    required int conversationId,
    required int messageId,
  }) async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: ApiEndpoints.baseUrl.trim(),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      await dio.post(
        ApiEndpoints.pixoCancelMessage(conversationId, messageId),
        options: Options(headers: {
          'Authorization': 'Bearer ${ApiService.token}',
        }),
      );
    } catch (e) {
      debugPrint('[Pixo] cancelMessage error (non-fatal): $e');
    }
  }
}

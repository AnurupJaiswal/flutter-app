import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lala_ai/Models/chat_model.dart';
import 'package:lala_ai/app/modules/studio/data/pixo_event.dart';
import 'package:lala_ai/networking/api_endpoints.dart';
import 'package:lala_ai/networking/api_service.dart';

/// The single source of truth for ALL Pixo-related network calls.
///
/// M10 architecture constraints (strictly enforced here):
///
/// ① `stream()` is the **only** way to send a user message.  Never call any
///    legacy `/api/v1/chats` endpoint to "send" a message.
/// ② `fetchHistory()` is the **only** recovery mechanism after a disconnect.
///    Never re-POST to `pixoStream` for recovery.
/// ③ `cancelMessage()` (Option B) must be called before dropping the HTTP
///    connection to prevent orphaned LLM calls on the Java side.
/// ④ Conversation list / rename / delete use the Pixo conversation endpoints,
///    not the old generic chat endpoints.
class PixoSseRepository {
  // ── Shared Dio instances ──────────────────────────────────────────────────

  /// Infinite receive-timeout for the long-lived SSE connection.
  static final Dio _streamDio = Dio(BaseOptions(
    baseUrl: ApiEndpoints.baseUrl.trim(),
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: Duration.zero, // SSE must not time-out on receive
    responseType: ResponseType.stream,
  ));

  /// Standard JSON Dio for all non-streaming Pixo calls.
  static Dio get _jsonDio => Dio(BaseOptions(
        baseUrl: ApiEndpoints.baseUrl.trim(),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
      ));

  static Options _authOptions({String contentType = 'application/json'}) =>
      Options(
        headers: {
          'Authorization': 'Bearer ${ApiService.token}',
          'Content-Type': contentType,
        },
        validateStatus: (_) => true,
      );

  // ── 1. SSE Streaming ──────────────────────────────────────────────────────

  /// Opens the single Pixo SSE stream for one user turn.
  ///
  /// Pass [conversationId] for existing conversations; omit (null) to let the
  /// backend create a new one — the `START` event will return the new id.
  ///
  /// Returns a typed [Stream<PixoEvent>] that [StudioController] dispatches on.
  Stream<PixoEvent> stream({
    int? conversationId,
    required String message,
    CancelToken? cancelToken,
  }) async* {
    final token = ApiService.token;
    if (token == null || token.isEmpty) {
      debugPrint('[Pixo SSE Error] Unauthenticated request attempted.');
      yield PixoErrorEvent(message: 'Not authenticated');
      return;
    }

    final preview = message.length > 60 ? '${message.substring(0, 60)}...' : message;
    debugPrint('[Pixo SSE Send] ---> POST ${ApiEndpoints.pixoStream} | conversationId: $conversationId | message: "$preview"');

    final body = <String, dynamic>{
      'message': message,
      if (conversationId != null && conversationId > 0)
        'conversationId': conversationId,
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
        debugPrint('[Pixo SSE Cancel] Request was cancelled by user via CancelToken.');
        yield const PixoCancelledEvent();
        return;
      }
      debugPrint('[Pixo SSE Error] DioException during stream: ${e.message} (type: ${e.type})');
      yield PixoErrorEvent(message: e.message ?? 'Network error');
      return;
    } catch (e) {
      debugPrint('[Pixo SSE Error] Unexpected exception during stream: $e');
      yield PixoErrorEvent(message: e.toString());
      return;
    }

    if (response.statusCode != 200) {
      debugPrint('[Pixo SSE Error] Stream request failed with status HTTP ${response.statusCode}');
      String friendlyError = 'Unable to connect to the assistant right now. Please try again.';
      if (response.statusCode == 401) {
        friendlyError = 'Your session has expired. Please sign in again to continue.';
      } else if (response.statusCode == 403) {
        friendlyError = 'You do not have permission to access this resource or an upgrade is required.';
      } else if (response.statusCode == 404) {
        friendlyError = 'The requested conversation could not be found.';
      } else if (response.statusCode == 429) {
        friendlyError = 'Too many requests. Please wait a moment before trying again.';
      } else if (response.statusCode != null && response.statusCode! >= 500) {
        friendlyError = 'The server is temporarily unavailable. Please try again shortly.';
      }
      yield PixoErrorEvent(message: friendlyError);
      return;
    }

    // ── SSE frame parser ────────────────────────────────────────────────────
    final byteStream = response.data!.stream;
    final buffer = StringBuffer();
    String currentEvent = '';
    String currentData = '';

    await for (final bytes in byteStream) {
      buffer.write(utf8.decode(bytes, allowMalformed: true));

      final raw = buffer.toString();
      final lines = raw.split('\n');

      // Keep any incomplete trailing line in the buffer
      buffer
        ..clear()
        ..write(lines.last);

      for (final line in lines.sublist(0, lines.length - 1)) {
        final trimmed = line.trimRight();

        if (trimmed.isEmpty) {
          // Empty line → dispatch the accumulated event frame
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
          final chunk = trimmed.substring('data:'.length).trim();
          currentData =
              currentData.isEmpty ? chunk : '$currentData\n$chunk';
        }
        // id: and retry: are intentionally ignored per M10 spec
      }
    }

    // Flush any trailing content not terminated by a newline
    final remaining = buffer.toString().trimRight();
    if (remaining.isNotEmpty) {
      for (final line in remaining.split('\n')) {
        final t = line.trimRight();
        if (t.startsWith('event:')) {
          currentEvent = t.substring('event:'.length).trim();
        } else if (t.startsWith('data:')) {
          currentData = t.substring('data:'.length).trim();
        }
      }
      final event = _parseFrame(currentEvent.trim(), currentData.trim());
      if (event != null) yield event;
    }
  }

  PixoEvent? _parseFrame(String eventType, String rawData) {
    if (eventType.isEmpty) return null;
    debugPrint('[Pixo SSE Receive] Event: "$eventType" | Payload: ${rawData.length > 100 ? '${rawData.substring(0, 100)}...' : rawData}');
    
    Map<String, dynamic> data = {};
    if (rawData.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is Map) {
          data = Map<String, dynamic>.from(decoded);
        } else if (decoded != null) {
          data['message'] = decoded.toString();
          data['content'] = decoded.toString();
        }
      } catch (_) {
        // Payload is plain text (e.g., plain error message or non-JSON string)
        data['message'] = rawData;
        data['content'] = rawData;

        // Best-effort regex extraction for conversationId and messageId if formatted like conversationId: 123
        final convMatch = RegExp(r'conversationId["\s:=]+(\d+)', caseSensitive: false).firstMatch(rawData);
        if (convMatch != null) {
          data['conversationId'] = int.tryParse(convMatch.group(1) ?? '');
        }
        final msgMatch = RegExp(r'messageId["\s:=]+(\d+)', caseSensitive: false).firstMatch(rawData);
        if (msgMatch != null) {
          data['messageId'] = int.tryParse(msgMatch.group(1) ?? '');
        }
      }
    }

    try {
      final event = PixoEvent.fromParsed(eventType, data);
      debugPrint('[Pixo SSE Dispatch] Dispatched ${event.runtimeType}');
      return event;
    } catch (e) {
      debugPrint('[Pixo SSE Error] Unparseable event "$eventType": $e');
      return PixoUnknownEvent(eventType: eventType);
    }
  }

  // ── 2. Recovery — history fetch (NO re-streaming) ─────────────────────────

  /// Fetches the authoritative persisted messages for [conversationId].
  ///
  /// Called ONLY during disconnect recovery.  Never re-POST to [pixoStream].
  Future<List<ChatMessageModel>> fetchHistory(int conversationId) async {
    debugPrint('[Pixo History] GET ${ApiEndpoints.pixoConversationMessages(conversationId)}');
    try {
      final response = await _jsonDio.get(
        ApiEndpoints.pixoConversationMessages(conversationId),
        options: _authOptions(),
      );
      if (response.statusCode == 200 && response.data != null) {
        final raw = response.data;
        List<dynamic>? list;
        if (raw is List) {
          list = raw;
        } else if (raw is Map) {
          list = raw['messages'] as List? ??
              raw['data'] as List? ??
              raw['items'] as List?;
        }
        if (list != null) {
          final res = list
              .whereType<Map>()
              .map((e) =>
                  ChatMessageModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          debugPrint('[Pixo History] Loaded ${res.length} messages for convId: $conversationId');
          return res;
        }
      }
    } catch (e) {
      debugPrint('[Pixo Error] fetchHistory failed for convId $conversationId: $e');
    }
    return [];
  }

  // ── 3. Cancellation — Option B ────────────────────────────────────────────

  Future<void> cancelMessage({
    required int conversationId,
    required int messageId,
  }) async {
    debugPrint('[Pixo Cancel] POST ${ApiEndpoints.pixoCancelMessage(conversationId, messageId)}');
    try {
      await _jsonDio.post(
        ApiEndpoints.pixoCancelMessage(conversationId, messageId),
        options: _authOptions(),
      );
    } catch (e) {
      debugPrint('[Pixo Error] cancelMessage failed (non-fatal): $e');
    }
  }

  // ── 4. Conversation list (sidebar) ────────────────────────────────────────

  Future<List<ChatSessionModel>> getConversations() async {
    debugPrint('[Pixo Conversations] GET ${ApiEndpoints.pixoConversations}');
    try {
      final response = await _jsonDio.get(
        ApiEndpoints.pixoConversations,
        options: _authOptions(),
      );
      if (response.statusCode == 200 && response.data != null) {
        final raw = response.data;
        List<dynamic>? list;
        if (raw is List) {
          list = raw;
        } else if (raw is Map) {
          list = raw['content'] as List? ??
              raw['conversations'] as List? ??
              raw['data'] as List? ??
              raw['sessions'] as List?;
        }
        if (list != null) {
          final res = list
              .whereType<Map>()
              .map((e) =>
                  ChatSessionModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          debugPrint('[Pixo Conversations] Loaded ${res.length} sessions from backend.');
          return res;
        }
      }
    } catch (e) {
      debugPrint('[Pixo Error] getConversations failed: $e');
    }
    return [];
  }

  // ── 5. Rename conversation ────────────────────────────────────────────────

  Future<bool> renameConversation({
    required int conversationId,
    required String newTitle,
  }) async {
    debugPrint('[Pixo Rename] PUT ${ApiEndpoints.pixoConversationDetail(conversationId)} | title: "$newTitle"');
    try {
      final response = await _jsonDio.put(
        ApiEndpoints.pixoConversationDetail(conversationId),
        data: {'title': newTitle},
        options: _authOptions(),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('[Pixo Error] renameConversation failed: $e');
      return false;
    }
  }

  // ── 6. Delete conversation ────────────────────────────────────────────────

  Future<bool> deleteConversation(int conversationId) async {
    debugPrint('[Pixo Delete] DELETE ${ApiEndpoints.pixoConversationDetail(conversationId)}');
    try {
      final response = await _jsonDio.delete(
        ApiEndpoints.pixoConversationDetail(conversationId),
        options: _authOptions(),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('[Pixo Error] deleteConversation failed: $e');
      return false;
    }
  }
}

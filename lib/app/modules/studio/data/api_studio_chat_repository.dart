import 'package:lala_ai/Models/chat_model.dart';
import 'package:lala_ai/app/modules/studio/data/studio_chat_repository.dart';
import 'package:lala_ai/networking/api_endpoints.dart';
import 'package:lala_ai/networking/api_service.dart';

/// Production API Implementation for Studio chat — connects to the same
/// chat backend endpoints as the Chatbot, but is a fully independent class.
class ApiStudioChatRepository implements StudioChatRepository {
  Map<String, dynamic>? _extractMap(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) {
      if (data['data'] is Map<String, dynamic>) {
        return data['data'] as Map<String, dynamic>;
      }
      if (data['chat'] is Map<String, dynamic>) {
        return data['chat'] as Map<String, dynamic>;
      }
      if (data['message'] is Map<String, dynamic>) {
        return data['message'] as Map<String, dynamic>;
      }
      return data;
    } else if (data is Map) {
      final typed = Map<String, dynamic>.from(data);
      if (typed['data'] is Map) return Map<String, dynamic>.from(typed['data'] as Map);
      if (typed['chat'] is Map) return Map<String, dynamic>.from(typed['chat'] as Map);
      if (typed['message'] is Map) return Map<String, dynamic>.from(typed['message'] as Map);
      return typed;
    }
    return null;
  }

  @override
  Future<List<ChatSessionModel>> getChats() async {
    final response = await ApiService.get(ApiEndpoints.chats);
    if (response.isSuccess && response.data != null) {
      dynamic listData;
      if (response.data is List) {
        listData = response.data;
      } else if (response.data is Map) {
        listData = response.data['data'] ?? response.data['chats'] ?? response.data['sessions'];
      }

      if (listData is List) {
        final List<ChatSessionModel> results = [];
        for (final item in listData) {
          if (item is Map) {
            try {
              results.add(ChatSessionModel.fromJson(Map<String, dynamic>.from(item)));
            } catch (_) {}
          }
        }
        return results;
      }
    }
    return [];
  }

  @override
  Future<ChatSessionModel?> getChat(String chatId) async {
    final response = await ApiService.get(ApiEndpoints.chatDetails(chatId));
    if (response.isSuccess && response.data != null) {
      final map = _extractMap(response.data);
      if (map != null) {
        return ChatSessionModel.fromJson(map);
      }
    }
    return null;
  }

  @override
  Future<ChatSessionModel> createChat({String? title, String? initialMessage}) async {
    final response = await ApiService.post(
      ApiEndpoints.chats,
      body: {
        'title': title ?? (initialMessage != null && initialMessage.length > 28
            ? "${initialMessage.substring(0, 28)}..."
            : initialMessage ?? "New Studio Chat"),
        if (initialMessage != null) 'initialMessage': initialMessage,
      },
    );

    if (response.isSuccess && response.data != null) {
      final map = _extractMap(response.data);
      if (map != null) {
        return ChatSessionModel.fromJson(map);
      }
    }

    // Fallback if backend response is format-incompatible
    return ChatSessionModel(
      id: "studio_chat_${DateTime.now().millisecondsSinceEpoch}",
      title: title ?? "New Studio Chat",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: [],
    );
  }

  @override
  Future<ChatMessageModel> sendMessage({
    required String chatId,
    required String message,
  }) async {
    final response = await ApiService.post(
      ApiEndpoints.chatMessages(chatId),
      body: {'message': message},
    );

    if (response.isSuccess && response.data != null) {
      final map = _extractMap(response.data);
      if (map != null) {
        return ChatMessageModel.fromJson(map);
      }
    }

    throw Exception(response.message.isNotEmpty ? response.message : "Failed to receive AI response");
  }

  @override
  Future<bool> deleteChat(String chatId) async {
    final response = await ApiService.delete(ApiEndpoints.chatDetails(chatId));
    return response.isSuccess;
  }

  @override
  Future<bool> renameChat({required String chatId, required String newTitle}) async {
    final response = await ApiService.put(
      ApiEndpoints.chatDetails(chatId),
      body: {'title': newTitle},
    );
    return response.isSuccess;
  }
}

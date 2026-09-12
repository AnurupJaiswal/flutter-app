import 'package:lala_ai/Models/chat_model.dart';
import 'package:lala_ai/app/modules/chat/data/chat_repository.dart';
import 'package:lala_ai/networking/api_endpoints.dart';
import 'package:lala_ai/networking/api_service.dart';

/// Production API Implementation connecting to live backend endpoints
class ApiChatRepository implements ChatRepository {
  @override
  Future<List<ChatSessionModel>> getChats() async {
    final response = await ApiService.get(ApiEndpoints.chats);
    if (response.isSuccess && response.data is List) {
      return (response.data as List)
          .map((item) => ChatSessionModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<ChatSessionModel?> getChat(String chatId) async {
    final response = await ApiService.get(ApiEndpoints.chatDetails(chatId));
    if (response.isSuccess && response.data != null) {
      return ChatSessionModel.fromJson(response.data as Map<String, dynamic>);
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
            : initialMessage ?? "New Chat"),
        if (initialMessage != null) 'initialMessage': initialMessage,
      },
    );

    if (response.isSuccess && response.data != null) {
      return ChatSessionModel.fromJson(response.data as Map<String, dynamic>);
    }

    // Fallback if backend offline
    return ChatSessionModel(
      id: "chat_${DateTime.now().millisecondsSinceEpoch}",
      title: title ?? "New Chat",
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
      return ChatMessageModel.fromJson(response.data as Map<String, dynamic>);
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

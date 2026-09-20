import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';
import 'package:lala_ai/app/modules/chat/controllers/chat_controller.dart';
import 'package:lala_ai/app/modules/chat/data/chat_repository.dart';
import 'package:lala_ai/Models/auth_response_model.dart';
import 'package:lala_ai/Models/user_model.dart';
import 'package:lala_ai/networking/api_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthRepository implements AuthRepository {
  bool _hasSession = false;
  UserModel? _currentUser;

  @override
  Future<ApiResponse<AuthResponseModel>> login({required String email, required String password}) async {
    _hasSession = true;
    _currentUser = UserModel(id: "1", name: "Alex", email: email);
    return ApiResponse.success(data: AuthResponseModel(success: true, accessToken: "mock_jwt_token", user: _currentUser));
  }

  @override
  Future<bool> restoreSession() async => _hasSession;

  @override
  Future<void> logout() async {
    _hasSession = false;
    _currentUser = null;
  }

  @override
  Future<void> clearSession() async {
    _hasSession = false;
    _currentUser = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
  });

  group('MockAuthRepository Tests', () {
    test('Logs in user and persists session', () async {
      final authRepo = MockAuthRepository();
      final res = await authRepo.login(email: "alex@lala.ai", password: "password123");

      expect(res.isSuccess, true);
      expect(res.data?.user?.email, "alex@lala.ai");

      final hasSession = await authRepo.restoreSession();
      expect(hasSession, true);
    });

    test('Logs out user and clears session', () async {
      final authRepo = MockAuthRepository();
      await authRepo.login(email: "alex@lala.ai", password: "password123");
      await authRepo.logout();

      final hasSession = await authRepo.restoreSession();
      expect(hasSession, false);
    });
  });

  group('MockChatRepository Tests', () {
    test('Initializes with seed chat sessions', () async {
      final repo = MockChatRepository();
      final chats = await repo.getChats();

      expect(chats.isNotEmpty, true);
      expect(chats.first.messages.isNotEmpty, true);
    });

    test('Creates new chat and sends messages with AI response', () async {
      final repo = MockChatRepository();
      final chat = await repo.createChat(initialMessage: "How do I write Flutter tests?");

      expect(chat.title.startsWith("How do I write"), true);

      final response = await repo.sendMessage(
        chatId: chat.id,
        message: "Can you show me sample code?",
      );

      expect(response.isAssistant, true);
      expect(response.content.isNotEmpty, true);
      expect(response.codeSnippets.isNotEmpty, true);
    });

    test('Renames and deletes chat', () async {
      final repo = MockChatRepository();
      final chat = await repo.createChat(title: "Old Title");

      final renamed = await repo.renameChat(chatId: chat.id, newTitle: "New Title");
      expect(renamed, true);

      final deleted = await repo.deleteChat(chat.id);
      expect(deleted, true);

      final check = await repo.getChat(chat.id);
      expect(check, null);
    });
  });

  group('ChatController Tests', () {
    test('Loads grouped chats correctly', () async {
      final repo = MockChatRepository();
      final controller = ChatController(repository: repo);

      await controller.loadChats();
      expect(controller.chats.isNotEmpty, true);

      final grouped = controller.groupedChats;
      expect(grouped.isNotEmpty, true);
    });
  });
}

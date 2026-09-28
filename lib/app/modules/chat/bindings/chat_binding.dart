import 'package:get/get.dart';
import 'package:lala_ai/app/modules/chat/controllers/chat_controller.dart';
import 'package:lala_ai/app/modules/chat/data/api_chat_repository.dart';
import 'package:lala_ai/app/modules/chat/data/chat_repository.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatRepository>(() => ApiChatRepository());
    Get.lazyPut<ChatController>(() => ChatController(repository: Get.find<ChatRepository>()));
  }
}

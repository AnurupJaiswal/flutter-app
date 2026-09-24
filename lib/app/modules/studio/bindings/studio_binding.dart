import 'package:get/get.dart';
import 'package:lala_ai/app/modules/studio/controllers/studio_controller.dart';
import 'package:lala_ai/app/modules/studio/data/studio_chat_repository.dart';

class StudioBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudioChatRepository>(() => MockStudioChatRepository());
    Get.lazyPut<StudioController>(() => StudioController(repository: Get.find<StudioChatRepository>()));
  }
}

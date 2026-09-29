import 'package:get/get.dart';
import 'package:lala_ai/app/modules/studio/controllers/studio_controller.dart';
import 'package:lala_ai/app/modules/studio/data/api_studio_chat_repository.dart';
import 'package:lala_ai/app/modules/studio/data/pixo_sse_repository.dart';
import 'package:lala_ai/app/modules/studio/data/studio_chat_repository.dart';

class StudioBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudioChatRepository>(() => ApiStudioChatRepository());
    Get.lazyPut<PixoSseRepository>(() => PixoSseRepository());
    Get.lazyPut<StudioController>(() => StudioController(
          repository: Get.find<StudioChatRepository>(),
          pixoRepo: Get.find<PixoSseRepository>(),
        ));
  }
}

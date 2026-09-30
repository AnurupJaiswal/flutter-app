import 'package:get/get.dart';
import 'package:lala_ai/app/modules/studio/controllers/studio_controller.dart';
import 'package:lala_ai/app/modules/studio/data/pixo_sse_repository.dart';

class StudioBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PixoSseRepository>(() => PixoSseRepository());
    Get.lazyPut<StudioController>(
      () => StudioController(pixoRepo: Get.find<PixoSseRepository>()),
    );
  }
}

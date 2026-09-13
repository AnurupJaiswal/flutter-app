import 'package:get/get.dart';
import 'package:lala_ai/app/modules/analytics/controllers/analytics_controller.dart';

class AnalyticsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AnalyticsController>()) {
      Get.lazyPut<AnalyticsController>(() => AnalyticsController());
    }
  }
}

import 'package:get/get.dart';
import 'package:lala_ai/Models/compare_creator_model.dart';
import 'package:lala_ai/networking/api_service.dart';
import 'package:lala_ai/utils/common_methods.dart';

class CompetitorController extends GetxController {
  final isLoading = false.obs;
  final compareData = Rxn<CompareCreatorModel>();
  final errorMessage = ''.obs;

  Future<void> compareWithCreator({
    required int accountId,
    required String competitorIdentifier,
    required String platform,
  }) async {
    if (competitorIdentifier.isEmpty) {
      CM.showToast('Please enter a competitor handle or URL');
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    compareData.value = null;

    final response = await ApiService.compareCreator(
      accountId: accountId,
      competitorIdentifier: competitorIdentifier,
      platform: platform,
    );

    isLoading.value = false;

    if (response.success && response.data != null) {
      compareData.value = response.data as CompareCreatorModel;
    } else {
      errorMessage.value = response.message.isNotEmpty
          ? response.message
          : 'Failed to compare creator. They may be private or unavailable.';
    }
  }
}

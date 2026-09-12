import 'package:get/get.dart';
import 'package:lala_ai/app/data/models/saved_model.dart';
import 'package:lala_ai/app/data/repositories/saved_repository.dart';
import 'package:lala_ai/utils/common_methods.dart';

class SavedController extends GetxController {
  final SavedRepository savedRepository;

  SavedController({required this.savedRepository});

  final savedItems = <SavedItemModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSavedItems();
  }

  Future<void> loadSavedItems() async {
    isLoading.value = true;
    final list = await savedRepository.getSavedItems();
    savedItems.assignAll(list);
    isLoading.value = false;
  }

  Future<void> removeItem(String id) async {
    await savedRepository.removeItem(id);
    savedItems.removeWhere((e) => e.id == id);
    CM.showToast("Item removed from bookmarks");
  }
}

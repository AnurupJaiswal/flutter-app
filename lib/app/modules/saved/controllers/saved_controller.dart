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
    final index = savedItems.indexWhere((e) => e.id == id);
    if (index == -1) return;
    final itemToRemove = savedItems[index];

    // 1. Optimistic removal (instant user feedback)
    savedItems.removeAt(index);
    CM.showToast("Item removed from bookmarks");

    // 2. Perform background network sync
    try {
      await savedRepository.removeItem(id);
    } catch (e) {
      // 3. Rollback on failure
      if (index <= savedItems.length) {
        savedItems.insert(index, itemToRemove);
      } else {
        savedItems.add(itemToRemove);
      }
      CM.showToast("Could not remove item. Please try again.", isError: true);
    }
  }
}


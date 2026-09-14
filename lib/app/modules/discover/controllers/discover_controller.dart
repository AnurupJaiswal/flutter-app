import 'package:get/get.dart';
import 'package:lala_ai/app/data/models/discover_model.dart';
import 'package:lala_ai/app/data/models/saved_model.dart';
import 'package:lala_ai/app/data/repositories/discover_repository.dart';
import 'package:lala_ai/app/data/repositories/saved_repository.dart';
import 'package:lala_ai/utils/common_methods.dart';

class DiscoverController extends GetxController {
  final DiscoverRepository discoverRepository;
  final SavedRepository savedRepository;

  DiscoverController({
    required this.discoverRepository,
    required this.savedRepository,
  });

  final searchQuery = ''.obs;
  final selectedCategory = 'All'.obs;
  final categories = ['All', 'AI', 'Technology', 'Finance', 'Science'].obs;
  final items = <DiscoverItemModel>[].obs;
  final isLoading = false.obs;
  final activeTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    search();
  }

  Future<void> search() async {
    isLoading.value = true;
    final list = await discoverRepository.getDiscoverItems(
      query: searchQuery.value,
      category: selectedCategory.value,
    );
    items.assignAll(list);
    isLoading.value = false;
  }

  void selectCategory(String cat) {
    selectedCategory.value = cat;
    search();
  }

  Future<void> bookmarkItem(DiscoverItemModel item) async {
    await savedRepository.saveItem(
      SavedItemModel(
        id: item.id,
        title: item.title,
        subtitle: item.description,
        category: item.category,
        type: item.type,
        savedAt: DateTime.now(),
      ),
    );
    CM.showToast("Saved to your workspace bookmarks");
  }
}

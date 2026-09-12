import 'package:lala_ai/app/data/models/discover_model.dart';
import 'package:lala_ai/app/data/models/saved_model.dart';

abstract class SavedRepository {
  Future<List<SavedItemModel>> getSavedItems();
  Future<bool> saveItem(SavedItemModel item);
  Future<bool> removeItem(String id);
}

class MockSavedRepository implements SavedRepository {
  final List<SavedItemModel> _savedItems = [
    SavedItemModel(
      id: "disc_1",
      title: "Building Multi-Agent Frameworks in 2026",
      subtitle: "A comprehensive analysis on state persistence and task routing.",
      category: "AI",
      type: DiscoverType.article,
      savedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    SavedItemModel(
      id: "trend_1",
      title: "Autonomous AI Agents",
      subtitle: "Multi-agent frameworks gain massive enterprise adoption.",
      category: "AI",
      type: DiscoverType.trend,
      savedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  @override
  Future<List<SavedItemModel>> getSavedItems() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.from(_savedItems);
  }

  @override
  Future<bool> saveItem(SavedItemModel item) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!_savedItems.any((e) => e.id == item.id)) {
      _savedItems.add(item);
    }
    return true;
  }

  @override
  Future<bool> removeItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _savedItems.removeWhere((item) => item.id == id);
    return true;
  }
}

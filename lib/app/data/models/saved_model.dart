import 'package:lala_ai/app/data/models/discover_model.dart';

class SavedItemModel {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final DiscoverType type;
  final DateTime savedAt;

  SavedItemModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.type,
    required this.savedAt,
  });
}

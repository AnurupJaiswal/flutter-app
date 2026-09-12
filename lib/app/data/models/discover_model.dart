enum DiscoverType { topic, trend, news, article, insight }

class DiscoverItemModel {
  final String id;
  final String title;
  final String description;
  final DiscoverType type;
  final String category;
  final String source;
  final DateTime publishedAt;
  final bool isSaved;

  DiscoverItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.source,
    required this.publishedAt,
    this.isSaved = false,
  });

  DiscoverItemModel copyWith({
    String? id,
    String? title,
    String? description,
    DiscoverType? type,
    String? category,
    String? source,
    DateTime? publishedAt,
    bool? isSaved,
  }) {
    return DiscoverItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      source: source ?? this.source,
      publishedAt: publishedAt ?? this.publishedAt,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

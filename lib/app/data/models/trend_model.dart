class TrendModel {
  final String id;
  final int rank;
  final String title;
  final String category;
  final double changePercentage;
  final String summary;
  final String? imageUrl;
  final String source;
  final DateTime createdAt;
  final bool isSaved;

  TrendModel({
    required this.id,
    required this.rank,
    required this.title,
    required this.category,
    required this.changePercentage,
    required this.summary,
    this.imageUrl,
    required this.source,
    required this.createdAt,
    this.isSaved = false,
  });

  TrendModel copyWith({
    String? id,
    int? rank,
    String? title,
    String? category,
    double? changePercentage,
    String? summary,
    String? imageUrl,
    String? source,
    DateTime? createdAt,
    bool? isSaved,
  }) {
    return TrendModel(
      id: id ?? this.id,
      rank: rank ?? this.rank,
      title: title ?? this.title,
      category: category ?? this.category,
      changePercentage: changePercentage ?? this.changePercentage,
      summary: summary ?? this.summary,
      imageUrl: imageUrl ?? this.imageUrl,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

class TrendDetailModel {
  final TrendModel trend;
  final String overview;
  final List<double> historicalScores;
  final String whyTrending;
  final List<String> relatedTopics;
  final List<String> keyInsights;

  TrendDetailModel({
    required this.trend,
    required this.overview,
    required this.historicalScores,
    required this.whyTrending,
    required this.relatedTopics,
    required this.keyInsights,
  });
}

class TrendModel {
  final String id;
  final int rank;
  final String name;
  final String category;
  final String platform;
  final double score;
  final String lifecycleStage;
  final double growthScore;
  final double velocityScore;
  final double confidenceScore;
  final DateTime calculatedAt;
  final String summary;
  final String? imageUrl;
  final bool isSaved;

  TrendModel({
    required this.id,
    this.rank = 1,
    required this.name,
    String? title,
    required this.category,
    String? platform,
    String? source,
    double? score,
    double? changePercentage,
    this.lifecycleStage = "RISING",
    this.growthScore = 0.0,
    this.velocityScore = 0.0,
    this.confidenceScore = 0.0,
    DateTime? calculatedAt,
    DateTime? createdAt,
    this.summary = "",
    this.imageUrl,
    this.isSaved = false,
  })  : platform = (platform ?? source ?? "ALL"),
        score = (score ?? changePercentage ?? 0.0),
        calculatedAt = (calculatedAt ?? createdAt ?? DateTime.now());

  // Backwards compatibility getters
  String get title => name;
  String get source => platform;
  double get changePercentage => score;
  DateTime get createdAt => calculatedAt;

  factory TrendModel.fromJson(Map<String, dynamic> json, {int? defaultRank}) {
    final rawId = json['id']?.toString() ?? '';
    final rawName = json['name']?.toString() ?? json['title']?.toString() ?? 'Trending Topic';
    final rawCategory = json['category']?.toString() ?? '';
    final rawPlatform = json['platform']?.toString() ?? json['source']?.toString() ?? 'YOUTUBE';
    
    final rawScore = (json['score'] as num?)?.toDouble() ??
        (json['changePercentage'] as num?)?.toDouble() ??
        0.0;
        
    final rawLifecycle = json['lifecycleStage']?.toString() ?? 'RISING';
    final rawGrowth = (json['growthScore'] as num?)?.toDouble() ?? 0.0;
    final rawVelocity = (json['velocityScore'] as num?)?.toDouble() ?? 0.0;
    final rawConfidence = (json['confidenceScore'] as num?)?.toDouble() ?? 0.0;

    DateTime? date;
    if (json['calculatedAt'] != null) {
      date = DateTime.tryParse(json['calculatedAt'].toString());
    } else if (json['createdAt'] != null) {
      date = DateTime.tryParse(json['createdAt'].toString());
    }

    String summaryText = json['summary']?.toString() ?? json['description']?.toString() ?? '';
    if (summaryText.isEmpty) {
      final stage = rawLifecycle.toUpperCase();
      final plat = rawPlatform.isNotEmpty
          ? (rawPlatform[0].toUpperCase() + rawPlatform.substring(1).toLowerCase())
          : rawPlatform;
      if (stage == 'EMERGING') {
        summaryText = "Early viral momentum detected on $plat with strong creator breakout potential.";
      } else if (stage == 'PEAKING') {
        summaryText = "High search volume and peak viral saturation across $plat right now.";
      } else {
        summaryText = "Rapidly accelerating topic on $plat with surging audience engagement and search velocity.";
      }
    }

    return TrendModel(
      id: rawId,
      rank: (json['rank'] as num?)?.toInt() ?? defaultRank ?? 1,
      name: rawName,
      category: rawCategory,
      platform: rawPlatform,
      score: rawScore,
      lifecycleStage: rawLifecycle,
      growthScore: rawGrowth,
      velocityScore: rawVelocity,
      confidenceScore: rawConfidence,
      calculatedAt: date ?? DateTime.now(),
      summary: summaryText,
      imageUrl: json['imageUrl']?.toString(),
      isSaved: json['isSaved'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'platform': platform,
      'score': score,
      'lifecycleStage': lifecycleStage,
      'growthScore': growthScore,
      'velocityScore': velocityScore,
      'confidenceScore': confidenceScore,
      'calculatedAt': calculatedAt.toIso8601String(),
      'summary': summary,
      'imageUrl': imageUrl,
      'rank': rank,
      'isSaved': isSaved,
    };
  }

  TrendModel copyWith({
    String? id,
    int? rank,
    String? name,
    String? title,
    String? category,
    String? platform,
    String? source,
    double? score,
    double? changePercentage,
    String? lifecycleStage,
    double? growthScore,
    double? velocityScore,
    double? confidenceScore,
    DateTime? calculatedAt,
    DateTime? createdAt,
    String? summary,
    String? imageUrl,
    bool? isSaved,
  }) {
    return TrendModel(
      id: id ?? this.id,
      rank: rank ?? this.rank,
      name: name ?? title ?? this.name,
      category: category ?? this.category,
      platform: platform ?? source ?? this.platform,
      score: score ?? changePercentage ?? this.score,
      lifecycleStage: lifecycleStage ?? this.lifecycleStage,
      growthScore: growthScore ?? this.growthScore,
      velocityScore: velocityScore ?? this.velocityScore,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      calculatedAt: calculatedAt ?? createdAt ?? this.calculatedAt,
      summary: summary ?? this.summary,
      imageUrl: imageUrl ?? this.imageUrl,
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

  factory TrendDetailModel.fromTrend(TrendModel trend) {
    return TrendDetailModel(
      trend: trend,
      overview:
          "${trend.name} is currently in the ${trend.lifecycleStage.toUpperCase()} stage on ${trend.platform.toUpperCase()} with an overall score of ${trend.score.toStringAsFixed(1)}. Growth trajectory is at ${trend.growthScore > 0 ? '+' : ''}${trend.growthScore.toStringAsFixed(1)}% with a velocity score of ${trend.velocityScore.toStringAsFixed(1)}.",
      historicalScores: [
        (trend.score * 0.6).clamp(0, 100),
        (trend.score * 0.72).clamp(0, 100),
        (trend.score * 0.85).clamp(0, 100),
        (trend.score * 0.93).clamp(0, 100),
        trend.score,
      ],
      whyTrending:
          "Algorithm spikes and high creator engagement across ${trend.platform} are accelerating discussion around ${trend.name}.",
      relatedTopics: [
        trend.category,
        "${trend.platform} Trends",
        "Viral Signals",
        "Audience Growth",
      ],
      keyInsights: [
        "Current lifecycle phase: ${trend.lifecycleStage.toUpperCase()}",
        "Confidence score: ${(trend.confidenceScore * 100).toStringAsFixed(0)}%",
        "Signal velocity index: ${trend.velocityScore.toStringAsFixed(1)}",
        if (trend.growthScore != 0) "Growth rate: ${trend.growthScore > 0 ? '+' : ''}${trend.growthScore.toStringAsFixed(1)}%",
      ],
    );
  }

  factory TrendDetailModel.fromJson(Map<String, dynamic> json) {
    TrendModel trendObj;
    if (json['trend'] is Map) {
      trendObj = TrendModel.fromJson(Map<String, dynamic>.from(json['trend'] as Map));
    } else {
      trendObj = TrendModel.fromJson(json);
    }

    final hist = <double>[];
    if (json['historicalScores'] is List) {
      for (final s in json['historicalScores'] as List) {
        if (s is num) hist.add(s.toDouble());
      }
    }

    final topics = <String>[];
    if (json['relatedTopics'] is List) {
      for (final t in json['relatedTopics'] as List) {
        topics.add(t.toString());
      }
    }

    final insights = <String>[];
    if (json['keyInsights'] is List) {
      for (final k in json['keyInsights'] as List) {
        insights.add(k.toString());
      }
    }

    return TrendDetailModel(
      trend: trendObj,
      overview: json['overview']?.toString() ??
          "${trendObj.name} has seen strong acceleration across ${trendObj.platform}.",
      historicalScores: hist.isNotEmpty ? hist : [40, 55, 70, 85, trendObj.score],
      whyTrending: json['whyTrending']?.toString() ??
          "Surging audience interest and algorithmic boost across ${trendObj.platform}.",
      relatedTopics: topics.isNotEmpty ? topics : [trendObj.category, "${trendObj.platform} Signals"],
      keyInsights: insights.isNotEmpty
          ? insights
          : [
              "Stage: ${trendObj.lifecycleStage}",
              "Velocity: ${trendObj.velocityScore.toStringAsFixed(1)}",
              "Confidence: ${(trendObj.confidenceScore * 100).toStringAsFixed(0)}%",
            ],
    );
  }
}

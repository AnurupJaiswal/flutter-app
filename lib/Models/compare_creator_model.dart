class CompareCreatorModel {
  final CreatorMetrics you;
  final CreatorMetrics competitor;

  CompareCreatorModel({
    required this.you,
    required this.competitor,
  });

  factory CompareCreatorModel.fromJson(Map<String, dynamic> json) {
    return CompareCreatorModel(
      you: CreatorMetrics.fromJson(json['you'] ?? {}),
      competitor: CreatorMetrics.fromJson(json['competitor'] ?? {}),
    );
  }
}

class CreatorMetrics {
  final int? subscribers;
  final int? totalContent;
  final double? avgViews;
  final double? avgLikes;
  final double? postingFrequencyPerWeek;
  final String? dataStatus;
  final String? calculatedAt;
  final int? sampleSize;
  final int? sampleWindowDays;

  CreatorMetrics({
    this.subscribers,
    this.totalContent,
    this.avgViews,
    this.avgLikes,
    this.postingFrequencyPerWeek,
    this.dataStatus,
    this.calculatedAt,
    this.sampleSize,
    this.sampleWindowDays,
  });

  factory CreatorMetrics.fromJson(Map<String, dynamic> json) {
    return CreatorMetrics(
      subscribers: _parseInt(json['subscribers']),
      totalContent: _parseInt(json['totalContent']),
      avgViews: _parseDouble(json['avgViews']),
      avgLikes: _parseDouble(json['avgLikes']),
      postingFrequencyPerWeek: _parseDouble(json['postingFrequencyPerWeek']),
      dataStatus: json['dataStatus']?.toString(),
      calculatedAt: json['calculatedAt']?.toString(),
      sampleSize: _parseInt(json['sampleSize']),
      sampleWindowDays: _parseInt(json['sampleWindowDays']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

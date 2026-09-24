class PublicDocumentModel {
  final String slug;
  final String title;
  final String contentHtml;
  final String version;
  final String? lastUpdated;

  PublicDocumentModel({
    required this.slug,
    required this.title,
    required this.contentHtml,
    required this.version,
    this.lastUpdated,
  });

  factory PublicDocumentModel.fromJson(Map<String, dynamic> json) {
    return PublicDocumentModel(
      slug: json['slug']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      contentHtml: json['contentHtml']?.toString() ?? json['htmlContent']?.toString() ?? '',
      version: json['version']?.toString() ?? '',
      lastUpdated: json['lastUpdated']?.toString(),
    );
  }
}

class PublicFaqModel {
  final dynamic id;
  final String question;
  final String answer;
  final String? answerHtml;
  final String category;
  final int sortOrder;
  final bool isActive;

  PublicFaqModel({
    this.id,
    required this.question,
    required this.answer,
    this.answerHtml,
    required this.category,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory PublicFaqModel.fromJson(Map<String, dynamic> json) {
    final rawHtml = json['answerHtml']?.toString() ??
        json['htmlContent']?.toString() ??
        json['contentHtml']?.toString();
    final rawAnswer = json['answer']?.toString() ?? '';

    // Clean / fallback text
    final effectiveAnswer = rawAnswer.isNotEmpty
        ? rawAnswer
        : (rawHtml != null ? _stripHtmlTags(rawHtml) : '');

    return PublicFaqModel(
      id: json['id'] ?? json['faqId'],
      question: json['question']?.toString() ?? json['title']?.toString() ?? '',
      answer: effectiveAnswer,
      answerHtml: rawHtml,
      category: json['category']?.toString() ?? 'General',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] != false,
    );
  }

  static String _stripHtmlTags(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

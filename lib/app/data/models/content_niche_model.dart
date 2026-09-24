class ContentNicheModel {
  final String title;

  const ContentNicheModel({
    required this.title,
  });

  /// Checks if this niche matches a given string
  bool matches(String? text) {
    if (text == null || text.trim().isEmpty) return false;
    final clean = text.trim().toLowerCase();
    return clean == title.toLowerCase();
  }
}

/// Curated list of creator content niches.
const List<ContentNicheModel> kContentNiches = [
  ContentNicheModel(title: "Tech & AI"),
  ContentNicheModel(title: "Gaming"),
  ContentNicheModel(title: "Technology"),
  ContentNicheModel(title: "Social Media"),
  ContentNicheModel(title: "Finance"),
  ContentNicheModel(title: "Business & Entrepreneurship"),
  ContentNicheModel(title: "Education"),
  ContentNicheModel(title: "Career & Jobs"),
  ContentNicheModel(title: "Self Improvement"),
  ContentNicheModel(title: "Fitness"),
  ContentNicheModel(title: "Health & Wellness"),
  ContentNicheModel(title: "Food & Cooking"),
  ContentNicheModel(title: "Travel"),
  ContentNicheModel(title: "Fashion"),
  ContentNicheModel(title: "Beauty & Makeup"),
  ContentNicheModel(title: "Home & Lifestyle"),
  ContentNicheModel(title: "Family & Parenting"),
  ContentNicheModel(title: "Pets & Animals"),
  ContentNicheModel(title: "Automotive"),
  ContentNicheModel(title: "Sports"),
  ContentNicheModel(title: "Music"),
  ContentNicheModel(title: "Entertainment"),
  ContentNicheModel(title: "Comedy"),
  ContentNicheModel(title: "Art & Creativity"),
  ContentNicheModel(title: "Photography"),
  ContentNicheModel(title: "Filmmaking"),
  ContentNicheModel(title: "DIY & Crafts"),
  ContentNicheModel(title: "Agriculture"),
  ContentNicheModel(title: "History & Culture"),
  ContentNicheModel(title: "Science"),
  ContentNicheModel(title: "News & Commentary"),
  ContentNicheModel(title: "Spirituality"),
  ContentNicheModel(title: "Books & Literature"),
  ContentNicheModel(title: "Science & Education"),
  ContentNicheModel(title: "Product Reviews"),
  ContentNicheModel(title: "Real Estate"),
  ContentNicheModel(title: "Law & Legal Education"),
  ContentNicheModel(title: "Programming"),
];

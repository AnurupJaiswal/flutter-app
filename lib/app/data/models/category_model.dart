class CategoryItemModel {
  final String id;
  final String code;
  final String name;
  final String? slug;
  final String? icon;
  final String? description;
  final bool isSubscribed;

  CategoryItemModel({
    required this.id,
    required this.code,
    required this.name,
    this.slug,
    this.icon,
    this.description,
    this.isSubscribed = false,
  });

  factory CategoryItemModel.fromJson(dynamic json) {
    if (json is String) {
      return CategoryItemModel(
        id: json,
        code: json,
        name: json,
        slug: json.toLowerCase().replaceAll(' ', '-'),
      );
    }
    if (json is Map) {
      final code = json['code']?.toString() ??
          json['id']?.toString() ??
          json['_id']?.toString() ??
          json['name']?.toString() ??
          '';
      final name = json['displayName']?.toString() ??
          json['name']?.toString() ??
          json['title']?.toString() ??
          json['categoryName']?.toString() ??
          code;
      final slug = json['slug']?.toString() ?? name.toLowerCase().replaceAll(' ', '-');
      final icon = json['icon']?.toString();
      final description = json['description']?.toString();
      final isSub = json['isSubscribed'] == true ||
          json['subscribed'] == true ||
          json['is_subscribed'] == true;

      return CategoryItemModel(
        id: code,
        code: code,
        name: name,
        slug: slug,
        icon: icon,
        description: description,
        isSubscribed: isSub,
      );
    }
    return CategoryItemModel(id: '', code: '', name: '');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'displayName': name,
      'name': name,
      'slug': slug,
      'icon': icon,
      'description': description,
      'isSubscribed': isSubscribed,
    };
  }
}

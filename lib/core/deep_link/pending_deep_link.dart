import 'package:lala_ai/core/deep_link/deep_link_type.dart';

/// Represents a queued deep link awaiting app readiness or user authentication.
class PendingDeepLink {
  final Uri uri;
  final DeepLinkType type;
  final List<String> segments;
  final Map<String, String> queryParameters;
  final DateTime createdAt;
  final bool requiresAuth;

  PendingDeepLink({
    required this.uri,
    required this.type,
    required this.segments,
    required this.queryParameters,
    required this.requiresAuth,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isExpired =>
      DateTime.now().difference(createdAt).inMinutes > 30; // 30-minute grace window

  @override
  String toString() =>
      'PendingDeepLink(type: $type, uri: $uri, requiresAuth: $requiresAuth, createdAt: $createdAt)';
}

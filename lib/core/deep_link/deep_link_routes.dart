import 'package:lala_ai/core/deep_link/deep_link_type.dart';

/// Routes and domain constants for deep linking in Lala AI.
class DeepLinkRoutes {
  DeepLinkRoutes._();

  /// CURRENT SUPPORTED DOMAIN ONLY
  /// Note: lalaai.in will be added in a future update.
  static const String supportedDomain = 'lala-ai-green.vercel.app';
  static const String devTunnelDomain = 'notifications-independently-marie-determined.trycloudflare.com';

  /// Custom URL scheme (legacy fallback)
  static const String customScheme = 'lala';

  /// Normalizes URI into a clean list of lowercased path segments.
  /// Handles both HTTPS (where host is domain and path contains route)
  /// and custom scheme (e.g. lala://subscription/success or lala:///subscription/success).
  static List<String> extractNormalizedSegments(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    final segments = <String>[];

    if (scheme == 'https' || scheme == 'http') {
      segments.addAll(
        uri.pathSegments.map((s) => s.trim().toLowerCase()).where((s) => s.isNotEmpty),
      );
    } else if (scheme == customScheme) {
      // For lala://subscription/success -> host='subscription', pathSegments=['success']
      // For lala:///subscription/success -> host='', pathSegments=['subscription', 'success']
      if (uri.host.isNotEmpty) {
        segments.add(uri.host.trim().toLowerCase());
      }
      segments.addAll(
        uri.pathSegments.map((s) => s.trim().toLowerCase()).where((s) => s.isNotEmpty),
      );
    } else {
      // Fallback
      segments.addAll(
        uri.pathSegments.map((s) => s.trim().toLowerCase()).where((s) => s.isNotEmpty),
      );
    }

    return segments;
  }

  /// Validates whether the incoming URI is authorized.
  static bool isValidDomainOrScheme(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    if (scheme == customScheme) {
      return true;
    }
    if (scheme == 'https' || scheme == 'http') {
      final host = uri.host.toLowerCase();
      // Allow production domain as well as trycloudflare dev tunnels for testing
      return host == supportedDomain ||
          host.endsWith('.trycloudflare.com') ||
          host == 'localhost' ||
          host == '127.0.0.1';
    }
    return false;
  }

  /// Parses normalized segments into a [DeepLinkType] and parameter payload.
  static DeepLinkType parseType(List<String> segments) {
    if (segments.isEmpty) return DeepLinkType.unknown;

    final first = segments[0];

    // 0. App Open Route: /open-app, /open, /app
    if (first == 'open-app' || first == 'open' || first == 'app') {
      return DeepLinkType.openApp;
    }

    // 1. Subscription Routes: /subscription/success, /subscription/failed, /subscription/pending
    if (first == 'subscription') {
      if (segments.length >= 2) {
        final subAction = segments[1];
        if (subAction == 'success') return DeepLinkType.subscriptionSuccess;
        if (subAction == 'failed' || subAction == 'cancel') return DeepLinkType.subscriptionFailed;
        if (subAction == 'pending') return DeepLinkType.subscriptionPending;
      }
      return DeepLinkType.unknown;
    }

    // 2. OAuth Routes: /oauth/youtube/callback, /oauth/instagram/callback
    if (first == 'oauth') {
      if (segments.length >= 3 && segments[2] == 'callback') {
        final provider = segments[1];
        if (provider == 'youtube') return DeepLinkType.oauthYoutube;
        if (provider == 'instagram') return DeepLinkType.oauthInstagram;
      }
      return DeepLinkType.unknown;
    }

    // 3. Password Reset: /auth/reset-password or /reset-password
    if ((first == 'auth' && segments.length >= 2 && segments[1] == 'reset-password') ||
        first == 'reset-password') {
      return DeepLinkType.resetPassword;
    }

    // 4. Content / Post: /content/{id} or /post/{id}
    if (first == 'content' && segments.length >= 2) {
      return DeepLinkType.content;
    }
    if (first == 'post' && segments.length >= 2) {
      return DeepLinkType.post;
    }

    // 5. Creator: /creator/{id}
    if (first == 'creator' && segments.length >= 2) {
      return DeepLinkType.creator;
    }

    // 6. Share: /share/{type}/{id} or /share/post/{id}
    if (first == 'share' && segments.length >= 2) {
      return DeepLinkType.share;
    }

    // 7. Invite / Referral: /invite/{code}
    if (first == 'invite' && segments.length >= 2) {
      return DeepLinkType.invite;
    }

    // 8. In-App Navigation Aliases
    if (first == 'settings') return DeepLinkType.settings;
    if (first == 'studio') return DeepLinkType.studio;
    if (first == 'trends' || first == 'trending') return DeepLinkType.trends;
    if (first == 'calendar') return DeepLinkType.calendar;
    if (first == 'discover' || first == 'radar' || first == 'competitor') return DeepLinkType.discover;
    if (first == 'connect-accounts' || first == 'connections') return DeepLinkType.connectAccounts;

    return DeepLinkType.unknown;
  }
}

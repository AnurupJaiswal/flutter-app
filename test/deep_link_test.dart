import 'package:flutter_test/flutter_test.dart';
import 'package:lala_ai/core/deep_link/deep_link_router.dart';
import 'package:lala_ai/core/deep_link/deep_link_routes.dart';
import 'package:lala_ai/core/deep_link/deep_link_type.dart';
import 'package:lala_ai/networking/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeepLinkRoutes Domain & Segment Parsing Tests', () {
    test('Validates current domain https://lala-ai-green.vercel.app', () {
      final validHttps = Uri.parse('https://lala-ai-green.vercel.app/open-app');
      expect(DeepLinkRoutes.isValidDomainOrScheme(validHttps), isTrue);
    });

    test('Validates custom scheme lala://', () {
      final validCustomScheme = Uri.parse('lala://subscription/success?orderId=TEST123');
      expect(DeepLinkRoutes.isValidDomainOrScheme(validCustomScheme), isTrue);
    });

    test('Rejects unauthorized external domains', () {
      final invalidDomain = Uri.parse('https://evil-phishing.com/subscription/success');
      expect(DeepLinkRoutes.isValidDomainOrScheme(invalidDomain), isFalse);

      final futureDomainNotYetConfigured = Uri.parse('https://lalaai.in/subscription/success');
      expect(DeepLinkRoutes.isValidDomainOrScheme(futureDomainNotYetConfigured), isFalse);
    });

    test('Extracts normalized segments for HTTPS URLs', () {
      final uri = Uri.parse('https://lala-ai-green.vercel.app/open-app?orderId=ORD123');
      final segments = DeepLinkRoutes.extractNormalizedSegments(uri);
      expect(segments, equals(['open-app']));
    });

    test('Parses 0. /open-app to DeepLinkType.openApp', () {
      final uri = Uri.parse('https://lala-ai-green.vercel.app/open-app');
      final segments = DeepLinkRoutes.extractNormalizedSegments(uri);
      expect(DeepLinkRoutes.parseType(segments), equals(DeepLinkType.openApp));
    });

    test('Parses 0b. /open-app?orderId=ORD123 to DeepLinkType.openApp', () {
      final uri = Uri.parse('https://lala-ai-green.vercel.app/open-app?orderId=ORD123');
      final segments = DeepLinkRoutes.extractNormalizedSegments(uri);
      expect(DeepLinkRoutes.parseType(segments), equals(DeepLinkType.openApp));
    });

    test('Parses 1. /subscription/success', () {
      final uri = Uri.parse('https://lala-ai-green.vercel.app/subscription/success?orderId=TEST123');
      final segments = DeepLinkRoutes.extractNormalizedSegments(uri);
      expect(DeepLinkRoutes.parseType(segments), equals(DeepLinkType.subscriptionSuccess));
    });

    test('Parses 2. /subscription/failed', () {
      final uri = Uri.parse('https://lala-ai-green.vercel.app/subscription/failed?orderId=TEST123');
      final segments = DeepLinkRoutes.extractNormalizedSegments(uri);
      expect(DeepLinkRoutes.parseType(segments), equals(DeepLinkType.subscriptionFailed));
    });

    test('Parses 3. /subscription/pending', () {
      final uri = Uri.parse('https://lala-ai-green.vercel.app/subscription/pending?orderId=TEST123');
      final segments = DeepLinkRoutes.extractNormalizedSegments(uri);
      expect(DeepLinkRoutes.parseType(segments), equals(DeepLinkType.subscriptionPending));
    });

    test('Parses 4. /oauth/youtube/callback', () {
      final uri = Uri.parse('https://lala-ai-green.vercel.app/oauth/youtube/callback?code=TEST&state=TEST');
      final segments = DeepLinkRoutes.extractNormalizedSegments(uri);
      expect(DeepLinkRoutes.parseType(segments), equals(DeepLinkType.oauthYoutube));
    });

    test('Parses 5. /oauth/instagram/callback', () {
      final uri = Uri.parse('https://lala-ai-green.vercel.app/oauth/instagram/callback?code=TEST&state=TEST');
      final segments = DeepLinkRoutes.extractNormalizedSegments(uri);
      expect(DeepLinkRoutes.parseType(segments), equals(DeepLinkType.oauthInstagram));
    });

    test('Parses 6. /content/123', () {
      final uri = Uri.parse('https://lala-ai-green.vercel.app/content/123');
      final segments = DeepLinkRoutes.extractNormalizedSegments(uri);
      expect(DeepLinkRoutes.parseType(segments), equals(DeepLinkType.content));
      expect(segments[1], equals('123'));
    });

    test('Parses 7. /post/123', () {
      final uri = Uri.parse('https://lala-ai-green.vercel.app/post/123');
      final segments = DeepLinkRoutes.extractNormalizedSegments(uri);
      expect(DeepLinkRoutes.parseType(segments), equals(DeepLinkType.post));
      expect(segments[1], equals('123'));
    });

    test('Parses 8. /creator/123', () {
      final uri = Uri.parse('https://lala-ai-green.vercel.app/creator/123');
      final segments = DeepLinkRoutes.extractNormalizedSegments(uri);
      expect(DeepLinkRoutes.parseType(segments), equals(DeepLinkType.creator));
      expect(segments[1], equals('123'));
    });

    test('Parses 9. /share/post/123', () {
      final uri = Uri.parse('https://lala-ai-green.vercel.app/share/post/123');
      final segments = DeepLinkRoutes.extractNormalizedSegments(uri);
      expect(DeepLinkRoutes.parseType(segments), equals(DeepLinkType.share));
      expect(segments[1], equals('post'));
      expect(segments[2], equals('123'));
    });

    test('Parses 10. /invite/ABC123', () {
      final uri = Uri.parse('https://lala-ai-green.vercel.app/invite/ABC123');
      final segments = DeepLinkRoutes.extractNormalizedSegments(uri);
      expect(DeepLinkRoutes.parseType(segments), equals(DeepLinkType.invite));
      expect(segments[1], equals('abc123'));
    });

    test('Parses password reset links /auth/reset-password', () {
      final uri = Uri.parse('https://lala-ai-green.vercel.app/auth/reset-password?token=XYZ_TOKEN');
      final segments = DeepLinkRoutes.extractNormalizedSegments(uri);
      expect(DeepLinkRoutes.parseType(segments), equals(DeepLinkType.resetPassword));
    });

    test('Handles malformed / empty / unknown paths gracefully', () {
      final emptyUri = Uri.parse('https://lala-ai-green.vercel.app/');
      expect(DeepLinkRoutes.parseType(DeepLinkRoutes.extractNormalizedSegments(emptyUri)), equals(DeepLinkType.unknown));

      final unknownUri = Uri.parse('https://lala-ai-green.vercel.app/unknown/path/test');
      expect(DeepLinkRoutes.parseType(DeepLinkRoutes.extractNormalizedSegments(unknownUri)), equals(DeepLinkType.unknown));
    });
  });

  group('DeepLinkRouter Lifecycle & Pending Link Tests', () {
    setUp(() {
      DeepLinkRouter.clearPendingLink();
      DeepLinkRouter.setAppReady(ready: false);
      ApiService.token = null;
    });

    test('Queues open-app with orderId when app is not yet ready (Cold Start)', () async {
      final uri = Uri.parse('https://lala-ai-green.vercel.app/open-app?orderId=ORD123');
      final routed = await DeepLinkRouter.routeUri(uri, isColdStart: true);

      expect(routed, isTrue);
      expect(DeepLinkRouter.pendingLink, isNotNull);
      expect(DeepLinkRouter.pendingLink!.type, equals(DeepLinkType.openApp));
      expect(DeepLinkRouter.pendingLink!.queryParameters['orderId'], equals('ORD123'));
    });

    test('Queues protected link when user is unauthenticated', () async {
      DeepLinkRouter.setAppReady(ready: true);
      ApiService.token = null;

      final uri = Uri.parse('https://lala-ai-green.vercel.app/content/123');
      final routed = await DeepLinkRouter.routeUri(uri);

      expect(routed, isTrue);
      expect(DeepLinkRouter.pendingLink, isNotNull);
      expect(DeepLinkRouter.pendingLink!.type, equals(DeepLinkType.content));
      expect(DeepLinkRouter.pendingLink!.requiresAuth, isTrue);
    });

    test('Rejects unauthorized domain without queuing or crashing', () async {
      final uri = Uri.parse('https://external-domain.com/content/123');
      final routed = await DeepLinkRouter.routeUri(uri);

      expect(routed, isFalse);
      expect(DeepLinkRouter.pendingLink, isNull);
    });
  });
}

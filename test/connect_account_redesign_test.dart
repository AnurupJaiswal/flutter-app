import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/connect_accounts/widgets/connect_account_hero_widget.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    if (!Get.isRegistered<ThemeService>()) {
      Get.put<ThemeService>(ThemeService());
    }
  });

  tearDown(() {
    Get.reset();
  });

  Widget buildTestWidget({
    VoidCallback? onConnectInstagram,
    VoidCallback? onConnectYouTube,
    bool isLoading = false,
    bool isDark = false,
  }) {
    return GetMaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        body: SingleChildScrollView(
          child: ConnectAccountHeroWidget(
            onConnectInstagram: onConnectInstagram ?? () {},
            onConnectYouTube: onConnectYouTube ?? () {},
            isLoading: isLoading,
          ),
        ),
      ),
    );
  }

  group('ConnectAccountHeroWidget Redesign Tests', () {
    testWidgets('Renders single primary Connect Account CTA and key sections', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // 1. Verify main heading and subtitle
      expect(find.text('Connect your'), findsOneWidget);
      expect(find.text('social account'), findsOneWidget);
      expect(
        find.text('Connect your Instagram or YouTube to start viewing your content performance and analytics.'),
        findsOneWidget,
      );

      // 2. Verify floating orbital badges
      expect(find.text('Track Performance'), findsOneWidget);
      expect(find.text('Get Insights'), findsOneWidget);
      expect(find.text('Grow Faster'), findsOneWidget);
      expect(find.text('Reach More People'), findsOneWidget);

      // 3. Verify ONLY ONE primary CTA "Connect Account"
      expect(find.text('Connect Account'), findsOneWidget);
      expect(find.text('Connect Instagram'), findsNothing);
      expect(find.text('Connect YouTube'), findsNothing);

      // 4. Verify 3-Step Horizontal Flow & Caption
      expect(find.text('Connect'), findsOneWidget);
      expect(find.text('Analyze'), findsOneWidget);
      expect(find.text('Grow'), findsOneWidget);
      expect(
        find.text('Connect your platform and let Lala turn your content data into actionable insights.'),
        findsOneWidget,
      );
    });

    testWidgets('Tapping primary Connect Account button opens platform selection bottom sheet', (WidgetTester tester) async {
      bool instagramTapped = false;
      bool youTubeTapped = false;

      await tester.pumpWidget(buildTestWidget(
        onConnectInstagram: () => instagramTapped = true,
        onConnectYouTube: () => youTubeTapped = true,
      ));
      await tester.pumpAndSettle();

      // Bottom sheet should NOT be present initially
      expect(find.text('Connect a platform'), findsNothing);

      // Tap the single primary CTA
      await tester.tap(find.text('Connect Account'));
      await tester.pumpAndSettle();

      // Verify bottom sheet title and options
      expect(find.text('Connect a platform'), findsOneWidget);
      expect(find.text('Choose the account you want to connect'), findsOneWidget);
      expect(find.text('Instagram'), findsWidgets);
      expect(find.text('Connect your Instagram account'), findsOneWidget);
      expect(find.text('YouTube'), findsWidgets);
      expect(find.text('Connect your YouTube channel'), findsOneWidget);

      // Tap Instagram card
      await tester.tap(find.text('Connect your Instagram account'));
      await tester.pumpAndSettle();

      expect(instagramTapped, isTrue);
      expect(youTubeTapped, isFalse);
      // Bottom sheet should be dismissed
      expect(find.text('Connect a platform'), findsNothing);
    });

    testWidgets('Selecting YouTube from bottom sheet triggers YouTube connection callback', (WidgetTester tester) async {
      bool youTubeTapped = false;

      await tester.pumpWidget(buildTestWidget(
        onConnectYouTube: () => youTubeTapped = true,
      ));
      await tester.pumpAndSettle();

      // Open bottom sheet
      await tester.tap(find.text('Connect Account'));
      await tester.pumpAndSettle();

      // Tap YouTube card
      await tester.tap(find.text('Connect your YouTube channel'));
      await tester.pumpAndSettle();

      expect(youTubeTapped, isTrue);
      expect(find.text('Connect a platform'), findsNothing);
    });

    testWidgets('Supports Dark Mode without overflow', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 812)); // Standard iPhone size
      await tester.pumpWidget(buildTestWidget(isDark: true));
      await tester.pumpAndSettle();

      expect(find.text('Connect Account'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Supports Small Screen without overflow', (WidgetTester tester) async {
      FlutterErrorDetails? caughtDetails;
      final oldOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        caughtDetails = details;
        oldOnError?.call(details);
      };

      await tester.binding.setSurfaceSize(const Size(320, 568)); // Small screen (SE 1st gen)
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      FlutterError.onError = oldOnError;

      if (caughtDetails != null) {
        debugPrint("CAUGHT ERROR DETAILS: ${caughtDetails!.toString()}");
      }
      expect(find.text('Connect Account'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

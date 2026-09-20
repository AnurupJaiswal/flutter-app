import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/main_container/widgets/pixo_overlay_widget.dart';
import 'package:lala_ai/app/navigation/app_navigation_service.dart';
import 'package:lala_ai/app/routes/app_pages.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
    if (!Get.isRegistered<ThemeService>()) {
      final service = ThemeService();
      await service.init();
      Get.put<ThemeService>(service, permanent: true);
    }
    if (!Get.isRegistered<AppNavigationService>()) {
      Get.put<AppNavigationService>(AppNavigationService(), permanent: true);
    }
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('PixoOverlayWidget renders within safe area bounds and responds to gestures', (WidgetTester tester) async {
    // Set a phone screen with status bar and bottom gesture inset
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0; // Logical size: 360 x 800
    tester.view.padding = const FakeViewPadding(top: 132, bottom: 102); // top: 44dp, bottom: 34dp

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetPadding();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        getPages: AppPages.routes,
        home: const MediaQuery(
          data: MediaQueryData(
            size: Size(360, 800),
            padding: EdgeInsets.only(top: 44, bottom: 34),
            viewPadding: EdgeInsets.only(top: 44, bottom: 34),
          ),
          child: Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                SizedBox.expand(),
                PixoOverlayWidget(),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify Pixo normal widget is found
    expect(find.byKey(const ValueKey('normal')), findsOneWidget);

    final pixoFinder = find.byKey(const ValueKey('normal'));
    final initialTopLeft = tester.getTopLeft(pixoFinder);

    // Assert top position is strictly below the status bar (44dp top inset + 14dp margin = 58dp)
    expect(initialTopLeft.dy, greaterThanOrEqualTo(58.0));

    // Drag Pixo upwards towards status bar
    await tester.drag(pixoFinder, const Offset(0, -500));
    await tester.pump(const Duration(milliseconds: 100));

    final draggedTopLeft = tester.getTopLeft(pixoFinder);

    // Verify it is clamped and NEVER goes above status bar (minY = 58.0)
    expect(draggedTopLeft.dy, greaterThanOrEqualTo(58.0));

    // Drag Pixo across to left edge
    await tester.drag(pixoFinder, const Offset(-300, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verify it snaps to safe left margin (>= 14.0)
    final snappedTopLeft = tester.getTopLeft(pixoFinder);
    expect(snappedTopLeft.dx, greaterThanOrEqualTo(14.0));
  });

  testWidgets('PixoOverlayWidget handles orientation resize and maintains clamped position', (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        getPages: AppPages.routes,
        home: const MediaQuery(
          data: MediaQueryData(
            size: Size(800, 360), // Landscape
            padding: EdgeInsets.only(top: 24, bottom: 20, left: 40, right: 40),
            viewPadding: EdgeInsets.only(top: 24, bottom: 20, left: 40, right: 40),
          ),
          child: Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                SizedBox.expand(),
                PixoOverlayWidget(),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify Pixo normal widget is found in landscape
    expect(find.byKey(const ValueKey('normal')), findsOneWidget);

    final pixoFinder = find.byKey(const ValueKey('normal'));
    final landscapeTopLeft = tester.getTopLeft(pixoFinder);

    // In landscape with 40dp left/right padding, ensure it respects left/right safe insets
    expect(landscapeTopLeft.dx, greaterThanOrEqualTo(54.0)); // 40 + 14 = 54
    expect(landscapeTopLeft.dy, greaterThanOrEqualTo(38.0)); // 24 + 14 = 38
  });
}

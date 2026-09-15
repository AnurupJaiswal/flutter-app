import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';
import 'package:lala_ai/app/routes/app_pages.dart';
import 'package:lala_ai/utils/theme/app_theme.dart';
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
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(() => ApiAuthRepository());
    }
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('Splash view displays app subtitle check', (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        title: "Lala Ai",
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
        theme: AppTheme.lightTheme(),
      ),
    );

    await tester.pump();

    // Verify subtitle text on Splash
    expect(find.text("AI-Powered Creator Operating System"), findsOneWidget);

    // Pump timer so pending timer is completed before test ends
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('Splash navigates to Login when no active session exists', (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        title: "Lala Ai",
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
        theme: AppTheme.lightTheme(),
      ),
    );

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify Login / Sign In view is displayed
    expect(find.text("Sign in to continue to your workspace"), findsOneWidget);
    expect(find.text("Sign In"), findsWidgets);
  });

  testWidgets('Splash navigates to Home when valid session exists', (WidgetTester tester) async {
    final authRepo = Get.find<AuthRepository>();
    await authRepo.login(email: "creator@lala.ai", password: "password123");

    await tester.pumpWidget(
      GetMaterialApp(
        title: "Lala Ai",
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
        theme: AppTheme.lightTheme(),
      ),
    );

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify Home / Main Container is displayed
    expect(find.text("Lala Ai"), findsWidgets);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';
import 'package:lala_ai/app/modules/settings/views/settings_view.dart';
import 'package:lala_ai/app/modules/settings/controllers/settings_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  group('ThemeService Tests', () {
    test('Defaults to system when no saved preference exists', () async {
      SharedPreferences.setMockInitialValues({});
      final themeService = ThemeService();
      await themeService.init();
      Get.put<ThemeService>(themeService, permanent: true);

      expect(themeService.currentThemeSetting, equals(ThemeService.themeSystem));
      expect(themeService.themeMode, equals(ThemeMode.system));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(ThemeService.themeKey), equals(ThemeService.themeSystem));
    });

    test('Loads saved light preference correctly', () async {
      SharedPreferences.setMockInitialValues({
        ThemeService.themeKey: ThemeService.themeLight,
      });
      final themeService = ThemeService();
      await themeService.init();
      Get.put<ThemeService>(themeService, permanent: true);

      expect(themeService.currentThemeSetting, equals(ThemeService.themeLight));
      expect(themeService.themeMode, equals(ThemeMode.light));
      expect(themeService.isDarkMode, isFalse);
    });

    test('Loads saved dark preference correctly', () async {
      SharedPreferences.setMockInitialValues({
        ThemeService.themeKey: ThemeService.themeDark,
      });
      final themeService = ThemeService();
      await themeService.init();
      Get.put<ThemeService>(themeService, permanent: true);

      expect(themeService.currentThemeSetting, equals(ThemeService.themeDark));
      expect(themeService.themeMode, equals(ThemeMode.dark));
      expect(themeService.isDarkMode, isTrue);
    });

    test('setThemeMode updates state, persistence, and dynamic CC tokens', () async {
      SharedPreferences.setMockInitialValues({});
      final themeService = ThemeService();
      await themeService.init();
      Get.put<ThemeService>(themeService, permanent: true);

      // Switch to Dark
      await themeService.setThemeMode(ThemeService.themeDark);
      expect(themeService.currentThemeSetting, equals(ThemeService.themeDark));
      expect(themeService.themeMode, equals(ThemeMode.dark));
      expect(themeService.isDarkMode, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(ThemeService.themeKey), equals(ThemeService.themeDark));

      // Verify Approved Dark Colors
      expect(CC.primary, equals(const Color(0xFF108CFF)));
      expect(CC.background, equals(const Color(0xFF000000)));
      expect(CC.surface, equals(const Color(0xFF000000)));
      expect(CC.stroke, equals(const Color(0xFF515151)));
      expect(CC.textPrimary, equals(const Color(0xFFFFFFFF)));
      expect(CC.textSecondary, equals(const Color(0xFFC7C7C7)));
      expect(CC.error, equals(const Color(0xFFFF1010)));
      expect(CC.success, equals(const Color(0xFF10FF10)));

      // Switch to Light
      await themeService.setThemeMode(ThemeService.themeLight);
      expect(themeService.currentThemeSetting, equals(ThemeService.themeLight));
      expect(themeService.themeMode, equals(ThemeMode.light));
      expect(themeService.isDarkMode, isFalse);
      expect(prefs.getString(ThemeService.themeKey), equals(ThemeService.themeLight));

      // Verify Approved Light Colors
      expect(CC.primary, equals(const Color(0xFF108CFF)));
      expect(CC.secondary, equals(const Color(0xFF222222)));
      expect(CC.background, equals(const Color(0xFFFFFFFF)));
      expect(CC.surface, equals(const Color(0xFFFFFFFF)));
      expect(CC.disabled, equals(const Color(0xFFC0C8C9)));
      expect(CC.textPrimary, equals(const Color(0xFF000000)));
      expect(CC.textSecondary, equals(const Color(0xFF465D61)));
      expect(CC.stroke, equals(const Color(0xFFD1D1D1)));
      expect(CC.commentStroke, equals(const Color(0xFFC8C8C8)));
      expect(CC.notification, equals(const Color(0xFFFF1010)));
      expect(CC.error, equals(const Color(0xFFFF1010)));
      expect(CC.success, equals(const Color(0xFF10FF10)));
      expect(CC.insightful, equals(const Color(0xFF966E00)));

      // Switch back to System
      await themeService.setThemeMode(ThemeService.themeSystem);
      expect(themeService.currentThemeSetting, equals(ThemeService.themeSystem));
      expect(themeService.themeMode, equals(ThemeMode.system));
      expect(prefs.getString(ThemeService.themeKey), equals(ThemeService.themeSystem));
    });
  });

  group('System Theme Mode Synchronization Test Cases 1-6', () {
    testWidgets('Case 1: System selected + device Light -> Light UI', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      SharedPreferences.setMockInitialValues({});
      final themeService = ThemeService();
      await themeService.init();
      Get.put<ThemeService>(themeService, permanent: true);

      expect(themeService.currentThemeSetting, equals(ThemeService.themeSystem));
      expect(themeService.effectiveBrightness, equals(Brightness.light));
      expect(themeService.isDarkMode, isFalse);
      expect(CC.background, equals(const Color(0xFFFFFFFF)));
    });

    testWidgets('Case 2 & 3: System selected + device changes Light -> Dark -> Light', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      SharedPreferences.setMockInitialValues({});
      final themeService = ThemeService();
      await themeService.init();
      Get.put<ThemeService>(themeService, permanent: true);

      // System changes to Dark
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      themeService.didChangePlatformBrightness();
      await tester.pumpAndSettle();

      expect(themeService.currentThemeSetting, equals(ThemeService.themeSystem));
      expect(themeService.effectiveBrightness, equals(Brightness.dark));
      expect(themeService.isDarkMode, isTrue);
      expect(CC.background, equals(const Color(0xFF000000)));

      // System changes back to Light
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      themeService.didChangePlatformBrightness();
      await tester.pumpAndSettle();

      expect(themeService.currentThemeSetting, equals(ThemeService.themeSystem));
      expect(themeService.effectiveBrightness, equals(Brightness.light));
      expect(themeService.isDarkMode, isFalse);
      expect(CC.background, equals(const Color(0xFFFFFFFF)));
    });

    testWidgets('Case 4: Light selected -> device changes to Dark -> App remains Light', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      SharedPreferences.setMockInitialValues({});
      final themeService = ThemeService();
      await themeService.init();
      Get.put<ThemeService>(themeService, permanent: true);

      await themeService.setThemeMode(ThemeService.themeLight);

      // System changes to Dark
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      themeService.didChangePlatformBrightness();
      await tester.pumpAndSettle();

      expect(themeService.currentThemeSetting, equals(ThemeService.themeLight));
      expect(themeService.effectiveBrightness, equals(Brightness.light));
      expect(themeService.isDarkMode, isFalse);
    });

    testWidgets('Case 5: Dark selected -> device changes to Light -> App remains Dark', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      SharedPreferences.setMockInitialValues({});
      final themeService = ThemeService();
      await themeService.init();
      Get.put<ThemeService>(themeService, permanent: true);

      await themeService.setThemeMode(ThemeService.themeDark);

      // System changes to Light
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      themeService.didChangePlatformBrightness();
      await tester.pumpAndSettle();

      expect(themeService.currentThemeSetting, equals(ThemeService.themeDark));
      expect(themeService.effectiveBrightness, equals(Brightness.dark));
      expect(themeService.isDarkMode, isTrue);
    });

    testWidgets('Case 6: System selected -> app backgrounded -> system changes -> app resumed', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      SharedPreferences.setMockInitialValues({});
      final themeService = ThemeService();
      await themeService.init();
      Get.put<ThemeService>(themeService, permanent: true);

      // App backgrounded, system changes to Dark
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;

      // App resumed
      themeService.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(themeService.currentThemeSetting, equals(ThemeService.themeSystem));
      expect(themeService.effectiveBrightness, equals(Brightness.dark));
      expect(themeService.isDarkMode, isTrue);
      expect(CC.background, equals(const Color(0xFF000000)));
    });
  });

  group('Settings Appearance Widget Tests', () {
    testWidgets('SettingsView displays Appearance section and opens theme selector', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final themeService = ThemeService();
      await themeService.init();
      Get.put<ThemeService>(themeService, permanent: true);
      Get.put<SettingsController>(SettingsController(authRepository: ApiAuthRepository()));

      await tester.pumpWidget(
        GetMaterialApp(
          home: const SettingsView(),
        ),
      );
      await tester.pumpAndSettle();

      // Check section label and theme tile
      expect(find.text("Appearance"), findsWidgets);
      expect(find.text("Theme"), findsOneWidget);
      expect(find.text("System Default"), findsOneWidget);

      // Tap theme tile to open bottom sheet
      await tester.tap(find.text("Theme"));
      await tester.pumpAndSettle();

      // Bottom sheet should display options
      expect(find.text("Appearance Theme"), findsOneWidget);
      expect(find.text("Light Mode"), findsOneWidget);
      expect(find.text("Dark Mode"), findsOneWidget);

      // Tap "Dark Mode"
      await tester.tap(find.text("Dark Mode"));
      await tester.pumpAndSettle();

      // Tap "Apply Theme"
      await tester.tap(find.text("Apply Theme"));
      await tester.pumpAndSettle();

      // Theme mode should now be dark
      expect(themeService.currentThemeSetting, equals(ThemeService.themeDark));
      expect(themeService.isDarkMode, isTrue);

      // SettingsView should now display "Dark" as current selection
      expect(find.text("Dark"), findsOneWidget);
    });
  });
}

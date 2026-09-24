import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';
import 'package:lala_ai/app/routes/app_pages.dart';
import 'package:lala_ai/utils/theme/app_theme.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';
import 'package:lala_ai/Models/auth_response_model.dart';
import 'package:lala_ai/networking/api_response.dart';
import 'package:lala_ai/networking/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAuthRepository implements AuthRepository {
  bool hasSession = false;

  @override
  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      ApiService.token = token;
      return true;
    }
    ApiService.token = null;
    return false;
  }

  @override
  Future<ApiResponse<AuthResponseModel>> login({required String email, required String password}) async {
    hasSession = true;
    return ApiResponse.success(data: null);
  }

  @override
  Future<void> logout() async {
    hasSession = false;
  }

  @override
  Future<void> clearSession() async {
    hasSession = false;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeAuthRepository fakeAuthRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
    fakeAuthRepo = FakeAuthRepository();
    Get.put<AuthRepository>(fakeAuthRepo);
    if (!Get.isRegistered<ThemeService>()) {
      final service = ThemeService();
      await service.init();
      Get.put<ThemeService>(service, permanent: true);
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

    // Verify Welcome view is displayed when no session exists
    expect(find.text("Get Started on Website"), findsWidgets);
  });

  testWidgets('Session restore correctly identifies stored token', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', 'mock_jwt_token_creator_123');
    await prefs.setString('user_data', '{"id":"1","name":"Creator","email":"creator@lala.ai"}');

    final hasValidSession = await fakeAuthRepo.restoreSession();
    expect(hasValidSession, isTrue);
    expect(ApiService.isAuthenticated, isTrue);
  });
}

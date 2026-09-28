import 'package:lala_ai/app/modules/splash/bindings/splash_binding.dart';
import 'package:lala_ai/app/modules/splash/views/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/routes/app_pages.dart';
import 'package:lala_ai/utils/keyboard_dismiss_wrapper.dart';
import 'package:lala_ai/core/deep_link/deep_link_service.dart';
import 'package:lala_ai/utils/theme/app_theme.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Production Crash Prevention: Gracefully handle any unexpected render errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const Material(
      color: Colors.transparent,
      child: SizedBox.shrink(),
    );
  };

  // Low-end / Cross-device memory management: restrict imageCache to prevent OOM
  PaintingBinding.instance.imageCache.maximumSize = 100;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 40 * 1024 * 1024; // 40MB max cache buffer

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final themeService = ThemeService();
  await themeService.init();
  Get.put<ThemeService>(themeService, permanent: true);

  final deepLinkService = DeepLinkService();
  await deepLinkService.init();
  Get.put<DeepLinkService>(deepLinkService, permanent: true);

  runApp(
    GetBuilder<ThemeService>(
      builder: (service) => GetMaterialApp(
        title: "Lala Ai",
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
        unknownRoute: GetPage(
          name: '/notfound',
          page: () => const SplashView(),
          binding: SplashBinding(),
        ),
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(fontFamily: "Poppins"),
        darkTheme: AppTheme.darkTheme(fontFamily: "Poppins"),
        themeMode: service.themeMode,
        builder: (context, child) {
          return KeyboardDismissWrapper(
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    ),
  );
}

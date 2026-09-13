import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/routes/app_pages.dart';
import 'package:lala_ai/utils/keyboard_dismiss_wrapper.dart';
import 'package:lala_ai/utils/theme/app_theme.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final themeService = ThemeService();
  await themeService.init();
  Get.put<ThemeService>(themeService, permanent: true);

  runApp(
    GetBuilder<ThemeService>(
      builder: (service) => GetMaterialApp(
        key: ValueKey('${service.currentThemeSetting}_${service.effectiveBrightness.name}'),
        title: "Lala Ai",
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(fontFamily: "Gilroy"),
        darkTheme: AppTheme.darkTheme(fontFamily: "Gilroy"),
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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends GetxController with WidgetsBindingObserver {
  static ThemeService get to => Get.find<ThemeService>();

  static const String themeKey = 'app_theme_mode';
  static const String themeLight = 'light';
  static const String themeDark = 'dark';
  static const String themeSystem = 'system';

  final RxString _currentThemeSetting = themeSystem.obs;
  final RxInt rxThemeVersion = 0.obs;
  late final SharedPreferences _prefs;

  String get currentThemeSetting => _currentThemeSetting.value;

  /// Returns the current device platform brightness.
  Brightness get platformBrightness {
    try {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness;
    } catch (_) {
      return Brightness.light;
    }
  }

  /// Returns the effective brightness (Light or Dark) based on current setting and system brightness.
  Brightness get effectiveBrightness {
    if (_currentThemeSetting.value == themeLight) {
      return Brightness.light;
    } else if (_currentThemeSetting.value == themeDark) {
      return Brightness.dark;
    } else {
      return platformBrightness;
    }
  }

  /// Returns true if the app is effectively rendering in dark mode.
  bool get isDarkMode => effectiveBrightness == Brightness.dark;

  /// Returns Flutter's ThemeMode for MaterialApp.
  ThemeMode get themeMode {
    switch (_currentThemeSetting.value) {
      case themeLight:
        return ThemeMode.light;
      case themeDark:
        return ThemeMode.dark;
      case themeSystem:
      default:
        return ThemeMode.system;
    }
  }

  Future<ThemeService> init() async {
    WidgetsBinding.instance.addObserver(this);
    try {
      PlatformDispatcher.instance.onPlatformBrightnessChanged = () {
        _handleSystemThemeUpdate();
      };
    } catch (_) {}

    _prefs = await SharedPreferences.getInstance();
    final savedTheme = _prefs.getString(themeKey);

    if (savedTheme == themeLight || savedTheme == themeDark || savedTheme == themeSystem) {
      _currentThemeSetting.value = savedTheme!;
    } else {
      _currentThemeSetting.value = themeSystem;
      await _prefs.setString(themeKey, themeSystem);
    }
    return this;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  /// Called automatically by Flutter whenever system brightness changes.
  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    _handleSystemThemeUpdate();
  }

  /// Called automatically by Flutter whenever app lifecycle state changes (e.g. returning from background).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _handleSystemThemeUpdate();
    }
  }

  void _handleSystemThemeUpdate() {
    if (_currentThemeSetting.value == themeSystem) {
      rxThemeVersion.value++;
      Get.changeThemeMode(ThemeMode.system);
      update();
    }
  }

  Future<void> setThemeMode(String mode) async {
    if (mode != themeLight && mode != themeDark && mode != themeSystem) {
      return;
    }

    if (_currentThemeSetting.value == mode) return;

    _currentThemeSetting.value = mode;
    await _prefs.setString(themeKey, mode);
    rxThemeVersion.value++;

    switch (mode) {
      case themeLight:
        Get.changeThemeMode(ThemeMode.light);
        break;
      case themeDark:
        Get.changeThemeMode(ThemeMode.dark);
        break;
      case themeSystem:
        Get.changeThemeMode(ThemeMode.system);
        break;
    }

    update();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

class AppTheme {
  /// Approved Light Theme
  static ThemeData lightTheme({String? fontFamily}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontFamily ?? TS.fontFamily,
      scaffoldBackgroundColor: CC.lightBackground,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      colorScheme: const ColorScheme.light(
        primary: CC.lightPrimary,
        secondary: CC.lightSecondary,
        surface: CC.lightSurface,
        surfaceTint: Colors.transparent, // Prevents Material 3 pink/purple surface tint
        error: CC.lightError,
        onPrimary: CC.whiteText,
        onSecondary: CC.whiteText,
        onSurface: CC.lightPrimaryText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: CC.lightSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        centerTitle: true,
        iconTheme: const IconThemeData(color: CC.lightPrimaryText),
        titleTextStyle: const TextStyle(
          color: CC.lightPrimaryText,
          fontSize: 16,
          fontFamily: TS.fontFamily,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: CC.lightSurface,
        selectedItemColor: CC.lightPrimary,
        unselectedItemColor: CC.lightSecondaryText,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: CC.lightSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: CC.lightStroke, width: 0.8),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: CC.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: CC.lightStroke, width: 0.8),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: CC.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: CC.lightSecondary,
        contentTextStyle: const TextStyle(color: CC.whiteText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CC.lightSurface,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        hintStyle: const TextStyle(color: CC.lightMutedText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: CC.lightStroke, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: CC.lightStroke, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: CC.lightPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: CC.lightError, width: 0.8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: CC.lightError, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: CC.lightSurface,
        surfaceTintColor: Colors.transparent,
        side: const BorderSide(color: CC.lightStroke),
        labelStyle: const TextStyle(color: CC.lightPrimaryText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return CC.lightPrimary;
          return CC.lightMutedText;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return CC.lightPrimary.withAlpha(90);
          return CC.lightStroke;
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: CC.lightStroke,
        thickness: 0.8,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: CC.lightPrimary,
        selectionColor: CC.lightPrimary.withValues(alpha: 0.22),
        selectionHandleColor: CC.lightPrimary,
      ),
      textTheme: TTS.textStyle(fontFamily: fontFamily, brightness: Brightness.light),
    );
  }

  /// Approved Dark Theme
  static ThemeData darkTheme({String? fontFamily}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily ?? TS.fontFamily,
      scaffoldBackgroundColor: CC.darkBackground,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      colorScheme: const ColorScheme.dark(
        primary: CC.darkPrimary,
        secondary: CC.darkSecondary,
        surface: CC.darkBg2,
        surfaceTint: Colors.transparent, // Prevents Material 3 pink/purple surface tint
        error: CC.darkError,
        onPrimary: CC.whiteText,
        onSecondary: CC.whiteText,
        onSurface: CC.darkPrimaryText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: CC.darkBg2,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.6),
        centerTitle: true,
        iconTheme: const IconThemeData(color: CC.darkPrimaryText),
        titleTextStyle: const TextStyle(
          color: CC.darkPrimaryText,
          fontSize: 16,
          fontFamily: TS.fontFamily,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: CC.darkBg2,
        selectedItemColor: CC.darkPrimary,
        unselectedItemColor: CC.darkSecondaryText,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: CC.darkComment,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: CC.darkStroke, width: 0.8),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: CC.darkComment,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: CC.darkStroke, width: 0.8),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: CC.darkBottomSheet,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: CC.darkBg2,
        contentTextStyle: const TextStyle(color: CC.darkPrimaryText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CC.darkComment,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        hintStyle: const TextStyle(color: CC.darkMutedText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: CC.darkStroke, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: CC.darkStroke, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: CC.darkPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: CC.darkError, width: 0.8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: CC.darkError, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: CC.darkComment,
        surfaceTintColor: Colors.transparent,
        side: const BorderSide(color: CC.darkStroke),
        labelStyle: const TextStyle(color: CC.darkPrimaryText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return CC.darkPrimary;
          return CC.darkMutedText;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return CC.darkPrimary.withAlpha(90);
          return CC.darkStroke;
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: CC.darkStroke,
        thickness: 0.8,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: CC.darkPrimary,
        selectionColor: CC.darkPrimary.withValues(alpha: 0.25),
        selectionHandleColor: CC.darkPrimary,
      ),
      textTheme: TTS.textStyle(fontFamily: fontFamily, brightness: Brightness.dark),
    );
  }
}

class AppRadius {
  static const double small = 8;
  static const double medium = 12;
  static const double large = 14;
  static const double card = 14;
  static const double button = 12;
  static const double input = 12;
}

class AppSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

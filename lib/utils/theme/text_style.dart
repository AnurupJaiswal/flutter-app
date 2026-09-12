import 'package:flutter/material.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';

class TS {
  static const String fontFamily = 'Gilroy';

  // 1. Material 3 Display & Screen Titles
  static TextStyle displayLarge({
    Color? color,
    FontWeight? fontWeight,
    double? height,
    String? fontFamily,
    double? fontSize,
  }) =>
      TextStyle(
        fontSize: fontSize ?? 24,
        fontFamily: fontFamily ?? TS.fontFamily,
        fontWeight: fontWeight ?? FontWeight.w700,
        color: color ?? CC.textPrimary,
        height: height ?? 1.25,
        letterSpacing: -0.4,
        decoration: TextDecoration.none,
      );

  static TextStyle screenTitle({
    Color? color,
    FontWeight? fontWeight,
    double? height,
    String? fontFamily,
    double? fontSize,
  }) =>
      TextStyle(
        fontSize: fontSize ?? 20,
        fontFamily: fontFamily ?? TS.fontFamily,
        fontWeight: fontWeight ?? FontWeight.w700,
        color: color ?? CC.textPrimary,
        height: height ?? 1.25,
        letterSpacing: -0.2,
        decoration: TextDecoration.none,
      );

  // 2. Material 3 Headings & Section Titles
  static TextStyle headingLarge({
    Color? color,
    FontWeight? fontWeight,
    double? height,
    String? fontFamily,
    double? fontSize,
  }) =>
      TextStyle(
        fontSize: fontSize ?? 18,
        fontFamily: fontFamily ?? TS.fontFamily,
        fontWeight: fontWeight ?? FontWeight.w700,
        color: color ?? CC.textPrimary,
        height: height ?? 1.3,
        letterSpacing: -0.15,
        decoration: TextDecoration.none,
      );

  static TextStyle sectionTitle({
    Color? color,
    FontWeight? fontWeight,
    double? height,
    String? fontFamily,
    double? fontSize,
  }) =>
      TextStyle(
        fontSize: fontSize ?? 16,
        fontFamily: fontFamily ?? TS.fontFamily,
        fontWeight: fontWeight ?? FontWeight.w600,
        color: color ?? CC.textPrimary,
        height: height ?? 1.35,
        letterSpacing: -0.1,
        decoration: TextDecoration.none,
      );

  static TextStyle headingMedium({
    Color? color,
    FontWeight? fontWeight,
    double? height,
    String? fontFamily,
    double? fontSize,
  }) =>
      TextStyle(
        fontSize: fontSize ?? 14.5,
        fontFamily: fontFamily ?? TS.fontFamily,
        fontWeight: fontWeight ?? FontWeight.w600,
        color: color ?? CC.textPrimary,
        height: height ?? 1.35,
        decoration: TextDecoration.none,
      );

  // 3. Material 3 Subheadings & Body
  static TextStyle subHeading({
    Color? color,
    FontWeight? fontWeight,
    double? height,
    String? fontFamily,
    double? fontSize,
  }) =>
      TextStyle(
        fontSize: fontSize ?? 13.5,
        fontFamily: fontFamily ?? TS.fontFamily,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: color ?? CC.textSecondary,
        height: height ?? 1.4,
        decoration: TextDecoration.none,
      );

  static TextStyle body({
    Color? color,
    FontWeight? fontWeight,
    double? height,
    String? fontFamily,
    double? fontSize,
  }) =>
      TextStyle(
        fontSize: fontSize ?? 14,
        fontFamily: fontFamily ?? TS.fontFamily,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: color ?? CC.textPrimary,
        height: height ?? 1.5,
        decoration: TextDecoration.none,
      );

  static TextStyle bodyMedium({
    Color? color,
    FontWeight? fontWeight,
    double? height,
    String? fontFamily,
    double? fontSize,
  }) =>
      TextStyle(
        fontSize: fontSize ?? 13.5,
        fontFamily: fontFamily ?? TS.fontFamily,
        fontWeight: fontWeight ?? FontWeight.w500,
        color: color ?? CC.textPrimary,
        height: height ?? 1.45,
        decoration: TextDecoration.none,
      );

  static TextStyle bodySmall({
    Color? color,
    FontWeight? fontWeight,
    double? height,
    String? fontFamily,
    double? fontSize,
  }) =>
      TextStyle(
        fontSize: fontSize ?? 12.5,
        fontFamily: fontFamily ?? TS.fontFamily,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: color ?? CC.textSecondary,
        height: height ?? 1.4,
        decoration: TextDecoration.none,
      );

  // 4. Material 3 Buttons, Labels & Captions
  static TextStyle button({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
  }) =>
      TextStyle(
        fontSize: fontSize ?? 14.5,
        fontFamily: fontFamily ?? TS.fontFamily,
        fontWeight: fontWeight ?? FontWeight.w700,
        color: color ?? CC.whiteText,
        letterSpacing: 0.1,
        decoration: TextDecoration.none,
      );

  static TextStyle caption({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double letterSpacing = 0.1,
  }) =>
      TextStyle(
        fontSize: fontSize ?? 11.5,
        fontFamily: fontFamily ?? TS.fontFamily,
        fontWeight: fontWeight ?? FontWeight.w500,
        color: color ?? CC.grey,
        letterSpacing: letterSpacing,
        decoration: TextDecoration.none,
      );

  static TextStyle titleMedium({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 15,
      fontFamily: fontFamily ?? TS.fontFamily,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color ?? CC.textPrimary,
      decoration: TextDecoration.none,
    );
  }
}

class TTS {
  static TextTheme textStyle({String? fontFamily, Brightness brightness = Brightness.light}) {
    final isDark = brightness == Brightness.dark;
    final primaryTextColor = isDark ? CC.darkTextPrimary : CC.textPrimary;
    final secondaryTextColor = isDark ? CC.darkTextSecondary : CC.textSecondary;

    return TextTheme(
      displayLarge: TS.displayLarge(fontFamily: fontFamily, color: primaryTextColor),
      headlineMedium: TS.sectionTitle(fontFamily: fontFamily, color: primaryTextColor),
      titleMedium: TS.titleMedium(fontFamily: fontFamily, color: primaryTextColor),
      bodyLarge: TS.body(fontFamily: fontFamily, color: primaryTextColor),
      bodyMedium: TS.bodyMedium(fontFamily: fontFamily, color: primaryTextColor),
      labelLarge: TS.button(fontFamily: fontFamily, color: CC.whiteText),
      bodySmall: TS.caption(fontFamily: fontFamily, color: secondaryTextColor),
    );
  }
}

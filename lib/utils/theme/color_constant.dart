import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/utils/theme/theme_service.dart';

class CC {
  // -------------------------------------------------------------
  // 1. Raw Approved Light Mode Colors
  // -------------------------------------------------------------
  static const Color lightPrimary = Color(0xFF108CFF);
  static const Color lightSecondary = Color(0xFF222222);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightComment = Color(0xFFFFFFFF);
  static const Color lightSearch = Color(0xFFE7E7E7);
  static const Color lightDisabled = Color(0xFFC0C8C9);
  static const Color lightPrimaryText = Color(0xFF000000);
  static const Color lightSecondaryText = Color(0xFF465D61);
  static const Color lightMutedText = Color(0xFF8A9594);
  static const Color lightDisabledText = Color(0xFFD0D2D2);
  static const Color lightStroke = Color(0xFFD1D1D1);
  static const Color lightCommentStroke = Color(0xFFC8C8C8);
  static const Color lightNotification = Color(0xFFFF1010);
  static const Color lightError = Color(0xFFFF1010);
  static const Color lightSuccess = Color(0xFF10FF10);
  static const Color lightInsightful = Color(0xFF966E00);
  
  static const Color darkPrimary = Color(0xFF108CFF);
  static const Color darkSecondary = Color(0xFFE0E0E0);
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkBg = Color(0xFF000000);
  static const Color darkBg2 = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF000000);
  static const Color darkComment = Color(0xFF000000);
  static const Color darkSearch = Color(0xFF1C1C1E);
  static const Color darkDisabled = Color(0xFF515151);
  static const Color darkPrimaryText = Color(0xFFFFFFFF);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkSecondaryText = Color(0xFFC7C7C7);
  static const Color darkTextSecondary = Color(0xFFC7C7C7);
  static const Color darkMutedText = Color(0xFF8D8D8D);
  static const Color darkDisabledText = Color(0xFF515151);
  static const Color darkStroke = Color(0xFF515151);
  static const Color darkCommentStroke = Color(0xFF333333);
  static const Color darkNotification = Color(0xFFFF1010);
  static const Color darkError = Color(0xFFFF1010);
  static const Color darkSuccess = Color(0xFF10FF10);
  static const Color darkInsightful = Color(0xFFFFB300);
  static const Color darkBottomSheet = Color(0xFF000000);
  static const Color darkPopUpBack = Color(0xFF262626);
  static const Color darkMessageSender = Color(0xFF3D3D3D);

  static const Color poorPerformance = Color(0xFFFF1010);
  static const Color goodPerformance = Color(0xFF10FF10);

  // -------------------------------------------------------------
  // 3. Fixed / Immutable Values
  // -------------------------------------------------------------
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color whiteText = Color(0xFFFFFFFF);

  // Code Block Colors (Neutral Dark IDE)
  static const Color codeBackground = Color(0xFF1E242B);
  static const Color codeHeader = Color(0xFF15191E);
  static const Color codeBorder = Color(0xFF2D3748);
  static const Color codeKeyword = Color(0xFF38BDF8);
  static const Color codeString = Color(0xFF4ADE80);
  static const Color codeText = Color(0xFFF8FAFC);

  // -------------------------------------------------------------
  // 4. Dynamic Mode Resolution
  // -------------------------------------------------------------
  static bool get isDark {
    if (Get.isRegistered<ThemeService>()) {
      ThemeService.to.rxThemeVersion.value;
      return ThemeService.to.isDarkMode;
    }
    return false;
  }

  // Dynamic Theme Getters
  static Color get primary => isDark ? darkPrimary : lightPrimary;
  static Color get secondary => isDark ? darkSecondary : lightSecondary;
  static Color get background => isDark ? darkBackground : lightBackground;
  static Color get surface => isDark ? darkSurface : lightSurface;
  static Color get comment => isDark ? darkComment : lightComment;
  static Color get disabled => isDark ? darkDisabled : lightDisabled;
  static Color get searchBar => isDark ? darkSearch : lightDisabled;
  static Color get searchBackground => isDark ? darkSearch : lightSearch;
  static Color get inputBackground => isDark ? darkSurface : lightSurface;

  static Color get text => isDark ? darkPrimaryText : lightPrimaryText;
  static Color get textPrimary => isDark ? darkPrimaryText : lightPrimaryText;
  static Color get textSecondary => isDark ? darkSecondaryText : lightSecondaryText;
  static Color get subText => isDark ? darkSecondaryText : lightSecondaryText;
  static Color get grey => isDark ? darkMutedText : lightMutedText;
  static Color get muted => isDark ? darkMutedText : lightMutedText;
  static Color get hint => isDark ? darkMutedText : lightMutedText;
  static Color get textDisabled => isDark ? darkDisabledText : lightDisabledText;

  static Color get stroke => isDark ? darkStroke : lightStroke;
  static Color get border => isDark ? darkStroke : lightStroke;
  static Color get commentStroke => isDark ? darkCommentStroke : lightCommentStroke;
  static Color get borderSubtle => isDark ? const Color(0xFF262626) : const Color(0xFFE2E8F0);
  static Color get borderFocused => isDark ? darkPrimary : lightPrimary;
  static Color get divider => isDark ? darkStroke : const Color(0xFFE2E8F0);

  static Color get notification => isDark ? darkNotification : lightNotification;
  static Color get error => isDark ? darkError : lightError;
  static Color get errorText => isDark ? darkError : lightError;
  static Color get success => isDark ? darkSuccess : lightSuccess;
  static Color get insightful => isDark ? darkInsightful : lightInsightful;
  static Color get warning => isDark ? darkInsightful : lightInsightful;
  static Color get errorHover => isDark ? darkError : lightError;

  static Color get tealSubtle => isDark ? const Color(0x2600AFBE) : const Color(0x1A00808B);
  static Color get tealLight => isDark ? const Color(0xFF00383D) : const Color(0xFFE0F2F1);
}

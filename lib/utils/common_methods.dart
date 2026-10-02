import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lala_ai/utils/app_toast.dart';

class CM {
  static void log({required String msg}) {
    if (kDebugMode) {
      debugPrint(msg, wrapWidth: 1024);
    }
  }

  static void unFocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// All toasts in the app go through AppToast for a unified experience.
  static void showToast(
    String message, {
    bool showInRelease = true,
    bool isError = false,
  }) {
    if (!kDebugMode && !showInRelease) return;
    if (isError) {
      AppToast.error(message);
    } else {
      AppToast.info(message);
    }
  }

  /// Deprecated — use AppToast directly. Kept for backward compatibility.
  static void showSnackBar({
    required String title,
    required String message,
    bool isError = false,
  }) {
    final combined = title.isNotEmpty ? "$title: $message" : message;
    if (isError) {
      AppToast.error(combined);
    } else {
      AppToast.success(combined);
    }
  }


  /// FOR UNFOCUS KEYBOARD
  static void unFocsKeyBoard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// FOR GET DEVICE TYPE
  static String getDeviceType() {
    if (kIsWeb) return "Web";
    if (Platform.isAndroid) {
      return "Android";
    } else if (Platform.isIOS) {
      return "IOS";
    } else if (Platform.isWindows) {
      return "Windows";
    } else if (Platform.isMacOS) {
      return "MacOS";
    } else if (Platform.isLinux) {
      return "Linux";
    } else {
      return "Unknown";
    }
  }

  /// Formats an ALL_CAPS_ENUM string into Title Case (e.g., "TECHNICAL_ISSUE" -> "Technical Issue")
  static String formatEnum(String? value) {
    if (value == null || value.isEmpty) return '';
    return value.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

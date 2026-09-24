import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AppReviewService — Production service for native In-App Store Reviews.
///
/// Triggers Google Play In-App Review API on Android and Apple StoreKit on iOS.
/// Gracefully falls back to open the official store listing if in-app review
/// is unavailable on the device. Includes cooldown prevention.
/// ─────────────────────────────────────────────────────────────────────────────
class AppReviewService {
  AppReviewService._();

  static final InAppReview _inAppReview = InAppReview.instance;

  // Centralized Store IDs for Fallback Listing
  static const String _appStoreId = '6470000000'; // Replace with actual iOS App Store ID if applicable
  static const String _microsoftStoreId = '';
  static const String _prefKeyLastPrompt = 'last_app_review_prompt_time';

  /// Triggers the native platform review dialog.
  /// [forcePrompt] is true when user explicitly taps "Rate Lala AI" in Settings.
  static Future<void> requestReview({bool forcePrompt = false}) async {
    // Unsupported platform guard
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastPrompt = prefs.getInt(_prefKeyLastPrompt) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Rate limit automatic prompts to once every 14 days
      if (!forcePrompt && (now - lastPrompt < const Duration(days: 14).inMilliseconds)) {
        return;
      }

      final isAvailable = await _inAppReview.isAvailable();

      if (isAvailable) {
        await prefs.setInt(_prefKeyLastPrompt, now);
        await _inAppReview.requestReview();
      } else if (forcePrompt) {
        // Fallback: Open Store Listing directly if user explicitly requested
        await _inAppReview.openStoreListing(
          appStoreId: _appStoreId,
          microsoftStoreId: _microsoftStoreId,
        );
      }
    } catch (e) {
      // Fail gracefully — do not show raw exception stack traces or debug errors to users
      debugPrint("AppReviewService: native review failed - $e");
    }
  }
}


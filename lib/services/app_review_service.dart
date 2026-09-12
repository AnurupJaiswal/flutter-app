import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AppReviewService — Production service for native In-App Store Reviews.
///
/// Triggers Google Play In-App Review API on Android and Apple StoreKit on iOS.
/// Gracefully falls back to open the official store listing if in-app review
/// is unavailable on the device.
/// ─────────────────────────────────────────────────────────────────────────────
class AppReviewService {
  AppReviewService._();

  static final InAppReview _inAppReview = InAppReview.instance;

  // Centralized Store IDs for Fallback Listing
  static const String _appStoreId = '6470000000'; // Replace with actual iOS App Store ID if applicable
  static const String _microsoftStoreId = '';

  /// Triggers the native platform review dialog.
  static Future<void> requestReview() async {
    // Unsupported platform guard
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) return;

    try {
      final isAvailable = await _inAppReview.isAvailable();

      if (isAvailable) {
        await _inAppReview.requestReview();
      } else {
        // Fallback: Open Store Listing directly
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

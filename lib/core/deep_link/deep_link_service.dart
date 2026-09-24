import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lala_ai/core/deep_link/deep_link_router.dart';

/// Centralized Deep Link Service managing lifecycle listeners and forwarding to [DeepLinkRouter].
class DeepLinkService extends GetxService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  Uri? _lastProcessedUri;
  DateTime? _lastProcessedTime;
  static const Duration _dedupWindow = Duration(milliseconds: 1500);

  /// Initializes deep link listeners for cold start and active runtime.
  Future<DeepLinkService> init() async {
    // 1. Check Initial Link (Cold Start from terminated state)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        if (kDebugMode) {
          debugPrint("[DeepLink] Cold start link detected: $initialUri");
        }
        await _processIncomingUri(initialUri, isColdStart: true);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("[DeepLink] Initial link retrieval check: $e");
      }
    }

    // 2. Listen to Link Stream (Foreground & Background Resumes)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) async {
        if (kDebugMode) {
          debugPrint("[DeepLink] Runtime link stream event: $uri");
        }
        await _processIncomingUri(uri, isColdStart: false);
      },
      onError: (err) {
        if (kDebugMode) {
          debugPrint("[DeepLink] Link stream error: $err");
        }
      },
    );

    return this;
  }

  /// Processes URI with deduplication check.
  Future<void> _processIncomingUri(Uri uri, {required bool isColdStart}) async {
    final now = DateTime.now();

    // Check if the exact same URI was received within deduplication window
    if (_lastProcessedUri == uri &&
        _lastProcessedTime != null &&
        now.difference(_lastProcessedTime!) < _dedupWindow) {
      if (kDebugMode) {
        debugPrint("[DeepLink] Deduplication: Skipping identical URI within window ($uri)");
      }
      return;
    }

    _lastProcessedUri = uri;
    _lastProcessedTime = now;

    await DeepLinkRouter.routeUri(uri, isColdStart: isColdStart);
  }

  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }
}

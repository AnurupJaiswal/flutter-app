import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/app/routes/app_routes.dart';

class DeepLinkService extends GetxService {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  Future<DeepLinkService> init() async {
    // Check initial link if app was cold started from a deep link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri, isColdStart: true);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Deep link initialization check completed");
      }
    }

    // Listen to incoming links while app is open
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri, isColdStart: false);
    }, onError: (err) {
      if (kDebugMode) {
        debugPrint("Deep link stream event encountered");
      }
    });

    return this;
  }

  void _handleDeepLink(Uri uri, {bool isColdStart = false}) {
    final path = uri.path.toLowerCase();

    if (path.contains('/auth/reset-password')) {
      if (kDebugMode) {
        debugPrint("Password reset deep link received (${isColdStart ? 'cold start' : 'runtime'})");
      }
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        _executeWhenNavigationReady(() {
          Get.toNamed(Routes.RESET_PASSWORD, parameters: {'token': token});
        });
      }
    } else {
      if (kDebugMode) {
        debugPrint("Deep link received for path: ${uri.path}");
      }
    }
  }

  void _executeWhenNavigationReady(VoidCallback callback) {
    if (Get.context != null && Get.key.currentState != null) {
      callback();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        callback();
      });
    }
  }

  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }
}


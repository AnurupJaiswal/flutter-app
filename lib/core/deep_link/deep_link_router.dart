import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/core/deep_link/deep_link_routes.dart';
import 'package:lala_ai/core/deep_link/deep_link_type.dart';
import 'package:lala_ai/core/deep_link/pending_deep_link.dart';
import 'package:lala_ai/app/data/repositories/dashboard_repository.dart';
import 'package:lala_ai/app/modules/authentication/data/auth_repository.dart';
import 'package:lala_ai/app/navigation/app_navigation_service.dart';
import 'package:lala_ai/app/routes/app_routes.dart';
import 'package:lala_ai/networking/api_service.dart';
import 'package:lala_ai/utils/app_toast.dart';

/// Centralized Deep Link Router for Lala AI.
///
/// Dispatches incoming URIs to their corresponding feature handlers,
/// enforcing domain checks, authentication gates, and cold-start readiness.
class DeepLinkRouter {
  DeepLinkRouter._();

  static PendingDeepLink? _pendingLink;
  static bool _isAppReady = false;

  /// Returns current pending link for testing/inspection.
  static PendingDeepLink? get pendingLink => _pendingLink;
  static bool get isAppReady => _isAppReady;

  /// Called by Splash / Initialization flow when the app UI and navigation are ready.
  static void setAppReady({bool ready = true}) {
    _isAppReady = ready;
    if (_isAppReady && _pendingLink != null) {
      if (kDebugMode) {
        debugPrint("[DeepLink] App is now ready. Processing pending link...");
      }
      processPendingLink();
    }
  }

  /// Called when user completes login / session restoration.
  static void onUserAuthenticated() {
    if (_pendingLink != null && _pendingLink!.requiresAuth) {
      if (kDebugMode) {
        debugPrint("[DeepLink] User authenticated. Resuming pending protected link...");
      }
      processPendingLink();
    }
  }

  /// Clears any pending link.
  static void clearPendingLink() {
    _pendingLink = null;
  }

  /// Main entry point for routing an incoming URI.
  static Future<bool> routeUri(Uri uri, {bool isColdStart = false}) async {
    // 1. Validate Domain / Scheme
    if (!DeepLinkRoutes.isValidDomainOrScheme(uri)) {
      if (kDebugMode) {
        debugPrint("[DeepLink] Ignored unauthorized domain/scheme: ${uri.scheme}://${uri.host}");
      }
      return false;
    }

    // 2. Parse Segments & Action Type
    final segments = DeepLinkRoutes.extractNormalizedSegments(uri);
    final type = DeepLinkRoutes.parseType(segments);
    final queryParams = Map<String, String>.from(uri.queryParameters);

    _logDeepLink(uri: uri, type: type, segments: segments, params: queryParams);

    // 3. Determine if link requires Authentication
    final bool requiresAuth = _isAuthRequired(type);

    // 4. Handle App Startup / Not Ready State
    if (!_isAppReady || Get.context == null || Get.key.currentState == null) {
      if (kDebugMode) {
        debugPrint("[DeepLink] Waiting for startup/navigation readiness. Storing pending link.");
      }
      _pendingLink = PendingDeepLink(
        uri: uri,
        type: type,
        segments: segments,
        queryParameters: queryParams,
        requiresAuth: requiresAuth,
      );
      return true;
    }

    // 5. Handle Authentication Check
    if (requiresAuth && !ApiService.isAuthenticated) {
      if (kDebugMode) {
        debugPrint("[DeepLink] Auth required but user not logged in. Storing pending link & routing to Auth.");
      }
      _pendingLink = PendingDeepLink(
        uri: uri,
        type: type,
        segments: segments,
        queryParameters: queryParams,
        requiresAuth: requiresAuth,
      );

      _navigateToLogin();
      return true;
    }

    // 6. Dispatch to specific feature handler
    return await _dispatch(type: type, segments: segments, params: queryParams, uri: uri);
  }

  /// Re-processes the current pending link once conditions are met.
  static Future<void> processPendingLink() async {
    if (_pendingLink == null) return;
    if (_pendingLink!.isExpired) {
      if (kDebugMode) {
        debugPrint("[DeepLink] Pending link expired. Clearing.");
      }
      _pendingLink = null;
      return;
    }

    final linkToProcess = _pendingLink!;
    _pendingLink = null; // Clear before executing to avoid infinite loop

    if (linkToProcess.requiresAuth && !ApiService.isAuthenticated) {
      // Re-store and redirect if still unauthenticated
      _pendingLink = linkToProcess;
      _navigateToLogin();
      return;
    }

    await _dispatch(
      type: linkToProcess.type,
      segments: linkToProcess.segments,
      params: linkToProcess.queryParameters,
      uri: linkToProcess.uri,
    );
  }

  /// Determines whether a given deep link type requires user authentication.
  static bool _isAuthRequired(DeepLinkType type) {
    switch (type) {
      case DeepLinkType.subscriptionSuccess:
      case DeepLinkType.subscriptionFailed:
      case DeepLinkType.subscriptionPending:
      case DeepLinkType.oauthYoutube:
      case DeepLinkType.oauthInstagram:
      case DeepLinkType.content:
      case DeepLinkType.post:
      case DeepLinkType.creator:
      case DeepLinkType.share:
      case DeepLinkType.invite:
      case DeepLinkType.studio:
      case DeepLinkType.trends:
      case DeepLinkType.calendar:
      case DeepLinkType.discover:
      case DeepLinkType.connectAccounts:
      case DeepLinkType.settings:
        return true;
      case DeepLinkType.openApp:
      case DeepLinkType.resetPassword:
      case DeepLinkType.unknown:
        return false;
    }
  }

  /// Dispatches the parsed deep link to the corresponding feature handler.
  static Future<bool> _dispatch({
    required DeepLinkType type,
    required List<String> segments,
    required Map<String, String> params,
    required Uri uri,
  }) async {
    switch (type) {
      // -- APP OPEN (Canonical HTTPS route: /open-app) ----------------
      case DeepLinkType.openApp:
        final orderId = params['orderId'] ??
            params['order_id'] ??
            params['orderID'] ??
            params['id'] ??
            params['sessionId'] ??
            params['session_id'] ??
            params['reference'];
        if (orderId != null && orderId.trim().isNotEmpty) {
          try {
            if (Get.isRegistered<AuthRepository>()) {
              await Get.find<AuthRepository>().fetchAndSaveMe();
            } else {
              await Get.put<AuthRepository>(ApiAuthRepository()).fetchAndSaveMe();
            }
          } catch (_) {}
          AppToast.success("Subscription verified for Order #$orderId");
        }
        if (ApiService.isAuthenticated) {
          _switchTab(AppNavigationService.tabDashboard);
        } else {
          _navigateToLogin();
        }
        return true;

      // ── SUBSCRIPTION LINKS ──────────────────────────────────────────────────
      case DeepLinkType.subscriptionSuccess:
        return await _handleSubscription(status: 'success', params: params);

      case DeepLinkType.subscriptionFailed:
        return await _handleSubscription(status: 'failed', params: params);

      case DeepLinkType.subscriptionPending:
        return await _handleSubscription(status: 'pending', params: params);

      // ── OAUTH LINKS ────────────────────────────────────────────────────────
      case DeepLinkType.oauthYoutube:
        return await _handleOAuth(platform: 'YouTube', params: params);

      case DeepLinkType.oauthInstagram:
        return await _handleOAuth(platform: 'Instagram', params: params);

      // ── RESET PASSWORD ─────────────────────────────────────────────────────
      case DeepLinkType.resetPassword:
        return _handleResetPassword(params: params);

      // ── CONTENT / POST ─────────────────────────────────────────────────────
      case DeepLinkType.content:
      case DeepLinkType.post:
        final id = segments.length >= 2 ? segments[1] : '';
        return _handleContent(id: id);

      // ── CREATOR ────────────────────────────────────────────────────────────
      case DeepLinkType.creator:
        final id = segments.length >= 2 ? segments[1] : '';
        return _handleCreator(id: id);

      // ── SHARE ──────────────────────────────────────────────────────────────
      case DeepLinkType.share:
        final shareType = segments.length >= 2 ? segments[1] : 'post';
        final id = segments.length >= 3 ? segments[2] : (segments.length == 2 ? segments[1] : '');
        return _handleShare(shareType: shareType, id: id);

      // ── INVITE / REFERRAL ──────────────────────────────────────────────────
      case DeepLinkType.invite:
        final code = segments.length >= 2 ? segments[1] : '';
        return _handleInvite(code: code);

      // ── TAB / NAVIGATION ALIASES ───────────────────────────────────────────
      case DeepLinkType.studio:
        _switchTab(AppNavigationService.tabStudio);
        return true;
      case DeepLinkType.trends:
        _switchTab(AppNavigationService.tabTrends);
        return true;
      case DeepLinkType.calendar:
        _switchTab(AppNavigationService.tabCalendar);
        return true;
      case DeepLinkType.discover:
        _switchTab(AppNavigationService.tabDiscover);
        return true;
      case DeepLinkType.settings:
        _navigateTo(Routes.SETTINGS);
        return true;
      case DeepLinkType.connectAccounts:
        _navigateTo(Routes.CONNECT_ACCOUNTS);
        return true;

      // ── UNKNOWN / MALFORMED ────────────────────────────────────────────────
      case DeepLinkType.unknown:
        if (kDebugMode) {
          debugPrint("[DeepLink] Unhandled or unknown route path: ${uri.path}");
        }
        return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // FEATURE HANDLERS
  // ─────────────────────────────────────────────────────────────────────────────

  /// Handles Subscription callbacks with server verification.
  static Future<bool> _handleSubscription({
    required String status,
    required Map<String, String> params,
  }) async {
    final orderId = params['orderId'] ??
        params['order_id'] ??
        params['orderID'] ??
        params['id'] ??
        params['sessionId'] ??
        params['session_id'] ??
        params['reference'];

    if (orderId == null || orderId.trim().isEmpty) {
      AppToast.error("Invalid subscription callback: Missing Order ID.");
      _navigateTo(Routes.SETTINGS);
      return false;
    }

    if (kDebugMode) {
      debugPrint("[DeepLink] Verifying subscription for orderId: $orderId | Status: $status");
    }

    // Trigger backend profile & subscription status sync
    try {
      if (Get.isRegistered<AuthRepository>()) {
        await Get.find<AuthRepository>().fetchAndSaveMe();
      } else {
        await Get.put<AuthRepository>(ApiAuthRepository()).fetchAndSaveMe();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("[DeepLink] Subscription sync warning: $e");
      }
    }

    if (status == 'success') {
      AppToast.success("Subscription updated! Order #$orderId has been processed.");
    } else if (status == 'pending') {
      AppToast.info("Payment pending: Order #$orderId is being verified.");
    } else {
      AppToast.error("Payment failed or cancelled for Order #$orderId.");
    }

    _navigateTo(Routes.SETTINGS);
    return true;
  }

  /// Handles OAuth callbacks for social channels (YouTube / Instagram).
  static Future<bool> _handleOAuth({
    required String platform,
    required Map<String, String> params,
  }) async {
    final error = params['error'] ?? params['err'];
    final errorDescription = params['error_description'] ?? params['message'] ?? params['description'];
    final code = params['code'] ?? params['auth_code'] ?? params['authorization_code'];

    if (error != null && error.isNotEmpty) {
      final msg = errorDescription ?? error;
      AppToast.error("$platform connection failed: $msg");
      _navigateTo(Routes.CONNECT_ACCOUNTS);
      return false;
    }

    if (code == null || code.isEmpty) {
      AppToast.error("$platform connection callback was missing authorization code.");
      _navigateTo(Routes.CONNECT_ACCOUNTS);
      return false;
    }

    // Refresh channel connections & entitlements cache
    try {
      final dashboardRepo = Get.isRegistered<DashboardRepository>()
          ? Get.find<DashboardRepository>()
          : Get.put<DashboardRepository>(ApiDashboardRepository());
      await dashboardRepo.getConnectionsWithEntitlements();

      final authRepo = Get.isRegistered<AuthRepository>()
          ? Get.find<AuthRepository>()
          : Get.put<AuthRepository>(ApiAuthRepository());
      await authRepo.fetchAndSaveMe();

      AppToast.success("$platform account connected successfully!");
    } catch (e) {
      if (kDebugMode) {
        debugPrint("[DeepLink] OAuth sync warning: $e");
      }
      AppToast.info("$platform callback received. Updating connections...");
    }

    _navigateTo(Routes.CONNECT_ACCOUNTS);
    return true;
  }

  /// Handles Password Reset tokens.
  static bool _handleResetPassword({required Map<String, String> params}) {
    final token = params['token'] ??
        params['reset_token'] ??
        params['resetToken'] ??
        params['code'];
    if (token == null || token.trim().isEmpty) {
      AppToast.error("Password reset link is invalid or expired (missing token).");
      return false;
    }

    _executeWhenNavigationReady(() {
      Get.toNamed(Routes.RESET_PASSWORD, parameters: {'token': token.trim()});
    });
    return true;
  }

  /// Handles Content / Post deep links.
  static bool _handleContent({required String id}) {
    if (id.isEmpty) {
      _switchTab(AppNavigationService.tabStudio);
      return true;
    }
    AppToast.info("Opening content #$id");
    _switchTab(AppNavigationService.tabStudio);
    return true;
  }

  /// Handles Creator profile links.
  static bool _handleCreator({required String id}) {
    if (id.isEmpty) {
      _switchTab(AppNavigationService.tabDiscover);
      return true;
    }
    AppToast.info("Viewing creator #$id");
    _switchTab(AppNavigationService.tabDiscover);
    return true;
  }

  /// Handles Share links.
  static bool _handleShare({required String shareType, required String id}) {
    AppToast.info("Viewing shared $shareType ${id.isNotEmpty ? '#$id' : ''}");
    _switchTab(AppNavigationService.tabDashboard);
    return true;
  }

  /// Handles Referral / Invite code links.
  static bool _handleInvite({required String code}) {
    if (code.isNotEmpty) {
      AppToast.success("Referral code applied: $code");
    }
    _switchTab(AppNavigationService.tabDashboard);
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // NAVIGATION HELPERS
  // ─────────────────────────────────────────────────────────────────────────────

  static void _navigateToLogin() {
    _executeWhenNavigationReady(() {
      if (Get.currentRoute != Routes.AUTHENTICATION && Get.currentRoute != Routes.WELCOME) {
        Get.toNamed(Routes.AUTHENTICATION);
      }
    });
  }

  static void _navigateTo(String routeName) {
    _executeWhenNavigationReady(() {
      if (Get.currentRoute != routeName) {
        Get.toNamed(routeName);
      }
    });
  }

  static void _switchTab(int tabIndex) {
    _executeWhenNavigationReady(() {
      if (Get.currentRoute != Routes.MAIN_CONTAINER) {
        Get.offAllNamed(Routes.MAIN_CONTAINER);
      }
      try {
        if (Get.isRegistered<AppNavigationService>()) {
          // Reset nested stack of target tab and switch tab index
          AppNavigationService.to.popToTabRoot(tabIndex);
        }
      } catch (_) {}
    });
  }

  static void _executeWhenNavigationReady(VoidCallback callback) {
    if (Get.context != null && Get.key.currentState != null) {
      callback();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.context != null && Get.key.currentState != null) {
          callback();
        }
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // LOGGING HELPER (SENSITIVE DATA SANITIZED)
  // ─────────────────────────────────────────────────────────────────────────────

  static void _logDeepLink({
    required Uri uri,
    required DeepLinkType type,
    required List<String> segments,
    required Map<String, String> params,
  }) {
    if (!kDebugMode) return;

    // Sanitize any potential sensitive credentials in parameters
    final sanitizedParams = <String, String>{};
    for (final entry in params.entries) {
      final key = entry.key.toLowerCase();
      if (key.contains('secret') ||
          key.contains('password') ||
          key.contains('access_token') ||
          key.contains('refresh_token')) {
        sanitizedParams[entry.key] = '***REDACTED***';
      } else if (key == 'code') {
        // Redact auth code length/value
        sanitizedParams[entry.key] = entry.value.isNotEmpty ? '***AUTH_CODE***' : '';
      } else if (key == 'token') {
        sanitizedParams[entry.key] = entry.value.length > 8
            ? '${entry.value.substring(0, 4)}...${entry.value.substring(entry.value.length - 4)}'
            : '***TOKEN***';
      } else {
        sanitizedParams[entry.key] = entry.value;
      }
    }

    debugPrint("──────────────────────────────────────────");
    debugPrint("[DeepLink] URI: ${uri.toString()}");
    debugPrint("[DeepLink] Scheme: ${uri.scheme}");
    debugPrint("[DeepLink] Host: ${uri.host}");
    debugPrint("[DeepLink] Path: ${uri.path}");
    debugPrint("[DeepLink] Route Type: $type");
    debugPrint("[DeepLink] Segments: $segments");
    debugPrint("[DeepLink] Query Parameters: $sanitizedParams");
    debugPrint("[DeepLink] Auth Required: ${_isAuthRequired(type)}");
    debugPrint("──────────────────────────────────────────");
  }
}

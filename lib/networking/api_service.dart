import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:lala_ai/app/navigation/app_navigation_service.dart';
import 'package:lala_ai/app/routes/app_routes.dart';
import 'package:lala_ai/networking/api_endpoints.dart';
import 'package:lala_ai/networking/api_error_handler.dart';
import 'package:lala_ai/networking/api_response.dart';
import 'package:lala_ai/utils/common_methods.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/Models/creator_profile_model.dart';
import 'package:lala_ai/Models/connected_accounts_model.dart';
import 'package:lala_ai/Models/subscription_model.dart';
import 'package:lala_ai/Models/user_model.dart';
import 'package:lala_ai/Models/compare_creator_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  ApiService._();

  static String? token;
  static String? refreshToken;
  static String? userUuid;
  static String? userEmail;
  static String? userName;
  static UserModel? currentUser;
  static SubscriptionModel? currentSubscription;
  static CreatorProfileModel? currentCreatorProfile;
  static ConnectedAccountsModel? currentConnectedAccounts;
  static CreatorStatsModel? currentStats;

  // Cached SharedPreferences instance to prevent repeated getInstance() overhead
  static SharedPreferences? _prefs;
  static Future<SharedPreferences> get _getPrefs async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// Returns true if an active access token exists
  static bool get isAuthenticated => token != null && token!.trim().isNotEmpty;

  /// Returns the standardized display name for the user across the entire app.
  static String get effectiveDisplayName {
    final creatorName = currentCreatorProfile?.displayName?.trim();
    if (creatorName != null && creatorName.isNotEmpty) return creatorName;

    final userDisplayName = currentUser?.displayName?.trim();
    if (userDisplayName != null && userDisplayName.isNotEmpty) return userDisplayName;

    final storedName = userName?.trim();
    if (storedName != null && storedName.isNotEmpty && storedName != "Creator") return storedName;

    final userFullName = currentUser?.fullName?.trim() ?? currentUser?.name.trim();
    if (userFullName != null && userFullName.isNotEmpty) return userFullName;

    return "Creator";
  }

  /// Returns the user's full legal/account name if available, otherwise effectiveDisplayName.
  static String get effectiveFullName {
    final userFullName = currentUser?.fullName?.trim() ?? currentUser?.name.trim();
    if (userFullName != null && userFullName.isNotEmpty) return userFullName;
    return effectiveDisplayName;
  }

  static bool _sessionExpiredHandled = false;
  static Completer<bool>? _refreshCompleter;
  static final Dio _dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl.trim(),
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
      responseType: ResponseType.json,
    ));

    // Request & Concurrency-Safe 401 Interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (token != null && token!.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        final statusCode = e.response?.statusCode;
        final isRefreshEndpoint = e.requestOptions.path.contains(ApiEndpoints.refresh);
        final alreadyRetried = e.requestOptions.extra['isRetry'] == true;

        // Check for HTTP 401 or non-standard HTTP 400 with auth error messages from backend
        final responseData = e.response?.data;
        final String errorMsg = (responseData is Map
                ? (responseData['message'] ?? responseData['error'] ?? '')
                : responseData?.toString() ?? '')
            .toString()
            .toLowerCase();

        final isAuthFailure = statusCode == 401 ||
            (statusCode == 400 &&
                (errorMsg.contains('authentication required') ||
                    errorMsg.contains('authorization required') ||
                    errorMsg.contains('unauthorized') ||
                    errorMsg.contains('token expired') ||
                    errorMsg.contains('jwt expired') ||
                    errorMsg.contains('invalid token')));

        if (isAuthFailure && !isRefreshEndpoint && !alreadyRetried) {
          // Token expired, attempt or wait for concurrent refresh
          final refreshed = await _attemptRefresh();
          if (refreshed && token != null) {
            final requestOptions = e.requestOptions;
            requestOptions.extra['isRetry'] = true;
            requestOptions.headers['Authorization'] = 'Bearer $token';

            try {
              final retryResponse = await dio.request(
                requestOptions.path,
                data: requestOptions.data,
                queryParameters: requestOptions.queryParameters,
                cancelToken: requestOptions.cancelToken,
                options: Options(
                  method: requestOptions.method,
                  headers: requestOptions.headers,
                  extra: requestOptions.extra,
                  responseType: requestOptions.responseType,
                  contentType: requestOptions.contentType,
                  validateStatus: requestOptions.validateStatus,
                  receiveTimeout: requestOptions.receiveTimeout,
                  sendTimeout: requestOptions.sendTimeout,
                ),
                onReceiveProgress: requestOptions.onReceiveProgress,
                onSendProgress: requestOptions.onSendProgress,
              );
              return handler.resolve(retryResponse);
            } on DioException catch (retryErr) {
              return handler.next(retryErr);
            } catch (retryOther) {
              return handler.next(e);
            }
          } else {
            _handleSessionExpired();
            return handler.next(e);
          }
        } else if (isAuthFailure && isRefreshEndpoint) {
          _handleSessionExpired();
          return handler.next(e);
        }

        return handler.next(e);
      },
    ));

    // Safe Network Logger Interceptor with Sensitive Data Redaction
    dio.interceptors.add(_SafeNetworkLoggerInterceptor());

    return dio;
  }

  /// Concurrency-safe token refresh: single shared Completer prevents multiple refresh requests
  static Future<bool> _attemptRefresh() async {
    if (_refreshCompleter != null) {
      // Refresh already running, wait for active refresh
      return _refreshCompleter!.future;
    }

    final completer = Completer<bool>();
    _refreshCompleter = completer;

    try {
      if (refreshToken == null || refreshToken!.trim().isEmpty) {
        completer.complete(false);
        _refreshCompleter = null;
        return false;
      }

      final refreshDio = Dio(BaseOptions(
        baseUrl: ApiEndpoints.baseUrl.trim(),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ));

      final response = await refreshDio.post(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic raw = response.data;
        final data = raw is Map && raw['data'] != null ? raw['data'] : raw;
        final newToken = data['accessToken'] ?? data['token'];
        final newRefresh = data['refreshToken'];

        if (newToken != null && newToken.toString().trim().isNotEmpty) {
          token = newToken.toString().trim();
          if (newRefresh != null && newRefresh.toString().trim().isNotEmpty) {
            refreshToken = newRefresh.toString().trim();
          }

          final pref = await _getPrefs;
          await pref.setString('accessToken', token!);
          if (refreshToken != null) {
            await pref.setString('refreshToken', refreshToken!);
          }

          _sessionExpiredHandled = false;
          completer.complete(true);
          _refreshCompleter = null;
          return true;
        }
      }
      completer.complete(false);
    } catch (e) {
      CM.log(msg: "Token refresh failed: $e");
      completer.complete(false);
    } finally {
      _refreshCompleter = null;
    }
    return false;
  }

  static void _handleSessionExpired() {
    if (_sessionExpiredHandled) return;
    _sessionExpiredHandled = true;
    CM.showToast("Your session has expired. Please sign in again.", isError: true);
    logout();
  }

  /// Clears all session credentials, cached user and subscription info from memory and local storage
  static Future<void> clearSessionData() async {
    token = null;
    refreshToken = null;
    userUuid = null;
    userEmail = null;
    userName = null;
    currentUser = null;
    currentSubscription = null;
    currentCreatorProfile = null;
    currentConnectedAccounts = null;
    currentStats = null;
    _sessionExpiredHandled = false;

    final pref = await _getPrefs;
    await pref.remove('accessToken');
    await pref.remove('refreshToken');
    await pref.remove('userUuid');
    await pref.remove('userEmail');
    await pref.remove('userName');
    await pref.remove('userProfile');
    await pref.remove('userSubscription');
    await pref.remove('creatorProfile');
    await pref.remove('connectedAccounts');
    await pref.remove('creatorStats');
  }

  /// Clears all non-permanent GetX controllers to prevent data leakage between user sessions
  static void clearUserControllers() {
    try {
      Get.deleteAll(force: false);
    } catch (_) {}
  }

  /// Clear token and saved session, delete user controllers, navigate to authentication
  static Future<void> logout() async {
    await clearSessionData();
    clearUserControllers();
    if (Get.isRegistered<AppNavigationService>()) {
      AppNavigationService.to.resetAllTabStacks();
    }
    Get.offAllNamed(Routes.AUTHENTICATION);
  }


  /// Logout confirmation dialog with Black + Blue theme
  static Future<void> logoutWithConfirmation() async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: CC.border, width: 1),
        ),
        backgroundColor: CC.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CC.error.withOpacityValue(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.logout_rounded, color: CC.error, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              "Sign Out",
              style: TS.sectionTitle(color: CC.text),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to sign out of your account?",
          style: TS.body(color: CC.subText),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: TS.button(color: CC.subText),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CC.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () async {
              Get.back();
              await logout();
            },
            child: Text(
              "Sign Out",
              style: TS.button(color: CC.whiteText),
            ),
          ),
        ],
      ),
    );
  }

  static Future<ApiResponse> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: ApiErrorHandler.getMessage(e),
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse> compareCreator({
    required int accountId,
    required String competitorIdentifier,
    required String platform,
  }) async {
    final response = await post(
      ApiEndpoints.compareCreator,
      body: {
        'accountId': accountId,
        'competitorIdentifier': competitorIdentifier,
        'platform': platform.toUpperCase(),
      },
    );

    if (response.success && response.data != null) {
      try {
        final model = CompareCreatorModel.fromJson(response.data as Map<String, dynamic>);
        return ApiResponse.success(data: model, message: response.message);
      } catch (e) {
        return ApiResponse.error(message: 'Failed to parse comparison data.');
      }
    }
    return response;
  }

  static Future<ApiResponse> post(String endpoint, {dynamic body, dynamic data}) async {
    try {
      final payload = body ?? data;
      final response = await _dio.post(endpoint, data: payload);
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: ApiErrorHandler.getMessage(e),
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse> put(String endpoint, {dynamic body, dynamic data}) async {
    try {
      final payload = body ?? data;
      final response = await _dio.put(endpoint, data: payload);
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: ApiErrorHandler.getMessage(e),
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(
        message: ApiErrorHandler.getMessage(e),
        statusCode: 500,
      );
    }
  }

  static ApiResponse _handleResponse(Response response) {
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
      if (response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        final bool isExplicitFailure = map['success'] == false;
        final String? message = map['message']?.toString();
        final String? errorCode = map['errorCode']?.toString();

        if (isExplicitFailure) {
          final safeMessage = (message != null && ApiErrorHandler.isSafeForUser(message))
              ? message
              : ApiErrorHandler.fromStatusCode(response.statusCode, rawData: map);

          return ApiResponse.error(
            message: safeMessage,
            statusCode: response.statusCode,
            errorCode: errorCode,
            data: map['data'],
          );
        }

        // Unpack data field when wrapped with global response schema
        final dynamic unwrapped = (map.containsKey('data') && map.containsKey('success'))
            ? map['data']
            : response.data;

        return ApiResponse.success(
          data: unwrapped,
          message: message ?? "Success",
          statusCode: response.statusCode,
          errorCode: errorCode,
        );
      }

      return ApiResponse.success(
        data: response.data,
        message: "Success",
        statusCode: response.statusCode,
      );
    }

    String? errorCode;
    if (response.data is Map) {
      errorCode = (response.data as Map)['errorCode']?.toString();
    }

    final safeMessage = ApiErrorHandler.fromStatusCode(
      response.statusCode,
      rawData: response.data,
    );

    return ApiResponse.error(
      message: safeMessage,
      statusCode: response.statusCode,
      errorCode: errorCode,
      data: response.data is Map && (response.data as Map).containsKey('data')
          ? (response.data as Map)['data']
          : response.data,
    );
  }

  static ApiResponse _handleDioError(DioException e) {
    final safeMessage = ApiErrorHandler.fromDioException(e);
    final statusCode = e.response?.statusCode ?? (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout
        ? 408
        : 0);

    String? errorCode;
    dynamic errorData = e.response?.data;

    if (e.response?.data is Map) {
      final errMap = Map<String, dynamic>.from(e.response!.data as Map);
      errorCode = errMap['errorCode']?.toString();
      if (errMap.containsKey('data')) {
        errorData = errMap['data'];
      }
    }

    if (statusCode == 401) {
      return ApiResponse.error(
        message: "Your session has expired. Please sign in again.",
        statusCode: 401,
        errorCode: errorCode ?? "UNAUTHORIZED",
        data: errorData,
      );
    }

    return ApiResponse.error(
      message: safeMessage,
      statusCode: statusCode,
      errorCode: errorCode,
      data: errorData,
    );
  }
}

/// Production-ready network logger interceptor that pretty-prints requests, responses,
/// and errors in a formatted, human-readable layout while automatically redacting sensitive tokens and credentials.
class _SafeNetworkLoggerInterceptor extends Interceptor {
  static const _jsonEncoder = JsonEncoder.withIndent('  ');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final sanitizedHeaders = Map<String, dynamic>.from(options.headers);
      if (sanitizedHeaders.containsKey('Authorization')) {
        sanitizedHeaders['Authorization'] = 'Bearer [REDACTED]';
      }
      final sanitizedData = _sanitizeData(options.data);
      final query = options.queryParameters.isNotEmpty ? " | Params: ${_pretty(options.queryParameters)}" : "";

      debugPrint("┌─────────────────────────────────────────────────────────────────────────");
      debugPrint("│ 🚀 [HTTP REQUEST] --> ${options.method} ${options.uri}$query");
      debugPrint("│ Headers: ${_pretty(sanitizedHeaders)}");
      if (sanitizedData != null) {
        debugPrint("│ Request Payload:\n${_indent(_pretty(sanitizedData))}");
      }
      debugPrint("└─────────────────────────────────────────────────────────────────────────");
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint("┌─────────────────────────────────────────────────────────────────────────");
      debugPrint("│ ✅ [HTTP RESPONSE] <-- ${response.statusCode} ${response.requestOptions.uri}");
      if (response.data != null) {
        debugPrint("│ Response Payload:\n${_indent(_pretty(response.data))}");
      }
      debugPrint("└─────────────────────────────────────────────────────────────────────────");
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint("┌─────────────────────────────────────────────────────────────────────────");
      debugPrint("│ ❌ [HTTP ERROR] <-- ${err.response?.statusCode ?? 'NO_STATUS'} ${err.requestOptions.uri}");
      debugPrint("│ Message: ${err.message}");
      if (err.requestOptions.data != null) {
        debugPrint("│ Request Payload:\n${_indent(_pretty(_sanitizeData(err.requestOptions.data)))}");
      }
      if (err.response?.data != null) {
        debugPrint("│ Error Response Payload:\n${_indent(_pretty(err.response?.data))}");
      }
      debugPrint("└─────────────────────────────────────────────────────────────────────────");
    }
    return handler.next(err);
  }

  String _pretty(dynamic data) {
    try {
      if (data is Map || data is List) {
        return _jsonEncoder.convert(data);
      }
      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }

  String _indent(String text) {
    return text.split('\n').map((line) => '│   $line').join('\n');
  }

  dynamic _sanitizeData(dynamic data) {
    if (data is Map) {
      final sanitized = <String, dynamic>{};
      for (final entry in data.entries) {
        final key = entry.key.toString().toLowerCase();
        if (key.contains('password') ||
            key.contains('token') ||
            key.contains('otp') ||
            key.contains('secret') ||
            key.contains('auth') ||
            key.contains('key') ||
            key.contains('credential')) {
          sanitized[entry.key.toString()] = '[REDACTED]';
        } else {
          sanitized[entry.key.toString()] = _sanitizeData(entry.value);
        }
      }
      return sanitized;
    }
    return data;
  }
}


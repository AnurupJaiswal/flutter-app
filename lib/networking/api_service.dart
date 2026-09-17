import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:lala_ai/app/routes/app_routes.dart';
import 'package:lala_ai/networking/api_endpoints.dart';
import 'package:lala_ai/networking/api_response.dart';
import 'package:lala_ai/utils/common_methods.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:lala_ai/Models/creator_profile_model.dart';
import 'package:lala_ai/Models/connected_accounts_model.dart';
import 'package:lala_ai/Models/subscription_model.dart';
import 'package:lala_ai/Models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

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

  /// Returns true if an active access token exists
  static bool get isAuthenticated => token != null && token!.trim().isNotEmpty;

  /// Returns the standardized display name for the user across the entire app.
  /// Priority:
  /// 1. currentCreatorProfile.displayName
  /// 2. currentUser.displayName
  /// 3. userName (persisted display name)
  /// 4. currentUser.fullName / currentUser.name
  /// 5. Fallback: "Creator"
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

  static bool _sessionExpiredDialogShowing = false;
  static bool _isRefreshing = false;
  static final Dio _dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
      responseType: ResponseType.json,
    ));

    // Request Interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (token != null && token!.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token expired, attempt refresh
          if (refreshToken != null && refreshToken!.isNotEmpty) {
            final refreshed = await _attemptRefresh(dio);
            if (refreshed) {
              // Retry the original request
              final retryOptions = Options(
                method: e.requestOptions.method,
                headers: e.requestOptions.headers,
              );
              // Update authorization header
              retryOptions.headers?['Authorization'] = 'Bearer $token';
              try {
                final retryResponse = await dio.request(
                  e.requestOptions.path,
                  options: retryOptions,
                  data: e.requestOptions.data,
                  queryParameters: e.requestOptions.queryParameters,
                );
                return handler.resolve(retryResponse);
              } catch (retryError) {
                return handler.next(e);
              }
            } else {
              _handleSessionExpired();
              return handler.next(e);
            }
          } else {
            _handleSessionExpired();
            return handler.next(e);
          }
        }
        return handler.next(e);
      },
    ));

    // Logger Interceptor
    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));

    return dio;
  }

  static Future<bool> _attemptRefresh(Dio dio) async {
    if (_isRefreshing) return false;
    _isRefreshing = true;
    try {
      // Use a separate Dio instance or clear authorization to avoid loops
      final refreshDio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
      final response = await refreshDio.post(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] ?? response.data;
        final newToken = data['accessToken'];
        final newRefresh = data['refreshToken'];

        if (newToken != null) {
          token = newToken;
          if (newRefresh != null) refreshToken = newRefresh;

          final pref = await SharedPreferences.getInstance();
          await pref.setString('accessToken', token!);
          if (refreshToken != null) await pref.setString('refreshToken', refreshToken!);

          _isRefreshing = false;
          return true;
        }
      }
    } catch (e) {
      CM.log(msg: "Token refresh failed: $e");
    }
    _isRefreshing = false;
    return false;
  }

  static void _handleSessionExpired() {
    if (!_sessionExpiredDialogShowing) {
      _sessionExpiredDialogShowing = true;
      CM.showToast("Session expired. Please log in again.", isError: true);
      logout();
      _sessionExpiredDialogShowing = false;
    }
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

    final pref = await SharedPreferences.getInstance();
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
      return ApiResponse.error(message: "An unexpected error occurred: $e");
    }
  }

  static Future<ApiResponse> post(String endpoint, {dynamic body, dynamic data}) async {
    try {
      final payload = body ?? data;
      final response = await _dio.post(endpoint, data: payload);
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(message: "An unexpected error occurred: $e");
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
      return ApiResponse.error(message: "An unexpected error occurred: $e");
    }
  }

  static Future<ApiResponse> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error(message: "An unexpected error occurred: $e");
    }
  }

  static ApiResponse _handleResponse(Response response) {
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
      return ApiResponse.success(
        data: response.data,
        message: response.data is Map ? response.data['message'] : null,
        statusCode: response.statusCode,
      );
    }
    String defaultMessage = "Oops! Something went wrong on our end. Please try again later.";

    return ApiResponse.error(
      message: _extractErrorMessage(response.data) ?? defaultMessage,
      statusCode: response.statusCode,
      data: response.data,
    );
  }

  static ApiResponse _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return ApiResponse.error(message: "Connection timed out. Please try again.", statusCode: 408);
    }

    if (e.response != null) {
      if (e.response!.statusCode == 401) {
        return ApiResponse.error(
          message: "Unauthorized. Session expired.",
          statusCode: 401,
          data: e.response!.data,
        );
      }
      String defaultMessage = "Oops! Something went wrong on our end. Please try again later.";

      return ApiResponse.error(
        message: _extractErrorMessage(e.response!.data) ?? defaultMessage,
        statusCode: e.response!.statusCode,
        data: e.response!.data,
      );
    }
    return ApiResponse.error(message: "Network connection failed.", statusCode: 0);
  }

  static String? _extractErrorMessage(dynamic data) {
    if (data is Map) {
      return data['message']?.toString() ?? data['error']?.toString();
    }
    return null;
  }
}

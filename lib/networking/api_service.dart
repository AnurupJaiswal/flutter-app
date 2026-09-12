import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lala_ai/app/routes/app_routes.dart';
import 'package:lala_ai/networking/api_endpoints.dart';
import 'package:lala_ai/networking/api_response.dart';
import 'package:lala_ai/utils/common_methods.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  ApiService._();

  static const Duration timeout = Duration(seconds: 30);

  static String? token;
  static String? refreshToken;
  static String? userUuid;
  static String? userEmail;
  static String? userName;

  static bool _sessionExpiredDialogShowing = false;

  /// Clear token and saved session, navigate to login
  static Future<void> logout() async {
    token = null;
    refreshToken = null;
    userUuid = null;
    userEmail = null;
    userName = null;

    final pref = await SharedPreferences.getInstance();
    await pref.remove('accessToken');
    await pref.remove('refreshToken');
    await pref.remove('userUuid');
    await pref.remove('userEmail');
    await pref.remove('userName');

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
              style: TS.button(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  static Map<String, String> _buildHeaders({
    bool requiresAuth = true,
    Map<String, String>? extraHeaders,
  }) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth && token != null && token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  static String _fullUrl(String endpoint) {
    if (endpoint.startsWith('http://') || endpoint.startsWith('https://')) {
      return endpoint;
    }
    return '${ApiEndpoints.baseUrl}$endpoint';
  }

  static Future<ApiResponse> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    Map<String, String>? headers,
  }) async {
    try {
      var uri = Uri.parse(_fullUrl(endpoint));
      if (queryParameters != null && queryParameters.isNotEmpty) {
        final stringParams = queryParameters.map(
          (k, v) => MapEntry(k, v.toString()),
        );
        uri = uri.replace(queryParameters: stringParams);
      }

      final response = await http
          .get(uri, headers: _buildHeaders(requiresAuth: requiresAuth, extraHeaders: headers))
          .timeout(timeout);

      return _handleResponse(response);
    } on TimeoutException {
      return ApiResponse.error(message: "Connection timed out. Please try again.");
    } catch (e) {
      CM.log(msg: "ApiService.get error: $e");
      return ApiResponse.error(message: "Network error: $e");
    }
  }

  static Future<ApiResponse> post(
    String endpoint, {
    dynamic body,
    dynamic data,
    bool requiresAuth = true,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse(_fullUrl(endpoint));
      final payload = body ?? data;
      final encodedBody = payload is String ? payload : (payload != null ? jsonEncode(payload) : null);

      final response = await http
          .post(
            uri,
            headers: _buildHeaders(requiresAuth: requiresAuth, extraHeaders: headers),
            body: encodedBody,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on TimeoutException {
      return ApiResponse.error(message: "Connection timed out. Please try again.");
    } catch (e) {
      CM.log(msg: "ApiService.post error: $e");
      return ApiResponse.error(message: "Network error: $e");
    }
  }

  static Future<ApiResponse> put(
    String endpoint, {
    dynamic body,
    dynamic data,
    bool requiresAuth = true,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse(_fullUrl(endpoint));
      final payload = body ?? data;
      final encodedBody = payload is String ? payload : (payload != null ? jsonEncode(payload) : null);

      final response = await http
          .put(
            uri,
            headers: _buildHeaders(requiresAuth: requiresAuth, extraHeaders: headers),
            body: encodedBody,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on TimeoutException {
      return ApiResponse.error(message: "Connection timed out. Please try again.");
    } catch (e) {
      CM.log(msg: "ApiService.put error: $e");
      return ApiResponse.error(message: "Network error: $e");
    }
  }

  static Future<ApiResponse> delete(
    String endpoint, {
    bool requiresAuth = true,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse(_fullUrl(endpoint));
      final response = await http
          .delete(uri, headers: _buildHeaders(requiresAuth: requiresAuth, extraHeaders: headers))
          .timeout(timeout);

      return _handleResponse(response);
    } on TimeoutException {
      return ApiResponse.error(message: "Connection timed out. Please try again.");
    } catch (e) {
      CM.log(msg: "ApiService.delete error: $e");
      return ApiResponse.error(message: "Network error: $e");
    }
  }

  static ApiResponse _handleResponse(http.Response response) {
    dynamic decodedData;
    try {
      decodedData = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (_) {
      decodedData = response.body;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.success(
        data: decodedData,
        statusCode: response.statusCode,
      );
    } else if (response.statusCode == 401) {
      if (!_sessionExpiredDialogShowing) {
        _sessionExpiredDialogShowing = true;
        CM.showToast("Session expired. Please log in again.", isError: true);
        logout();
        _sessionExpiredDialogShowing = false;
      }
      return ApiResponse.error(
        message: "Unauthorized",
        statusCode: 401,
        data: decodedData,
      );
    } else {
      String? errorMessage;
      if (decodedData is Map<String, dynamic>) {
        errorMessage = decodedData['message']?.toString() ??
            decodedData['error']?.toString();
      }
      return ApiResponse.error(
        message: errorMessage ?? "Request failed with status: ${response.statusCode}",
        statusCode: response.statusCode,
        data: decodedData,
      );
    }
  }
}

import 'dart:io';
import 'package:dio/dio.dart';

/// Centralized API and Network Error Handler for Lala AI.
/// Translates raw Dio/HTTP/Network/Backend exceptions into safe, human-readable UI messages.
/// Ensures technical details (DioException, stack traces, Cloudflare error codes, 530, etc.)
/// are NEVER exposed to the end user while preserving developer diagnostic logs.
class ApiErrorHandler {
  ApiErrorHandler._();

  /// Standard User-Friendly HTTP Status Error Messages
  static const Map<int, String> _statusMessages = {
    400: "Something is wrong with your request. Please try again.",
    401: "Your session has expired. Please sign in again.",
    403: "You don't have permission to perform this action.",
    404: "The requested information could not be found.",
    408: "The request took too long. Please try again.",
    409: "This action could not be completed. Please try again.",
    422: "Please check your information and try again.",
    429: "Too many requests. Please wait a moment and try again.",
    500: "Something went wrong on the server. Please try again.",
    502: "The server is temporarily unavailable. Please try again in a moment.",
    503: "The service is temporarily unavailable. Please try again shortly.",
    504: "The server took too long to respond. Please try again.",
    530: "The service is temporarily unavailable. Please try again in a moment.",
  };

  /// Fallback error messages for connection/network types
  static const String noInternetMessage =
      "No internet connection. Please check your connection and try again.";
  static const String timeoutMessage =
      "The request took too long. Please try again.";
  static const String connectionFailedMessage =
      "Unable to connect to the server. Please try again.";
  static const String defaultGenericMessage =
      "Something went wrong. Please try again.";

  /// Main entry point: converts any exception or DioException to a safe, user-friendly string.
  static String getMessage(dynamic error, {int? statusCode, String? customFallback}) {
    if (error is DioException) {
      return fromDioException(error, customFallback: customFallback);
    }

    if (error is SocketException) {
      return noInternetMessage;
    }

    if (statusCode != null) {
      return fromStatusCode(statusCode, customFallback: customFallback);
    }

    if (error != null) {
      final str = error.toString();
      if (_isTechnicalOrUnsafe(str)) {
        return customFallback ?? defaultGenericMessage;
      }
      final sanitized = _sanitizeUserMessage(str);
      if (sanitized.isNotEmpty && isSafeForUser(sanitized)) {
        return sanitized;
      }
    }

    return customFallback ?? defaultGenericMessage;
  }

  /// Maps HTTP status code to user-friendly message, evaluating backend message safety when available.
  static String fromStatusCode(int? statusCode, {dynamic rawData, String? customFallback}) {
    if (statusCode == null) {
      return customFallback ?? defaultGenericMessage;
    }

    // 1. Try to extract and validate backend message for 4xx client errors (e.g. 400, 409, 422)
    if (rawData != null && statusCode >= 400 && statusCode < 500 && statusCode != 401) {
      final backendMsg = _extractRawMessage(rawData);
      if (backendMsg != null && backendMsg.isNotEmpty && isSafeForUser(backendMsg)) {
        return _sanitizeUserMessage(backendMsg);
      }
    }

    // 2. Map known HTTP status codes
    if (_statusMessages.containsKey(statusCode)) {
      return _statusMessages[statusCode]!;
    }

    // 3. Status range fallbacks
    if (statusCode >= 500) {
      return "Something went wrong on the server. Please try again.";
    }

    if (statusCode >= 400) {
      return "Something is wrong with your request. Please try again.";
    }

    return customFallback ?? defaultGenericMessage;
  }

  /// Translates DioException into clean user message
  static String fromDioException(DioException error, {String? customFallback}) {
    // 1. If HTTP response was received from server
    if (error.response != null) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;
      return fromStatusCode(statusCode, rawData: data, customFallback: customFallback);
    }

    // 2. If no response received (Network / Timeout / Socket / Cancellation)
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return timeoutMessage;

      case DioExceptionType.connectionError:
        if (error.error is SocketException) {
          return noInternetMessage;
        }
        return connectionFailedMessage;

      case DioExceptionType.badCertificate:
        return "Secure connection could not be established. Please try again.";

      case DioExceptionType.cancel:
        return "Request was cancelled.";

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return noInternetMessage;
        }
        final rawMsg = error.message ?? error.error?.toString() ?? "";
        if (rawMsg.toLowerCase().contains("socket") ||
            rawMsg.toLowerCase().contains("network") ||
            rawMsg.toLowerCase().contains("failed host lookup") ||
            rawMsg.toLowerCase().contains("connection refused")) {
          return connectionFailedMessage;
        }
        return customFallback ?? defaultGenericMessage;

      case DioExceptionType.badResponse:
        return fromStatusCode(error.response?.statusCode, rawData: error.response?.data, customFallback: customFallback);

      default:
        return customFallback ?? defaultGenericMessage;
    }
  }

  /// Extracts raw message string from response data (Map or String)
  static String? _extractRawMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final msg = data['message'] ??
          data['error'] ??
          data['msg'] ??
          data['errorMessage'] ??
          data['detail'];
      if (msg != null && msg is String) return msg.trim();
      if (msg != null && msg is List && msg.isNotEmpty) {
        return msg.first.toString().trim();
      }
    }

    if (data is String) {
      final trimmed = data.trim();
      if (!trimmed.startsWith('{') && !trimmed.startsWith('<')) {
        return trimmed;
      }
    }

    return null;
  }

  /// Verifies if a message is strictly safe to display to an end-user in production
  static bool isSafeForUser(String message) {
    if (message.isEmpty || message.length > 250) return false;
    return !_isTechnicalOrUnsafe(message);
  }

  /// Identifies technical jargon, stack traces, cloudflare errors, DB syntax, or internal exceptions
  static bool _isTechnicalOrUnsafe(String str) {
    final lower = str.toLowerCase();

    // HTML / Cloudflare error page indicators
    if (lower.contains("<html") ||
        lower.contains("<!doctype") ||
        lower.contains("<body") ||
        lower.contains("<head") ||
        lower.contains("<div") ||
        lower.contains("cloudflare") ||
        lower.contains("1033") ||
        lower.contains("trycloudflare") ||
        lower.contains("ray id") ||
        lower.contains("cf-ray")) {
      return true;
    }

    // Framework / Library / Exception names
    if (lower.contains("dioexception") ||
        lower.contains("requestoptions") ||
        lower.contains("validatestatus") ||
        lower.contains("socketexception") ||
        lower.contains("httpexception") ||
        lower.contains("nullpointerexception") ||
        lower.contains("formatexception") ||
        lower.contains("typeerror") ||
        lower.contains("status code of") ||
        lower.contains("status code 530") ||
        lower.contains("status code 502") ||
        lower.contains("status code 500")) {
      return true;
    }

    // Stack trace / Code details
    if (lower.contains("traceback") ||
        lower.contains("at line") ||
        lower.contains("exception:") ||
        lower.contains("error:") ||
        lower.contains("at com.") ||
        lower.contains("at org.") ||
        lower.contains(".dart:") ||
        lower.contains(".js:") ||
        lower.contains(".ts:") ||
        lower.contains("unhandled exception")) {
      return true;
    }

    // Database / SQL / Backend internal details
    if (lower.contains("syntax error") ||
        lower.contains("foreign key") ||
        lower.contains("constraint") ||
        lower.contains("table '") ||
        lower.contains("column '") ||
        lower.contains("sqlstate") ||
        lower.contains("postgres") ||
        lower.contains("prisma") ||
        lower.contains("mongoose") ||
        lower.contains("internal_server_error")) {
      return true;
    }

    // JSON fragments
    if ((str.startsWith("{") && str.endsWith("}")) ||
        (str.startsWith("[") && str.endsWith("]"))) {
      return true;
    }

    return false;
  }

  /// Sanitizes whitespace, punctuation, and casing
  static String _sanitizeUserMessage(String message) {
    var cleaned = message.trim();
    if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
      cleaned = cleaned.substring(1, cleaned.length - 1).trim();
    }
    return cleaned;
  }
}

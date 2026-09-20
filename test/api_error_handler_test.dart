import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lala_ai/networking/api_error_handler.dart';

void main() {
  group('ApiErrorHandler Status Codes', () {
    test('400 returns friendly request error', () {
      final msg = ApiErrorHandler.fromStatusCode(400);
      expect(msg, 'Something is wrong with your request. Please try again.');
    });

    test('401 returns session expired error', () {
      final msg = ApiErrorHandler.fromStatusCode(401);
      expect(msg, 'Your session has expired. Please sign in again.');
    });

    test('403 returns permission error', () {
      final msg = ApiErrorHandler.fromStatusCode(403);
      expect(msg, "You don't have permission to perform this action.");
    });

    test('404 returns not found error', () {
      final msg = ApiErrorHandler.fromStatusCode(404);
      expect(msg, 'The requested information could not be found.');
    });

    test('408 returns timeout error', () {
      final msg = ApiErrorHandler.fromStatusCode(408);
      expect(msg, 'The request took too long. Please try again.');
    });

    test('409 returns conflict error or safe message', () {
      final msgDefault = ApiErrorHandler.fromStatusCode(409);
      expect(msgDefault, 'This action could not be completed. Please try again.');

      final msgCustom = ApiErrorHandler.fromStatusCode(409, rawData: {'message': 'Channel is already connected'});
      expect(msgCustom, 'Channel is already connected');
    });

    test('422 returns validation error or safe message', () {
      final msgDefault = ApiErrorHandler.fromStatusCode(422);
      expect(msgDefault, 'Please check your information and try again.');

      final msgCustom = ApiErrorHandler.fromStatusCode(422, rawData: {'message': 'Invalid email format'});
      expect(msgCustom, 'Invalid email format');
    });

    test('429 returns rate limit error', () {
      final msg = ApiErrorHandler.fromStatusCode(429);
      expect(msg, 'Too many requests. Please wait a moment and try again.');
    });

    test('500 returns server error', () {
      final msg = ApiErrorHandler.fromStatusCode(500);
      expect(msg, 'Something went wrong on the server. Please try again.');
    });

    test('502 returns service unavailable', () {
      final msg = ApiErrorHandler.fromStatusCode(502);
      expect(msg, 'The server is temporarily unavailable. Please try again in a moment.');
    });

    test('503 returns service unavailable shortly', () {
      final msg = ApiErrorHandler.fromStatusCode(503);
      expect(msg, 'The service is temporarily unavailable. Please try again shortly.');
    });

    test('504 returns gateway timeout', () {
      final msg = ApiErrorHandler.fromStatusCode(504);
      expect(msg, 'The server took too long to respond. Please try again.');
    });

    test('530 returns service unavailable and hides Cloudflare 1033', () {
      final msg = ApiErrorHandler.fromStatusCode(530);
      expect(msg, 'The service is temporarily unavailable. Please try again in a moment.');

      final dioError530 = DioException(
        requestOptions: RequestOptions(path: '/api/v1/creators/me/connections'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/creators/me/connections'),
          statusCode: 530,
          data: '<html><title>530 Cloudflare error 1033</title><body>Error 1033 Ray ID: 888...</body></html>',
        ),
      );
      final handled = ApiErrorHandler.fromDioException(dioError530);
      expect(handled, 'The service is temporarily unavailable. Please try again in a moment.');
      expect(handled.contains('530'), isFalse);
      expect(handled.contains('Cloudflare'), isFalse);
      expect(handled.contains('1033'), isFalse);
    });
  });

  group('ApiErrorHandler Network & Timeout Exceptions', () {
    test('SocketException returns no internet message', () {
      final msg = ApiErrorHandler.getMessage(const SocketException('Failed host lookup'));
      expect(msg, 'No internet connection. Please check your connection and try again.');
    });

    test('Connection timeout DioException returns timeout message', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );
      final msg = ApiErrorHandler.fromDioException(dioErr);
      expect(msg, 'The request took too long. Please try again.');
    });

    test('Connection error returns connection failure message', () {
      final dioErr = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );
      final msg = ApiErrorHandler.fromDioException(dioErr);
      expect(msg, 'Unable to connect to the server. Please try again.');
    });
  });

  group('ApiErrorHandler Message Sanitization & Unsafe Jargon Blocking', () {
    test('Unsafe raw exception strings are converted to default friendly messages', () {
      expect(
        ApiErrorHandler.getMessage('DioException [bad response]: This exception was thrown because the response has a status code of 530'),
        'Something went wrong. Please try again.',
      );
      expect(
        ApiErrorHandler.getMessage('Exception: org.postgresql.util.PSQLException: ERROR: syntax error at or near "SELECT"'),
        'Something went wrong. Please try again.',
      );
      expect(
        ApiErrorHandler.getMessage('SocketException: OS Error: Connection refused, errno = 111'),
        'Something went wrong. Please try again.',
      );
    });

    test('Safe user messages are preserved', () {
      expect(
        ApiErrorHandler.getMessage('Channel disconnected successfully'),
        'Channel disconnected successfully',
      );
    });
  });
}

import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_dream247/core/constants/storage_constants.dart';

class ApiImpl {
  final Dio _dio;

  ApiImpl()
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {"Content-Type": "application/json"},
        ),
      );

  /// Get unified user ID from storage
  Future<String> _getUnifiedUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(StorageConstants.userId) ?? '';
    } catch (e) {
      debugPrint('Error getting user ID: $e');
      return '';
    }
  }

  /// Get auth token from storage
  Future<String> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(StorageConstants.authToken) ?? '';
    } catch (e) {
      debugPrint('Error getting auth token: $e');
      return '';
    }
  }

  /// Common request executor with retry + logging
  Future<Response> _request(
    String method,
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    int retryCount = 3,
  }) async {
    int attempt = 0;

    while (attempt < retryCount) {
      try {
        // Get unified user ID and auth token
        final userId = await _getUnifiedUserId();
        final token = await _getAuthToken();

        // Build final headers with unified auth
        final finalHeaders = {
          ..._dio.options.headers.cast<String, String>(),
          if (headers != null) ...headers,
          // Add unified user ID header for Fantasy APIs
          if (userId.isNotEmpty) 'X-User-ID': userId,
          // Add Authorization header with unified token
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        };

        final options = Options(
          method: method,
          headers: finalHeaders,
        );

        debugPrint('============ ENDPOINT ===============');
        debugPrint(url);
        debugPrint('============ METHOD =================');
        debugPrint(method);
        debugPrint('============ HEADERS ================');
        debugPrint(options.headers.toString());
        debugPrint('============ BODY ===================');
        debugPrint(body?.toString() ?? "No Body");

        final response = await _dio.request(
          url,
          data: body,
          queryParameters: queryParameters,
          options: options,
        );

        debugPrint('============ RESPONSE ===============');
        debugPrint(response.data.toString());

        if (response.statusCode != null && response.statusCode! >= 400) {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
          );
        }

        return response;
      } on DioException catch (e) {
        debugPrint("Dio error: ${e.message}");
        if (attempt == retryCount - 1) rethrow;
      } on TimeoutException {
        debugPrint("Request timed out. Retrying...");
      } on SocketException catch (_) {
        debugPrint("No internet. Retrying...");
      }

      attempt++;
      await Future.delayed(Duration(seconds: 2 * attempt));
    }

    throw Exception("Request failed after $retryCount attempts.");
  }

  // Public Methods:

  Future<Response> get(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) {
    return _request(
      'GET',
      url,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  Future<Response> post(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) {
    return _request('POST', url, body: body, headers: headers);
  }

  Future<Response> put(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) {
    return _request('PUT', url, body: body, headers: headers);
  }

  Future<Response> patch(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) {
    return _request('PATCH', url, body: body, headers: headers);
  }

  Future<Response> delete(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) {
    return _request('DELETE', url, body: body, headers: headers);
  }

  Future<Uint8List> readBytes(
    String url, {
    Map<String, String>? headers,
  }) async {
    final response = await _request('GET', url, headers: headers);
    return response.data;
  }

  void close() {
    _dio.close(force: true);
  }
}

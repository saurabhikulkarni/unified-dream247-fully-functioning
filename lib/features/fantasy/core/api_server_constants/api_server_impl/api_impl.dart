import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:unified_dream247/core/services/auth_service.dart' as core_auth;
import 'package:unified_dream247/core/constants/api_constants.dart';
import 'package:unified_dream247/features/fantasy/core/utils/user_id_helper.dart';

class ApiImpl {
  final Dio _dio;

  ApiImpl()
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        ),
      );

  /// Get headers with unified auth token and userId
  Future<Map<String, String>> getHeaders() async {
    final authService = core_auth.AuthService();
    await authService.initialize();
    final token = await authService.getValidToken(ApiConstants.fantasyBackendUrl);
    
    // Get userId from unified storage
    final userId = await UserIdHelper.getUnifiedUserId();
    
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
      'Accept': 'application/json',
    };
    
    // Add userId header if available (Hygraph user ID)
    if (userId.isNotEmpty) {
      headers['X-User-ID'] = userId;
      if (kDebugMode) {
        debugPrint('📝 [API] Added userId header: ${userId.substring(0, userId.length > 20 ? 20 : userId.length)}...');
      }
    } else {
      debugPrint('⚠️ [API] No userId available for X-User-ID header');
    }
    
    return headers;
  }

  /// Common request executor with retry + logging + auto token refresh
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
        // Get unified auth headers
        final authHeaders = await getHeaders();
        
        final options = Options(
          method: method,
          headers: {
            ..._dio.options.headers,
            ...authHeaders,
            if (headers != null) ...headers,
          },
        );

        debugPrint('============ METHOD =================');
        debugPrint(method);
        debugPrint('============ HEADERS ================');
        debugPrint(options.headers.toString());
        debugPrint('============ BODY ===================');
        debugPrint(body?.toString() ?? 'No Body');

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
        // If 401, token might have expired during request, try refresh
        if (e.response?.statusCode == 401 && attempt == 0) {
          debugPrint('Token expired, attempting refresh...');
          final authService = core_auth.AuthService();
          await authService.initialize();
          final newToken = await authService.refreshAccessToken(ApiConstants.fantasyBackendUrl);
          
          if (newToken != null) {
            // Retry the request with new token
            attempt++;
            continue;
          }
        }
        
        debugPrint('Dio error: ${e.message}');
        if (attempt == retryCount - 1) rethrow;
      } on TimeoutException {
        debugPrint('Request timed out. Retrying...');
      } on SocketException catch (_) {
        debugPrint('No internet. Retrying...');
      }

      attempt++;
      await Future.delayed(Duration(seconds: 2 * attempt));
    }

    throw Exception('Request failed after $retryCount attempts.');
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

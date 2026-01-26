// ignore_for_file: unrelated_type_equality_checks

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_keys.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_storage_keys.dart';

class ApiImplWithAccessToken {
  final Dio _dio;
  final Connectivity _connectivity = Connectivity();

  ApiImplWithAccessToken()
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );

  /// Check if JWT token is expired
  bool _isTokenExpired(String token) {
    try {
      // JWT format: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) {
        debugPrint('⚠️ [TOKEN] Invalid JWT format');
        return true;
      }

      // Decode payload (base64url)
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;

      // Check expiry
      final exp = payloadMap['exp'];
      if (exp == null) {
        debugPrint('⚠️ [TOKEN] No expiry in token');
        return false; // No expiry means it doesn't expire
      }

      final expiryTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();
      final isExpired = now.isAfter(expiryTime);

      if (isExpired) {
        debugPrint('⚠️ [TOKEN] Token expired at $expiryTime (now: $now)');
      } else {
        final remaining = expiryTime.difference(now);
        debugPrint('✅ [TOKEN] Token valid for ${remaining.inMinutes} minutes');
      }

      return isExpired;
      return isExpired;
    } catch (e) {
      debugPrint('⚠️ [TOKEN] Error checking expiry (might not be JWT): $e');
      // If we can't parse it as JWT, assume it's a simple API Key and Valid
      // Do NOT assume expired, as that deletes the token!
      return false; 
    }
  }

  Future<Response> _request(
    String method,
    String url, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    bool isJson = true,
    bool showLog = true,
    int retryCount = 3,
    String? customToken,
  }) async {
    int attempt = 0;

    while (attempt < retryCount) {
      try {
        final connectivityResult = await _connectivity.checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          throw const SocketException('No internet connection');
        }

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = customToken;
        
        // If custom token is not provided, try to load from storage
        if (token == null || token.isEmpty) {
           token = prefs.getString(AppStorageKeys.authToken);
           
           // Fallback checks
           if (token == null || token.isEmpty) token = prefs.getString('token'); // Canonical shared key
           if (token == null || token.isEmpty) token = prefs.getString('auth_token'); // Legacy key
           if (token == null || token.isEmpty) token = prefs.getString('temp_otp_token'); // Recovery key
        }

        // Debug: Log token status
        if (token == null || token.isEmpty) {
          debugPrint('⚠️ [FANTASY API] No auth token found!');
        } else {
          // Check expiry if we loaded from storage (trusted custom tokens assumed valid/checked by caller)
          if (customToken == null && _isTokenExpired(token)) {
             debugPrint('🔄 [FANTASY API] Stored token expired, dropping.');
             token = null;
          }
        }

        final Map<String, String> headers = {
          if (isJson) ApiServerKeys.contentType: ApiServerKeys.applicationJson,
          if (token != null && token.isNotEmpty)
            ApiServerKeys.authorization: 'Bearer $token',
        };

        final Options options = Options(
          method: method,
          headers: headers,
          responseType: ResponseType.json,
          validateStatus: (status) => true,
        );
        if (showLog) {
          debugPrint('============ ENDPOINT ===============');
          debugPrint(url);
          debugPrint('============ METHOD =================');
          debugPrint(method);
          debugPrint('============ HEADERS ================');
          debugPrint(headers.toString());
          debugPrint('============ BODY ===================');
          debugPrint(body?.toString() ?? 'No Body');
        }

        final response = await _dio.request(
          url,
          data: body,
          queryParameters: queryParameters,
          options: options,
        );

        if (showLog) {
          debugPrint('============ STATUS CODE ===================');
          debugPrint(response.statusCode.toString());
          debugPrint('============ RESPONSE ===============');
          debugPrint(response.data.toString());
        }

        return response;
      } catch (e) {
        if (e is SocketException ||
            e is TimeoutException ||
            e is DioException) {
          if (attempt == retryCount - 1) rethrow;
          await Future.delayed(Duration(milliseconds: 1000 * (attempt + 1)));
        } else {
          rethrow;
        }
      }

      attempt++;
    }

    throw Exception('Request failed after $retryCount attempts.');
  }

  // Public Methods:

  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    bool showLog = true,
    String? token,
  }) {
    return _request(
      'GET',
      url,
      queryParameters: queryParameters,
      showLog: showLog,
      customToken: token,
    );
  }

  Future<Response> post(
    String url, {
    Map<String, dynamic>? body,
    bool showLog = true,
    String? token,
  }) {
    return _request('POST', url, body: body, showLog: showLog, customToken: token);
  }

  Future<Response> put(
    String url, {
    Map<String, dynamic>? body,
    bool showLog = true,
    String? token,
  }) {
    return _request('PUT', url, body: body, showLog: showLog, customToken: token);
  }

  Future<Response> patch(
    String url, {
    Map<String, dynamic>? body,
    bool showLog = true,
    String? token,
  }) {
    return _request('PATCH', url, body: body, showLog: showLog, customToken: token);
  }

  Future<Response> delete(
    String url, {
    Map<String, dynamic>? body,
    bool showLog = true,
    String? token,
  }) {
    return _request('DELETE', url, body: body, showLog: showLog, customToken: token);
  }

  Future<Uint8List> readBytes(String url, {bool showLog = true}) async {
    final response = await _request(
      'GET',
      url,
      showLog: showLog,
      isJson: false,
    );
    return Uint8List.fromList(response.data);
  }

  void close() {
    _dio.close(force: true);
  }
}

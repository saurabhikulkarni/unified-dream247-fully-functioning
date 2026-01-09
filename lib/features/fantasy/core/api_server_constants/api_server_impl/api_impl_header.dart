// ignore_for_file: unrelated_type_equality_checks

import 'dart:async';
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
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );

  Future<Response> _request(
    String method,
    String url, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    bool isJson = true,
    bool showLog = true,
    int retryCount = 3,
  }) async {
    int attempt = 0;

    while (attempt < retryCount) {
      try {
        final connectivityResult = await _connectivity.checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          throw const SocketException('No internet connection');
        }

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(AppStorageKeys.authToken);

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

    throw Exception("Request failed after $retryCount attempts.");
  }

  // Public Methods:

  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    bool showLog = true,
  }) {
    return _request(
      'GET',
      url,
      queryParameters: queryParameters,
      showLog: showLog,
    );
  }

  Future<Response> post(
    String url, {
    Map<String, dynamic>? body,
    bool showLog = true,
  }) {
    return _request('POST', url, body: body, showLog: showLog);
  }

  Future<Response> put(
    String url, {
    Map<String, dynamic>? body,
    bool showLog = true,
  }) {
    return _request('PUT', url, body: body, showLog: showLog);
  }

  Future<Response> patch(
    String url, {
    Map<String, dynamic>? body,
    bool showLog = true,
  }) {
    return _request('PATCH', url, body: body, showLog: showLog);
  }

  Future<Response> delete(
    String url, {
    Map<String, dynamic>? body,
    bool showLog = true,
  }) {
    return _request('DELETE', url, body: body, showLog: showLog);
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

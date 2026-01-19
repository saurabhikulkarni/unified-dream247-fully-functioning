import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:unified_dream247/config/api_config.dart';
import '../services/auth_service.dart';
import 'graphql_client.dart';
import 'rest_client.dart';

/// API client that provides access to both GraphQL and REST clients
class ApiClient {
  final GraphQLClientService graphQLClient;
  final RestClient restClient;

  ApiClient({
    required this.graphQLClient,
    required this.restClient,
  });
}

/// API Response wrapper
class ApiResponse {
  final bool success;
  final int statusCode;
  final dynamic data;
  final String? message;
  final bool requiresReauth;

  ApiResponse({
    required this.success,
    required this.statusCode,
    this.data,
    this.message,
    this.requiresReauth = false,
  });

  @override
  String toString() {
    return 'ApiResponse(success: $success, statusCode: $statusCode, message: $message)';
  }
}

/// Authenticated API Client with auto token refresh
/// 
/// Use this for all authenticated API calls to Fantasy backend.
/// Automatically handles:
/// - Adding Authorization header
/// - Token refresh on 401 errors
/// - Request retry after refresh
class AuthenticatedApiClient {
  final AuthService _authService = AuthService();
  
  /// Base URL for API calls (defaults to Fantasy backend)
  final String baseUrl;
  
  AuthenticatedApiClient({String? baseUrl}) 
      : baseUrl = baseUrl ?? ApiConfig.fantasyBaseUrl;

  /// Get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    await _authService.initialize();
    final token = _authService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Make GET request with auto token refresh
  Future<ApiResponse> get(String endpoint) async {
    return _request(() async {
      final headers = await _getHeaders();
      return http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
    });
  }

  /// Make POST request with auto token refresh
  Future<ApiResponse> post(String endpoint, {Map<String, dynamic>? body}) async {
    return _request(() async {
      final headers = await _getHeaders();
      return http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  /// Make PUT request with auto token refresh
  Future<ApiResponse> put(String endpoint, {Map<String, dynamic>? body}) async {
    return _request(() async {
      final headers = await _getHeaders();
      return http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  /// Make DELETE request with auto token refresh
  Future<ApiResponse> delete(String endpoint) async {
    return _request(() async {
      final headers = await _getHeaders();
      return http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
    });
  }

  /// Internal request handler with auto token refresh
  Future<ApiResponse> _request(Future<http.Response> Function() requestFn) async {
    try {
      var response = await requestFn();

      // Handle 401 - Token expired
      if (response.statusCode == 401) {
        if (kDebugMode) {
          debugPrint('🔄 [API_CLIENT] 401 received, attempting token refresh...');
        }
        
        final refreshed = await _authService.refreshAccessToken();
        
        if (refreshed != null) {
          // Retry request with new token
          response = await requestFn();
          if (kDebugMode) {
            debugPrint('✅ [API_CLIENT] Request retried after token refresh');
          }
        } else {
          return ApiResponse(
            success: false,
            statusCode: 401,
            message: 'Session expired. Please login again.',
            requiresReauth: true,
          );
        }
      }

      // Parse response
      try {
        final data = jsonDecode(response.body);
        return ApiResponse(
          success: data['status'] == true || data['success'] == true,
          statusCode: response.statusCode,
          data: data,
          message: data['message'],
        );
      } catch (e) {
        return ApiResponse(
          success: response.statusCode >= 200 && response.statusCode < 300,
          statusCode: response.statusCode,
          data: response.body,
          message: 'Response received',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [API_CLIENT] Request error: $e');
      }
      return ApiResponse(
        success: false,
        statusCode: 0,
        message: 'Network error: $e',
      );
    }
  }
}

/// Global instance for Fantasy API calls
final fantasyApiClient = AuthenticatedApiClient();

/// Shop API Client (uses Shop backend URL)
final shopApiClient = AuthenticatedApiClient(baseUrl: ApiConfig.shopApiUrl);

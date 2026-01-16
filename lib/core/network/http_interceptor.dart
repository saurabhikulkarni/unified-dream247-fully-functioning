import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';
import '../constants/api_constants.dart';

/// HTTP client with automatic token refresh on 401 errors
class AuthenticatedHttpClient {
  final AuthService _authService = AuthService();

  /// Make authenticated GET request with auto token refresh
  Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    final token = await _authService.getValidToken(ApiConstants.shopBackendUrl);
    
    if (token == null) {
      throw Exception('No valid token available');
    }

    final authHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      ...?headers,
    };

    final response = await http.get(Uri.parse(url), headers: authHeaders);

    // If token expired during request, try refresh once
    if (response.statusCode == 401) {
      final newToken = await _authService.refreshAccessToken(ApiConstants.shopBackendUrl);
      
      if (newToken != null) {
        authHeaders['Authorization'] = 'Bearer $newToken';
        return await http.get(Uri.parse(url), headers: authHeaders);
      }
    }

    return response;
  }

  /// Make authenticated POST request with auto token refresh
  Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final token = await _authService.getValidToken(ApiConstants.shopBackendUrl);
    
    if (token == null) {
      throw Exception('No valid token available');
    }

    final authHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      ...?headers,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: authHeaders,
      body: body,
    );

    // If token expired during request, try refresh once
    if (response.statusCode == 401) {
      final newToken = await _authService.refreshAccessToken(ApiConstants.shopBackendUrl);
      
      if (newToken != null) {
        authHeaders['Authorization'] = 'Bearer $newToken';
        return await http.post(Uri.parse(url), headers: authHeaders, body: body);
      }
    }

    return response;
  }
}

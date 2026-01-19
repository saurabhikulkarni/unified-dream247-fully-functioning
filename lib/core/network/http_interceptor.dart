import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

/// HTTP client with automatic token refresh on 401 errors
/// 
/// This client automatically:
/// - Adds Authorization header with JWT token
/// - Refreshes token on 401 errors
/// - Retries failed requests after token refresh
/// 
/// Use this for all authenticated API calls to both Shop and Fantasy backends.
class AuthenticatedHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  final AuthService _authService = AuthService();
  
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    await _authService.initialize();
    
    // Add auth token to request
    final token = await _authService.getValidToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Content-Type'] = 'application/json';

    var response = await _inner.send(request);

    // If 401, try refresh token
    if (response.statusCode == 401) {
      if (kDebugMode) {
        debugPrint('🔄 [HTTP] 401 received, attempting token refresh...');
      }
      
      final refreshed = await _authService.refreshAccessToken();
      if (refreshed != null) {
        // Create new request with refreshed token
        final newRequest = _copyRequest(request, refreshed);
        response = await _inner.send(newRequest);
        
        if (kDebugMode) {
          debugPrint('✅ [HTTP] Request retried after token refresh');
        }
      } else {
        if (kDebugMode) {
          debugPrint('❌ [HTTP] Token refresh failed, user may need to re-login');
        }
      }
    }

    return response;
  }
  
  /// Copy request with new token
  http.BaseRequest _copyRequest(http.BaseRequest original, String newToken) {
    http.BaseRequest newRequest;
    
    if (original is http.Request) {
      newRequest = http.Request(original.method, original.url)
        ..headers.addAll(original.headers)
        ..headers['Authorization'] = 'Bearer $newToken'
        ..body = original.body;
    } else if (original is http.MultipartRequest) {
      newRequest = http.MultipartRequest(original.method, original.url)
        ..headers.addAll(original.headers)
        ..headers['Authorization'] = 'Bearer $newToken'
        ..fields.addAll(original.fields)
        ..files.addAll(original.files);
    } else {
      throw UnsupportedError('Cannot copy request of type ${original.runtimeType}');
    }
    
    return newRequest;
  }

  /// Make authenticated GET request with auto token refresh
  Future<http.Response> getUrl(String url, {Map<String, String>? headers}) async {
    await _authService.initialize();
    final token = await _authService.getValidToken();
    
    final authHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    var response = await http.get(Uri.parse(url), headers: authHeaders);

    // If token expired during request, try refresh once
    if (response.statusCode == 401 && token != null) {
      final newToken = await _authService.refreshAccessToken();
      
      if (newToken != null) {
        authHeaders['Authorization'] = 'Bearer $newToken';
        response = await http.get(Uri.parse(url), headers: authHeaders);
      }
    }

    return response;
  }

  /// Make authenticated POST request with auto token refresh
  Future<http.Response> postUrl(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    await _authService.initialize();
    final token = await _authService.getValidToken();

    final authHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    var response = await http.post(
      Uri.parse(url),
      headers: authHeaders,
      body: body,
    );

    // If token expired during request, try refresh once
    if (response.statusCode == 401 && token != null) {
      final newToken = await _authService.refreshAccessToken();
      
      if (newToken != null) {
        authHeaders['Authorization'] = 'Bearer $newToken';
        response = await http.post(Uri.parse(url), headers: authHeaders, body: body);
      }
    }

    return response;
  }

  /// Make authenticated PUT request with auto token refresh
  Future<http.Response> putUrl(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    await _authService.initialize();
    final token = await _authService.getValidToken();

    final authHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    var response = await http.put(
      Uri.parse(url),
      headers: authHeaders,
      body: body,
    );

    // If token expired during request, try refresh once
    if (response.statusCode == 401 && token != null) {
      final newToken = await _authService.refreshAccessToken();
      
      if (newToken != null) {
        authHeaders['Authorization'] = 'Bearer $newToken';
        response = await http.put(Uri.parse(url), headers: authHeaders, body: body);
      }
    }

    return response;
  }

  /// Make authenticated DELETE request with auto token refresh
  Future<http.Response> deleteUrl(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    await _authService.initialize();
    final token = await _authService.getValidToken();

    final authHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    var response = await http.delete(
      Uri.parse(url),
      headers: authHeaders,
      body: body,
    );

    // If token expired during request, try refresh once
    if (response.statusCode == 401 && token != null) {
      final newToken = await _authService.refreshAccessToken();
      
      if (newToken != null) {
        authHeaders['Authorization'] = 'Bearer $newToken';
        response = await http.delete(Uri.parse(url), headers: authHeaders, body: body);
      }
    }

    return response;
  }
}

/// Global instance for easy access
final authenticatedClient = AuthenticatedHttpClient();

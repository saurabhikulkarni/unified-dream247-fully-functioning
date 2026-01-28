import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Base API Service for all HTTP operations
/// Handles GET, POST, PUT, DELETE requests with proper error handling
class ApiService {
  static const String defaultBaseUrl = 'http://localhost:3000';
  
  // Get base URL from environment or use default
  static String get baseUrl {
    return dotenv.env['API_BASE_URL'] ?? defaultBaseUrl;
  }

  /// Performs a GET request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('[ApiService] GET: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      print('[ApiService] GET Error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
        'statusCode': 0,
      };
    }
  }

  /// Performs a POST request
  static Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('[ApiService] POST: $url');
      print('[ApiService] Body: ${jsonEncode(body)}');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      print('[ApiService] POST Error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
        'statusCode': 0,
      };
    }
  }

  /// Performs a PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('[ApiService] PUT: $url');
      print('[ApiService] Body: ${jsonEncode(body)}');
      
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      print('[ApiService] PUT Error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
        'statusCode': 0,
      };
    }
  }

  /// Performs a DELETE request
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('[ApiService] DELETE: $url');
      
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      print('[ApiService] DELETE Error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
        'statusCode': 0,
      };
    }
  }

  /// Handles HTTP response and converts to standard format
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      print('[ApiService] Status Code: ${response.statusCode}');
      print('[ApiService] Response: ${response.body}');
      
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'data': json['data'] ?? json,
          'message': json['message'] ?? 'Success',
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': json['message'] ?? 'Error: ${response.statusCode}',
          'data': json['data'],
        };
      }
    } catch (e) {
      print('[ApiService] Response Parse Error: $e');
      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': 'Failed to parse response: $e',
      };
    }
  }

  /// Helper method to check if response was successful
  static bool isSuccess(Map<String, dynamic> response) {
    return response['success'] == true ||
        (response['statusCode'] != null && 
         response['statusCode'] >= 200 && 
         response['statusCode'] < 300);
  }

  /// Helper method to get error message
  static String getErrorMessage(Map<String, dynamic> response) {
    return response['message'] ?? 'An error occurred';
  }
}

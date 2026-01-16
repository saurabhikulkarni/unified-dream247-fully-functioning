import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unified_dream247/core/services/auth_service.dart';

/// API Error Handler - Centralized error handling for all API calls
/// Handles common HTTP status codes and errors
class ApiErrorHandler {
  static final ApiErrorHandler _instance = ApiErrorHandler._internal();

  factory ApiErrorHandler() => _instance;
  ApiErrorHandler._internal();

  /// Handle API errors based on status code
  static Future<void> handleApiError(
    BuildContext context, {
    required int statusCode,
    required String message,
    String? endpoint,
  }) async {
    debugPrint('❌ API Error: $statusCode - $message');
    if (endpoint != null) {
      debugPrint('   Endpoint: $endpoint');
    }

    switch (statusCode) {
      case 400:
        _showErrorSnackBar(context, 'Invalid Request: $message');
        break;

      case 401:
        // Unauthorized - token expired or invalid
        await _handleUnauthorized(context);
        break;

      case 403:
        // Forbidden - no access to resource
        _showErrorSnackBar(context, 'Access Denied: You don\'t have permission to access this resource');
        break;

      case 404:
        // Not Found
        _showErrorSnackBar(context, 'Resource Not Found: $message');
        break;

      case 429:
        // Too Many Requests
        _showErrorSnackBar(context, 'Too Many Requests: Please try again later');
        break;

      case 500:
      case 502:
      case 503:
      case 504:
        // Server Errors
        _showErrorSnackBar(context, 'Server Error: Please try again later');
        break;

      default:
        _showErrorSnackBar(context, 'Error: $message');
    }
  }

  /// Handle network errors
  static void handleNetworkError(BuildContext context, String error) {
    debugPrint('🌐 Network Error: $error');

    if (error.contains('timeout')) {
      _showErrorSnackBar(context, 'Request Timeout: Please check your connection');
    } else if (error.contains('Connection refused')) {
      _showErrorSnackBar(context, 'Connection Failed: Server is not reachable');
    } else if (error.contains('No internet')) {
      _showErrorSnackBar(context, 'No Internet Connection: Please check your network');
    } else {
      _showErrorSnackBar(context, 'Network Error: $error');
    }
  }

  /// Handle parsing errors
  static void handleParsingError(BuildContext context, String error) {
    debugPrint('📦 Parsing Error: $error');
    _showErrorSnackBar(context, 'Invalid Response Format: Please try again');
  }

  /// Handle unauthorized access (401)
  static Future<void> _handleUnauthorized(BuildContext context) async {
    debugPrint('🔐 Unauthorized - Logging out');

    // Show error message
    _showErrorSnackBar(context, 'Session Expired: Please login again');

    // Clear auth
    try {
      final authService = AuthService();
      await authService.initialize();
      await authService.logout();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }

    // Wait a moment for user to see message
    await Future.delayed(const Duration(milliseconds: 800));

    if (context.mounted) {
      // Redirect to login
      context.go('/login');
    }
  }

  /// Show error snackbar
  static void _showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Handle success messages
  static void showSuccessMessage(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show info message
  static void showInfoMessage(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue.shade600,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show warning message
  static void showWarningMessage(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange.shade600,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

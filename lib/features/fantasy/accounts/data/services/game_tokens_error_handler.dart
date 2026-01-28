import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Enum for categorizing game tokens errors
enum TokenErrorType {
  insufficientBalance,
  networkError,
  backendError,
  unauthorized,
  unknown
}

/// Custom exception for game tokens operations
class TokenError implements Exception {
  final TokenErrorType type;
  final String message;
  final dynamic originalError;

  TokenError({
    required this.type,
    required this.message,
    this.originalError,
  });

  @override
  String toString() => message;

  /// Check if this is a recoverable error
  bool get isRecoverable {
    return type == TokenErrorType.networkError || 
           type == TokenErrorType.backendError;
  }

  /// Check if user needs to take action
  bool get requiresUserAction {
    return type == TokenErrorType.insufficientBalance || 
           type == TokenErrorType.unauthorized;
  }
}

/// Error handler for game tokens operations
class GameTokensErrorHandler {
  /// Categorize any error into TokenErrorType
  static TokenError categorizeError(dynamic error) {
    debugPrint('[GameTokensErrorHandler] Categorizing error: $error');

    // Network timeout
    if (error is TimeoutException) {
      return TokenError(
        type: TokenErrorType.networkError,
        message: 'Network timeout. Please check your connection.',
        originalError: error,
      );
    }

    // Socket error (no internet)
    if (error is SocketException) {
      return TokenError(
        type: TokenErrorType.networkError,
        message: 'No internet connection. Using cached data.',
        originalError: error,
      );
    }

    // DIO errors
    if (error is DioException) {
      // Unauthorized - session expired
      if (error.response?.statusCode == 401) {
        return TokenError(
          type: TokenErrorType.unauthorized,
          message: 'Session expired. Please login again.',
          originalError: error,
        );
      }

      // Bad request - check for specific messages
      if (error.response?.statusCode == 400) {
        final responseData = error.response?.data;
        final message = responseData is Map ? responseData['message'] : null;

        if (message != null && message.toString().contains('Insufficient game tokens')) {
          return TokenError(
            type: TokenErrorType.insufficientBalance,
            message: message.toString(),
            originalError: error,
          );
        }

        return TokenError(
          type: TokenErrorType.backendError,
          message: message?.toString() ?? 'Invalid request',
          originalError: error,
        );
      }

      // Server error
      if (error.response?.statusCode == 500) {
        return TokenError(
          type: TokenErrorType.backendError,
          message: 'Backend error. Please try again later.',
          originalError: error,
        );
      }

      // Network error for DIO
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return TokenError(
          type: TokenErrorType.networkError,
          message: 'Network timeout. Please check your connection.',
          originalError: error,
        );
      }

      // Connection error
      if (error.type == DioExceptionType.connectionError) {
        return TokenError(
          type: TokenErrorType.networkError,
          message: 'No internet connection. Please check your connection.',
          originalError: error,
        );
      }
    }

    // Unknown error
    return TokenError(
      type: TokenErrorType.unknown,
      message: 'An unexpected error occurred. Please try again.',
      originalError: error,
    );
  }

  /// Get user-friendly message for display
  static String getUserMessage(TokenError error) {
    switch (error.type) {
      case TokenErrorType.insufficientBalance:
        return '💰 You don\'t have enough tokens. Please topup first!';
      case TokenErrorType.networkError:
        return '📡 Network error. Please check your internet connection.';
      case TokenErrorType.backendError:
        return '⚠️ Server error. Try again in a moment.';
      case TokenErrorType.unauthorized:
        return '🔐 Your session expired. Please login again.';
      case TokenErrorType.unknown:
        return '❌ Something went wrong. Please try again.';
    }
  }

  /// Get emoji for error type
  static String getErrorEmoji(TokenErrorType type) {
    switch (type) {
      case TokenErrorType.insufficientBalance:
        return '💰';
      case TokenErrorType.networkError:
        return '📡';
      case TokenErrorType.backendError:
        return '⚠️';
      case TokenErrorType.unauthorized:
        return '🔐';
      case TokenErrorType.unknown:
        return '❌';
    }
  }

  /// Log error with context
  static void logError(TokenError error, String context) {
    debugPrint(
      '[GameTokensErrorHandler] $context\n'
      'Type: ${error.type}\n'
      'Message: ${error.message}\n'
      'Original Error: ${error.originalError}',
    );
  }
}

/// Extension for better error handling
extension on dynamic {}

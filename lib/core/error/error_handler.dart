import 'package:dio/dio.dart';
import 'exceptions.dart';
import 'failures.dart';

/// Centralized error handler for the application
class ErrorHandler {
  /// Converts exceptions to user-friendly failure messages
  static Failure handleException(Exception exception) {
    if (exception is ServerException) {
      return ServerFailure(
        _getServerErrorMessage(exception.statusCode),
        code: exception.statusCode,
      );
    } else if (exception is NetworkException) {
      return const NetworkFailure(
        'No internet connection. Please check your network.',
      );
    } else if (exception is CacheException) {
      return CacheFailure(exception.message);
    } else if (exception is AuthenticationException) {
      return AuthenticationFailure(exception.message);
    } else if (exception is ValidationException) {
      return ValidationFailure(
        exception.message,
        errors: exception.errors,
      );
    } else if (exception is PaymentException) {
      return PaymentFailure(exception.message, code: int.tryParse(exception.code ?? ''));
    } else if (exception is DioException) {
      return _handleDioException(exception);
    } else {
      return UnknownFailure('An unexpected error occurred: ${exception.toString()}');
    }
  }

  /// Handles Dio-specific exceptions
  static Failure _handleDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timeout. Please try again.');
      
      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        return ServerFailure(
          _getServerErrorMessage(statusCode),
          code: statusCode,
        );
      
      case DioExceptionType.cancel:
        return const UnknownFailure('Request was cancelled');
      
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return const NetworkFailure(
          'No internet connection. Please check your network.',
        );
      
      default:
        return const UnknownFailure('An unexpected error occurred');
    }
  }

  /// Returns user-friendly error message based on HTTP status code
  static String _getServerErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access forbidden. You don\'t have permission.';
      case 404:
        return 'Resource not found.';
      case 408:
        return 'Request timeout. Please try again.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  /// Extracts error message from a failure
  static String getErrorMessage(Failure failure) {
    return failure.message;
  }
}

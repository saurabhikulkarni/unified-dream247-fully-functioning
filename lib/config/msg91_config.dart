import 'package:unified_dream247/config/api_config.dart';

/// Configuration for MSG91 OTP authentication
class Msg91Config {
  /// Base URL for MSG91 backend API (now uses centralized ApiConfig)
  static String get baseUrl => ApiConfig.shopApiUrl;

  /// Send OTP endpoint
  static String get sendOtpEndpoint => ApiConfig.shopSendOtpEndpoint;

  /// Verify OTP endpoint
  static String get verifyOtpEndpoint => ApiConfig.shopVerifyOtpEndpoint;

  /// OTP configuration
  static const int otpLength = 6;
  static const int otpTimeoutSeconds = 60;
  
  /// Request timeout duration (in seconds)
  static int get requestTimeoutSeconds => ApiConfig.requestTimeoutSeconds;
  
  /// OTP expiry time (in minutes) - should match backend configuration
  static const int otpExpiryMinutes = 10;
  
  /// Resend OTP cooldown (in seconds)
  static const int resendCooldownSeconds = 30;
}

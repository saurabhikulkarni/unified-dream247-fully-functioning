/// Configuration for MSG91 OTP authentication
class Msg91Config {
  /// Base URL for MSG91 backend API
  static const String baseUrl = 
      'http://localhost:3000/api';

  /// Send OTP endpoint
  static const String sendOtpEndpoint = '$baseUrl/auth/send-otp';

  /// Verify OTP endpoint
  static const String verifyOtpEndpoint = '$baseUrl/auth/verify-otp';

  /// OTP configuration
  static const int otpLength = 6;
  static const int otpTimeoutSeconds = 60;
  
  /// Request timeout duration (in seconds)
  static const int requestTimeoutSeconds = 30;
  
  /// OTP expiry time (in minutes) - should match backend configuration
  static const int otpExpiryMinutes = 10;
  
  /// Resend OTP cooldown (in seconds)
  static const int resendCooldownSeconds = 30;
}

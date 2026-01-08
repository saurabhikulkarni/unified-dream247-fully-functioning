/// Configuration for MSG91 OTP authentication
class Msg91Config {
  /// Base URL for MSG91 backend API
  static const String baseUrl = 
      'https://brighthex-dream-24-7-backend-psi.vercel.app/api';

  /// Send OTP endpoint
  static const String sendOtpEndpoint = '$baseUrl/auth/send-otp';

  /// Verify OTP endpoint
  static const String verifyOtpEndpoint = '$baseUrl/auth/verify-otp';

  /// OTP configuration
  static const int otpLength = 6;
  static const int otpTimeoutSeconds = 60;
}

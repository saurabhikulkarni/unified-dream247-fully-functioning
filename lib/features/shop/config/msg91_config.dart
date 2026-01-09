/// MSG91 Backend API Configuration
/// 
/// This file contains the backend API endpoint for MSG91 OTP services.
/// The actual MSG91 API key should be stored on your backend server, NOT in this frontend code.
/// 
/// Backend endpoints expected:
/// - POST /api/auth/send-otp - Send OTP to mobile number
/// - POST /api/auth/verify-otp - Verify OTP
/// 
/// See MSG91_BACKEND_SETUP.md for backend implementation details.
library;

class Msg91Config {
  static const String baseUrl = 'https://brighthex-dream-24-7-backend-psi.vercel.app/api';
  
  // Alternative: Use localhost for development (uncomment if testing locally)
  // static const String baseUrl = 'http://localhost:3000';
  
  // API endpoints (backend exposes routes under /api/auth)
  static const String sendOtpEndpoint = '$baseUrl/auth/send-otp';
  static const String verifyOtpEndpoint = '$baseUrl/auth/verify-otp';
  
  // Request timeout duration (in seconds)
  static const int requestTimeoutSeconds = 30;
  
  // OTP expiry time (in minutes) - should match backend configuration
  static const int otpExpiryMinutes = 10;
  
  // Resend OTP cooldown (in seconds)
  static const int resendCooldownSeconds = 30;
}

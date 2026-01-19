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

import 'package:unified_dream247/config/api_config.dart';

/// NOTE: This is a duplicate/legacy config file in features/shop/config/
/// The primary Msg91Config is now at lib/config/msg91_config.dart
/// This file is kept for backward compatibility but delegates to ApiConfig.
class Msg91Config {
  // Now uses centralized ApiConfig for environment-based URL switching
  static String get baseUrl => ApiConfig.shopApiUrl;
  
  // API endpoints (backend exposes routes under /api/auth)
  static String get sendOtpEndpoint => ApiConfig.shopSendOtpEndpoint;
  static String get verifyOtpEndpoint => ApiConfig.shopVerifyOtpEndpoint;
  
  // Request timeout duration (in seconds)
  static int get requestTimeoutSeconds => ApiConfig.requestTimeoutSeconds;
  
  // OTP expiry time (in minutes) - should match backend configuration
  static const int otpExpiryMinutes = 10;
  
  // Resend OTP cooldown (in seconds)
  static const int resendCooldownSeconds = 30;
}

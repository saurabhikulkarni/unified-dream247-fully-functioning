/// Razorpay Backend API Configuration
/// 
/// This file contains the backend API endpoints for Razorpay payment processing.
/// The Razorpay Key Secret should be stored on your backend server, NOT in this frontend code.
/// 
/// Backend endpoints expected:
/// - POST /api/payments/create-order - Create Razorpay order
/// - POST /api/payments/verify-signature - Verify payment signature
/// 
/// See BACKEND_SERVER_SETUP.md for backend implementation details.
library;

import 'package:unified_dream247/config/api_config.dart';

class RazorpayBackendConfig {
  // Now uses centralized ApiConfig for environment-based URL switching
  static String get baseUrl => ApiConfig.shopApiUrl;
  
  // API endpoints
  static String get createOrderEndpoint => '$baseUrl/payments/create-order';
  static String get verifySignatureEndpoint => '$baseUrl/payments/verify-signature';
  
  // Request timeout duration (in seconds)
  static int get requestTimeoutSeconds => ApiConfig.requestTimeoutSeconds;
}

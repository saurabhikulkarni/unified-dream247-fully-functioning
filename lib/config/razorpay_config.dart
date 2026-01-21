import 'package:unified_dream247/config/api_config.dart';

/// Configuration for Razorpay payment gateway
class RazorpayConfig {
  /// Razorpay API Key ID
  /// Test key for development, Live key for production
  static const String _testKeyId = 'rzp_test_S0bjTVUZm4brLR'; // Current test key
  static const String _prodKeyId = 'rzp_live_RzKEI3xUwyf7Tu'; // Live key - for production
  
  // Force test key for now - change to: ApiConfig.isProduction ? _prodKeyId : _testKeyId for production
  static String get keyId => _testKeyId;

  /// Backend base URL for payment processing (now uses centralized ApiConfig)
  static String get backendBaseUrl => ApiConfig.shopApiUrl;

  /// Create order endpoint
  static String get createOrderEndpoint => '$backendBaseUrl/payment/create-order';

  /// Verify payment endpoint
  static String get verifyPaymentEndpoint => '$backendBaseUrl/payment/verify';

  /// Razorpay configuration
  static Map<String, dynamic> get config => {
        'key': keyId,
        'amount': 0, // Will be set dynamically
        'name': 'DREAM247',
        'description': 'Payment for order',
        'prefill': {
          'contact': '',
          'email': '',
        },
        'theme': {
          'color': '#6441A5',
        },
      };
}

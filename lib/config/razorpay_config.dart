import 'package:unified_dream247/config/api_config.dart';

/// Configuration for Razorpay payment gateway
class RazorpayConfig {
  /// Razorpay API Key ID for test environment
  /// TODO: Use environment variable for production key
  static const String _testKeyId = 'rzp_test_RqEBl9COpBTyyz';
  static const String _prodKeyId = String.fromEnvironment('RAZORPAY_KEY_ID', defaultValue: 'rzp_test_RqEBl9COpBTyyz');
  
  static String get keyId => ApiConfig.isProduction ? _prodKeyId : _testKeyId;

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

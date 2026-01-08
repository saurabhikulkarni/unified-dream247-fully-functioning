/// Configuration for Razorpay payment gateway
class RazorpayConfig {
  /// Razorpay API Key ID for test environment
  static const String keyId = 'rzp_test_RqEBl9COpBTyyz';

  /// Backend base URL for payment processing
  static const String backendBaseUrl = 
      'https://brighthex-dream-24-7-backend-psi.vercel.app/api';

  /// Create order endpoint
  static const String createOrderEndpoint = '$backendBaseUrl/payment/create-order';

  /// Verify payment endpoint
  static const String verifyPaymentEndpoint = '$backendBaseUrl/payment/verify';

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

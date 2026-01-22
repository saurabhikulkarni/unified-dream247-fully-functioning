// Razorpay Payment Configuration
// Get your credentials from https://dashboard.razorpay.com/

import 'package:unified_dream247/config/api_config.dart';

class RazorpayConfig {
  // ⚠️ TEST MODE - Using Test Razorpay credentials for testing
  // Your Razorpay API Key (Public Key)
  // Available at: https://dashboard.razorpay.com/#/app/keys
  // static const String _testKeyId = 'rzp_test_S0bjTVUZm4brLR'; // Test key - commented out
  static const String _prodKeyId = 'rzp_live_RzKEI3xUwyf7Tu'; // Live key - for production
  
  // Now using live key for production
  static String get keyId => _prodKeyId;

  // Your Razorpay API Secret (Keep this ONLY on backend)
  // Never expose this in frontend code!
  // This is stored on backend server for signature verification
  static const String keySecret = 'STORED_ON_BACKEND_SERVER';

  // Backend API base URL for Razorpay operations (now uses ApiConfig)
  static String get backendBaseUrl => ApiConfig.shopApiUrl;
  
  // Backend API endpoints
  static String get createOrderEndpoint => '$backendBaseUrl/payments/create-order';
  static String get verifySignatureEndpoint => '$backendBaseUrl/payments/verify-signature';
  static String get getPaymentEndpoint => '$backendBaseUrl/payments';

  // Merchant Name/App Name
  static const String merchantName = 'Dream247';

  // Merchant Description
  static const String merchantDescription = 'Premium E-commerce Shopping App';

  // Support Email
  static const String supportEmail = 'support@dream247.com';

  // Support Phone
  static const String supportPhone = '+91 9876543210';

  // Theme Color (Razorpay payment modal)
  static const String themeColor = '#6441A5';

  // Logo URL (Optional - should be HTTPS)
  // Set to empty string if no logo is needed in payment modal
  static const String logoUrl = '';

  // Website URL
 // static const String websiteUrl = 'https://dream247.com';

  // Environment: 'production' or 'sandbox'
  // Use 'sandbox' for testing, 'production' for live
  static const String environment = 'sandbox';

  // Timeout duration for payment
  static const Duration paymentTimeout = Duration(minutes: 15);

  // Enable auto capture (capture payment automatically)
  static const bool autoCapture = true;

  // Payment methods to enable
  static const List<String> enabledPaymentMethods = [
    'card',        // Credit/Debit Card
    'netbanking',  // Net Banking
    'wallet',      // Wallet (PayTM, AmazonPay, Mobikwik, etc)
    'upi',         // UPI
    'emandate',    // EMI with Mandate
    'emi',         // EMI
  ];

  // Supported UPI apps
  static const List<String> upiApps = [
    'google_pay',
    'phonepe',
    'paytm',
    'whatsapp',
  ];

  /// Update API Key
  static void updateKeyId(String newKeyId) {
    print('Razorpay Key ID updated. Remember to rebuild the app.');
  }

  /// Get Razorpay Dashboard URL
  static String getDashboardUrl() {
    return 'https://dashboard.razorpay.com/';
  }

  /// Validate configuration
  static bool isConfigured() {
    // Check if using production key
    return keyId == 'rzp_live_RzKEI3xUwyf7Tu' ||
        keyId != 'rzp_test_RqEBl9COpBTyyz';
  }
}

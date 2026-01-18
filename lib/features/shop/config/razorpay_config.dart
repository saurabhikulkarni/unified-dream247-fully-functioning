// Razorpay Payment Configuration
// Get your credentials from https://dashboard.razorpay.com/

class RazorpayConfig {
  // ⚠️ TEST MODE - Replace with production credentials before launch
  // Your Razorpay API Key (Public Key)
  // Available at: https://dashboard.razorpay.com/#/app/keys
  // PRODUCTION: Change from rzp_test_* to rzp_live_* after approval
  static const String keyId = 'rzp_test_RqEBl9COpBTyyz';

  // Your Razorpay API Secret (Keep this ONLY on backend)
  // Never expose this in frontend code!
  // This is stored on backend server for signature verification
  static const String keySecret = 'STORED_ON_BACKEND_SERVER';

  // Backend API base URL for Razorpay operations
  static const String backendBaseUrl = 'http://localhost:3000/api';
  
  // Backend API endpoints
  static const String createOrderEndpoint = '$backendBaseUrl/payments/create-order';
  static const String verifySignatureEndpoint = '$backendBaseUrl/payments/verify-signature';
  static const String getPaymentEndpoint = '$backendBaseUrl/payments';

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
    return keyId != 'rzp_test_RqEBl9COpBTyyz' &&
        keySecret != 'STORED_ON_BACKEND_SERVER';
  }
}

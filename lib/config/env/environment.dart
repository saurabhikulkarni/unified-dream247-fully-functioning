/// Environment configuration
class Environment {
  // Environment type
  static const String env = String.fromEnvironment('ENV', defaultValue: 'dev');
  
  // API URLs
  static String get ecommerceApiUrl {
    switch (env) {
      case 'prod':
        return 'https://api-ap-south-1.hygraph.com/v2/';
      case 'staging':
        return 'https://api-ap-south-1.hygraph.com/v2/';
      default:
        return 'https://api-ap-south-1.hygraph.com/v2/';
    }
  }
  
  static String get gamingApiUrl {
    switch (env) {
      case 'prod':
        return 'http://134.209.158.211:4000/';
      case 'staging':
        return 'http://134.209.158.211:4000/';
      default:
        return 'http://134.209.158.211:4000/';
    }
  }
  
  // Feature flags
  static bool get enableAnalytics => env == 'prod';
  static bool get enableCrashlytics => env == 'prod';
  static bool get enableDebugMode => env != 'prod';
  
  // API Keys (should be moved to secure storage in production)
  static const String razorpayKey = String.fromEnvironment(
    'RAZORPAY_KEY',
    defaultValue: 'YOUR_RAZORPAY_KEY',
  );
  
  static const String hygraphApiKey = String.fromEnvironment(
    'HYGRAPH_API_KEY',
    defaultValue: 'YOUR_HYGRAPH_API_KEY',
  );
  
  // Firebase configuration (add your Firebase config)
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: '',
  );
}

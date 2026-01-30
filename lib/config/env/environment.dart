/// Environment configuration
/// Now delegates to ApiConfig for all API URLs
import 'package:unified_dream247/config/api_config.dart';

class Environment {
  // Environment type
  static const String env = String.fromEnvironment('ENV', defaultValue: 'dev');
  
  // API URLs - delegated to ApiConfig for centralized configuration
  static String get ecommerceApiUrl => ApiConfig.hygraphEndpoint;
  static String get gamingApiUrl => ApiConfig.fantasyBaseUrl;
  
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

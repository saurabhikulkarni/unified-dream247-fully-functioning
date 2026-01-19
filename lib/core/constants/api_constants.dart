import 'package:unified_dream247/config/api_config.dart';

/// API endpoint constants for the application
/// 
/// NOTE: This class now delegates to ApiConfig for environment-based URLs.
/// Prefer using ApiConfig directly for new code.
class ApiConstants {
  // Shop Backend URL (delegated to ApiConfig)
  static String get shopBackendUrl => ApiConfig.shopBaseUrl;
  
  // Fantasy Backend URL (delegated to ApiConfig)
  static String get fantasyBackendUrl => ApiConfig.fantasyBaseUrl;
  
  // Hygraph Endpoint (delegated to ApiConfig)
  static String get hygraphEndpoint => ApiConfig.hygraphEndpoint;
  
  // Base URLs (legacy - kept for backward compatibility)
  static const String ecommerceBaseUrl = 'https://api-ap-south-1.hygraph.com/v2/';
  static String get gamingBaseUrl => ApiConfig.fantasyBaseUrl;
  
  // Hygraph E-commerce endpoints (legacy)
  static const String hygraphApiKey = 'YOUR_HYGRAPH_API_KEY';
  
  // Gaming API endpoints
  static String get matchesEndpoint => '${gamingBaseUrl}api/matches';
  static String get contestsEndpoint => '${gamingBaseUrl}api/contests';
  static String get teamEndpoint => '${gamingBaseUrl}api/teams';
  
  // Authentication endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String verifyOtpEndpoint = '/api/auth/verify-otp';
  static const String logoutEndpoint = '/api/auth/logout';
  
  // Wallet endpoints
  static const String walletBalanceEndpoint = '/wallet/balance';
  static const String addMoneyEndpoint = '/wallet/add-money';
  static const String transactionsEndpoint = '/wallet/transactions';
  
  // Product endpoints
  static const String productsEndpoint = '/products';
  static const String productDetailEndpoint = '/products/{id}';
  
  // Request timeout (delegated to ApiConfig)
  static int get connectionTimeout => ApiConfig.connectionTimeout;
  static int get receiveTimeout => ApiConfig.receiveTimeout;
}

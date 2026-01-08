/// API endpoint constants for the application
class ApiConstants {
  // Base URLs
  static const String ecommerceBaseUrl = 'https://api-ap-south-1.hygraph.com/v2/';
  static const String gamingBaseUrl = 'https://api.dream247.com/';
  
  // Hygraph E-commerce endpoints
  static const String hygraphApiKey = 'YOUR_HYGRAPH_API_KEY';
  static const String hygraphEndpoint = '${ecommerceBaseUrl}YOUR_PROJECT_ID/master';
  
  // Gaming API endpoints
  static const String matchesEndpoint = '${gamingBaseUrl}api/matches';
  static const String contestsEndpoint = '${gamingBaseUrl}api/contests';
  static const String teamEndpoint = '${gamingBaseUrl}api/teams';
  
  // Authentication endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String verifyOtpEndpoint = '/auth/verify-otp';
  static const String logoutEndpoint = '/auth/logout';
  
  // Wallet endpoints
  static const String walletBalanceEndpoint = '/wallet/balance';
  static const String addMoneyEndpoint = '/wallet/add-money';
  static const String transactionsEndpoint = '/wallet/transactions';
  
  // Product endpoints
  static const String productsEndpoint = '/products';
  static const String productDetailEndpoint = '/products/{id}';
  
  // Request timeout
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
}

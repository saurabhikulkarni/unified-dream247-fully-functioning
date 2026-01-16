/// API endpoint constants for the application
class ApiConstants {
  // Shop Backend URL
  static const String shopBackendUrl = String.fromEnvironment(
    'SHOP_BACKEND_URL',
    defaultValue: 'http://localhost:3000',
  );
  
  // Fantasy Backend URL  
  static const String fantasyBackendUrl = String.fromEnvironment(
    'FANTASY_API_URL',
    defaultValue: 'http://localhost:3001',
  );
  
  // Hygraph Endpoint
  static const String hygraphEndpoint = String.fromEnvironment(
    'HYGRAPH_ENDPOINT',
    defaultValue: 'https://ap-south-1.cdn.hygraph.com/content/cmj85rtgv038n07uo8egj5fkb/master',
  );
  
  // Base URLs (legacy)
  static const String ecommerceBaseUrl = 'https://api-ap-south-1.hygraph.com/v2/';
  static const String gamingBaseUrl = 'https://api.dream247.com/';
  
  // Hygraph E-commerce endpoints (legacy)
  static const String hygraphApiKey = 'YOUR_HYGRAPH_API_KEY';
  
  // Gaming API endpoints
  static const String matchesEndpoint = '${gamingBaseUrl}api/matches';
  static const String contestsEndpoint = '${gamingBaseUrl}api/contests';
  static const String teamEndpoint = '${gamingBaseUrl}api/teams';
  
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
  
  // Request timeout
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
}

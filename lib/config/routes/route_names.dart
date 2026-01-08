/// Route name constants for the application
class RouteNames {
  // Authentication routes
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  
  // Main navigation routes
  static const String home = '/home';
  static const String shop = '/shop';
  static const String gaming = '/gaming';
  static const String wallet = '/wallet';
  static const String profile = '/profile';
  
  // E-commerce routes
  static const String products = '/products';
  static const String productDetail = '/products/:id';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:id';
  
  // Gaming routes
  static const String matches = '/matches';
  static const String matchDetail = '/matches/:id';
  static const String contests = '/contests';
  static const String contestDetail = '/contests/:id';
  static const String myTeams = '/my-teams';
  static const String createTeam = '/create-team';
  
  // Wallet routes
  static const String addMoney = '/wallet/add-money';
  static const String transactions = '/wallet/transactions';
  static const String withdraw = '/wallet/withdraw';
  
  // Profile routes
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String help = '/help';
  static const String about = '/about';
  
  // Other routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
}

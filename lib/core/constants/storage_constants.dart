/// Storage key constants for local persistence
class StorageConstants {
  // Authentication
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String authToken = 'auth_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userPhone = 'user_phone';
  static const String isLoggedIn = 'is_logged_in';
  
  // Module access control
  static const String fantasyUserId = 'fantasy_user_id';
  static const String shopEnabled = 'shop_enabled';
  static const String fantasyEnabled = 'fantasy_enabled';
  static const String modules = 'modules';
  
  // Unified Wallet - Shop Token System
  static const String shopTokens = 'shop_tokens';
  static const String shopTransactionHistory = 'shop_transaction_history';
  static const String gameTokens = 'game_tokens';
  static const String totalWalletAmount = 'total_wallet_amount';
  
  // User preferences
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String notificationsEnabled = 'notifications_enabled';
  
  // Cache
  static const String cachedProducts = 'cached_products';
  static const String cachedMatches = 'cached_matches';
  static const String lastSyncTime = 'last_sync_time';
  
  // Onboarding
  static const String isFirstLaunch = 'is_first_launch';
  static const String hasCompletedOnboarding = 'has_completed_onboarding';
  
  // Hive boxes
  static const String userBox = 'user_box';
  static const String cacheBox = 'cache_box';
  static const String settingsBox = 'settings_box';
}

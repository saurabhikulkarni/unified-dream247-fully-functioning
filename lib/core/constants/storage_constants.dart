/// Storage key constants for local persistence
class StorageConstants {
  // Authentication
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userPhone = 'user_phone';
  static const String isLoggedIn = 'is_logged_in';
  
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

/// Centralized API Configuration with Environment-Based Switching
/// 
/// This configuration automatically switches between development and production URLs.
/// 
/// Usage:
/// ```dart
/// import 'package:unified_dream247/config/api_config.dart';
/// 
/// final url = ApiConfig.shopBaseUrl;  // Returns appropriate URL based on environment
/// ```
/// 
/// Build Commands:
/// - Development: `flutter run`
/// - Production: `flutter run --release` or `flutter build apk --release`
/// - Custom: `flutter run --dart-define=ENV=staging`
/// 
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  // ─────────────────────────────────────────────────────────────────────────
  // ENVIRONMENT DETECTION
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Check if running in release/production mode
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  
  /// Environment override via --dart-define=ENV=prod|staging|dev
  static const String _envOverride = String.fromEnvironment('ENV', defaultValue: '');
  
  /// Get current environment name
  static String get environment {
    if (_envOverride.isNotEmpty) return _envOverride;
    return isProduction ? 'prod' : 'dev';
  }
  
  /// Check if in development mode
  static bool get isDevelopment => environment == 'dev';
  
  /// Check if in staging mode
  static bool get isStaging => environment == 'staging';

  // ─────────────────────────────────────────────────────────────────────────
  // SHOP BACKEND (Vercel)
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Shop Backend URLs by environment (base URL without /api suffix)
  static const String _shopDevUrl = 'http://localhost:3000';
  static const String _shopStagingUrl = 'https://brighthex-dream-24-7-backend-psi.vercel.app';
  static const String _shopProdUrl = 'https://brighthex-dream-24-7-backend-psi.vercel.app';
  // Note: Full API URL = base + '/api' → https://brighthex-dream-24-7-backend-psi.vercel.app/api
  
  /// Get Shop Backend base URL (without /api suffix)
  static String get shopBaseUrl {
    // Allow override via dart-define
    const override = String.fromEnvironment('SHOP_BACKEND_URL', defaultValue: '');
    if (override.isNotEmpty) return override;
    
    switch (environment) {
      case 'prod':
        return _shopProdUrl;
      case 'staging':
        return _shopStagingUrl;
      default:
        return _shopDevUrl;
    }
  }
  
  /// Get Shop Backend API URL (with /api suffix)
  static String get shopApiUrl => '$shopBaseUrl/api';
  
  // Shop API Endpoints - Authentication
  static String get shopSendOtpEndpoint => '$shopApiUrl/auth/send-otp';
  static String get shopVerifyOtpEndpoint => '$shopApiUrl/auth/verify-otp';
  static String get shopRefreshTokenEndpoint => '$shopApiUrl/auth/refresh-token';
  static String get shopValidateTokenEndpoint => '$shopApiUrl/auth/validate-token';
  static String get shopLogoutEndpoint => '$shopApiUrl/auth/logout';
  
  // Shop API Endpoints - Wallet
  static String get shopWalletBalanceEndpoint => '$shopApiUrl/wallet/shop-tokens-only';

  // ─────────────────────────────────────────────────────────────────────────
  // FANTASY BACKEND (Digital Ocean)
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Fantasy Backend URLs by environment
  static const String _fantasyDevUrl = 'http://134.209.158.211:4000';
  static const String _fantasyStagingUrl = 'http://134.209.158.211:4000';
  static const String _fantasyProdUrl = 'http://134.209.158.211:4000';  // TODO: Update with SSL domain when ready
  
  /// Get Fantasy Backend base URL
  static String get fantasyBaseUrl {
    // Allow override via dart-define
    const override = String.fromEnvironment('FANTASY_API_URL', defaultValue: '');
    if (override.isNotEmpty) return override;
    
    switch (environment) {
      case 'prod':
        return _fantasyProdUrl;
      case 'staging':
        return _fantasyStagingUrl;
      default:
        return _fantasyDevUrl;
    }
  }
  
  // Fantasy API Path Prefixes
  static String get fantasyUserUrl => '$fantasyBaseUrl/user/';
  static String get fantasyKycUrl => '$fantasyBaseUrl/kyc/';
  static String get fantasyLeaderboardUrl => '$fantasyBaseUrl/leaderboard/';
  static String get fantasyTeamsUrl => '$fantasyBaseUrl/team/';
  static String get fantasyMatchUrl => '$fantasyBaseUrl/match/';
  static String get fantasyContestUrl => '$fantasyBaseUrl/contest/';
  static String get fantasyDepositUrl => '$fantasyBaseUrl/deposit/';
  static String get fantasyWithdrawUrl => '$fantasyBaseUrl/withdraw/';
  static String get fantasyJoinContestUrl => '$fantasyBaseUrl/joincontest/';
  static String get fantasyLiveMatchUrl => '$fantasyBaseUrl/live-match/';
  static String get fantasyMyJoinContestUrl => '$fantasyBaseUrl/myjoined-contest/';
  static String get fantasyMyTeamsUrl => '$fantasyBaseUrl/getmyteams/';
  static String get fantasyCompletedMatchUrl => '$fantasyBaseUrl/completed-match/';
  static String get fantasyOtherUrl => '$fantasyBaseUrl/other/';
  
  // Fantasy User API Endpoints
  static String get fantasyUserSyncEndpoint => '$fantasyBaseUrl/api/user/sync';
  static String get fantasyUserLoginEndpoint => '$fantasyBaseUrl/api/user/login';
  static String get fantasyWalletBalanceEndpoint => '$fantasyBaseUrl/api/user/wallet/balance-full';
  static String get fantasyShopTokensEndpoint => '$fantasyBaseUrl/api/user/wallet/shop-tokens-only';
  static String get fantasyUnifiedHistoryEndpoint => '$fantasyBaseUrl/api/user/wallet/unified-history';
  static String get fantasySyncShopTokensEndpoint => '$fantasyBaseUrl/api/user/wallet/sync-shop-tokens-to-shop';
  static String get fantasyRefreshTokenEndpoint => '$fantasyBaseUrl/api/auth/refresh-token';

  // ─────────────────────────────────────────────────────────────────────────
  // HYGRAPH (GraphQL CMS)
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Hygraph Content API endpoint
  static const String hygraphEndpoint = String.fromEnvironment(
    'HYGRAPH_ENDPOINT',
    defaultValue: 'https://ap-south-1.cdn.hygraph.com/content/cmj85rtgv038n07uo8egj5fkb/master',
  );
  
  /// Hygraph Management API endpoint (for mutations)
  static const String hygraphMutationEndpoint = String.fromEnvironment(
    'HYGRAPH_MUTATION_ENDPOINT',
    defaultValue: 'https://api-ap-south-1.hygraph.com/v2/cmj85rtgv038n07uo8egj5fkb/master',
  );

  // ─────────────────────────────────────────────────────────────────────────
  // MEDIA SERVER
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Media/uploads server URL
  static String get mediaServerUrl {
    switch (environment) {
      case 'prod':
        return 'http://134.209.158.211:5001';  // TODO: Update with SSL domain when ready
      default:
        return 'http://134.209.158.211:5001';
    }
  }
  
  /// Get full URL for uploaded files
  static String getMediaUrl(String path) => '$mediaServerUrl/uploads/$path';

  // ─────────────────────────────────────────────────────────────────────────
  // REQUEST CONFIGURATION
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Connection timeout in milliseconds
  static const int connectionTimeout = 30000;
  
  /// Receive timeout in milliseconds
  static const int receiveTimeout = 30000;
  
  /// Request timeout in seconds (for http package)
  static const int requestTimeoutSeconds = 30;

  // ─────────────────────────────────────────────────────────────────────────
  // FEATURE FLAGS
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Enable debug logging for API calls
  static bool get enableApiLogging => !isProduction;
  
  /// Enable analytics
  static bool get enableAnalytics => isProduction;
  
  /// Enable crashlytics
  static bool get enableCrashlytics => isProduction;

  // ─────────────────────────────────────────────────────────────────────────
  // DEBUG HELPERS
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Print current configuration (for debugging)
  static void printConfig() {
    if (!enableApiLogging) return;
    
    print('═══════════════════════════════════════════════════════════');
    print('📱 API CONFIGURATION');
    print('═══════════════════════════════════════════════════════════');
    print('Environment: $environment');
    print('Is Production: $isProduction');
    print('───────────────────────────────────────────────────────────');
    print('Shop Backend URL: $shopBaseUrl');
    print('Shop API URL: $shopApiUrl');
    print('───────────────────────────────────────────────────────────');
    print('Fantasy Backend URL: $fantasyBaseUrl');
    print('Fantasy User URL: $fantasyUserUrl');
    print('───────────────────────────────────────────────────────────');
    print('Hygraph Endpoint: $hygraphEndpoint');
    print('Media Server: $mediaServerUrl');
    print('═══════════════════════════════════════════════════════════');
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/di/injection_container.dart';
import 'core/services/auth_service.dart' as core_auth;
import 'core/providers/app_provider.dart';
import 'features/fantasy/accounts/data/services/game_tokens_service.dart';

// Ecommerce shop services - Use features/shop/services for full GraphQL support
import 'features/shop/services/cart_service.dart';
import 'features/shop/services/wishlist_service.dart';
import 'features/shop/services/user_service.dart';
import 'features/shop/services/graphql_client.dart';
import 'core/services/shop/search_service.dart';
import 'features/shop/services/auth_service.dart' as shop_auth;

/// Main entry point for the unified Dream247 application
/// Initializes both ecommerce and fantasy gaming features
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF6441A5),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    // Initialize GraphQL with Hive for persistent caching
    // Uses graphql_flutter's initHiveForFlutter() which handles Hive initialization
    await GraphQLService.initHiveStore();
    // Reset client to ensure new endpoint URLs are picked up
    GraphQLService.resetClient();

    // Load fantasy environment variables
    try {
      String envFile = kReleaseMode 
          ? 'assets/config/.env.prod' 
          : 'assets/config/.env.dev';
      await dotenv.load(fileName: envFile);
    } catch (e) {
      debugPrint('⚠️ Environment file not loaded: $e');
    }

    // Initialize Firebase (for fantasy features) - Skip on web for now
    if (!kIsWeb) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        debugPrint('✅ Firebase initialized successfully');
        // Uncomment when FCM service is implemented
        // await FCMService.init();
      } catch (e) {
        debugPrint('⚠️ Firebase initialization error: $e');
      }
    } else {
      debugPrint('ℹ️ Skipping Firebase initialization on web platform');
    }

    // Initialize dependency injection
    await configureDependencies();

    // Initialize shared authentication service
    await core_auth.authService.initialize();
    
    // Initialize app provider for periodic balance refresh
    appProvider = AppProvider(refreshInterval: 30);
    
    final shopAuthService = shop_auth.AuthService();
    
    // Initialize ecommerce services
    await UserService.initialize(); // Initialize user service first
    await wishlistService.initialize();
    await cartService.initialize();
    await searchService.initialize();

    // Initialize and fetch game tokens on app startup
    await _initializeGameTokens();

    if (await shopAuthService.isUnifiedLoggedIn()) {
      debugPrint('✅ User logged in - syncing...');
      final userId = await shopAuthService.getUnifiedUserId();
      debugPrint('   User ID: $userId');
      
      await wishlistService.syncWithBackend();
      await cartService.syncWithBackend();
      
      // Trigger initial refresh for logged-in users
      await appProvider.forceRefresh();
    }

    debugPrint('✅ All services initialized');
    debugPrint('🎯 Using Shop Splash Screen as entry point');
  } catch (e) {
    debugPrint('⚠️ Initialization error: $e');
  }

  // Run the app
  runApp(const MyApp());
}

/// Initialize game tokens on app startup
/// Fetches from backend and caches locally
Future<void> _initializeGameTokens() async {
  try {
    debugPrint('🔄 [APP_INIT] Initializing game tokens...');
    
    final gameTokensService = getIt<GameTokensService>();
    final tokens = await gameTokensService.fetchGameTokensOnStartup();
    
    if (tokens != null) {
      debugPrint(
        '✅ [APP_INIT] Game tokens loaded: ${tokens.balance} tokens',
      );
    } else {
      debugPrint('⚠️ [APP_INIT] Game tokens not available, using empty balance');
    }
  } catch (e) {
    debugPrint('❌ [APP_INIT] Game tokens initialization error: $e');
    // App will continue with default/empty tokens
    // Users can manually refresh balance from wallet screen
  }
}

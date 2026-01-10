import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/di/injection_container.dart';
import 'core/services/auth_service.dart' as core_auth;
import 'core/services/user_service.dart';

// Ecommerce shop services
import 'core/services/shop/cart_service.dart';
import 'core/services/shop/wishlist_service.dart';
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

    // Initialize Hive for GraphQL caching (ecommerce)
    await Hive.initFlutter();

    // Load fantasy environment variables
    try {
      String envFile = kReleaseMode 
          ? 'assets/config/.env.prod' 
          : 'assets/config/.env.dev';
      await dotenv.load(fileName: envFile);
    } catch (e) {
      debugPrint('⚠️ Environment file not loaded: $e');
    }

    // Initialize Firebase (for fantasy features)
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Uncomment when FCM service is implemented
    // await FCMService.init();

    // Initialize dependency injection
    await configureDependencies();

    // Initialize shared authentication service
    await core_auth.authService.initialize();
    
    final shopAuthService = shop_auth.AuthService();
    
    await UserService.initialize();
    await wishlistService.initialize();
    await cartService.initialize();
    await searchService.initialize();

    if (await shopAuthService.isUnifiedLoggedIn()) {
      debugPrint('✅ User logged in - syncing...');
      final userId = await shopAuthService.getUnifiedUserId();
      debugPrint('   User ID: $userId');
      
      await wishlistService.syncWithBackend();
      await cartService.syncWithBackend();
    }

    debugPrint('✅ All services initialized');
    debugPrint('🎯 Using Shop Splash Screen as entry point');
  } catch (e) {
    debugPrint('⚠️ Initialization error: $e');
  }

  // Run the app
  runApp(const MyApp());
}

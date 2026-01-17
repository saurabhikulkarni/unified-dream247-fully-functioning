# Game Tokens System - Initialization & Setup Guide

## App Initialization Flow

```
main() called
  ↓
WidgetsFlutterBinding.ensureInitialized()
  ↓
Setup system UI overlay style
  ↓
Initialize Hive (ecommerce caching)
  ↓
Load environment variables
  ↓
Initialize Firebase (fantasy features)
  ↓
configureDependencies() ← DI setup
  ├─→ Register services
  ├─→ Register GameTokensCache
  ├─→ Register GameTokensService
  └─→ Register ContestJoinService
  ↓
Initialize core auth service
  ↓
Initialize ecommerce services (wishlist, cart, search)
  ↓
_initializeGameTokens() ← NEW (fetch tokens on startup)
  ├─→ Get GameTokensService from GetIt
  ├─→ Call fetchGameTokensOnStartup()
  ├─→ Fetch from backend (Priority 1)
  ├─→ Fallback to cache if backend fails
  └─→ Log success/error
  ↓
Sync ecommerce data (if user logged in)
  ├─→ Sync wishlist
  └─→ Sync cart
  ↓
runApp(MyApp())
  ↓
App ready with game tokens loaded
```

---

## Initialization Code

### main.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/di/injection_container.dart';
import 'core/services/auth_service.dart' as core_auth;
import 'features/fantasy/accounts/data/services/game_tokens_service.dart';

/// Main entry point for the unified Dream247 application
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
    if (!kIsWeb) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        debugPrint('✅ Firebase initialized successfully');
      } catch (e) {
        debugPrint('⚠️ Firebase initialization error: $e');
      }
    }

    // Initialize dependency injection
    await configureDependencies();

    // Initialize shared authentication service
    await core_auth.authService.initialize();

    // Initialize ecommerce services
    await wishlistService.initialize();
    await cartService.initialize();
    await searchService.initialize();

    // Initialize and fetch game tokens on app startup
    await _initializeGameTokens();

    debugPrint('✅ All services initialized');
    debugPrint('🎯 App ready to launch');
  } catch (e) {
    debugPrint('⚠️ Initialization error: $e');
  }

  // Run the app
  runApp(const MyApp());
}

/// Initialize game tokens on app startup
/// Fetches from backend with cache fallback
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
      debugPrint('⚠️ [APP_INIT] Game tokens not available, using default');
    }
  } catch (e) {
    debugPrint('❌ [APP_INIT] Game tokens initialization error: $e');
    // App continues - tokens will be empty/default
  }
}
```

---

## Dependency Injection Setup (injection_container.dart)

### Registration Order
```dart
Future<void> configureDependencies() async {
  // 1. External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  // 2. Network
  getIt.registerLazySingleton(() => RestClient(getIt()));
  getIt.registerLazySingleton(() => GraphQLClientService());
  getIt.registerLazySingleton(() => ApiClient(...));

  // 3. Cache managers
  getIt.registerLazySingleton(() => GameTokensCache());

  // 4. Services
  getIt.registerLazySingleton(() => GameTokensService(...));
  getIt.registerLazySingleton(() => ContestJoinService(...));

  // 5. Other features...
}
```

### Critical Order Constraints
```
SharedPreferences   (must be first - used by cache)
  ↓
RestClient (network)
  ↓
GameTokensCache (uses SharedPreferences)
  ↓
GameTokensService (uses cache + API)
  ↓
ContestJoinService (uses service + cache)
```

---

## Game Tokens Service Registration

### in injection_container.dart
```dart
// Fantasy - Game Tokens
getIt.registerLazySingleton(() => GameTokensCache());

getIt.registerLazySingleton(
  () => GameTokensService(
    getIt<ApiImplWithAccessToken>(),
    getIt<GameTokensCache>(),
  ),
);

getIt.registerLazySingleton(
  () => ContestJoinService(
    getIt<ApiImplWithAccessToken>(),
    getIt<GameTokensCache>(),
  ),
);
```

### Lazy Singleton Pattern
```
Why lazy singleton?
├─→ Single instance per app session
├─→ Created on first access
├─→ Shared across all screens
├─→ Memory efficient
└─→ State persists throughout app lifecycle
```

---

## Initialization Sequence

### Phase 1: System Setup
```
1. WidgetsFlutterBinding.ensureInitialized()
   └─→ Allows async operations before runApp()

2. SystemChrome.setSystemUIOverlayStyle()
   └─→ Set status bar color/brightness

3. Hive.initFlutter()
   └─→ Initialize local database
```

### Phase 2: Configuration
```
1. dotenv.load()
   └─→ Load API URLs, keys from .env file
   └─→ Try/catch - app continues if file missing

2. Firebase.initializeApp()
   └─→ Cloud messaging, analytics
   └─→ Skipped on web platform
```

### Phase 3: Dependency Injection
```
1. configureDependencies()
   └─→ Register all services in GetIt
   └─→ Order matters! (see order constraints)

2. Services can now access each other
   └─→ Example: GameTokensService uses cache
```

### Phase 4: Authentication
```
1. core_auth.authService.initialize()
   └─→ Load JWT token from secure storage
   └─→ Setup auth interceptor

2. Fantasy auth token added to all API calls
   └─→ ApiClient automatically adds header
```

### Phase 5: Game Tokens
```
1. _initializeGameTokens() called
   └─→ Fetch balance from backend
   └─→ Fallback to cache if offline
   └─→ Display loaded balance in UI

2. Balance available for all screens
   └─→ MyBalancePage shows loaded balance
   └─→ ContestJoinService uses cached balance
```

---

## Error Handling Strategy

### Initialization Errors Don't Block App

```
If Game Tokens Fail:
├─→ App still launches
├─→ Balance defaults to empty/0.0
├─→ User can retry from wallet screen
└─→ No app crash

If Firebase Fails:
├─→ App continues without notifications
├─→ Fantasy features still work
└─→ User can still play contests

If Auth Fails:
├─→ User presented with login screen
├─→ Can manually login
└─→ Tokens fetched after login
```

### Try-Catch at Every Level

```dart
// Level 1: main()
try {
  await configureDependencies();
  await _initializeGameTokens();
} catch (e) {
  debugPrint('⚠️ Initialization error: $e');
  // App continues with defaults
}

// Level 2: _initializeGameTokens()
try {
  final gameTokensService = getIt<GameTokensService>();
  final tokens = await gameTokensService.fetchGameTokensOnStartup();
} catch (e) {
  debugPrint('❌ Game tokens error: $e');
  // Logged but app continues
}

// Level 3: GameTokensService.fetchGameTokensOnStartup()
try {
  final tokens = await _fetchFromBackend();
} catch (e) {
  final error = GameTokensErrorHandler.categorizeError(e);
  // Use cache fallback
  return await _cache.getTokens();
}
```

---

## Logging During Initialization

### Log Output (Console)
```
WidgetsFlutterBinding.ensureInitialized()
✅ Firebase initialized successfully
✅ All services initialized
🔄 [APP_INIT] Initializing game tokens...
✅ [GAME_TOKENS_SERVICE] Fetching game tokens on startup...
✅ [GAME_TOKENS_SERVICE] Backend fetch successful: 1000.0
✅ [APP_INIT] Game tokens loaded: 1000.0 tokens
🎯 App ready to launch
```

### Search for Initialization Issues
```
❌ - Critical errors (check before app launch)
⚠️ - Warnings (app continues with fallback)
🔄 - In-progress operations
✅ - Successful completions
```

---

## Testing Initialization

### Test 1: Normal Startup
```
Precondition:
- User logged in
- Internet connected
- Game tokens available in backend

Expected:
- App launches
- Balance loaded: "✅ Game tokens loaded: 1000 tokens"
- MyBalancePage shows ₹1000
```

### Test 2: Offline Startup
```
Precondition:
- User logged in
- No internet connection
- Cache has previous balance: ₹500

Expected:
- App launches
- Backend call fails
- Falls back to cache
- Shows ₹500 from cache
- Warning: "⚠️ Using cached tokens"
```

### Test 3: No Cache Available
```
Precondition:
- First time user
- No internet connection
- Cache empty

Expected:
- App launches
- Backend call fails
- Cache empty
- Shows default: ₹0
- Log: "⚠️ Game tokens not available"
```

### Test 4: Backend Error
```
Precondition:
- Internet connected
- Backend returns 500 error

Expected:
- App launches
- Backend call fails with 500
- Categorized as backendError
- Falls back to cache
- Shows cached balance
```

### Test 5: Session Expired
```
Precondition:
- JWT token expired
- Backend returns 401

Expected:
- App launches
- Backend call fails with 401
- Categorized as unauthorized
- User shown login screen
- After login, tokens fetched
```

---

## Debugging Tips

### Enable Initialization Logging
```dart
// Add to main.dart if needed
debugPrintBeginFrame = true;
debugPrintEndFrame = true;
```

### Check Initialization Order
```
1. Look for error messages in console
2. Search for time stamps
3. Verify order: DI → Auth → GameTokens → App
```

### Common Issues

**Issue: "GameTokensService not found in GetIt"**
```
Solution:
- Check injection_container.dart has registration
- Verify configureDependencies() called in main()
- Check import statement for GameTokensService
```

**Issue: "Game tokens always show ₹0"**
```
Solution:
- Check backend endpoint returns correct response
- Verify JWT token sent with request
- Check cache is saving tokens
- Look for "Backend call failed" logs
```

**Issue: "App crashes on startup"**
```
Solution:
- Check try-catch in _initializeGameTokens()
- Look for unhandled exceptions
- Verify all services registered before use
- Check for circular dependencies in DI
```

---

## Performance Optimization

### Initialization Timeline
```
Phase 1: System setup              ~50ms
Phase 2: Configuration             ~200ms
Phase 3: DI setup                  ~100ms
Phase 4: Auth initialization       ~300ms
Phase 5: Game tokens fetch         ~500ms (network dependent)
──────────────────────────────────────────
Total                              ~1150ms (varies)
```

### Optimization Strategies
```
1. Parallel Initialization
   ├─→ Auth + GameTokens can run in parallel
   └─→ Use Future.wait() for concurrent operations

2. Async Initialization
   ├─→ Don't block UI while initializing
   ├─→ Show splash screen during init
   └─→ Continue with defaults if backend slow

3. Lazy Loading
   ├─→ Services created on first access (lazy singleton)
   └─→ Not created until actually needed
```

---

## Production Checklist

Before releasing to production:

- [ ] Game tokens initialized on startup
- [ ] Error handling doesn't crash app
- [ ] Offline mode works with cache
- [ ] Session expired redirects to login
- [ ] Logging properly configured
- [ ] No sensitive data in logs
- [ ] Cache expiry working (5 minutes)
- [ ] Performance acceptable (~1-2 seconds)
- [ ] Multiple startup tests passed
- [ ] Backend endpoints verified

---

## Summary

**Game Tokens Initialization:**
1. ✅ Called in main() after DI setup
2. ✅ Fetches from backend with cache fallback
3. ✅ Non-blocking - app continues even if fails
4. ✅ Proper error categorization
5. ✅ Logging at each step
6. ✅ Ready for production

**Key Components:**
- GameTokensService - Fetch logic
- GameTokensCache - Local persistence
- GameTokensErrorHandler - Error categorization
- main.dart - Initialization orchestration

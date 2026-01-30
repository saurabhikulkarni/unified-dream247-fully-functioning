import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:unified_dream247/config/api_config.dart';
import 'package:unified_dream247/features/shop/services/graphql_client.dart';
import 'package:unified_dream247/features/shop/services/graphql_queries.dart';
import 'package:unified_dream247/core/services/wallet_service.dart';
import 'package:unified_dream247/core/services/shop/wishlist_service.dart'
    as core_wishlist;
import 'package:unified_dream247/core/services/shop/cart_service.dart'
    as core_cart;
import 'package:unified_dream247/features/shop/services/user_service.dart';
import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_storage_keys.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_storage.dart';
import 'package:unified_dream247/core/services/auth_service.dart' as core_auth;

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final GraphQLClient _graphQLClient = GraphQLService.getClient();

  // Keys for SharedPreferences
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userPhoneKey = 'user_phone';
  static const String _userNameKey = 'user_name';
  static const String _phoneVerifiedKey = 'phone_verified';
  static const String _walletBalanceKey = 'wallet_balance';
  static const String _authTokenKey = 'auth_token';
  static const String _lastLoginKey = 'last_login';
  static const String _userIdKey = 'user_id';

  bool _isInitialized = false;

  // Initialize auth service from SharedPreferences
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Initialize UserService with userId from SharedPreferences if user is logged in
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userIdKey);
      if (userId != null && userId.isNotEmpty) {
        await UserService.setCurrentUserId(userId);
      }
    } catch (e) {
      print('Error initializing UserService userId: $e');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Check if phone is verified
  Future<bool> isPhoneVerified() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_phoneVerifiedKey) ?? false;
    } catch (e) {
      print('Error checking phone verification: $e');
      return false;
    }
  }

  // Get user phone
  Future<String?> getUserPhone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userPhoneKey);
    } catch (e) {
      print('Error getting user phone: $e');
      return null;
    }
  }

  // Get user name
  Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey);
    } catch (e) {
      print('Error getting user name: $e');
      return null;
    }
  }

  // Check if phone number is test user
  bool isTestUser(String phone) {
    if (!enableTestUser) return false;
    return phone.replaceAll(RegExp(r'[^\d]'), '') == testUserPhone;
  }

  // Login test user directly (bypass OTP)
  Future<bool> loginTestUser() async {
    if (!enableTestUser) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, testUserId);
      await prefs.setString(_userPhoneKey, testUserPhone);
      await prefs.setString(_userNameKey, testUserName);
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setBool(_phoneVerifiedKey, true);
      await prefs.setDouble(_walletBalanceKey, testUserWalletBalance);
      await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());

      // Set current user ID in UserService
      await UserService.setCurrentUserId(testUserId);

      // Share user ID with fantasy auth service
      await prefs.setString('user_id_fantasy', testUserId);
      await prefs.setBool('is_logged_in_fantasy', true);
      await prefs.setString('user_phone_fantasy', testUserPhone);

      print('✅ Test user logged in successfully');
      print('User ID: $testUserId');
      print('Phone: $testUserPhone');
      print('Wallet: $testUserWalletBalance');

      return true;
    } catch (e) {
      print('Error logging in test user: $e');
      return false;
    }
  }

  // Get user ID
  Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }

  // Save login session
  Future<void> saveLoginSession({
    required String phone,
    required String name,
    required bool phoneVerified,
    String? userId,
    String? fantasyToken,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userPhoneKey, phone);
      await prefs.setString(_userNameKey, name);
      await prefs.setBool(_phoneVerifiedKey, phoneVerified);
      await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());

      // Store userId and set it in wallet/wishlist/cart services
      if (userId != null && userId.isNotEmpty) {

        // Save to all possible keys for Shop and Fantasy compatibility
        await prefs.setString(_userIdKey, userId); // user_id (primary)
        await prefs.setString(
            'shop_user_id', userId); // shop_user_id (explicit)
        await prefs.setString(
            'user_id_fantasy', userId); // user_id_fantasy (fantasy legacy)
        await prefs.setString('userId', userId); // userId (fantasy modern)

        // Set userId in user services for GraphQL backend sync
        // Note: UnifiedWalletService gets userId from SharedPreferences automatically
        await UserService.setCurrentUserId(userId);

        // Initialize wishlist and cart services with userId
        await core_wishlist.wishlistService.initialize();
        await core_cart.cartService.initialize();

        // Fantasy session flags - SYNC BOTH login flags
        await prefs.setBool('is_logged_in_fantasy', true);
        await prefs.setBool(
            _isLoggedInKey, true); // Also set Shop login flag for sync
        await prefs.setString('user_phone_fantasy', phone);
      }

      // Store user phone (shared identifier across both systems)
      await prefs.setString('user_phone', phone);

      // Store fantasy JWT token for API authentication
      if (fantasyToken != null && fantasyToken.isNotEmpty) {
        // Save to both keys for compatibility:
        // - 'token' for Fantasy module (AppStorageKeys.authToken)
        // - 'auth_token' for core AuthService (StorageConstants.authToken)
        await prefs.setString('token', fantasyToken);
        await prefs.setString('auth_token', fantasyToken);

        // Verify token was saved to both keys
        final tokenKey1 = prefs.getString('token');
        final tokenKey2 = prefs.getString('auth_token');
        if (tokenKey1 != fantasyToken || tokenKey2 != fantasyToken) {
          print('❌ [AUTH] Token verification failed!');
          if (tokenKey1 != fantasyToken) print('  - Key "token" mismatch');
          if (tokenKey2 != fantasyToken) print('  - Key "auth_token" mismatch');
        }
      } else {
        print('❌ [AUTH] No fantasy token to save (token is null or empty)');
      }
    } catch (e) {
      print('Error saving login session: $e');
    }
  }

  // Fetch fantasy authentication token from backend
  Future<String?> fetchFantasyToken({
    required String phone,
    String? name,
    String? username,
    String? shopUserId,
    String? userId,
    bool isNewUser = false,
  }) async {
    try {
      // Fantasy backend user endpoint - using correct userServerUrl structure
      // Fantasy uses: baseUrl/user/ + endpoint (not /api/user/)
      final userBaseUrl =
          ApiConfig.fantasyUserUrl; // http://134.209.158.211:4000/user/
      final loginEndpoint =
          '${userBaseUrl}verify-otp'; // Creates user or returns existing

      // Clean mobile number (remove non-digits)
      final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

      // Parse name into firstName and lastName
      final nameParts = (name ?? '').trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // Prepare request body for Fantasy user creation/login
      final body = {
        'mobile_number': cleanPhone,
        'first_name': firstName,
        'last_name': lastName,
        'username': username ?? firstName.toLowerCase(),
        'name': name ?? '$firstName $lastName'.trim(),
        'hygraph_user_id': userId ?? '',
      };

      // Make HTTP POST request to fantasy backend for user login/registration
      final response = await http
          .post(
            Uri.parse(loginEndpoint),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        // Try different possible token keys from multiple response formats
        String? token;

        // Format 1: Direct token field
        token = data['token'] as String?;

        // Format 2: accessToken field
        if (token == null || token.isEmpty) {
          token = data['accessToken'] as String?;
        }

        // Format 3: access_token field
        if (token == null || token.isEmpty) {
          token = data['access_token'] as String?;
        }

        // Format 4: data.auth_key field (nested in data object)
        if (token == null || token.isEmpty) {
          final dataObj = data['data'];
          if (dataObj != null && dataObj is Map) {
            token = dataObj['auth_key'] as String?;
          }
        }

        // Format 5: Direct auth_key field
        if (token == null || token.isEmpty) {
          token = data['auth_key'] as String?;
        }

        if (token != null && token.isNotEmpty) {
          return token;
        } else {
          print('❌ [AUTH] No token found in any expected field');
          return null;
        }
      } else {
        print(
            '❌ [AUTH] Fantasy token fetch failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ [AUTH] Error fetching fantasy token: $e');
      return null;
    }
  }

  // Mark phone as verified
  Future<void> markPhoneVerified(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userPhoneKey, phone);
      await prefs.setBool(_phoneVerifiedKey, true);
    } catch (e) {
      print('Error marking phone as verified: $e');
    }
  }

  /// Clear LOCAL login session (logout)
  ///
  /// ✅ IMPORTANT: This only clears LOCAL session data.
  /// ✅ User's data (shopTokens, wallet balance, orders, etc.) is SAFELY STORED ON BACKEND.
  /// ✅ When user logs back in, their data will be automatically restored from the backend.
  Future<void> unifiedLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear Shop LOCAL authentication (backend data is preserved)
      await prefs.setBool(_isLoggedInKey, false);
      await prefs.remove(_userPhoneKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_phoneVerifiedKey);
      await prefs.remove(_walletBalanceKey);
      await prefs.remove(_authTokenKey);
      await prefs.remove(_lastLoginKey);
      await prefs.remove(_userIdKey);
      await prefs.remove('shop_user_id');
      await prefs.remove('userId');
      await prefs.remove('user_id');

      // Clear LOCAL Fantasy authentication tokens
      await prefs.remove('token');
      await prefs.remove('auth_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_id_fantasy');
      await prefs.remove('is_logged_in_fantasy');
      await prefs.remove('user_phone_fantasy');
      await prefs.remove('shop_tokens');
      await prefs.remove('wallet_balance');
      await prefs.remove('wallet_last_update');

      // Clear LOCAL Fantasy storage
      await AppStorage.saveToStorageBool(AppStorageKeys.isLoggedIn, false);
      await AppStorage.removeStorageValue(AppStorageKeys.authToken);
      await AppStorage.removeStorageValue(AppStorageKeys.loginToken);
      await AppStorage.removeStorageValue(AppStorageKeys.userId);

      // Clear core AuthService LOCAL data
      try {
        final coreAuthService = core_auth.AuthService();
        await coreAuthService.initialize();
        await coreAuthService.logout();
      } catch (e) {
        debugPrint('⚠️ [LOGOUT] Error clearing core AuthService: $e');
      }

      // Clear LOCAL wallet, wishlist, cart caches
      await UnifiedWalletService().clearAll();
      await core_wishlist.wishlistService.clearWishlist();
      await core_cart.cartService.clearCart();
      await UserService.setCurrentUserId('');

      // Clear image cache to prevent memory issues on re-login
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (e) {
      debugPrint('❌ Error in unified logout: $e');
    }
  }

  Future<void> logout() async {
    try {
      await unifiedLogout();
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Get last login time
  Future<DateTime?> getLastLoginTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastLoginStr = prefs.getString(_lastLoginKey);
      if (lastLoginStr != null) {
        return DateTime.parse(lastLoginStr);
      }
      return null;
    } catch (e) {
      print('Error getting last login time: $e');
      return null;
    }
  }

  // Get wallet balance
  Future<double> getWalletBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_walletBalanceKey) ?? 0.0;
    } catch (e) {
      print('Error getting wallet balance: $e');
      return 0.0;
    }
  }

  // Update wallet balance
  Future<void> updateWalletBalance(double newBalance) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_walletBalanceKey, newBalance);
    } catch (e) {
      print('Error updating wallet balance: $e');
    }
  }

  // Get auth token
  Future<String?> getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_authTokenKey);
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  // Save login session with wallet balance
  Future<void> saveLoginSessionWithToken({
    required String phone,
    required String name,
    required bool phoneVerified,
    required double walletBalance,
    required String authToken,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userPhoneKey, phone);
      await prefs.setString(_userNameKey, name);
      await prefs.setBool(_phoneVerifiedKey, phoneVerified);
      await prefs.setDouble(_walletBalanceKey, walletBalance);
      await prefs.setString(_authTokenKey, authToken);
      await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error saving login session: $e');
    }
  }

  // Fetch user profile from GraphQL backend
  Future<Map<String, dynamic>?> fetchUserProfile(String userId) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(GraphQLQueries.getUserProfile),
        variables: {'userId': userId},
      );

      final QueryResult result = await _graphQLClient.query(options);

      if (result.hasException) {
        print('Error fetching user profile: ${result.exception}');
        return null;
      }

      final data = result.data?['userDetail'];
      if (data != null) {
        // Update local wallet balance from backend
        if (data['walletBalance'] != null) {
          await updateWalletBalance(data['walletBalance'].toDouble());
        }
        return data;
      }
      return null;
    } catch (e) {
      print('Exception in fetchUserProfile: $e');
      return null;
    }
  }

  /// Save unified login session (compatible with Shop and Fantasy)
  Future<void> saveUnifiedLoginSession({
    required String phone,
    required String name,
    required bool phoneVerified,
    required String userId,
    String? email,
    String? authToken,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save for Shop module
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userPhoneKey, phone);
      await prefs.setString(_userNameKey, name);
      await prefs.setBool(_phoneVerifiedKey, phoneVerified);
      await prefs.setString(_userIdKey, userId);
      await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());

      if (email != null && email.isNotEmpty) {
        await prefs.setString('user_email', email);
      }
      if (authToken != null && authToken.isNotEmpty) {
        await prefs.setString(_authTokenKey, authToken);
      }

      // Save for Fantasy module
      await AppStorage.saveToStorageString(
          AppStorageKeys.loginToken, authToken ?? userId);
      await AppStorage.saveToStorageString(AppStorageKeys.userId, userId);
      await AppStorage.saveToStorageString(AppStorageKeys.userPhone, phone);
      await AppStorage.saveToStorageString(AppStorageKeys.userName, name);
      await AppStorage.saveToStorageBool(AppStorageKeys.isLoggedIn, true);
      await AppStorage.saveToStorageBool('phone_verified', phoneVerified);

      if (email != null && email.isNotEmpty) {
        await AppStorage.saveToStorageString('user_email', email);
      }

      // Save to core AuthService
      final coreAuthService = core_auth.authService;
      await coreAuthService.saveUserSession(
        userId: userId,
        authToken: authToken ?? userId,
        mobileNumber: phone,
        email: email,
        name: name,
      );

      await UserService.setCurrentUserId(userId);

      debugPrint('✅✅✅ UNIFIED LOGIN SUCCESSFUL ✅✅✅');
      debugPrint('📱 Shop & Fantasy now share the SAME authentication');
      debugPrint('👤 User ID: $userId');
      debugPrint('☎️ Phone: $phone');
      debugPrint('🚀 Fantasy will use Shop login - no separate login needed');
    } catch (e) {
      debugPrint('❌ Error saving unified login session: $e');
      rethrow;
    }
  }

  /// Check if user is logged in (unified check)
  Future<bool> isUnifiedLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final shopLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      final fantasyLoggedIn =
          await AppStorage.getStorageBoolValue(AppStorageKeys.isLoggedIn) ??
              false;
      return shopLoggedIn || fantasyLoggedIn;
    } catch (e) {
      debugPrint('❌ Error checking unified login: $e');
      return false;
    }
  }

  /// Get unified user ID
  Future<String?> getUnifiedUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString(_userIdKey);

      if (userId == null || userId.isEmpty) {
        userId = await AppStorage.getStorageValueString(AppStorageKeys.userId);
      }
      return userId;
    } catch (e) {
      debugPrint('❌ Error getting unified user ID: $e');
      return null;
    }
  }

  /// Get unified auth token
  Future<String?> getUnifiedAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(_authTokenKey);

      if (token == null || token.isEmpty) {
        token =
            await AppStorage.getStorageValueString(AppStorageKeys.loginToken);
      }
      return token;
    } catch (e) {
      debugPrint('❌ Error getting unified token: $e');
      return null;
    }
  }

  /// Refresh access token and update shopTokens
  Future<String?> refreshAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint('⚠️ [TOKEN_REFRESH] No refresh token available');
        return null;
      }

      final response = await http
          .post(
            Uri.parse(ApiConfig.fantasyRefreshTokenEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Update auth token
        final newToken = data['token'] ?? data['accessToken'];
        if (newToken != null) {
          await prefs.setString(_authTokenKey, newToken);
          await prefs.setString('token', newToken);
        }

        // NEW: Update shopTokens balance from backend response
        if (data['user'] != null && data['user']['shopTokens'] != null) {
          final shopTokens = (data['user']['shopTokens'] as num).toInt();
          await prefs.setInt('shop_tokens', shopTokens);
          debugPrint('💰 [TOKEN_REFRESH] Updated shopTokens: $shopTokens');
        }

        debugPrint('✅ [TOKEN_REFRESH] Token refreshed successfully');
        return newToken;
      } else {
        debugPrint('❌ [TOKEN_REFRESH] Failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ [TOKEN_REFRESH] Error: $e');
      return null;
    }
  }
}

// Global instance
final authService = AuthService();

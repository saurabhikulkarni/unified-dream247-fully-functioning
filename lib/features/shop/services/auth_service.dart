import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:unified_dream247/features/shop/services/graphql_client.dart';
import 'package:unified_dream247/features/shop/services/graphql_queries.dart';
import 'package:unified_dream247/features/shop/services/wallet_service.dart';
import 'package:unified_dream247/features/shop/services/wishlist_service.dart';
import 'package:unified_dream247/features/shop/services/cart_service.dart';
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
        await prefs.setString(_userIdKey, userId);
        // Set userId in wallet, wishlist, cart, and user services for GraphQL backend sync
        walletService.setUserId(userId);
        wishlistService.setUserId(userId);
        cartService.setUserId(userId);
        await UserService.setCurrentUserId(userId);
      }
    } catch (e) {
      print('Error saving login session: $e');
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

  // Clear login session (logout)
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, false);
      await prefs.remove(_userPhoneKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_phoneVerifiedKey);
      await prefs.remove(_walletBalanceKey);
      await prefs.remove(_authTokenKey);
      await prefs.remove(_lastLoginKey);
      await prefs.remove(_userIdKey);
      
      // Clear wallet, wishlist, cart, and user services on logout
      walletService.clear();
      wishlistService.clear();
      cartService.clear();
      await UserService.setCurrentUserId(''); // Clear userId in UserService
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
      await AppStorage.saveToStorageString(AppStorageKeys.loginToken, authToken ?? userId);
      await AppStorage.saveToStorageString(AppStorageKeys.userId, userId);
      await AppStorage.saveToStorageString(AppStorageKeys.userPhone, phone);
      await AppStorage.saveToStorageString(AppStorageKeys.userName, name);
      await AppStorage.saveToStorageBool(AppStorageKeys.isLoggedIn, true);
      await AppStorage.saveToStorageBool('phone_verified', phoneVerified);
      
      if (email != null && email.isNotEmpty) {
        await AppStorage.saveToStorageString(AppStorageKeys.userEmail, email);
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
      
      debugPrint('✅ Unified login session saved - Shop & Fantasy ready');
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
      final fantasyLoggedIn = await AppStorage.getStorageBoolValue(AppStorageKeys.isLoggedIn) ?? false;
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
        token = await AppStorage.getStorageValueString(AppStorageKeys.loginToken);
      }
      return token;
    } catch (e) {
      debugPrint('❌ Error getting unified token: $e');
      return null;
    }
  }

  /// Unified logout (clears both Shop and Fantasy)
  Future<void> unifiedLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear Shop data
      await prefs.setBool(_isLoggedInKey, false);
      await prefs.remove(_userPhoneKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_phoneVerifiedKey);
      await prefs.remove(_walletBalanceKey);
      await prefs.remove(_authTokenKey);
      await prefs.remove(_lastLoginKey);
      await prefs.remove(_userIdKey);
      await prefs.remove('user_email');
      
      // Clear Fantasy data
      await AppStorage.removeStorageValue(AppStorageKeys.loginToken);
      await AppStorage.removeStorageValue(AppStorageKeys.userId);
      await AppStorage.removeStorageValue(AppStorageKeys.userPhone);
      await AppStorage.removeStorageValue(AppStorageKeys.userName);
      await AppStorage.saveToStorageBool(AppStorageKeys.isLoggedIn, false);
      await AppStorage.removeStorageValue('phone_verified');
      await AppStorage.removeStorageValue(AppStorageKeys.userEmail);
      
      // Clear core auth
      final coreAuthService = core_auth.authService;
      await coreAuthService.logout();
      
      // Clear services
      walletService.clear();
      wishlistService.clear();
      cartService.clear();
      await UserService.setCurrentUserId('');
      
      debugPrint('✅ Unified logout completed');
    } catch (e) {
      debugPrint('❌ Error during logout: $e');
    }
  }
}

// Global instance
final authService = AuthService();

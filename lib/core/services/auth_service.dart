import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../constants/storage_constants.dart';
import 'package:unified_dream247/config/api_config.dart';
import '../models/unified_user_model.dart';

/// 🔗 UNIFIED AUTHENTICATION SERVICE
///
/// This service manages authentication for BOTH Shop and Fantasy modules.
/// There is ONLY ONE login system: MSG91 OTP-based authentication from the Shop module.
///
/// KEY PRINCIPLES:
/// ✅ Single login point: Shop's MSG91 OTP authentication
/// ✅ One user ID: Same user ID used across Shop and Fantasy
/// ✅ Automatic Fantasy access: User logged into Shop automatically has access to Fantasy
/// ✅ Unified logout: Logging out from either module logs out from both
///
/// FLOW:
/// 1. User enters phone number on Shop login screen
/// 2. MSG91 sends OTP to the phone
/// 3. User verifies OTP
/// 4. Shop backend creates/retrieves user with unique user ID
/// 5. User ID is SAVED to both Shop storage and Fantasy storage
/// 6. Fantasy reads this user ID from storage (no separate Fantasy login needed)
/// 7. Both modules use the same user ID for API calls
/// 8. Logout from either module clears auth from both
///
/// Shared authentication service for unified session management
/// This service is used by both ecommerce and fantasy modules
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  SharedPreferences? _prefs;

  /// Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Module access storage keys
  static const String fantasyUserId = 'fantasy_user_id';
  static const String shopEnabled = 'shop_enabled';
  static const String fantasyEnabled = 'fantasy_enabled';
  static const String modules = 'modules';
  static const String _userKey = 'unified_user_data';

  // ─────────────────────────────────────────────────────────────────────────
  // OTP AUTHENTICATION METHODS
  // ─────────────────────────────────────────────────────────────────────────

  /// Send OTP to mobile number
  Future<Map<String, dynamic>> sendOtp(String mobileNumber) async {
    try {
      // Clean mobile number
      final cleanMobile = mobileNumber.replaceAll(RegExp(r'[^\d]'), '');

      if (kDebugMode) {
        debugPrint('📱 [AUTH] Sending OTP to: $cleanMobile');
        debugPrint('📱 [AUTH] URL: ${ApiConfig.shopSendOtpEndpoint}');
      }

      final response = await http
          .post(
            Uri.parse(ApiConfig.shopSendOtpEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'mobileNumber': cleanMobile}),
          )
          .timeout(const Duration(seconds: ApiConfig.requestTimeoutSeconds));

      final data = jsonDecode(response.body);

      if (kDebugMode) {
        debugPrint('📱 [AUTH] Send OTP Response: ${response.statusCode}');
      }

      return {
        'success': data['success'] ?? false,
        'sessionId': data['sessionId'],
        'message': data['message'] ?? 'OTP sent successfully',
      };
    } catch (e) {
      debugPrint('❌ [AUTH] Send OTP Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Verify OTP and Login/Register user
  /// Returns user data and tokens on success
  Future<Map<String, dynamic>> verifyOtp({
    required String mobileNumber,
    required String otp,
    String? sessionId,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final cleanMobile = mobileNumber.replaceAll(RegExp(r'[^\d]'), '');

      if (kDebugMode) {
        debugPrint('📱 [AUTH] Verifying OTP for: $cleanMobile');
        debugPrint('📱 [AUTH] URL: ${ApiConfig.shopVerifyOtpEndpoint}');
      }

      final response = await http
          .post(
            Uri.parse(ApiConfig.shopVerifyOtpEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'mobileNumber': cleanMobile,
              'otp': otp,
              'sessionId': sessionId,
              'firstName': firstName,
              'lastName': lastName,
            }),
          )
          .timeout(const Duration(seconds: ApiConfig.requestTimeoutSeconds));

      final data = jsonDecode(response.body);

      if (kDebugMode) {
        debugPrint('📱 [AUTH] Verify OTP Response: ${response.statusCode}');
        debugPrint('📱 [AUTH] Success: ${data['success']}');
      }

      if (data['success'] == true) {
        // Save tokens
        final accessToken = data['authToken'] ?? data['token'];
        final refreshToken = data['refreshToken'];

        if (accessToken != null) {
          await _prefs?.setString(StorageConstants.authToken, accessToken);
          await _prefs?.setString(
            'token',
            accessToken,
          ); // For Fantasy compatibility
        }
        if (refreshToken != null) {
          await _prefs?.setString('refresh_token', refreshToken);
        }

        // Parse and save user
        if (data['user'] != null) {
          final user = UnifiedUserModel.fromJson(data['user']);
          await _saveUnifiedUser(user);

          // Also save to legacy keys for backward compatibility
          await saveUserSession(
            userId: user.userId,
            authToken: accessToken ?? '',
            mobileNumber: user.mobileNumber,
            name: user.fullName,
            fantasyUserId: user.fantasyUserId,
            shopEnabled: user.shopEnabled,
            fantasyEnabled: user.fantasyEnabled,
            modules: user.modules,
            refreshToken: refreshToken,
          );

          return {
            'success': true,
            'user': user,
            'isNewUser': user.isNewUser,
            'message': data['message'] ?? 'Login successful',
          };
        }

        return {
          'success': true,
          'isNewUser': data['isNewUser'] ?? false,
          'message': data['message'] ?? 'Login successful',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Verification failed',
      };
    } catch (e) {
      debugPrint('❌ [AUTH] Verify OTP Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Save unified user to storage
  Future<void> _saveUnifiedUser(UnifiedUserModel user) async {
    await _prefs?.setString(_userKey, jsonEncode(user.toJson()));

    // Also save individual fields for backward compatibility
    await _prefs?.setString(StorageConstants.userId, user.userId);
    await _prefs?.setString('user_id', user.userId);
    await _prefs?.setString('userId', user.userId);
    await _prefs?.setInt('shop_tokens', user.shopTokens);

    if (user.fantasyUserId != null) {
      await _prefs?.setString(AuthService.fantasyUserId, user.fantasyUserId!);
      await _prefs?.setString('user_id_fantasy', user.fantasyUserId!);
    }
  }

  /// Get stored unified user
  Future<UnifiedUserModel?> getUnifiedUser() async {
    final userData = _prefs?.getString(_userKey);
    if (userData == null) return null;

    try {
      return UnifiedUserModel.fromJson(jsonDecode(userData));
    } catch (e) {
      debugPrint('Error parsing unified user: $e');
      return null;
    }
  }

  /// Update shop tokens in stored user
  Future<void> updateShopTokens(int newBalance) async {
    final user = await getUnifiedUser();
    if (user != null) {
      final updatedUser = user.copyWith(shopTokens: newBalance);
      await _saveUnifiedUser(updatedUser);
    }
    await _prefs?.setInt('shop_tokens', newBalance);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOGIN FROM SHOP (After OTP Verification)
  // ─────────────────────────────────────────────────────────────────────────

  /// Login to Fantasy backend after Shop OTP verification
  /// This creates/syncs user in Fantasy MongoDB with Hygraph user ID
  Future<Map<String, dynamic>> loginFromShop({
    required String hygraphUserId,
    required String mobileNumber,
    String? firstName,
    String? lastName,
    String? username,
    String? name,
    int shopTokens = 0,
    int totalSpentTokens = 0,
    double walletBalance = 0,
  }) async {
    try {
      final cleanMobile = mobileNumber.replaceAll(RegExp(r'[^\d]'), '');

      if (kDebugMode) {
        debugPrint('🔗 [AUTH] Login from Shop to Fantasy backend');
        debugPrint('🔗 [AUTH] Hygraph User ID: $hygraphUserId');
        debugPrint('🔗 [AUTH] URL: ${ApiConfig.fantasyUserLoginEndpoint}');
      }

      // Fantasy backend add-temporary-user expects mobile_number only
      // It will return a temporary user entry and send OTP
      final response = await http
          .post(
            Uri.parse(ApiConfig.fantasyUserLoginEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'mobile':
                  cleanMobile, // Fantasy expects 'mobile' not 'mobile_number'
            }),
          )
          .timeout(const Duration(seconds: ApiConfig.requestTimeoutSeconds));

      final data = jsonDecode(response.body);

      if (kDebugMode) {
        debugPrint('🔗 [AUTH] Fantasy Login Response: ${response.statusCode}');
        debugPrint('🔗 [AUTH] Success: ${data['status'] ?? data['success']}');
      }

      if (data['status'] == true || data['success'] == true) {
        // Extract tokens from response (support both auth_key and fantasy_auth_key)
        final accessToken = data['data']?['auth_key'] ??
            data['data']?['fantasy_auth_key'] ??
            data['token'] ??
            data['authToken'];
        final refreshToken =
            data['data']?['refresh_token'] ?? data['refreshToken'];
        final fantasyUserId = data['data']?['userid'] ?? data['userId'];

        // Extract sync status fields for debugging
        final fantasySyncStatus =
            data['data']?['fantasy_sync_status'] ?? data['fantasy_sync_status'];
        final fantasySyncError =
            data['data']?['fantasy_sync_error'] ?? data['fantasy_sync_error'];

        // Log sync status for debugging
        if (kDebugMode) {
          debugPrint('🔗 [AUTH] Fantasy Sync Status: $fantasySyncStatus');
          if (fantasySyncError != null) {
            debugPrint('⚠️ [AUTH] Fantasy Sync Error: $fantasySyncError');
          }
        }

        // Store sync status in SharedPreferences for later access
        if (fantasySyncStatus != null) {
          await _prefs?.setString('fantasy_sync_status', fantasySyncStatus);
        }
        if (fantasySyncError != null) {
          await _prefs?.setString('fantasy_sync_error', fantasySyncError);
        }

        // Save tokens
        if (accessToken != null) {
          await _prefs?.setString(StorageConstants.authToken, accessToken);
          await _prefs?.setString('token', accessToken);
        }
        if (refreshToken != null) {
          await _prefs?.setString('refresh_token', refreshToken);
        }

        // Save user session
        await saveUserSession(
          userId: hygraphUserId,
          authToken: accessToken ?? '',
          mobileNumber: cleanMobile,
          name: name ?? '$firstName $lastName'.trim(),
          fantasyUserId: fantasyUserId,
          shopEnabled: true,
          fantasyEnabled: true,
          modules: ['shop', 'fantasy'],
          refreshToken: refreshToken,
        );

        // Create unified user model
        final user = UnifiedUserModel(
          userId: hygraphUserId,
          fantasyUserId: fantasyUserId,
          mobileNumber: cleanMobile,
          firstName: firstName ?? '',
          lastName: lastName ?? '',
          username: username,
          modules: const ['shop', 'fantasy'],
          shopEnabled: true,
          fantasyEnabled: true,
          shopTokens: shopTokens,
          isNewUser: data['data']?['isNewUser'] ?? data['isNewUser'] ?? false,
        );
        await _saveUnifiedUser(user);

        debugPrint('✅ [AUTH] Fantasy login successful');
        debugPrint('✅ [AUTH] Fantasy User ID: $fantasyUserId');

        return {
          'success': true,
          'message': data['message'] ?? 'Login successful',
          'accessToken': accessToken,
          'refreshToken': refreshToken,
          'userId': hygraphUserId,
          'fantasyUserId': fantasyUserId,
          'user': user,
          'isNewUser': data['data']?['isNewUser'] ?? data['isNewUser'] ?? false,
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Fantasy login failed',
      };
    } catch (e) {
      debugPrint('❌ [AUTH] Fantasy Login Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Save user session after successful login
  Future<void> saveUserSession({
    required String userId,
    required String authToken,
    required String mobileNumber,
    String? email,
    String? name,
    String? fantasyUserId,
    bool shopEnabled = true,
    bool fantasyEnabled = true,
    List<String> modules = const ['shop', 'fantasy'],
    String? refreshToken,
  }) async {
    await _prefs?.setString(StorageConstants.userId, userId);

    // IMPORTANT: Only update token if the new token is valid (not empty)
    // This prevents overwriting a valid token with an empty string
    if (authToken.isNotEmpty) {
      await _prefs?.setString(StorageConstants.authToken, authToken);
      await _prefs?.setString('token', authToken); // Ensure legacy key is set
      debugPrint('✅ [AUTH] Token saved: ${authToken.length} chars');
    } else {
      debugPrint(
        '⚠️ [AUTH] Skipping token save - empty token provided (keeping existing)',
      );
    }

    await _prefs?.setString('mobile_number', mobileNumber);
    await _prefs?.setBool(StorageConstants.isLoggedIn, shopEnabled);
    // Set Fantasy login flag based on fantasyEnabled parameter
    await _prefs?.setBool('is_logged_in_fantasy', fantasyEnabled);

    if (email != null) {
      await _prefs?.setString(StorageConstants.userEmail, email);
    }
    if (name != null) {
      await _prefs?.setString('user_name', name);
    }
    if (fantasyUserId != null) {
      await _prefs?.setString(AuthService.fantasyUserId, fantasyUserId);
    }
    if (refreshToken != null) {
      await _prefs?.setString('refresh_token', refreshToken);
    }

    await _prefs?.setBool(AuthService.shopEnabled, shopEnabled);
    await _prefs?.setBool(AuthService.fantasyEnabled, fantasyEnabled);
    await _prefs?.setStringList(AuthService.modules, modules);
  }

  /// Check if user is logged in
  /// Checks BOTH Shop (is_logged_in) AND Fantasy (is_logged_in_fantasy) flags
  Future<bool> isLoggedIn() async {
    final isShopLoggedIn =
        _prefs?.getBool(StorageConstants.isLoggedIn) ?? false;
    final isFantasyLoggedIn = _prefs?.getBool('is_logged_in_fantasy') ?? false;

    // Also verify we have a valid token (not empty)
    final token = _prefs?.getString(StorageConstants.authToken);
    final hasValidToken = token != null && token.isNotEmpty;

    // User is logged in if any login flag is true AND we have a valid token
    final result = (isShopLoggedIn || isFantasyLoggedIn) && hasValidToken;

    debugPrint(
      '🔐 [AUTH] isLoggedIn check: shop=$isShopLoggedIn, fantasy=$isFantasyLoggedIn, token=${hasValidToken ? "valid" : "missing"} => $result',
    );

    return result;
  }

  /// Get user ID
  String? getUserId() {
    return _prefs?.getString(StorageConstants.userId);
  }

  /// Get authentication token
  String? getAuthToken() {
    return _prefs?.getString(StorageConstants.authToken);
  }

  /// Get mobile number
  String? getMobileNumber() {
    return _prefs?.getString('mobile_number');
  }

  /// Get user email
  String? getUserEmail() {
    return _prefs?.getString(StorageConstants.userEmail);
  }

  /// Get user name
  String? getUserName() {
    return _prefs?.getString('user_name');
  }

  /// Get fantasy user ID (MongoDB ID)
  String? getFantasyUserId() {
    return _prefs?.getString(AuthService.fantasyUserId);
  }

  /// Check if shop module is enabled
  bool isShopEnabled() {
    return _prefs?.getBool(AuthService.shopEnabled) ?? true;
  }

  /// Check if fantasy module is enabled
  bool isFantasyEnabled() {
    return _prefs?.getBool(AuthService.fantasyEnabled) ?? true;
  }

  /// Get list of enabled modules
  List<String> getModules() {
    return _prefs?.getStringList(AuthService.modules) ?? ['shop', 'fantasy'];
  }

  /// Get refresh token
  String? getRefreshToken() {
    return _prefs?.getString('refresh_token');
  }

  /// Check if access token is valid (local JWT validation)
  Future<bool> isTokenValid() async {
    final token = getAuthToken();
    if (token == null) return false;

    try {
      // Decode JWT to check expiry locally
      final parts = token.split('.');
      if (parts.length != 3) return false;

      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      final exp = payload['exp'];
      if (exp == null) return true; // No expiry means token is valid

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isBefore(expiryDate);
    } catch (e) {
      debugPrint('Error checking token validity: $e');
      return false;
    }
  }

  /// Get a valid access token (auto-refresh if expired)
  /// Uses ApiConfig for backend URL automatically
  Future<String?> getValidToken([String? backendUrl]) async {
    final token = getAuthToken();

    if (token == null) return null;

    // Check if token is still valid
    if (await isTokenValid()) {
      return token;
    }

    // Token expired, try to refresh
    return await refreshAccessToken(backendUrl);
  }

  /// Refresh access token using refresh token
  /// Uses ApiConfig.shopRefreshTokenEndpoint by default
  Future<String?> refreshAccessToken([String? backendUrl]) async {
    final refreshToken = getRefreshToken();

    if (refreshToken == null) {
      debugPrint('No refresh token available');
      return null;
    }

    try {
      final url = backendUrl != null
          ? '$backendUrl/api/auth/refresh-token'
          : ApiConfig.shopRefreshTokenEndpoint;

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(const Duration(seconds: ApiConfig.requestTimeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final newToken = data['token'];

          // Update stored access token
          await _prefs?.setString(StorageConstants.authToken, newToken);
          await _prefs?.setString('token', newToken); // Fantasy compatibility

          // Update refresh token if provided
          if (data['refreshToken'] != null) {
            await _prefs?.setString('refresh_token', data['refreshToken']);
          }

          // Update shopTokens if provided
          if (data['user']?['shopTokens'] != null) {
            await updateShopTokens((data['user']['shopTokens'] as num).toInt());
          }

          debugPrint('✅ Token refreshed successfully');
          return newToken;
        }
      }

      debugPrint('❌ Token refresh failed: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('❌ Error refreshing token: $e');
      return null;
    }
  }

  /// Validate token with backend
  /// Uses ApiConfig.shopValidateTokenEndpoint by default
  Future<Map<String, dynamic>> validateToken([String? backendUrl]) async {
    final token = getAuthToken();

    if (token == null) return {'valid': false, 'message': 'No token'};

    try {
      final url = backendUrl != null
          ? '$backendUrl/api/auth/validate-token'
          : ApiConfig.shopValidateTokenEndpoint;

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': token}),
          )
          .timeout(const Duration(seconds: ApiConfig.requestTimeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['valid'] == true && data['user'] != null) {
          // Update local user data with latest from server
          final user = await getUnifiedUser();
          if (user != null) {
            final updatedUser = user.copyWith(
              fantasyUserId:
                  data['user']['fantasy_user_id'] ?? user.fantasyUserId,
              shopTokens: (data['user']['shopTokens'] as num?)?.toInt() ??
                  user.shopTokens,
            );
            await _saveUnifiedUser(updatedUser);
          }
        }

        return {
          'valid': data['valid'] ?? false,
          'user': data['user'],
          'message': data['message'],
        };
      }

      return {'valid': false, 'message': 'Validation failed'};
    } catch (e) {
      debugPrint('Error validating token: $e');
      return {'valid': false, 'message': 'Network error: $e'};
    }
  }

  /// Sync Fantasy Version & Token
  ///
  /// Calls the /user/get-version API, stores the full response,
  /// and synchronizes the bearer token if present.
  Future<Map<String, dynamic>?> syncFantasyVersion() async {
    try {
      debugPrint('🔄 [AUTH] Syncing Fantasy Version...');
      final token = getAuthToken();

      final response = await http.get(
        Uri.parse(ApiConfig.fantasyVersionEndpoint),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: ApiConfig.requestTimeoutSeconds));

      debugPrint('🔄 [AUTH] Version Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 1. Store full response data
        await _prefs?.setString('fantasy_version_data', response.body);
        debugPrint('✅ [AUTH] Fantasy version data saved to session');

        // 2. Extract and sync token if present
        String? newToken;
        if (data is Map) {
          newToken = data['token'] ??
              data['data']?['token'] ??
              data['auth_key'] ??
              data['data']?['auth_key'];
        }

        // 3. Update token if we got a new one
        if (newToken != null && newToken.isNotEmpty) {
          // Verify if it's different from current
          if (newToken != token) {
            debugPrint('♻️ [AUTH] Updating Auth Token from Version API');
            await _prefs?.setString(StorageConstants.authToken, newToken);
            await _prefs?.setString('token', newToken); // Legacy compatibility
          } else {
            debugPrint('✅ [AUTH] Token is already up to date');
          }
        }

        return data is Map<String, dynamic> ? data : {'data': data};
      } else {
        debugPrint('❌ [AUTH] Version Sync Failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ [AUTH] Error syncing fantasy version: $e');
      return null;
    }
  }

  /// Get current user profile from backend
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final token = getAuthToken();
      if (token == null || token.isEmpty) return null;

      final response = await http.get(
        Uri.parse('${ApiConfig.shopApiUrl}/auth/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: ApiConfig.requestTimeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['user'] ?? data['data'];
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  /// Logout and clear session
  Future<void> logout() async {
    try {
      final token = getAuthToken();

      if (token != null) {
        // Call backend unified logout endpoint
        try {
          await http.post(
            Uri.parse(ApiConfig.shopLogoutEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ).timeout(const Duration(seconds: ApiConfig.requestTimeoutSeconds));
        } catch (e) {
          debugPrint('Error calling logout API: $e');
        }
      }
    } catch (e) {
      debugPrint('Error during logout API call: $e');
    } finally {
      // Clear local storage regardless of API call success
      await _prefs?.remove(StorageConstants.userId);
      await _prefs?.remove(StorageConstants.authToken);
      await _prefs?.remove('mobile_number');
      await _prefs?.remove(StorageConstants.userEmail);
      await _prefs?.remove('user_name');
      await _prefs?.remove(AuthService.fantasyUserId);
      await _prefs?.remove(AuthService.shopEnabled);
      await _prefs?.remove(AuthService.fantasyEnabled);
      await _prefs?.remove(AuthService.modules);
      await _prefs?.remove('refresh_token');
      await _prefs?.remove('token');
      await _prefs?.remove('user_id');
      await _prefs?.remove('userId');
      await _prefs?.remove('user_id_fantasy');
      await _prefs?.remove('shop_tokens');
      await _prefs?.remove(_userKey);
      await _prefs?.setBool(StorageConstants.isLoggedIn, false);
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? email,
  }) async {
    if (name != null) {
      await _prefs?.setString('user_name', name);
    }
    if (email != null) {
      await _prefs?.setString(StorageConstants.userEmail, email);
    }
  }
}

/// Global instance of AuthService
final authService = AuthService();

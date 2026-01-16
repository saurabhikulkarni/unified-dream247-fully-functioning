import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../constants/storage_constants.dart';
import '../constants/api_constants.dart';

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
  }) async {
    await _prefs?.setString(StorageConstants.userId, userId);
    await _prefs?.setString(StorageConstants.authToken, authToken);
    await _prefs?.setString('mobile_number', mobileNumber);
    await _prefs?.setBool(StorageConstants.isLoggedIn, true);
    
    if (email != null) {
      await _prefs?.setString(StorageConstants.userEmail, email);
    }
    if (name != null) {
      await _prefs?.setString('user_name', name);
    }
    if (fantasyUserId != null) {
      await _prefs?.setString(AuthService.fantasyUserId, fantasyUserId);
    }
    
    await _prefs?.setBool(AuthService.shopEnabled, shopEnabled);
    await _prefs?.setBool(AuthService.fantasyEnabled, fantasyEnabled);
    await _prefs?.setStringList(AuthService.modules, modules);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return _prefs?.getBool(StorageConstants.isLoggedIn) ?? false;
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

  /// Validate token with backend
  Future<bool> validateTokenWithBackend() async {
    try {
      final token = getAuthToken();
      if (token == null || token.isEmpty) return false;

      final response = await http.post(
        Uri.parse('${ApiConstants.shopBackendUrl}/api/auth/validate-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error validating token: $e');
      return false;
    }
  }

  /// Get current user profile from backend
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final token = getAuthToken();
      if (token == null || token.isEmpty) return null;

      final response = await http.get(
        Uri.parse('${ApiConstants.shopBackendUrl}/api/auth/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

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

  /// Refresh auth token
  Future<bool> refreshToken() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.shopBackendUrl}/api/auth/refresh-token'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'refreshToken': _prefs?.getString('refresh_token'),
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['authToken'] != null) {
          await _prefs?.setString(StorageConstants.authToken, data['authToken']);
          if (data['refreshToken'] != null) {
            await _prefs?.setString('refresh_token', data['refreshToken']);
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return false;
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
            Uri.parse('${ApiConstants.shopBackendUrl}/api/auth/logout'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ).timeout(const Duration(seconds: 10));
        } catch (e) {
          print('Error calling logout API: $e');
        }
      }
    } catch (e) {
      print('Error during logout API call: $e');
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

import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_constants.dart';

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

  /// Save user session after successful login
  Future<void> saveUserSession({
    required String userId,
    required String authToken,
    required String mobileNumber,
    String? email,
    String? name,
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

  /// Logout and clear session
  Future<void> logout() async {
    // Clear only auth-related keys
    await _prefs?.remove(StorageConstants.userId);
    await _prefs?.remove(StorageConstants.authToken);
    await _prefs?.remove('mobile_number');
    await _prefs?.remove(StorageConstants.userEmail);
    await _prefs?.remove('user_name');
    await _prefs?.setBool(StorageConstants.isLoggedIn, false);
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

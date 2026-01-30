import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Helper to retrieve unified userId from Shop authentication
/// 
/// After Shop login with MSG91 OTP, the userId is saved to SharedPreferences.
/// Fantasy features use this helper to retrieve the same userId for API calls.
/// 
/// The helper tries multiple storage keys because different parts of the system
/// may save to different keys. This ensures compatibility across upgrades.
class UserIdHelper {
  /// Get the unified userId that was set by Shop login
  /// 
  /// Tries multiple storage keys in order:
  /// 1. 'user_id' - Primary Shop key
  /// 2. 'shop_user_id' - Explicit Shop key
  /// 3. 'user_id_fantasy' - Fantasy compatibility key
  /// 4. 'userId' - Modern Fantasy key
  /// 
  /// Returns empty string if userId not found
  static Future<String> getUnifiedUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Try all possible keys where Shop might have saved userId
      final userId = 
        prefs.getString('user_id') ??           // Primary Shop key
        prefs.getString('shop_user_id') ??      // Explicit Shop key
        prefs.getString('user_id_fantasy') ??   // Fantasy legacy key
        prefs.getString('userId') ??            // Fantasy modern key
        '';
      
      if (userId.isEmpty) {
        return '';
      }
      
      return userId;
    } catch (e) {
      debugPrint('❌ [USER_ID_HELPER] Error getting userId: $e');
      return '';
    }
  }
  
  /// Get userId synchronously from cache (if already loaded)
  /// 
  /// This is faster than [getUnifiedUserId] but only works if userId
  /// was already loaded in current session
  /// 
  /// Used for quick checks in hot paths
  static Future<String?> getUserIdFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_id') ?? 
             prefs.getString('shop_user_id');
    } catch (e) {
      debugPrint('❌ [USER_ID_HELPER] Error getting cached userId: $e');
      return null;
    }
  }
  
  /// Check if user is logged in (has userId)
  static Future<bool> isUserLoggedIn() async {
    final userId = await getUnifiedUserId();
    return userId.isNotEmpty;
  }
  
  /// Debug: Print all stored authentication keys
  static Future<void> debugPrintStoredKeys() async {
    // Debug method - implementation removed
  }
}

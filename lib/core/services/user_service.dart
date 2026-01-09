import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_constants.dart';

/// Service for managing user data and session
class UserService {
  final SharedPreferences _prefs;

  UserService(this._prefs);

  /// Get the current user ID
  String? getUserId() {
    return _prefs.getString(StorageConstants.userId);
  }

  /// Get the current user email
  String? getUserEmail() {
    return _prefs.getString(StorageConstants.userEmail);
  }

  /// Get the current user phone
  String? getUserPhone() {
    return _prefs.getString(StorageConstants.userPhone);
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getBool(StorageConstants.isLoggedIn) ?? false;
  }

  /// Set user session data
  Future<void> setUserSession({
    required String userId,
    required String email,
    String? phone,
  }) async {
    await _prefs.setString(StorageConstants.userId, userId);
    await _prefs.setString(StorageConstants.userEmail, email);
    if (phone != null) {
      await _prefs.setString(StorageConstants.userPhone, phone);
    }
    await _prefs.setBool(StorageConstants.isLoggedIn, true);
  }

  /// Clear user session
  Future<void> clearUserSession() async {
    await _prefs.remove(StorageConstants.userId);
    await _prefs.remove(StorageConstants.userEmail);
    await _prefs.remove(StorageConstants.userPhone);
    await _prefs.setBool(StorageConstants.isLoggedIn, false);
  }

  /// Get wallet balance (placeholder - should be fetched from API)
  Future<double> getWalletBalance() async {
    // In a real app, this would fetch from an API
    return 0.0;
  }

  /// Get coins (placeholder - should be fetched from API)
  Future<int> getCoins() async {
    // In a real app, this would fetch from an API
    return 100;
  }

  /// Get gems (placeholder - should be fetched from API)
  Future<int> getGems() async {
    // In a real app, this would fetch from an API
    return 100;
  }
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Local data source for authentication
abstract class AuthLocalDataSource {
  /// Get cached user
  Future<UserModel?> getCachedUser();

  /// Cache user
  Future<void> cacheUser(UserModel user);

  /// Get access token
  Future<String?> getAccessToken();

  /// Save access token
  Future<void> saveAccessToken(String token);

  /// Get refresh token
  Future<String?> getRefreshToken();

  /// Save refresh token
  Future<void> saveRefreshToken(String token);

  /// Clear all auth data
  Future<void> clearAuthData();

  /// Check if user is logged in
  Future<bool> isLoggedIn();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJson = sharedPreferences.getString(StorageConstants.userId);
      if (userJson == null) return null;

      // In a real app, you would store the full user object
      // For now, we'll return null as we need to implement proper caching
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached user');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await sharedPreferences.setString(StorageConstants.userId, user.id);
      if (user.email != null) {
        await sharedPreferences.setString(StorageConstants.userEmail, user.email!);
      }
      if (user.phone != null) {
        await sharedPreferences.setString(StorageConstants.userPhone, user.phone!);
      }
      await sharedPreferences.setBool(StorageConstants.isLoggedIn, true);
      
      // Share user ID with shop auth service
      await sharedPreferences.setString('user_id', user.id);
      await sharedPreferences.setBool('is_logged_in', true);
      if (user.phone != null) {
        await sharedPreferences.setString('user_phone', user.phone!);
      }
    } catch (e) {
      throw CacheException('Failed to cache user');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await secureStorage.read(key: StorageConstants.accessToken);
    } catch (e) {
      throw CacheException('Failed to get access token');
    }
  }

  @override
  Future<void> saveAccessToken(String token) async {
    try {
      await secureStorage.write(
        key: StorageConstants.accessToken,
        value: token,
      );
    } catch (e) {
      throw CacheException('Failed to save access token');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await secureStorage.read(key: StorageConstants.refreshToken);
    } catch (e) {
      throw CacheException('Failed to get refresh token');
    }
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    try {
      await secureStorage.write(
        key: StorageConstants.refreshToken,
        value: token,
      );
    } catch (e) {
      throw CacheException('Failed to save refresh token');
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await secureStorage.delete(key: StorageConstants.accessToken);
      await secureStorage.delete(key: StorageConstants.refreshToken);
      await sharedPreferences.remove(StorageConstants.userId);
      await sharedPreferences.remove(StorageConstants.userEmail);
      await sharedPreferences.remove(StorageConstants.userPhone);
      await sharedPreferences.setBool(StorageConstants.isLoggedIn, false);
    } catch (e) {
      throw CacheException('Failed to clear auth data');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return sharedPreferences.getBool(StorageConstants.isLoggedIn) ?? false;
    } catch (e) {
      return false;
    }
  }
}

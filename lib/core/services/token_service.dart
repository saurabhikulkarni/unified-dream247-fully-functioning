import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:unified_dream247/core/services/auth_service.dart';

/// Token Service - Manages JWT token lifecycle
/// Handles token refresh before expiry
class TokenService {
  static final TokenService _instance = TokenService._internal();

  factory TokenService() => _instance;
  TokenService._internal();

  Timer? _refreshTimer;
  static const int _refreshThresholdMinutes = 5; // Refresh 5 minutes before expiry

  /// Start token refresh timer
  /// Call this after successful login
  void startTokenRefreshTimer(String authToken) {
    _refreshTimer?.cancel();

    try {
      final expiryTime = _getTokenExpiryTime(authToken);
      if (expiryTime == null) {
        debugPrint('⚠️ Could not decode token expiry time');
        return;
      }

      final now = DateTime.now();
      final refreshTime = expiryTime.subtract(
        const Duration(minutes: _refreshThresholdMinutes),
      );

      if (refreshTime.isBefore(now)) {
        debugPrint('🔄 Token already expired, refreshing immediately');
        _refreshToken();
        return;
      }

      final duration = refreshTime.difference(now);
      debugPrint('⏱️ Token refresh scheduled for ${refreshTime.toIso8601String()}');
      debugPrint('   Time until refresh: ${duration.inMinutes} minutes');

      _refreshTimer = Timer(duration, _refreshToken);
    } catch (e) {
      debugPrint('❌ Error starting token refresh timer: $e');
    }
  }

  /// Stop token refresh timer
  void stopTokenRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    debugPrint('⏹️ Token refresh timer stopped');
  }

  /// Refresh token with backend
  Future<void> _refreshToken() async {
    try {
      debugPrint('🔄 Token expired or expiring soon - logging out');
      
      final authService = AuthService();
      await authService.initialize();
      await authService.logout();
    } catch (e) {
      debugPrint('❌ Error during token expiry logout: $e');
    }
  }

  /// Extract expiry time from JWT token
  DateTime? _getTokenExpiryTime(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        debugPrint('❌ Invalid token format');
        return null;
      }

      // Decode the payload (parts[1])
      final payload = parts[1];

      // Add padding if necessary
      final padded = _addPaddingToBase64(payload);
      final decoded = utf8.decode(base64Url.decode(padded));
      final json = jsonDecode(decoded) as Map<String, dynamic>;

      if (json['exp'] == null) {
        debugPrint('⚠️ Token does not contain exp claim');
        return null;
      }

      final expirySeconds = json['exp'] as int;
      return DateTime.fromMillisecondsSinceEpoch(expirySeconds * 1000);
    } catch (e) {
      debugPrint('❌ Error decoding token: $e');
      return null;
    }
  }

  /// Add padding to base64 string if needed
  String _addPaddingToBase64(String base64String) {
    final remaining = base64String.length % 4;
    if (remaining == 0) return base64String;
    return base64String + '=' * (4 - remaining);
  }

  /// Get token remaining time
  Duration? getTokenRemainingTime(String token) {
    try {
      final expiryTime = _getTokenExpiryTime(token);
      if (expiryTime == null) return null;

      final remaining = expiryTime.difference(DateTime.now());
      if (remaining.isNegative) return Duration.zero;

      return remaining;
    } catch (e) {
      debugPrint('Error calculating remaining time: $e');
      return null;
    }
  }

  /// Check if token is expired
  bool isTokenExpired(String token) {
    try {
      final expiryTime = _getTokenExpiryTime(token);
      if (expiryTime == null) return true;

      return DateTime.now().isAfter(expiryTime);
    } catch (e) {
      debugPrint('Error checking token expiry: $e');
      return true;
    }
  }

  /// Check if token will expire soon (within threshold)
  bool willTokenExpireSoon(String token) {
    try {
      final expiryTime = _getTokenExpiryTime(token);
      if (expiryTime == null) return true;

      final refreshTime = expiryTime.subtract(
        const Duration(minutes: _refreshThresholdMinutes),
      );

      return DateTime.now().isAfter(refreshTime);
    } catch (e) {
      debugPrint('Error checking token expiry: $e');
      return true;
    }
  }

  /// Cleanup resources
  void dispose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
}

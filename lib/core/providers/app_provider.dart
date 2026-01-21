import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_dream247/config/api_config.dart';

/// App-level provider for managing global app state
/// Handles periodic shopTokens refresh and wallet balance synchronization
class AppProvider extends ChangeNotifier {
  int shopTokens = 0;
  Timer? _refreshTimer;
  bool _isRefreshing = false;
  
  // Refresh interval in seconds (default: 30 seconds)
  final int refreshInterval;

  AppProvider({this.refreshInterval = 30}) {
    _initializeTokens();
  }

  /// Initialize shopTokens from SharedPreferences on app startup
  Future<void> _initializeTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      shopTokens = prefs.getInt('shop_tokens') ?? 0;
      debugPrint('💰 [APP_PROVIDER] Initialized shopTokens: $shopTokens');
      notifyListeners();
      
      // Start periodic refresh after initialization
      _startPeriodicRefresh();
    } catch (e) {
      debugPrint('❌ [APP_PROVIDER] Error initializing tokens: $e');
    }
  }

  /// Start periodic shopTokens refresh
  /// Refreshes every [refreshInterval] seconds
  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(Duration(seconds: refreshInterval), (_) {
      refreshShopTokens();
    });
    debugPrint('🔄 [APP_PROVIDER] Periodic refresh started (interval: ${refreshInterval}s)');
  }

  /// Refresh shopTokens from backend
  /// Calls the optimized shop-tokens-only endpoint
  Future<void> refreshShopTokens() async {
    if (_isRefreshing) {
      return; // Silent skip if already refreshing
    }

    try {
      _isRefreshing = true;
      final prefs = await SharedPreferences.getInstance();
      
      // Check if user is logged in first
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      if (!isLoggedIn) {
        // User not logged in, skip refresh silently (don't spam logs)
        _isRefreshing = false;
        return;
      }
      
      final authToken = prefs.getString('token') ?? 
                       prefs.getString('auth_token') ?? 
                       prefs.getString('fantasy_token');
      
      if (authToken == null || authToken.isEmpty) {
        // No token but logged in - this shouldn't happen normally
        _isRefreshing = false;
        return;
      }

      final response = await http.get(
        Uri.parse(ApiConfig.fantasyShopTokensEndpoint),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newShopTokens = (data['data']?['shopTokens'] as num?)?.toInt() ?? 
                             (data['shopTokens'] as num?)?.toInt() ?? 0;
        
        // Only notify listeners if value changed
        if (newShopTokens != shopTokens) {
          shopTokens = newShopTokens;
          await prefs.setInt('shop_tokens', shopTokens);
          notifyListeners();
          debugPrint('💰 [APP_PROVIDER] shopTokens refreshed: $shopTokens');
        }
      } else {
        debugPrint('⚠️ [APP_PROVIDER] Refresh failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [APP_PROVIDER] Error refreshing shopTokens: $e');
    } finally {
      _isRefreshing = false;
    }
  }

  /// Manual refresh trigger
  /// Use this when user performs actions that might change token balance
  Future<void> forceRefresh() async {
    debugPrint('🔄 [APP_PROVIDER] Force refresh triggered');
    await refreshShopTokens();
  }

  /// Update shopTokens locally (for immediate UI update)
  /// Also persists to SharedPreferences
  Future<void> updateShopTokens(int newBalance) async {
    try {
      if (newBalance != shopTokens) {
        shopTokens = newBalance;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('shop_tokens', shopTokens);
        notifyListeners();
        debugPrint('💰 [APP_PROVIDER] shopTokens updated locally: $shopTokens');
      }
    } catch (e) {
      debugPrint('❌ [APP_PROVIDER] Error updating shopTokens: $e');
    }
  }

  /// Pause periodic refresh (e.g., during offline)
  void pauseRefresh() {
    _refreshTimer?.cancel();
    debugPrint('⏸️  [APP_PROVIDER] Periodic refresh paused');
  }

  /// Resume periodic refresh
  void resumeRefresh() {
    if (_refreshTimer == null || !_refreshTimer!.isActive) {
      _startPeriodicRefresh();
    }
  }

  /// Get current shopTokens
  int getShopTokens() => shopTokens;

  @override
  void dispose() {
    _refreshTimer?.cancel();
    debugPrint('🛑 [APP_PROVIDER] Disposed, refresh timer cancelled');
    super.dispose();
  }
}

// Global instance
late AppProvider appProvider;

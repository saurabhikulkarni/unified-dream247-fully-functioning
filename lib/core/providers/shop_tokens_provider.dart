import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:unified_dream247/core/services/wallet_service.dart';

/// Provider for managing shopTokens state
/// Handles periodic refresh and local persistence
/// NOTE: Fetches from Fantasy backend /user/user-wallet-details, NOT Hygraph
/// This is the working implementation from merge-shop-and-fantasy branch
class ShopTokensProvider extends ChangeNotifier {
  int _shopTokens = 0;
  Timer? _refreshTimer;
  bool _isRefreshing = false;
  final int refreshInterval;

  ShopTokensProvider({this.refreshInterval = 30}) {
    _initializeTokens();
    // Register with UnifiedWalletService for instant deduction updates
    UnifiedWalletService().setShopTokensProvider(this);
  }

  int get shopTokens => _shopTokens;

  /// Initialize shopTokens from SharedPreferences, then refresh from backend
  Future<void> _initializeTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Handle both int and double types from SharedPreferences
      try {
        _shopTokens = prefs.getInt('shop_tokens') ?? 0;
      } catch (e) {
        try {
          final doubleValue = prefs.getDouble('shop_tokens') ?? 0.0;
          _shopTokens = doubleValue.toInt();
          // Convert to int for consistency
          await prefs.setInt('shop_tokens', _shopTokens);
        } catch (e2) {
          _shopTokens = 0;
        }
      }
      notifyListeners();
      debugPrint(
          '💰 [SHOP_TOKENS_PROVIDER] Initialized from cache: $_shopTokens',);
      debugPrint('   All keys in SharedPreferences: ${prefs.getKeys().toList()}');

      // Immediately refresh from backend to ensure sync
      await refreshShopTokens();

      _startPeriodicRefresh();
    } catch (e) {
      debugPrint('❌ [SHOP_TOKENS_PROVIDER] Error initializing: $e');
    }
  }

  /// Start periodic refresh with reduced frequency
  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(Duration(seconds: refreshInterval), (_) {
      refreshShopTokens();
    });
    debugPrint(
        '🔄 [SHOP_TOKENS_PROVIDER] Periodic refresh started (${refreshInterval}s interval)',);
  }

  /// Refresh shopTokens from Fantasy backend /user/user-wallet-details
  /// This endpoint returns balance which represents shop tokens
  /// Working implementation from merge-shop-and-fantasy branch
  Future<void> refreshShopTokens() async {
    if (_isRefreshing) {
      debugPrint(
          '⚠️  [SHOP_TOKENS_PROVIDER] Already refreshing, skipping duplicate call',);
      return;
    }

    try {
      _isRefreshing = true;
      final prefs = await SharedPreferences.getInstance();
      
      // Get cached value first - handle both int and double types
      int cachedTokens = 0;
      try {
        // Try to get as int first
        cachedTokens = prefs.getInt('shop_tokens') ?? 0;
      } catch (e) {
        // If int fails, try as double
        try {
          final doubleValue = prefs.getDouble('shop_tokens') ?? 0.0;
          cachedTokens = doubleValue.toInt();
        } catch (e2) {
          cachedTokens = 0;
        }
      }
      debugPrint('💰 [SHOP_TOKENS_PROVIDER] Cached tokens: $cachedTokens');
      
      final authToken =
          prefs.getString('token') ?? prefs.getString('auth_token');

      if (authToken == null || authToken.isEmpty) {
        debugPrint(
            '⚠️  [SHOP_TOKENS_PROVIDER] No auth token, skipping refresh, using cached: $cachedTokens',);
        _shopTokens = cachedTokens;
        notifyListeners();
        _isRefreshing = false;
        return;
      }

      // Use the working wallet endpoint that returns balance (shop tokens)
      // Endpoint: /user/user-wallet-details returns {success: true, data: {balance: 2000.00, ...}}
      // This is from Fantasy backend, same as working merge-shop-and-fantasy branch
      final baseUrl = dotenv.env['UserServerUrl'] ??
          'http://134.209.158.211:4000/user/';
      final url = '${baseUrl}user-wallet-details';

      debugPrint('🔄 [SHOP_TOKENS_PROVIDER] Fetching from Fantasy backend: $url');
      debugPrint(
          '🔄 [SHOP_TOKENS_PROVIDER] Token: ${authToken.substring(0, 20)}...',);

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('📊 [SHOP_TOKENS_PROVIDER] Status: ${response.statusCode}');
      if (response.body.isNotEmpty) {
        debugPrint('📊 [SHOP_TOKENS_PROVIDER] Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final walletData = data['data'];
          // Shop tokens are stored in 'balance' field from this endpoint
          // Extract balance and convert to int
          final balanceStr = walletData['balance']?.toString() ?? '0';
          final newBalance = double.tryParse(balanceStr)?.toInt() ?? 0;

          debugPrint('💰 [SHOP_TOKENS_PROVIDER] Backend balance: $newBalance');

          // If backend returns 0 but we have cached value, keep the cached value
          // This can happen if shop tokens haven't been synced to Fantasy backend yet
          if (newBalance == 0 && cachedTokens > 0) {
            debugPrint(
                '⚠️  [SHOP_TOKENS_PROVIDER] Backend returned 0 but cache has $cachedTokens - KEEPING CACHED VALUE',);
            _shopTokens = cachedTokens;
          } else {
            _shopTokens = newBalance;
            await prefs.setInt('shop_tokens', _shopTokens);
            debugPrint('✅ [SHOP_TOKENS_PROVIDER] Updated shop tokens: $_shopTokens');
          }
          notifyListeners();
        } else {
          debugPrint(
              '❌ [SHOP_TOKENS_PROVIDER] Response not successful: ${data['message']}',);
          // Use cached value as fallback
          _shopTokens = cachedTokens;
          notifyListeners();
        }
      } else {
        debugPrint(
            '❌ [SHOP_TOKENS_PROVIDER] HTTP error: ${response.statusCode}',);
        // Use cached value as fallback
        _shopTokens = cachedTokens;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ [SHOP_TOKENS_PROVIDER] Refresh error: $e');
      // Fallback: try to use cached value with safe type handling
      try {
        final prefs = await SharedPreferences.getInstance();
        int cachedTokens = 0;
        try {
          cachedTokens = prefs.getInt('shop_tokens') ?? 0;
        } catch (e2) {
          try {
            final doubleValue = prefs.getDouble('shop_tokens') ?? 0.0;
            cachedTokens = doubleValue.toInt();
          } catch (e3) {
            cachedTokens = 0;
          }
        }
        _shopTokens = cachedTokens;
        notifyListeners();
        debugPrint('💾 [SHOP_TOKENS_PROVIDER] Using cached tokens: $cachedTokens');
      } catch (e2) {
        debugPrint('❌ [SHOP_TOKENS_PROVIDER] Failed to read cache: $e2');
      }
    } finally {
      _isRefreshing = false;
    }
  }

  /// Manual force refresh from backend
  Future<void> forceRefresh() async {
    await refreshShopTokens();
  }

  /// Update tokens locally and in SharedPreferences immediately
  /// Use this after order deduction to sync UI without waiting for backend
  Future<void> updateTokens(int newBalance) async {
    try {
      if (newBalance != _shopTokens) {
        _shopTokens = newBalance;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('shop_tokens', _shopTokens);
        notifyListeners();
        debugPrint('💰 [SHOP_TOKENS_PROVIDER] Updated locally: $_shopTokens');
      }
    } catch (e) {
      debugPrint('❌ [SHOP_TOKENS_PROVIDER] Update error: $e');
    }
  }

  /// Sync tokens from SharedPreferences (without backend call)
  /// Use this when tokens have been updated by another service
  Future<void> syncFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int storedTokens = 0;
      try {
        storedTokens = prefs.getInt('shop_tokens') ?? 0;
      } catch (e) {
        try {
          final doubleValue = prefs.getDouble('shop_tokens') ?? 0.0;
          storedTokens = doubleValue.toInt();
        } catch (e2) {
          storedTokens = 0;
        }
      }
      
      if (storedTokens != _shopTokens) {
        _shopTokens = storedTokens;
        notifyListeners();
        debugPrint('💰 [SHOP_TOKENS_PROVIDER] Synced from storage: $_shopTokens');
      }
    } catch (e) {
      debugPrint('❌ [SHOP_TOKENS_PROVIDER] Sync error: $e');
    }
  }

  /// Pause refresh
  void pauseRefresh() {
    _refreshTimer?.cancel();
    debugPrint('⏸️  [SHOP_TOKENS_PROVIDER] Paused');
  }

  /// Resume refresh
  void resumeRefresh() {
    if (_refreshTimer == null || !_refreshTimer!.isActive) {
      _startPeriodicRefresh();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    debugPrint('🛑 [SHOP_TOKENS_PROVIDER] Disposed');
    super.dispose();
  }
}

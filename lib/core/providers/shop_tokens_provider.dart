import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_dream247/config/api_config.dart';

/// Provider for managing shopTokens state
/// Handles periodic refresh and local persistence
class ShopTokensProvider extends ChangeNotifier {
  int _shopTokens = 0;
  Timer? _refreshTimer;
  bool _isRefreshing = false;
  final int refreshInterval;

  ShopTokensProvider({this.refreshInterval = 30}) {
    _initializeTokens();
  }

  int get shopTokens => _shopTokens;

  /// Initialize shopTokens from SharedPreferences
  Future<void> _initializeTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _shopTokens = prefs.getInt('shop_tokens') ?? 0;
      notifyListeners();
      debugPrint('💰 [SHOP_TOKENS_PROVIDER] Initialized: $_shopTokens');
      _startPeriodicRefresh();
    } catch (e) {
      debugPrint('❌ [SHOP_TOKENS_PROVIDER] Error initializing: $e');
    }
  }

  /// Start periodic refresh
  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(Duration(seconds: refreshInterval), (_) {
      refreshShopTokens();
    });
    debugPrint('🔄 [SHOP_TOKENS_PROVIDER] Periodic refresh started (${refreshInterval}s)');
  }

  /// Refresh shopTokens from backend
  Future<void> refreshShopTokens() async {
    if (_isRefreshing) return;

    try {
      _isRefreshing = true;
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('token') ?? 
                       prefs.getString('auth_token');
      
      if (authToken == null || authToken.isEmpty) {
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
        final newBalance = (data['data']?['shopTokens'] as num?)?.toInt() ?? 
                          (data['shopTokens'] as num?)?.toInt() ?? 0;
        
        if (newBalance != _shopTokens) {
          _shopTokens = newBalance;
          await prefs.setInt('shop_tokens', _shopTokens);
          notifyListeners();
          debugPrint('💰 [SHOP_TOKENS_PROVIDER] Refreshed: $_shopTokens');
        }
      }
    } catch (e) {
      debugPrint('⚠️ [SHOP_TOKENS_PROVIDER] Refresh error: $e');
    } finally {
      _isRefreshing = false;
    }
  }

  /// Manual force refresh
  Future<void> forceRefresh() async {
    await refreshShopTokens();
  }

  /// Update tokens locally
  Future<void> updateTokens(int newBalance) async {
    try {
      if (newBalance != _shopTokens) {
        _shopTokens = newBalance;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('shop_tokens', _shopTokens);
        notifyListeners();
        debugPrint('💰 [SHOP_TOKENS_PROVIDER] Updated: $_shopTokens');
      }
    } catch (e) {
      debugPrint('❌ [SHOP_TOKENS_PROVIDER] Update error: $e');
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

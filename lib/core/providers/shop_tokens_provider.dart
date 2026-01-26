import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_dream247/features/shop/services/order_service_graphql.dart';
import 'package:unified_dream247/features/shop/services/user_service.dart';

/// Provider for managing shopTokens state
/// Handles periodic refresh and local persistence
class ShopTokensProvider extends ChangeNotifier {
  int _shopTokens = 0;
  Timer? _refreshTimer;
  bool _isRefreshing = false;
  final int refreshInterval;
  final OrderServiceGraphQL _graphQLService = OrderServiceGraphQL();

  ShopTokensProvider({this.refreshInterval = 30}) {
    _initializeTokens();
  }

  int get shopTokens => _shopTokens;

  /// Initialize shopTokens from SharedPreferences, then refresh from backend
  Future<void> _initializeTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _shopTokens = prefs.getInt('shop_tokens') ?? 0;
      notifyListeners();
      debugPrint(
          '💰 [SHOP_TOKENS_PROVIDER] Initialized from cache: $_shopTokens');

      // Immediately refresh from backend to ensure sync
      await refreshShopTokens();

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
    debugPrint(
        '🔄 [SHOP_TOKENS_PROVIDER] Periodic refresh started (${refreshInterval}s)');
  }

  /// Refresh shopTokens from backend
  Future<void> refreshShopTokens() async {
    if (_isRefreshing) return;

    try {
      _isRefreshing = true;
      final prefs = await SharedPreferences.getInstance();
      final authToken =
          prefs.getString('token') ?? prefs.getString('auth_token');

      if (authToken == null || authToken.isEmpty) {
        debugPrint('⚠️ [SHOP_TOKENS_PROVIDER] No auth token, skipping refresh');
        _isRefreshing = false;
        return;
      }

      // Get userId for GraphQL query
      final userId = UserService.getCurrentUserId();
      if (userId == null || userId.isEmpty) {
        debugPrint(
            '⚠️ [SHOP_TOKENS_PROVIDER] No userId found, skipping refresh');
        _isRefreshing = false;
        return;
      }

      debugPrint(
          '🔄 [SHOP_TOKENS_PROVIDER] Fetching shop tokens from GraphQL for user: $userId');

      // Use GraphQL to fetch shop tokens from Hygraph
      final walletData = await _graphQLService.getUserWallet(userId);
      final shopTokensValue = walletData['shopTokens'];

      // Convert to int (shopTokens can be double or int from GraphQL)
      final newBalance = (shopTokensValue is double)
          ? shopTokensValue.toInt()
          : (shopTokensValue as int? ?? 0);

      debugPrint('💰 [SHOP_TOKENS_PROVIDER] Backend shop tokens: $newBalance');

      _shopTokens = newBalance;
      await prefs.setInt('shop_tokens', _shopTokens);
      notifyListeners();
      debugPrint('✅ [SHOP_TOKENS_PROVIDER] Updated shop tokens: $_shopTokens');
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

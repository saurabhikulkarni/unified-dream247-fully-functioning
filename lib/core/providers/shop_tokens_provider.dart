import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  /// Initialize shopTokens from SharedPreferences, then refresh from backend
  Future<void> _initializeTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _shopTokens = prefs.getInt('shop_tokens') ?? 0;
      notifyListeners();
      debugPrint('💰 [SHOP_TOKENS_PROVIDER] Initialized from cache: $_shopTokens');
      
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
        debugPrint('⚠️ [SHOP_TOKENS_PROVIDER] No auth token, skipping refresh');
        _isRefreshing = false;
        return;
      }

      // Use the working wallet endpoint that returns balance (shop tokens)
      // Endpoint: /user/user-wallet-details returns {data: {balance: 2000.00, ...}}
      final baseUrl = dotenv.env['UserServerUrl'] ?? 'http://134.209.158.211:4000/user/';
      final url = '${baseUrl}user-wallet-details';
      
      debugPrint('🔄 [SHOP_TOKENS_PROVIDER] Fetching from: $url');
      debugPrint('🔑 [SHOP_TOKENS_PROVIDER] Token: ${authToken.substring(0, 20)}...');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      debugPrint('📥 [SHOP_TOKENS_PROVIDER] Status: ${response.statusCode}');
      debugPrint('📥 [SHOP_TOKENS_PROVIDER] Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final walletData = data['data'];
          // Shop tokens are stored in 'balance' field from this endpoint
          final balanceStr = walletData['balance']?.toString() ?? '0';
          final newBalance = double.tryParse(balanceStr)?.toInt() ?? 0;
          
          debugPrint('💰 [SHOP_TOKENS_PROVIDER] Backend balance: $newBalance');
        
          _shopTokens = newBalance;
          await prefs.setInt('shop_tokens', _shopTokens);
          notifyListeners();
          debugPrint('✅ [SHOP_TOKENS_PROVIDER] Updated shop tokens: $_shopTokens');
        } else {
          debugPrint('⚠️ [SHOP_TOKENS_PROVIDER] Response not successful: ${data['message']}');
        }
      } else {
        debugPrint('❌ [SHOP_TOKENS_PROVIDER] HTTP error: ${response.statusCode}');
        debugPrint('❌ [SHOP_TOKENS_PROVIDER] Response: ${response.body}');
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

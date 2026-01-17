import 'package:flutter/foundation.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/game_tokens_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/managers/game_tokens_cache.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_urls.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_keys.dart';

/// Game Tokens Service
/// Handles fetching and caching of game tokens from Fantasy backend
class GameTokensService {
  final ApiImplWithAccessToken _apiClient;
  final GameTokensCache _cache;

  GameTokensService(this._apiClient, this._cache);

  /// Fetch game tokens on app startup
  /// Priority: Backend > Cache > Default
  Future<GameTokens?> fetchGameTokensOnStartup() async {
    debugPrint('🔄 [GAME_TOKENS_SERVICE] Fetching game tokens on startup...');

    try {
      // Fetch from Fantasy backend
      final tokens = await _fetchFromBackend();

      if (tokens != null) {
        // Save to local cache
        await _cache.saveTokens(tokens);
        debugPrint(
          '✅ [GAME_TOKENS_SERVICE] Tokens synced from backend: ${tokens.balance}',
        );
        return tokens;
      }

      throw Exception('Backend returned null tokens');
    } catch (e) {
      debugPrint('❌ [GAME_TOKENS_SERVICE] Failed to fetch from backend: $e');

      // Fallback to local cache
      try {
        final cachedTokens = await _cache.getTokens();
        if (cachedTokens != null) {
          debugPrint(
            '⚠️ [GAME_TOKENS_SERVICE] Using cached tokens: ${cachedTokens.balance}',
          );
          return cachedTokens;
        }
      } catch (cacheError) {
        debugPrint('❌ [GAME_TOKENS_SERVICE] Cache error: $cacheError');
      }

      // If no cache available, return null
      debugPrint('⚠️ [GAME_TOKENS_SERVICE] No tokens available (returning null)');
      return null;
    }
  }

  /// Get game tokens with cache validation
  /// Returns cached if valid, fetches fresh otherwise
  Future<GameTokens> getGameTokens() async {
    debugPrint('📊 [GAME_TOKENS_SERVICE] Getting game tokens...');

    try {
      // Check cache validity first
      final isCacheValid = await _cache.isCacheValid();

      if (isCacheValid) {
        final cached = await _cache.getTokens();
        if (cached != null) {
          debugPrint(
            '✅ [GAME_TOKENS_SERVICE] Using valid cache: ${cached.balance}',
          );
          return cached;
        }
      }

      debugPrint('⏰ [GAME_TOKENS_SERVICE] Cache expired or invalid, fetching fresh...');

      // Fetch fresh data from backend
      final tokens = await _fetchFromBackend();
      if (tokens != null) {
        await _cache.saveTokens(tokens);
        debugPrint('✅ [GAME_TOKENS_SERVICE] Fetched fresh tokens: ${tokens.balance}');
        return tokens;
      }

      throw Exception('Backend returned null tokens');
    } catch (e) {
      debugPrint('⚠️ [GAME_TOKENS_SERVICE] Error fetching tokens: $e');

      // Fallback to cache
      try {
        final cached = await _cache.getTokens();
        if (cached != null) {
          debugPrint('⚠️ [GAME_TOKENS_SERVICE] Returning cached tokens as fallback');
          return cached;
        }
      } catch (cacheError) {
        debugPrint('❌ [GAME_TOKENS_SERVICE] Cache fallback failed: $cacheError');
      }

      // Return empty if everything fails
      debugPrint('❌ [GAME_TOKENS_SERVICE] Returning default empty tokens');
      return GameTokens(
        balance: 0.0,
        transactions: [],
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Fetch game tokens from Fantasy backend
  /// Private method - calls /user/wallet-details endpoint
  Future<GameTokens?> _fetchFromBackend() async {
    try {
      final url = '${APIServerUrl.userServerUrl}${APIServerUrl.myWalletDetails}';

      debugPrint('🔄 [GAME_TOKENS_SERVICE] Calling backend: $url');

      final response = await _apiClient.get(url);
      final res = response.data;

      if (res is! Map<String, dynamic>) {
        debugPrint('❌ [GAME_TOKENS_SERVICE] Invalid response format');
        return null;
      }

      // Check response success status
      final success = res['success'] == true;
      if (!success) {
        debugPrint(
          '❌ [GAME_TOKENS_SERVICE] Backend error: ${res['message']}',
        );
        return null;
      }

      // Parse response data
      final data = res['data'];
      if (data == null) {
        debugPrint('❌ [GAME_TOKENS_SERVICE] No data in response');
        return null;
      }

      // Convert balance to GameTokens model
      final balance = (data['balance'] ?? 0).toDouble();
      final tokens = GameTokens(
        balance: balance,
        transactions: [], // Backend doesn't return transaction history yet
        lastUpdated: DateTime.now(),
      );

      debugPrint('✅ [GAME_TOKENS_SERVICE] Backend fetch successful: $balance');
      return tokens;
    } catch (e) {
      debugPrint('❌ [GAME_TOKENS_SERVICE] Backend call failed: $e');
      return null;
    }
  }

  /// Refresh game tokens from backend
  /// Called when user returns to app or manually refreshes
  Future<GameTokens?> refreshGameTokens() async {
    debugPrint('🔄 [GAME_TOKENS_SERVICE] Refreshing game tokens from backend...');

    try {
      // Clear cache to force fresh fetch
      await _cache.clearCache();

      final tokens = await _fetchFromBackend();
      if (tokens != null) {
        await _cache.saveTokens(tokens);
        debugPrint('✅ [GAME_TOKENS_SERVICE] Tokens refreshed: ${tokens.balance}');
        return tokens;
      }

      return null;
    } catch (e) {
      debugPrint('❌ [GAME_TOKENS_SERVICE] Refresh failed: $e');
      return null;
    }
  }

  /// Get cache statistics for debugging
  Future<Map<String, dynamic>> getCacheStats() async {
    return await _cache.getCacheStats();
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/game_tokens_model.dart';

/// Game Tokens Cache Manager
/// Handles caching and retrieval of game tokens from local storage
class GameTokensCache {
  static const String cacheKey = 'game_tokens_cache';
  static const String lastSyncKey = 'game_tokens_last_sync';
  static const int cacheExpiryMinutes = 5;

  SharedPreferences? _prefs;

  /// Initialize the cache manager
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save game tokens to local cache
  Future<void> saveTokens(GameTokens tokens) async {
    await initialize();
    try {
      // Save tokens
      await _prefs?.setString(cacheKey, jsonEncode(tokens.toJson()));

      // Save last sync timestamp
      await _prefs?.setString(
        lastSyncKey,
        DateTime.now().toIso8601String(),
      );

      debugPrint('✅ [GAME_TOKENS_CACHE] Tokens cached: ${tokens.balance}');
    } catch (e) {
      debugPrint('❌ [GAME_TOKENS_CACHE] Error saving tokens: $e');
    }
  }

  /// Get cached game tokens
  Future<GameTokens?> getTokens() async {
    await initialize();
    try {
      final cached = _prefs?.getString(cacheKey);

      if (cached == null) {
        debugPrint('⚠️ [GAME_TOKENS_CACHE] No cached tokens found');
        return null;
      }

      final tokens = GameTokens.fromJson(jsonDecode(cached));
      debugPrint('✅ [GAME_TOKENS_CACHE] Retrieved cached tokens: ${tokens.balance}');
      return tokens;
    } catch (e) {
      debugPrint('❌ [GAME_TOKENS_CACHE] Error parsing cached tokens: $e');
      return null;
    }
  }

  /// Check if cache is still valid (not expired)
  Future<bool> isCacheValid() async {
    await initialize();
    try {
      final lastSync = _prefs?.getString(lastSyncKey);

      if (lastSync == null) {
        debugPrint('⚠️ [GAME_TOKENS_CACHE] No sync timestamp found');
        return false;
      }

      final lastSyncTime = DateTime.parse(lastSync);
      final diff = DateTime.now().difference(lastSyncTime);

      final isValid = diff.inMinutes < cacheExpiryMinutes;
      debugPrint(
        '${isValid ? '✅' : '⏰'} [GAME_TOKENS_CACHE] Cache valid: $isValid (${diff.inMinutes} min old)',
      );
      return isValid;
    } catch (e) {
      debugPrint('❌ [GAME_TOKENS_CACHE] Error checking cache validity: $e');
      return false;
    }
  }

  /// Get time remaining before cache expires
  Future<Duration?> getTimeToExpiry() async {
    await initialize();
    try {
      final lastSync = _prefs?.getString(lastSyncKey);
      if (lastSync == null) return null;

      final lastSyncTime = DateTime.parse(lastSync);
      final diff = DateTime.now().difference(lastSyncTime);
      final remaining = const Duration(minutes: cacheExpiryMinutes) - diff;

      return remaining.isNegative ? null : remaining;
    } catch (e) {
      debugPrint('❌ [GAME_TOKENS_CACHE] Error calculating expiry: $e');
      return null;
    }
  }

  /// Save single transaction to cache
  Future<void> addTransaction(Transaction transaction) async {
    await initialize();
    try {
      final current = await getTokens();
      if (current == null) {
        debugPrint('⚠️ [GAME_TOKENS_CACHE] No existing tokens to add transaction to');
        return;
      }

      final updated = GameTokens(
        balance: current.balance,
        transactions: [transaction, ...current.transactions],
        lastUpdated: DateTime.now(),
      );

      await saveTokens(updated);
      debugPrint('✅ [GAME_TOKENS_CACHE] Transaction added: ${transaction.type}');
    } catch (e) {
      debugPrint('❌ [GAME_TOKENS_CACHE] Error adding transaction: $e');
    }
  }

  /// Update token balance
  Future<void> updateBalance(double newBalance) async {
    await initialize();
    try {
      final current = await getTokens();
      if (current == null) {
        // Create new GameTokens if none exist
        final tokens = GameTokens(
          balance: newBalance,
          transactions: [],
          lastUpdated: DateTime.now(),
        );
        await saveTokens(tokens);
        return;
      }

      final updated = GameTokens(
        balance: newBalance,
        transactions: current.transactions,
        lastUpdated: DateTime.now(),
      );

      await saveTokens(updated);
      debugPrint('✅ [GAME_TOKENS_CACHE] Balance updated: $newBalance');
    } catch (e) {
      debugPrint('❌ [GAME_TOKENS_CACHE] Error updating balance: $e');
    }
  }

  /// Clear all cache data
  Future<void> clearCache() async {
    await initialize();
    try {
      await _prefs?.remove(cacheKey);
      await _prefs?.remove(lastSyncKey);
      debugPrint('✅ [GAME_TOKENS_CACHE] Cache cleared');
    } catch (e) {
      debugPrint('❌ [GAME_TOKENS_CACHE] Error clearing cache: $e');
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final tokens = await getTokens();
      final isValid = await isCacheValid();
      final timeToExpiry = await getTimeToExpiry();

      return {
        'hasCache': tokens != null,
        'balance': tokens?.balance ?? 0.0,
        'transactionCount': tokens?.transactions.length ?? 0,
        'isValid': isValid,
        'timeToExpiryMinutes': timeToExpiry?.inMinutes ?? 0,
      };
    } catch (e) {
      debugPrint('❌ [GAME_TOKENS_CACHE] Error getting cache stats: $e');
      return {
        'hasCache': false,
        'error': e.toString(),
      };
    }
  }
}

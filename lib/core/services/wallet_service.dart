import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:unified_dream247/core/constants/storage_constants.dart';
import 'package:unified_dream247/features/shop/models/shop_transaction_model.dart';

/// Unified Wallet Service
/// Manages wallet data across both Shop and Fantasy modules
class UnifiedWalletService {
  static final UnifiedWalletService _instance = UnifiedWalletService._internal();

  factory UnifiedWalletService() => _instance;
  UnifiedWalletService._internal();

  SharedPreferences? _prefs;

  /// Initialize service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    debugPrint('✅ [UNIFIED_WALLET] Service initialized');
  }

  // ==================== SHOP TOKENS ====================

  /// Get current shop tokens balance
  Future<double> getShopTokens() async {
    await _ensureInitialized();
    final tokens = _prefs?.getDouble(StorageConstants.shopTokens) ?? 0.0;
    debugPrint('📊 [UNIFIED_WALLET] Shop tokens: $tokens');
    return tokens;
  }

  /// Set shop tokens balance
  Future<void> setShopTokens(double amount) async {
    await _ensureInitialized();
    await _prefs?.setDouble(StorageConstants.shopTokens, amount);
    debugPrint('✅ [UNIFIED_WALLET] Shop tokens set to: $amount');
  }

  /// Add shop tokens
  Future<void> addShopTokens(double amount) async {
    final current = await getShopTokens();
    final newAmount = current + amount;
    await setShopTokens(newAmount);

    // Add transaction
    await ShopTransactionManager.addTransaction(
      type: 'add_money',
      amount: amount,
      description: 'Added ${amount.toStringAsFixed(0)} RS',
    );

    debugPrint('✅ [UNIFIED_WALLET] Added $amount shop tokens');
  }

  /// Deduct shop tokens (for purchases)
  Future<bool> deductShopTokens(double amount, {String? itemName}) async {
    final current = await getShopTokens();

    if (current < amount) {
      debugPrint('❌ [UNIFIED_WALLET] Insufficient shop tokens. Have: $current, Need: $amount');
      return false;
    }

    final newAmount = current - amount;
    await setShopTokens(newAmount);

    // Add transaction
    await ShopTransactionManager.addTransaction(
      type: 'purchase',
      amount: -amount,
      description: 'Purchased $itemName',
      itemName: itemName,
    );

    debugPrint('✅ [UNIFIED_WALLET] Deducted $amount shop tokens for: $itemName');
    return true;
  }

  /// Check if enough shop tokens available
  Future<bool> hasEnoughShopTokens(double amount) async {
    final current = await getShopTokens();
    return current >= amount;
  }

  // ==================== GAME TOKENS ====================

  /// Get current game tokens balance (from Fantasy)
  Future<double> getGameTokens() async {
    await _ensureInitialized();
    final tokens = _prefs?.getDouble(StorageConstants.gameTokens) ?? 0.0;
    return tokens;
  }

  /// Set game tokens (called by Fantasy module)
  Future<void> setGameTokens(double amount) async {
    await _ensureInitialized();
    await _prefs?.setDouble(StorageConstants.gameTokens, amount);
    debugPrint('✅ [UNIFIED_WALLET] Game tokens set to: $amount');
  }

  // ==================== TRANSACTIONS ====================

  /// Get all shop transactions
  Future<List<ShopTransaction>> getShopTransactions() async {
    return await ShopTransactionManager.getTransactions();
  }

  /// Get shop transactions by type
  Future<List<ShopTransaction>> getShopTransactionsByType(String type) async {
    return await ShopTransactionManager.getTransactionsByType(type);
  }

  /// Get total spent on shopping
  Future<double> getTotalShopSpent() async {
    return await ShopTransactionManager.getTotalSpent();
  }

  /// Get total added to wallet
  Future<double> getTotalAdded() async {
    return await ShopTransactionManager.getTotalAdded();
  }

  // ==================== COMBINED DATA ====================

  /// Get all wallet data (for unified display)
  Future<Map<String, dynamic>> getUnifiedWalletData({
    List<dynamic>? fantasyTransactions,
  }) async {
    final shopTokens = await getShopTokens();
    final gameTokens = await getGameTokens();
    final shopTransactions = await getShopTransactions();
    final totalSpent = await getTotalShopSpent();
    final totalAdded = await getTotalAdded();

    return {
      'shopTokens': shopTokens,
      'gameTokens': gameTokens,
      'shopTransactions': shopTransactions,
      'fantasyTransactions': fantasyTransactions ?? [],
      'totalSpent': totalSpent,
      'totalAdded': totalAdded,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  /// Merge shop and fantasy transactions for unified history
  Future<List<Map<String, dynamic>>> getMergedTransactionHistory({
    List<Map<String, dynamic>>? fantasyTransactions,
  }) async {
    final shopTransactions = await getShopTransactions();
    final merged = <Map<String, dynamic>>[];

    // Add shop transactions
    for (var txn in shopTransactions) {
      merged.add({
        'id': txn.id,
        'type': txn.type,
        'module': 'shop',
        'amount': txn.amount,
        'tokenType': 'shop',
        'description': txn.description,
        'itemName': txn.itemName,
        'timestamp': txn.timestamp,
        'status': txn.status,
        'displayText': txn.getDisplayText(),
        'icon': txn.getIcon(),
        'isPositive': txn.isPositive(),
      });
    }

    // Add fantasy transactions
    if (fantasyTransactions != null) {
      for (var txn in fantasyTransactions) {
        txn['module'] = 'fantasy';
        txn['tokenType'] = 'game';
        merged.add(txn);
      }
    }

    // Sort by timestamp (newest first)
    merged.sort((a, b) {
      final timeA = a['timestamp'] is DateTime
          ? a['timestamp'] as DateTime
          : DateTime.parse(a['timestamp'] as String);
      final timeB = b['timestamp'] is DateTime
          ? b['timestamp'] as DateTime
          : DateTime.parse(b['timestamp'] as String);
      return timeB.compareTo(timeA);
    });

    return merged;
  }

  // ==================== UTILITY ====================

  /// Ensure service is initialized
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await initialize();
    }
  }

  /// Clear all wallet data (logout)
  Future<void> clearAll() async {
    await _ensureInitialized();
    await _prefs?.remove(StorageConstants.shopTokens);
    await _prefs?.remove(StorageConstants.gameTokens);
    await _prefs?.remove(StorageConstants.totalWalletAmount);
    await ShopTransactionManager.clearAll();
    debugPrint('⚠️ [UNIFIED_WALLET] All wallet data cleared');
  }

  /// Debug: Print current state
  Future<void> debugPrintState() async {
    final shopTokens = await getShopTokens();
    final gameTokens = await getGameTokens();
    final transactions = await getShopTransactions();

    debugPrint('''
═══════════════════════════════════════
  UNIFIED WALLET STATE
═══════════════════════════════════════
  🪙 Shop Tokens: $shopTokens
  💎 Game Tokens: $gameTokens
  📝 Shop Transactions: ${transactions.length}
═══════════════════════════════════════
    ''');
  }
}

/// Global instance
final walletService = UnifiedWalletService();

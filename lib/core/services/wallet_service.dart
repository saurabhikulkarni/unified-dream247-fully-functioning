import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:unified_dream247/core/constants/storage_constants.dart';
import 'package:unified_dream247/features/shop/models/shop_transaction_model.dart';
import 'package:unified_dream247/features/shop/services/order_service_graphql.dart';
import 'package:unified_dream247/features/shop/services/user_service.dart';

/// Unified Wallet Service
/// Manages wallet data across both Shop and Fantasy modules
/// Now integrated with GraphQL backend for persistence
class UnifiedWalletService {
  static final UnifiedWalletService _instance = UnifiedWalletService._internal();

  factory UnifiedWalletService() => _instance;
  UnifiedWalletService._internal();

  SharedPreferences? _prefs;
  final OrderServiceGraphQL _graphQLService = OrderServiceGraphQL();
  
  // Cache for backend data (5 minutes)
  DateTime? _lastBackendSync;
  static const Duration _cacheExpiry = Duration(minutes: 5);
  Map<String, dynamic>? _cachedWalletData;

  /// Initialize service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    debugPrint('✅ [UNIFIED_WALLET] Service initialized with GraphQL backend');
  }

  // ==================== SHOP TOKENS ====================

  /// Get current shop tokens balance (from backend or cache)
  Future<double> getShopTokens() async {
    await _ensureInitialized();
    
    try {
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        debugPrint('⚠️ [UNIFIED_WALLET] User not logged in, using local storage');
        return _prefs?.getDouble(StorageConstants.shopTokens) ?? 0.0;
      }

      // Try to fetch from backend
      final wallet = await _graphQLService.getUserWallet(userId);
      final backendTokens = wallet['shopTokens'] as double? ?? 0.0;
      
      // Sync to local storage
      await _prefs?.setDouble(StorageConstants.shopTokens, backendTokens);
      debugPrint('📊 [UNIFIED_WALLET] Shop tokens (from backend): $backendTokens');
      return backendTokens;
    } catch (e) {
      // Fallback to local storage
      debugPrint('⚠️ [UNIFIED_WALLET] Backend fetch failed, using local: $e');
      final tokens = _prefs?.getDouble(StorageConstants.shopTokens) ?? 0.0;
      return tokens;
    }
  }

  /// Set shop tokens balance (local only - use addShopTokens or deductShopTokens for backend sync)
  Future<void> setShopTokens(double amount) async {
    await _ensureInitialized();
    await _prefs?.setDouble(StorageConstants.shopTokens, amount);
    debugPrint('✅ [UNIFIED_WALLET] Shop tokens synced locally: $amount');
  }

  /// Add shop tokens from payment (syncs to backend)
  Future<void> addShopTokens(double amount, {String paymentMethod = 'razorpay'}) async {
    await _ensureInitialized();
    
    try {
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        debugPrint('❌ [UNIFIED_WALLET] User not logged in, cannot add tokens');
        return;
      }

      // Call backend to add tokens
      final result = await _graphQLService.addShopTokens(
        userId: userId,
        amount: amount,
        paymentMethod: paymentMethod,
      );

      if (result['success'] == true) {
        final newBalance = result['newBalance'] as double? ?? 0.0;
        await _prefs?.setDouble(StorageConstants.shopTokens, newBalance);
        
        debugPrint('✅ [UNIFIED_WALLET] Added $amount shop tokens (Backend)');
        debugPrint('💰 New balance: $newBalance');
      }
    } catch (e) {
      debugPrint('❌ [UNIFIED_WALLET] Error adding tokens: $e');
      
      // Fallback: Add to local storage only
      final current = await getShopTokens();
      final newAmount = current + amount;
      await setShopTokens(newAmount);
      await ShopTransactionManager.addTransaction(
        type: 'add_money',
        amount: amount,
        description: 'Added ${amount.toStringAsFixed(0)} RS',
      );
    }
  }

  /// Deduct shop tokens (for purchases) - syncs to backend
  Future<bool> deductShopTokens(
    double amount, {
    String? itemName,
    String? orderId,
  }) async {
    await _ensureInitialized();
    
    try {
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        debugPrint('❌ [UNIFIED_WALLET] User not logged in, cannot deduct tokens');
        return false;
      }

      // Check local balance first
      final current = await getShopTokens();
      if (current < amount) {
        debugPrint('❌ [UNIFIED_WALLET] Insufficient shop tokens. Have: $current, Need: $amount');
        return false;
      }

      // Call backend to deduct tokens
      final result = await _graphQLService.deductShopTokens(
        userId: userId,
        amount: amount,
        orderId: orderId ?? 'local-${DateTime.now().millisecondsSinceEpoch}',
        itemName: itemName ?? 'Purchase',
      );

      if (result['success'] == true) {
        final newBalance = result['newBalance'] as double? ?? 0.0;
        await _prefs?.setDouble(StorageConstants.shopTokens, newBalance);
        
        debugPrint('✅ [UNIFIED_WALLET] Deducted $amount for: $itemName (Backend)');
        debugPrint('💰 New balance: $newBalance');
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('⚠️ [UNIFIED_WALLET] Backend deduction failed: $e');
      
      // Fallback: Deduct from local storage
      final current = await getShopTokens();
      if (current < amount) {
        debugPrint('❌ [UNIFIED_WALLET] Insufficient shop tokens (Fallback)');
        return false;
      }

      final newAmount = current - amount;
      await setShopTokens(newAmount);

      // Add transaction locally
      await ShopTransactionManager.addTransaction(
        type: 'purchase',
        amount: -amount,
        description: 'Purchased $itemName',
        itemName: itemName,
      );

      debugPrint('✅ [UNIFIED_WALLET] Deducted $amount shop tokens (Local only)');
      return true;
    }
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

  /// Get all shop transactions (from backend or local)
  Future<List<ShopTransaction>> getShopTransactions() async {
    try {
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        // Fallback to local storage
        return await ShopTransactionManager.getTransactions();
      }

      // Try to fetch from backend
      final backendTransactions = await _graphQLService.getWalletTransactions(
        userId: userId,
        first: 100,
      );

      // Convert backend transactions to ShopTransaction
      final transactions = <ShopTransaction>[];
      for (var txn in backendTransactions) {
        transactions.add(ShopTransaction(
          id: txn['id'] as String? ?? '',
          type: txn['type'] as String? ?? 'unknown',
          amount: txn['amount'] as double? ?? 0.0,
          description: txn['description'] as String? ?? '',
          itemName: txn['description'] as String?,
          timestamp: txn['timestamp'] is DateTime
              ? txn['timestamp'] as DateTime
              : DateTime.tryParse(txn['timestamp'] as String? ?? '') ?? DateTime.now(),
          status: txn['status'] as String? ?? 'completed',
        ));
      }

      debugPrint('✅ [UNIFIED_WALLET] Fetched ${transactions.length} transactions from backend');
      return transactions;
    } catch (e) {
      debugPrint('⚠️ [UNIFIED_WALLET] Backend transaction fetch failed: $e');
      // Fallback to local storage
      return await ShopTransactionManager.getTransactions();
    }
  }

  /// Get shop transactions by type
  Future<List<ShopTransaction>> getShopTransactionsByType(String type) async {
    final allTransactions = await getShopTransactions();
    return allTransactions.where((t) => t.type == type).toList();
  }

  /// Get total spent on shopping
  Future<double> getTotalShopSpent() async {
    final wallet = await _getWalletDataWithSync();
    return wallet['totalSpent'] as double? ?? 0.0;
  }

  /// Get total added to wallet
  Future<double> getTotalAdded() async {
    final wallet = await _getWalletDataWithSync();
    return wallet['totalAdded'] as double? ?? 0.0;
  }

  // ==================== COMBINED DATA ====================

  /// Get wallet data with backend sync (with caching)
  Future<Map<String, dynamic>> _getWalletDataWithSync() async {
    // Check cache validity
    if (_cachedWalletData != null && _lastBackendSync != null) {
      final timeSinceSync = DateTime.now().difference(_lastBackendSync!);
      if (timeSinceSync < _cacheExpiry) {
        return _cachedWalletData!;
      }
    }

    try {
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        return {
          'shopTokens': await _prefs?.getDouble(StorageConstants.shopTokens) ?? 0.0,
          'totalSpent': await ShopTransactionManager.getTotalSpent(),
          'totalAdded': await ShopTransactionManager.getTotalAdded(),
        };
      }

      // Fetch from backend
      final wallet = await _graphQLService.getUserWallet(userId);
      
      _cachedWalletData = {
        'shopTokens': wallet['shopTokens'] as double? ?? 0.0,
        'totalSpent': wallet['totalSpentTokens'] as double? ?? 0.0,
        'totalAdded': 0.0,
      };
      
      _lastBackendSync = DateTime.now();
      debugPrint('✅ [UNIFIED_WALLET] Synced wallet data from backend');
      return _cachedWalletData!;
    } catch (e) {
      debugPrint('⚠️ [UNIFIED_WALLET] Wallet sync failed: $e');
      // Return local data
      return {
        'shopTokens': await _prefs?.getDouble(StorageConstants.shopTokens) ?? 0.0,
        'totalSpent': await ShopTransactionManager.getTotalSpent(),
        'totalAdded': await ShopTransactionManager.getTotalAdded(),
      };
    }
  }

  /// Get all wallet data (for unified display)
  Future<Map<String, dynamic>> getUnifiedWalletData({
    List<dynamic>? fantasyTransactions,
  }) async {
    final shopTokens = await getShopTokens();
    final gameTokens = await getGameTokens();
    final shopTransactions = await getShopTransactions();
    final walletData = await _getWalletDataWithSync();
    final totalSpent = walletData['totalSpent'] as double? ?? 0.0;
    final totalAdded = walletData['totalAdded'] as double? ?? 0.0;

    return {
      'shopTokens': shopTokens,
      'gameTokens': gameTokens,
      'shopTransactions': shopTransactions,
      'fantasyTransactions': fantasyTransactions ?? [],
      'totalSpent': totalSpent,
      'totalAdded': totalAdded,
      'lastUpdated': DateTime.now().toIso8601String(),
      'syncedWithBackend': _lastBackendSync != null,
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

  /// Sync wallet data with backend (manual sync)
  Future<void> syncWithBackend() async {
    try {
      _lastBackendSync = null; // Force cache invalidation
      _cachedWalletData = null;
      
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        debugPrint('⚠️ [UNIFIED_WALLET] User not logged in, cannot sync');
        return;
      }

      // Fetch fresh data from backend
      final wallet = await _graphQLService.getUserWallet(userId);
      final shopTokens = wallet['shopTokens'] as double? ?? 0.0;
      
      // Update local storage
      await setShopTokens(shopTokens);
      
      // Update cache
      _cachedWalletData = wallet;
      _lastBackendSync = DateTime.now();
      
      debugPrint('✅ [UNIFIED_WALLET] Successfully synced with backend');
    } catch (e) {
      debugPrint('❌ [UNIFIED_WALLET] Backend sync failed: $e');
    }
  }

  /// Clear all wallet data (logout)
  Future<void> clearAll() async {
    await _ensureInitialized();
    await _prefs?.remove(StorageConstants.shopTokens);
    await _prefs?.remove(StorageConstants.gameTokens);
    await _prefs?.remove(StorageConstants.totalWalletAmount);
    await ShopTransactionManager.clearAll();
    
    // Clear cache
    _cachedWalletData = null;
    _lastBackendSync = null;
    
    debugPrint('⚠️ [UNIFIED_WALLET] All wallet data cleared (local & cache)');
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
  🔄 Backend Synced: ${_lastBackendSync != null ? 'Yes' : 'No'}
═══════════════════════════════════════
    ''');
  }
}

/// Global instance
final walletService = UnifiedWalletService();

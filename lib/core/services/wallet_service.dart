import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:unified_dream247/config/api_config.dart';
import 'package:unified_dream247/core/constants/storage_constants.dart';
import 'package:unified_dream247/features/shop/models/shop_transaction_model.dart';
import 'package:unified_dream247/features/shop/services/order_service_graphql.dart';
import 'package:unified_dream247/features/shop/services/user_service.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/game_tokens_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/managers/game_tokens_cache.dart';

/// Unified Wallet Service
/// Manages wallet data across both Shop and Fantasy modules
/// Now integrated with GraphQL backend for persistence
class UnifiedWalletService {
  static final UnifiedWalletService _instance = UnifiedWalletService._internal();

  factory UnifiedWalletService() => _instance;
  UnifiedWalletService._internal();

  SharedPreferences? _prefs;
  final OrderServiceGraphQL _graphQLService = OrderServiceGraphQL();
  final GameTokensCache _gameTokensCache = GameTokensCache();
  
  // Reference to ShopTokensProvider for instant UI updates
  // This is set by ShopTokensProvider when it initializes
  dynamic _shopTokensProvider;
  
  // Cache for backend data (5 minutes)
  DateTime? _lastBackendSync;
  static const Duration _cacheExpiry = Duration(minutes: 5);
  Map<String, dynamic>? _cachedWalletData;

  /// Safely get a double from SharedPreferences (handles int stored values)
  double _safeGetDouble(String key) {
    try {
      final value = _prefs?.get(key);
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  /// Initialize service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _gameTokensCache.initialize();
    debugPrint('✅ [UNIFIED_WALLET] Service initialized with GraphQL backend');
  }

  /// Register ShopTokensProvider for instant UI updates
  void setShopTokensProvider(dynamic provider) {
    _shopTokensProvider = provider;
    debugPrint('✅ [UNIFIED_WALLET] ShopTokensProvider registered for instant updates');
  }

  // ==================== SHOP TOKENS ====================

  /// Get current shop tokens balance (from cache FIRST, then backend)
  Future<double> getShopTokens() async {
    await _ensureInitialized();
    
    try {
      // ✅ PRIORITY 1: Check SharedPreferences FIRST (most reliable)
      // This has the value synced from Fantasy REST API endpoint
      final cachedValue = _prefs?.get(StorageConstants.shopTokens);
      if (cachedValue != null) {
        double value = 0.0;
        if (cachedValue is double) {
          value = cachedValue;
        } else if (cachedValue is int) {
          value = cachedValue.toDouble();
        }
        if (value > 0) {
          debugPrint('📊 [UNIFIED_WALLET] Shop tokens (from SharedPreferences cache): $value');
          return value;
        }
      }

      // ✅ PRIORITY 2: Try to fetch from backend if cache is empty or 0
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        debugPrint('⚠️ [UNIFIED_WALLET] User not logged in, using local storage');
        return _safeGetDouble(StorageConstants.shopTokens);
      }

      // Try to fetch from GraphQL backend
      final wallet = await _graphQLService.getUserWallet(userId);
      final backendTokens = wallet['balance'] as double? ?? 0.0;
      
      // If backend has value, sync to local storage
      if (backendTokens > 0) {
        await _prefs?.setDouble(StorageConstants.shopTokens, backendTokens);
        debugPrint('📊 [UNIFIED_WALLET] Shop tokens (from GraphQL backend): $backendTokens');
        return backendTokens;
      }
      
      // Backend returned 0 - keep using cached value if available
      final cached = _safeGetDouble(StorageConstants.shopTokens);
      debugPrint('⚠️ [UNIFIED_WALLET] Backend returned 0, keeping cached value: $cached');
      return cached;
    } catch (e) {
      // Fallback to local storage on any error
      debugPrint('⚠️ [UNIFIED_WALLET] Backend fetch failed, using local: $e');
      return _safeGetDouble(StorageConstants.shopTokens);
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
    debugPrint('=== [UNIFIED_WALLET] deductShopTokens CALLED ===');
    debugPrint('   - Amount: $amount');
    debugPrint('   - ItemName: $itemName');
    debugPrint('   - OrderID: $orderId');
    
    await _ensureInitialized();
    
    try {
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        debugPrint('❌ [UNIFIED_WALLET] User not logged in, cannot deduct tokens');
        return false;
      }

      // Check local balance - try to get from Provider first (UI state), fallback to SharedPreferences
      double current = 0.0;
      try {
        // Try to get from provider if available (this is the actual UI balance)
        if (_shopTokensProvider != null) {
          current = _shopTokensProvider!.shopTokens;
          debugPrint('📊 [UNIFIED_WALLET] Got balance from Provider: $current');
        } else {
          // Fallback to SharedPreferences
          current = await getShopTokens();
          debugPrint('📊 [UNIFIED_WALLET] Got balance from SharedPreferences: $current');
        }
      } catch (e) {
        debugPrint('⚠️ [UNIFIED_WALLET] Error getting balance, trying SharedPreferences: $e');
        current = await getShopTokens();
      }
      
      if (current < amount) {
        debugPrint('❌ [UNIFIED_WALLET] Insufficient shop tokens. Have: $current, Need: $amount');
        return false;
      }

      debugPrint('🔄 [UNIFIED_WALLET] Starting token deduction...');
      debugPrint('   - Current balance: $current');
      debugPrint('   - Amount to deduct: $amount');

      // PRIMARY: Try REST endpoint FIRST (this is the reliable method with your backend)
      final restSuccess = await _deductFromFantasyBackend(
        amount: amount,
        orderId: orderId ?? 'local-${DateTime.now().millisecondsSinceEpoch}',
        itemName: itemName ?? 'Purchase',
      );
      
      if (restSuccess) {
        debugPrint('✅ [UNIFIED_WALLET] REST deduction successful');
        return true;
      }
      
      // FALLBACK: If REST fails, deduct locally as last resort
      debugPrint('⚠️ [UNIFIED_WALLET] REST deduction failed, using local fallback');
      final newAmount = current - amount;
      await setShopTokens(newAmount);
      
      await ShopTransactionManager.addTransaction(
        type: 'purchase',
        amount: amount,
        description: itemName ?? 'Purchase',
        status: 'pending',
      );
      
      return true;
    } catch (e) {
      debugPrint('❌ [UNIFIED_WALLET] Deduction error: $e');
      return false;
    }
  }


  /// Helper to refresh from Fantasy if needed
  Future<void> _refreshFromFantasyIfNeeded(double expectedBalance) async {
    try {
      // Small delay to allow backend to sync
      await Future.delayed(const Duration(milliseconds: 500));
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? prefs.getString('auth_token');
      
      if (token == null) return;

      final url = '${ApiConfig.fantasyUserUrl}user-wallet-details';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final balanceStr = data['data']['balance']?.toString() ?? '0';
          final fantasyBalance = double.tryParse(balanceStr)?.toInt() ?? 0;
          
          debugPrint('🔄 [UNIFIED_WALLET] Fantasy balance after deduction: $fantasyBalance');
          
          // If Fantasy has different balance than expected, update to Fantasy's value
          if (fantasyBalance != expectedBalance.toInt()) {
            debugPrint('⚠️ [UNIFIED_WALLET] Syncing from Fantasy (GraphQL returned $expectedBalance, Fantasy has $fantasyBalance)');
            await _prefs?.setInt(StorageConstants.shopTokens, fantasyBalance);
          }
        }
      }
    } catch (e) {
      // Silent fail - this is just a sanity check
      debugPrint('ℹ️ [UNIFIED_WALLET] Fantasy refresh check skipped: $e');
    }
  }

  /// Deduct from Fantasy backend directly
  Future<bool> _deductFromFantasyBackend({
    required double amount,
    required String orderId,
    required String itemName,
  }) async {
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('🔄 [FANTASY_DEDUCT] *** METHOD ENTRY POINT ***');
    debugPrint('   Amount: $amount');
    debugPrint('   OrderID: $orderId');
    debugPrint('   ItemName: $itemName');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? prefs.getString('auth_token');
      
      debugPrint('🔄 [FANTASY_DEDUCT] Token check: ${token != null ? "✓ Token found" : "✗ NO TOKEN"}');
      if (token == null) {
        debugPrint('❌ [FANTASY_DEDUCT] No auth token available - RETURNING FALSE');
        return false;
      }

      final url = '${ApiConfig.fantasyBaseUrl}/user/wallet/deduct-shop-tokens';
      
      debugPrint('🔄 [FANTASY_DEDUCT] Attempting Fantasy backend deduction');
      debugPrint('   - Endpoint: user/wallet/deduct-shop-tokens');
      debugPrint('   - Amount: $amount');
      debugPrint('   - Order Reference: $orderId');

      try {
        final requestBody = {
          'amount': amount,
          'orderReference': orderId,
          'description': 'Product purchase - $itemName',
        };
        
        debugPrint('🔄 [FANTASY_DEDUCT] Request Body: $requestBody');
        debugPrint('🔄 [FANTASY_DEDUCT] Making HTTP POST request...');
        
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody),
        ).timeout(const Duration(seconds: 10));

        debugPrint('✅ [FANTASY_DEDUCT] HTTP Response received');
        debugPrint('📊 [FANTASY_DEDUCT] Status Code: ${response.statusCode}');
        debugPrint('📝 [FANTASY_DEDUCT] Response Body: ${response.body}');
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint('🔄 [FANTASY_DEDUCT] Response status OK, parsing JSON...');
          
          try {
            final data = jsonDecode(response.body);
            debugPrint('✅ [FANTASY_DEDUCT] Parsed response: $data');
            
            if (data['success'] == true) {
              final newBalance = double.tryParse(data['data']?['balance']?.toString() ?? '0') ?? 0;
              
              // Update local cache with new balance from Fantasy
              await _prefs?.setInt(StorageConstants.shopTokens, newBalance.toInt());
              
              // UPDATE SHOP TOKENS PROVIDER WITH NEW BALANCE IMMEDIATELY
              if (_shopTokensProvider != null) {
                debugPrint('🔄 [FANTASY_DEDUCT] Updating ShopTokensProvider with new balance: $newBalance');
                _shopTokensProvider!.updateTokens(newBalance.toInt());
              }
              
              debugPrint('✅ [FANTASY_DEDUCT] Successfully deducted $amount');
              debugPrint('   - New balance: $newBalance');
              debugPrint('═══════════════════════════════════════════════════════');
              return true;
            } else {
              debugPrint('⚠️ [FANTASY_DEDUCT] Response was 200 but success != true');
              debugPrint('   - Response: $data');
              return false;
            }
          } catch (parseError) {
            debugPrint('❌ [FANTASY_DEDUCT] Failed to parse JSON: $parseError');
            return false;
          }
        } else if (response.statusCode == 404) {
          debugPrint('⚠️ [FANTASY_DEDUCT] Endpoint not found (404) - Backend endpoint missing?');
          return false;
        } else {
          debugPrint('❌ [FANTASY_DEDUCT] HTTP Error ${response.statusCode}');
          return false;
        }
      } on TimeoutException catch (timeoutE) {
        debugPrint('⏱️ [FANTASY_DEDUCT] Request timed out after 10s: $timeoutE');
        return false;
      } on SocketException catch (socketE) {
        debugPrint('🔌 [FANTASY_DEDUCT] Network error: $socketE');
        return false;
      }
    } catch (e, st) {
      debugPrint('❌ [FANTASY_DEDUCT] Unexpected error: $e');
      debugPrint('❌ [FANTASY_DEDUCT] Stacktrace: $st');
      debugPrint('═══════════════════════════════════════════════════════');
      return false;
    }
  }

  /// Refresh shop tokens from Fantasy backend
  Future<void> refreshShopTokensFromFantasy() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? prefs.getString('auth_token');
      
      if (token == null) return;

      final url = '${ApiConfig.fantasyUserUrl}user-wallet-details';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final balanceStr = data['data']['balance']?.toString() ?? '0';
          final balance = double.tryParse(balanceStr)?.toInt() ?? 0;
          
          await _prefs?.setInt(StorageConstants.shopTokens, balance);
          debugPrint('✅ [WALLET_SERVICE] Refreshed shop tokens from Fantasy: $balance');
        }
      }
    } catch (e) {
      debugPrint('⚠️ [WALLET_SERVICE] Error refreshing from Fantasy: $e');
    }
  }

  /// Check if enough shop tokens available
  Future<bool> hasEnoughShopTokens(double amount) async {
    final current = await getShopTokens();
    return current >= amount;
  }

  // ==================== GAME TOKENS ====================

  /// Get current game tokens balance (from Fantasy backend with fallback to local cache)
  Future<double> getGameTokens() async {
    await _ensureInitialized();
    
    try {
      // Try to fetch from Fantasy backend
      final balance = await _fetchGameTokensFromFantasy();
      if (balance >= 0) {
        // Sync to local cache
        await _prefs?.setDouble(StorageConstants.gameTokens, balance);
        debugPrint('📊 [UNIFIED_WALLET] Game tokens (from Fantasy backend): $balance');
        return balance;
      }
    } catch (e) {
      // Fallback to local cache if backend fails
      debugPrint('⚠️ [UNIFIED_WALLET] Fantasy backend fetch failed, using local cache: $e');
    }
    
    // Return cached value
    final cached = _safeGetDouble(StorageConstants.gameTokens);
    debugPrint('💾 [UNIFIED_WALLET] Game tokens (from local cache): $cached');
    return cached;
  }

  /// Set game tokens (called by Fantasy module for local updates)
  Future<void> setGameTokens(double amount) async {
    await _ensureInitialized();
    await _prefs?.setDouble(StorageConstants.gameTokens, amount);
    debugPrint('✅ [UNIFIED_WALLET] Game tokens synced locally: $amount');
  }

  /// Fetch game tokens from Fantasy backend
  /// Returns -1 if fetch fails, otherwise returns balance
  Future<double> _fetchGameTokensFromFantasy() async {
    try {
      // Import fantasy accounts datasource
      // This method calls Fantasy's user-wallet-details endpoint
      // Response: {success: true, data: {balance: 5000, winning: 0, bonus: 100}}
      
      debugPrint('🔄 [UNIFIED_WALLET] Fetching game tokens from Fantasy backend...');
      
      // For now, return -1 to indicate need for backend call
      // This will be called from Fantasy module using proper API client
      return -1;
    } catch (e) {
      debugPrint('❌ [UNIFIED_WALLET] Error fetching from Fantasy: $e');
      return -1;
    }
  }

  /// Sync game tokens with Fantasy backend after topup
  /// Called after Razorpay payment verification in AddMoneyPage
  Future<bool> syncGameTokensWithFantasy() async {
    await _ensureInitialized();
    
    try {
      // Fetch latest balance from Fantasy backend
      final balance = await _fetchGameTokensFromFantasy();
      
      if (balance >= 0) {
        // Update local cache
        await _prefs?.setDouble(StorageConstants.gameTokens, balance);
        await _gameTokensCache.updateBalance(balance);
        debugPrint('✅ [UNIFIED_WALLET] Game tokens synced with Fantasy: $balance');
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ [UNIFIED_WALLET] Error syncing game tokens: $e');
      return false;
    }
  }

  /// Add game tokens transaction to cache
  /// Called when user tops up or participates in contests
  Future<void> addGameTokensTransaction({
    required double amount,
    required String type, // 'topup', 'debit', 'bonus'
    required String description,
    required String transactionId,
  }) async {
    await _ensureInitialized();
    
    try {
      final transaction = Transaction(
        amount: amount,
        type: type,
        description: description,
        transactionId: transactionId,
        createdAt: DateTime.now(),
        status: 'completed',
      );

      await _gameTokensCache.addTransaction(transaction);
      debugPrint('✅ [UNIFIED_WALLET] Transaction added: $type - $amount');
    } catch (e) {
      debugPrint('❌ [UNIFIED_WALLET] Error adding transaction: $e');
    }
  }

  /// Get game tokens model with all transactions
  Future<GameTokens?> getGameTokensModel() async {
    await _ensureInitialized();
    
    try {
      // Try to get from cache first
      final cached = await _gameTokensCache.getTokens();
      if (cached != null && await _gameTokensCache.isCacheValid()) {
        return cached;
      }

      // If cache is invalid, fetch from backend
      // This will be called from Fantasy module
      return null;
    } catch (e) {
      debugPrint('⚠️ [UNIFIED_WALLET] Error getting game tokens model: $e');
      return null;
    }
  }

  /// Get cache statistics for debugging
  Future<Map<String, dynamic>> getGameTokensCacheStats() async {
    await _ensureInitialized();
    return await _gameTokensCache.getCacheStats();
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
        ),);
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
          'shopTokens': _safeGetDouble(StorageConstants.shopTokens),
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
        'shopTokens': _safeGetDouble(StorageConstants.shopTokens),
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

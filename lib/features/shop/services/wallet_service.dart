import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_client.dart';
import 'graphql_queries.dart';
import 'user_service.dart';

/// DEPRECATED: Use UnifiedWalletService from lib/core/services/wallet_service.dart instead
/// This service is kept for backward compatibility but should not be used in new code
@Deprecated('Use UnifiedWalletService from lib/core/services/wallet_service.dart')
class WalletService {
  static final WalletService _instance = WalletService._internal();

  factory WalletService() {
    return _instance;
  }

  WalletService._internal() {
    if (kDebugMode) {
      debugPrint('⚠️ [DEPRECATED] WalletService is deprecated. Use UnifiedWalletService instead.');
    }
  }

  // Keys for SharedPreferences
  static const String _walletBalanceKey = 'wallet_balance';
  static const String _walletTransactionsKey = 'wallet_transactions';
  static const String _userIdKey = 'user_id';

  final GraphQLClient _graphQLClient = GraphQLService.getClient();

  // Get current wallet balance from local cache or GraphQL
  Future<double> getBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      double cachedBalance = prefs.getDouble(_walletBalanceKey) ?? 0.0;
      
      // Try to sync with backend if we have a user ID
      final userId = prefs.getString(_userIdKey);
      if (userId != null) {
        await syncWithBackend();
        return prefs.getDouble(_walletBalanceKey) ?? cachedBalance;
      }
      
      return cachedBalance;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting wallet balance: $e');
      }
      return 0.0;
    }
  }

  // Set wallet balance locally
  Future<void> setBalance(double amount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_walletBalanceKey, amount);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting wallet balance: $e');
      }
    }
  }

  // Add money to wallet via GraphQL
  Future<bool> addBalance(double amount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userIdKey);
      
      if (userId == null) {
        if (kDebugMode) {
          print('Error: User ID not found');
        }
        return false;
      }

      final currentBalance = await getBalance();
      final newBalance = currentBalance + amount;

      // Update via GraphQL mutation (convert to int for Hygraph)
      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.updateWalletBalance),
        variables: {
          'userId': userId,
          'walletBalance': newBalance.toInt(),
        },
      );

      final QueryResult result = await _graphQLClient.mutate(options);

      if (result.hasException) {
        if (kDebugMode) {
          print('Error adding balance: ${result.exception}');
        }
        return false;
      }

      // Update local cache
      await setBalance(newBalance);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding balance: $e');
      }
      return false;
    }
  }

  // Deduct money from wallet via GraphQL
  Future<bool> deductBalance(double amount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userIdKey);
      
      if (userId == null) {
        if (kDebugMode) {
          print('Error: User ID not found');
        }
        return false;
      }

      final currentBalance = await getBalance();
      if (currentBalance < amount) {
        return false; // Insufficient balance
      }

      // Use UserService to deduct balance with proper decrement operation
      final userService = UserService();
      final newBalance = await userService.deductWalletBalance(userId, amount);

      if (newBalance == null) {
        if (kDebugMode) {
          print('Error: Failed to deduct balance from backend');
        }
        return false;
      }

      // Update local cache with new balance
      await setBalance(newBalance);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deducting balance: $e');
      }
      return false;
    }
  }

  // Check if sufficient balance available
  Future<bool> hasSufficientBalance(double requiredAmount) async {
    try {
      final currentBalance = await getBalance();
      return currentBalance >= requiredAmount;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking balance: $e');
      }
      return false;
    }
  }

  // Sync wallet balance with backend via GraphQL
  Future<bool> syncWithBackend() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userIdKey);
      
      if (userId == null) {
        if (kDebugMode) {
          print('Error: User ID not found');
        }
        return false;
      }

      // Fetch current balance from GraphQL
      final QueryOptions options = QueryOptions(
        document: gql(GraphQLQueries.getUserWallet),
        variables: {'userId': userId},
      );

      final QueryResult result = await _graphQLClient.query(options);

      if (result.hasException) {
        if (kDebugMode) {
          print('Error syncing wallet: ${result.exception}');
        }
        return false;
      }

      final data = result.data;
      if (data != null && data['userDetail'] != null) {
        final walletBalance = (data['userDetail']['walletBalance'] ?? 0.0).toDouble();
        await setBalance(walletBalance);
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Exception in syncWithBackend: $e');
      }
      return false;
    }
  }

  // Add money via payment and update via GraphQL
  Future<bool> addMoneyViaPayment({
    required double amount,
    required String paymentId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userIdKey);
      
      if (userId == null) {
        if (kDebugMode) {
          print('Error: User ID not found');
        }
        return false;
      }

      final currentBalance = await getBalance();
      final newBalance = currentBalance + amount;

      // Update wallet via GraphQL mutation (convert to int for Hygraph)
      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.updateWalletBalance),
        variables: {
          'userId': userId,
          'walletBalance': newBalance.toInt(),
        },
      );

      final QueryResult result = await _graphQLClient.mutate(options);

      if (result.hasException) {
        if (kDebugMode) {
          print('Error adding money via payment: ${result.exception}');
        }
        return false;
      }

      // Update local cache
      await setBalance(newBalance);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding money via payment: $e');
      }
      return false;
    }
  }

  // Deduct balance for purchase via GraphQL
  Future<bool> deductForPurchase({
    required double amount,
    required String orderId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userIdKey);
      
      if (userId == null) {
        if (kDebugMode) {
          print('Error: User ID not found');
        }
        return false;
      }

      // Check if sufficient balance
      final hasBalance = await hasSufficientBalance(amount);
      if (!hasBalance) {
        if (kDebugMode) {
          print('Insufficient balance for purchase');
        }
        return false;
      }

      final currentBalance = await getBalance();
      final newBalance = currentBalance - amount;

      // Update wallet via GraphQL mutation (convert to int for Hygraph)
      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.updateWalletBalance),
        variables: {
          'userId': userId,
          'walletBalance': newBalance.toInt(),
        },
      );

      final QueryResult result = await _graphQLClient.mutate(options);

      if (result.hasException) {
        if (kDebugMode) {
          print('Error deducting for purchase: ${result.exception}');
        }
        return false;
      }

      // Update local cache
      await setBalance(newBalance);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deducting for purchase: $e');
      }
      return false;
    }
  }

  // Store user ID from login
  Future<void> setUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting user ID: $e');
      }
    }
  }

  // Clear wallet (logout)
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_walletBalanceKey);
      await prefs.remove(_walletTransactionsKey);
      await prefs.remove(_userIdKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing wallet: $e');
      }
    }
  }
}

// Global instance
final walletService = WalletService();

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_dream247/features/shop/models/product_model.dart';
import 'package:unified_dream247/features/shop/services/graphql_client.dart';
import 'package:unified_dream247/features/shop/services/graphql_queries.dart';

class UserService {
  final GraphQLClient _client = GraphQLService.getClient();

  // For now, using a local user ID - in production, get from auth state
  static String? _currentUserId;
  static SharedPreferences? _prefs;

  // Initialize UserService (call on app startup)
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _currentUserId = _prefs?.getString('user_id');
    print('[USER_SERVICE] Initialized - userId from prefs: $_currentUserId');
  }

  // Set current user ID (call this after login)
  static Future<void> setCurrentUserId(String userId) async {
    _currentUserId = userId.isEmpty ? null : userId;
    // Also persist to SharedPreferences
    if (_prefs != null) {
      if (userId.isNotEmpty) {
        await _prefs!.setString('user_id', userId);
      } else {
        await _prefs!.remove('user_id');
      }
    }
  }

  // Get current user ID - checks SharedPreferences if static var is null (e.g., after hot reload)
  static String? getCurrentUserId() {
    // Return static variable if set
    if (_currentUserId != null && _currentUserId!.isNotEmpty) {
      return _currentUserId;
    }
    
    // Fall back to SharedPreferences if available
    if (_prefs != null) {
      _currentUserId = _prefs!.getString('user_id');
    }
    
    return _currentUserId;
  }

  // Fetch user by ID
  Future<UserDetailModel?> getUserById(String userId) async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getUserById),
          variables: {'id': userId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['userDetail'] == null) {
        return null;
      }

      return UserDetailModel.fromJson(
          result.data!['userDetail'] as Map<String, dynamic>,);
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  // Fetch user by mobile number (for login with OTP)
  Future<UserDetailModel?> getUserByMobileNumber(String mobileNumber) async {
    try {
      // Clean phone number (remove non-digit characters)
      final cleanPhone = mobileNumber.replaceAll(RegExp(r'[^\d]'), '');
      
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getUserByMobileNumber),
          variables: {'mobileNumber': cleanPhone},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || 
          result.data!['userDetails'] == null || 
          (result.data!['userDetails'] as List).isEmpty) {
        return null;
      }

      final users = result.data!['userDetails'] as List;
      if (users.isEmpty) return null;

      return UserDetailModel.fromJson(users[0] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  // Fetch user by username (for backward compatibility)
  Future<UserDetailModel?> getUserByUsername(String username) async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getUserByUsername),
          variables: {'username': username},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || 
          result.data!['userDetails'] == null || 
          (result.data!['userDetails'] as List).isEmpty) {
        return null;
      }

      final users = result.data!['userDetails'] as List;
      if (users.isEmpty) return null;

      return UserDetailModel.fromJson(users[0] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  // Get current user's wallet balance
  Future<double> getWalletBalance() async {
    if (_currentUserId == null) return 0.0;

    try {
      // First check if we have a cached balance in SharedPreferences
      // This is important for test users and offline mode
      final prefs = await SharedPreferences.getInstance();
      final cachedBalance = prefs.getDouble('wallet_balance');
      final lastUpdateTime = prefs.getInt('wallet_last_update') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      print('[USER_SERVICE] Getting wallet balance for userId: $_currentUserId');
      print('[USER_SERVICE] Cached balance from SharedPreferences: $cachedBalance');
      print('[USER_SERVICE] Last update: ${lastUpdateTime > 0 ? "${now - lastUpdateTime}ms ago" : "never"}');
      
      // Try to get from backend
      try {
        final user = await getUserById(_currentUserId!);
        final backendBalance = user?.walletBalance ?? 0.0;
        print('[USER_SERVICE] Backend balance: $backendBalance');
        
        // If cache was updated very recently (within 5 seconds), prefer cache
        // This prevents race condition where backend hasn't synced yet
        if (cachedBalance != null && lastUpdateTime > 0 && (now - lastUpdateTime) < 5000) {
          print('[USER_SERVICE] Using recent cached balance (${now - lastUpdateTime}ms ago): $cachedBalance');
          return cachedBalance;
        }
        
        // If cache is significantly higher than backend and has no timestamp,
        // it's likely from a recent top-up where backend update failed (test user)
        // Prefer cache in this case
        if (cachedBalance != null && cachedBalance > backendBalance && lastUpdateTime == 0) {
          print('[USER_SERVICE] Using higher cached balance (no timestamp, likely test user): $cachedBalance');
          // Set timestamp now so future queries can use time-based logic
          await prefs.setInt('wallet_last_update', now);
          return cachedBalance;
        }
        
        // Otherwise use backend balance and update cache
        await prefs.setDouble('wallet_balance', backendBalance);
        await prefs.setInt('wallet_last_update', now);
        print('[USER_SERVICE] Using backend balance: $backendBalance');
        return backendBalance;
      } catch (e) {
        print('[USER_SERVICE] Error fetching from backend, using cached: $e');
        // Only use cached balance if backend is unavailable
        final finalBalance = cachedBalance ?? 0.0;
        print('[USER_SERVICE] Returning cached balance: $finalBalance');
        return finalBalance;
      }
    } catch (e) {
      print('[USER_SERVICE] Error in getWalletBalance: $e');
      return 0.0;
    }
  }

  // Update wallet balance
  Future<bool> updateWalletBalance(String userId, double newBalance) async {
    try {
      final QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.updateWalletBalance),
          variables: {
            'userId': userId,
            'walletBalance': newBalance.toInt(),
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      // Publish the update
      if (result.data != null && result.data!['updateUserDetail'] != null) {
        final updatedUserId = result.data!['updateUserDetail']['id'];
        await _publishUser(updatedUserId);
        return true;
      }

      return false;
    } catch (e) {
      throw Exception('Error updating wallet balance: $e');
    }
  }

  // Add money to wallet (increment)
  Future<double?> addWalletBalance(String userId, double amount) async {
    try {
      print('[USER_SERVICE] Adding wallet balance: userId=$userId, amount=$amount');
      
      // Get current balance from cache first
      final prefs = await SharedPreferences.getInstance();
      final currentBalance = await getWalletBalance();
      final newBalance = currentBalance + amount;
      
      print('[USER_SERVICE] Current balance: $currentBalance, New balance: $newBalance');
      
      // Update cache immediately with timestamp
      await prefs.setDouble('wallet_balance', newBalance);
      await prefs.setInt('wallet_last_update', DateTime.now().millisecondsSinceEpoch);
      print('[USER_SERVICE] Updated SharedPreferences wallet_balance to: $newBalance');
      
      // Verify it was saved
      final verifyBalance = prefs.getDouble('wallet_balance');
      print('[USER_SERVICE] Verified SharedPreferences wallet_balance: $verifyBalance');
      
      // Try to update backend (will fail for test users, but that's OK)
      try {
        final user = await getUserById(userId);
        print('[USER_SERVICE] Got user from backend: ${user?.id}, walletBalance: ${user?.walletBalance}');
        if (user != null) {
          // Update with new calculated balance
          print('[USER_SERVICE] Attempting GraphQL mutation to update balance to: ${newBalance.toInt()}');
          final QueryResult result = await _client.mutate(
            MutationOptions(
              document: gql(GraphQLQueries.updateWalletBalance),
              variables: {
                'userId': userId,
                'walletBalance': newBalance.toInt(),
              },
            ),
          );

          print('[USER_SERVICE] Mutation result - hasException: ${result.hasException}');
          if (result.hasException) {
            print('[USER_SERVICE] Mutation exception: ${result.exception.toString()}');
          }
          
          if (!result.hasException && result.data != null && result.data!['updateUserDetail'] != null) {
            final updatedUser = result.data!['updateUserDetail'];
            final updatedUserId = updatedUser['id'];
            final returnedBalance = (updatedUser['walletBalance'] ?? 0).toDouble();
            print('[USER_SERVICE] ✅ Backend mutation SUCCESS! New balance: $returnedBalance');
            
            print('[USER_SERVICE] Publishing user update...');
            await _publishUser(updatedUserId);
            await prefs.setDouble('wallet_balance', returnedBalance);
            await prefs.setInt('wallet_last_update', DateTime.now().millisecondsSinceEpoch);
            print('[USER_SERVICE] ✅ User published and cache updated');
            return returnedBalance;
          } else {
            print('[USER_SERVICE] ❌ Mutation did not return expected data');
          }
        } else {
          print('[USER_SERVICE] ❌ User not found in backend (getUserById returned null)');
        }
      } catch (e) {
        print('[USER_SERVICE] ❌ Backend update failed with exception: $e');
        print('[USER_SERVICE] Exception type: ${e.runtimeType}');
      }

      // Return the new balance from cache
      print('[USER_SERVICE] Returning cached balance: $newBalance');
      return newBalance;
    } catch (e) {
      print('Exception in addWalletBalance: $e'); // Debug
      throw Exception('Error adding wallet balance: $e');
    }
  }

  // Deduct money from wallet (decrement)
  Future<double?> deductWalletBalance(String userId, double amount) async {
    const maxRetries = 3;
    const baseDelay = Duration(seconds: 2);
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        // First, get current balance
        final user = await getUserById(userId);
        if (user == null) {
          throw Exception('User not found');
        }
        
        final currentBalance = user.walletBalance;
        final newBalance = (currentBalance - amount).toInt();
        
        // Don't allow negative balance
        if (newBalance < 0) {
          throw Exception('Insufficient wallet balance');
        }
        
        // Add delay between requests to avoid rate limiting (except for first attempt)
        if (attempt > 0) {
          final delay = baseDelay * (attempt + 1); // Exponential backoff
          print('⏳ Rate limit retry: waiting ${delay.inSeconds}s before attempt ${attempt + 1}');
          await Future.delayed(delay);
        }
        
        // Update with new calculated balance
        final QueryResult result = await _client.mutate(
          MutationOptions(
            document: gql(GraphQLQueries.updateWalletBalance),
            variables: {
              'userId': userId,
              'walletBalance': newBalance,
            },
            fetchPolicy: FetchPolicy.noCache, // Don't use cache for mutations
          ),
        );

        if (result.hasException) {
          final errorMessage = result.exception.toString().toLowerCase();
          
          // Check if it's a rate limit error
          if (errorMessage.contains('too many requests') || 
              errorMessage.contains('rate limit')) {
            if (attempt < maxRetries - 1) {
              print('⚠️ Rate limit hit on wallet deduction, will retry...');
              continue; // Retry
            } else {
              print('❌ Rate limit hit after $maxRetries attempts. Using current balance.');
              // Return current balance instead of failing
              return currentBalance;
            }
          }
          
          // For other errors, throw immediately
          throw Exception(result.exception.toString());
        }

        // Publish the update (with retry logic for rate limits)
        if (result.data != null && result.data!['updateUserDetail'] != null) {
          final updatedUser = result.data!['updateUserDetail'];
          final updatedUserId = updatedUser['id'];
          
          // Try to publish, but don't fail if rate limited
          try {
            await _publishUser(updatedUserId);
          } catch (publishError) {
            final publishErrorMsg = publishError.toString().toLowerCase();
            if (publishErrorMsg.contains('too many requests') || 
                publishErrorMsg.contains('rate limit')) {
              print('⚠️ Rate limit on publish, but balance updated successfully');
              // Balance was updated, just publishing failed - that's okay
            } else {
              print('⚠️ Publish failed (non-rate-limit): $publishError');
            }
          }
          
          return (updatedUser['walletBalance'] ?? 0).toDouble();
        }

        return null;
      } catch (e) {
        final errorMessage = e.toString().toLowerCase();
        
        // Check if it's a rate limit error
        if ((errorMessage.contains('too many requests') || 
             errorMessage.contains('rate limit')) && 
            attempt < maxRetries - 1) {
          print('⚠️ Rate limit error, retrying... (attempt ${attempt + 1}/$maxRetries)');
          continue; // Retry
        }
        
        // If it's the last attempt or not a rate limit error, throw
        if (attempt == maxRetries - 1) {
          throw Exception('Error deducting wallet balance after $maxRetries attempts: $e');
        }
        throw Exception('Error deducting wallet balance: $e');
      }
    }
    
    // Should never reach here, but just in case
    throw Exception('Error deducting wallet balance: Max retries exceeded');
  }

  // Publish user (required for Hygraph)
  Future<void> _publishUser(String userId) async {
    try {
      await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.publishUser),
          variables: {'id': userId},
        ),
      );
    } catch (e) {
      // Silently fail publish - balance is still updated
    }
  }
}

// Singleton instance
final userService = UserService();

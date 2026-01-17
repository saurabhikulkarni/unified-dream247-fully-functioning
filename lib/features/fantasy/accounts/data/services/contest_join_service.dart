import 'package:flutter/foundation.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/models/game_tokens_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/managers/game_tokens_cache.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/services/game_tokens_error_handler.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_urls.dart';

/// Contest Join Service
/// Handles game tokens debit when user joins a contest
class ContestJoinService {
  final ApiImplWithAccessToken _apiClient;
  final GameTokensCache _cache;

  ContestJoinService(this._apiClient, this._cache);

  /// Join a contest with entry fee debit
  /// Verifies balance → Calls backend debit → Updates cache
  Future<ContestJoinResponse> joinContest({
    required String contestId,
    required double entryFee,
    String? contestName,
    String? description,
  }) async {
    debugPrint(
      '🎮 [CONTEST_JOIN] Joining contest: $contestId, Entry fee: $entryFee tokens',
    );

    try {
      // Step 1: Verify sufficient balance locally (UX optimization)
      final cachedTokens = await _cache.getTokens();
      if (cachedTokens == null || cachedTokens.balance < entryFee) {
        throw ContestJoinException(
          'Insufficient game tokens',
          ContestJoinErrorCode.insufficientBalance,
        );
      }

      debugPrint('✅ [CONTEST_JOIN] Balance verified: ${cachedTokens.balance}');

      // Step 2: Call backend debit endpoint
      final response = await _debitTokensFromBackend(
        amount: entryFee,
        contestId: contestId,
        description: description ?? 'Contest entry',
      );

      if (!response['success']) {
        throw ContestJoinException(
          response['message'] ?? 'Failed to debit tokens',
          ContestJoinErrorCode.backendError,
        );
      }

      // Step 3: Parse backend response
      final newBalance = (response['data']?['balance'] ?? 0).toDouble();
      final transactionId = response['data']?['transaction_id'] as String? ?? '';

      debugPrint('✅ [CONTEST_JOIN] Tokens debited: $entryFee');
      debugPrint('   New balance: $newBalance');
      debugPrint('   Transaction ID: $transactionId');

      // Step 4: Update local cache with new balance
      await _updateCacheAfterDebit(
        newBalance: newBalance,
        entryFee: entryFee,
        transactionId: transactionId,
        contestId: contestId,
      );

      debugPrint('✅ [CONTEST_JOIN] Cache updated successfully');

      // Return success response
      return ContestJoinResponse(
        success: true,
        message: 'Successfully joined contest',
        newBalance: newBalance,
        transactionId: transactionId,
      );
    } on ContestJoinException {
      rethrow;
    } catch (e) {
      // Categorize error and log
      final tokenError = GameTokensErrorHandler.categorizeError(e);
      GameTokensErrorHandler.logError(tokenError, 'ContestJoinService.joinContest');
      
      debugPrint('❌ [CONTEST_JOIN] Error: ${tokenError.message}');
      throw ContestJoinException(
        tokenError.message,
        _mapTokenErrorToContestError(tokenError.type),
      );
    }
  }

  /// Call backend debit-tokens endpoint
  /// POST /user/debit-tokens
  Future<Map<String, dynamic>> _debitTokensFromBackend({
    required double amount,
    required String contestId,
    required String description,
  }) async {
    try {
      const url = 'debit-tokens'; // Relative path
      final fullUrl = '${APIServerUrl.userServerUrl}$url';

      debugPrint('🔄 [CONTEST_JOIN] Calling debit endpoint: $fullUrl');

      final body = {
        'amount': amount,
        'type': 'contest_join',
        'reference_id': contestId,
        'description': description,
      };

      debugPrint('   Request body: $body');

      final response = await _apiClient.post(fullUrl, body: body);
      final data = response.data;

      if (data is! Map<String, dynamic>) {
        debugPrint('❌ [CONTEST_JOIN] Invalid response format');
        return {
          'success': false,
          'message': 'Invalid response format from server',
        };
      }

      debugPrint('✅ [CONTEST_JOIN] Backend response received');
      return data;
    } catch (e) {
      debugPrint('❌ [CONTEST_JOIN] Backend call failed: $e');
      return {
        'success': false,
        'message': 'Failed to connect to server: $e',
      };
    }
  }

  /// Update local cache after successful debit
  Future<void> _updateCacheAfterDebit({
    required double newBalance,
    required double entryFee,
    required String transactionId,
    required String contestId,
  }) async {
    try {
      final oldTokens = await _cache.getTokens();
      if (oldTokens == null) {
        debugPrint('⚠️ [CONTEST_JOIN] No cached tokens found, creating new');
      }

      // Create debit transaction
      final transaction = Transaction(
        amount: entryFee,
        type: 'debit',
        description: 'Contest entry fee',
        transactionId: transactionId,
        createdAt: DateTime.now(),
        status: 'completed',
      );

      // Create updated tokens model
      final updatedTokens = GameTokens(
        balance: newBalance,
        transactions: [
          transaction,
          ...(oldTokens?.transactions ?? []),
        ],
        lastUpdated: DateTime.now(),
      );

      // Save to cache
      await _cache.saveTokens(updatedTokens);
      debugPrint('✅ [CONTEST_JOIN] Cache updated: new balance = $newBalance');
    } catch (e) {
      debugPrint('❌ [CONTEST_JOIN] Error updating cache: $e');
      rethrow;
    }
  }

  /// Verify if user has enough tokens without joining
  Future<bool> hasEnoughTokens(double requiredAmount) async {
    try {
      final tokens = await _cache.getTokens();
      if (tokens == null) {
        return false;
      }

      final hasEnough = tokens.balance >= requiredAmount;
      debugPrint(
        '[CONTEST_JOIN] Token verification: ${tokens.balance} >= $requiredAmount = $hasEnough',
      );
      return hasEnough;
    } catch (e) {
      debugPrint('❌ [CONTEST_JOIN] Error verifying tokens: $e');
      return false;
    }
  }

  /// Get current balance for UI display
  Future<double> getCurrentBalance() async {
    try {
      final tokens = await _cache.getTokens();
      return tokens?.balance ?? 0.0;
    } catch (e) {
      debugPrint('⚠️ [CONTEST_JOIN] Error getting balance: $e');
      return 0.0;
    }
  }

  /// Map TokenErrorType to ContestJoinErrorCode
  ContestJoinErrorCode _mapTokenErrorToContestError(TokenErrorType type) {
    switch (type) {
      case TokenErrorType.insufficientBalance:
        return ContestJoinErrorCode.insufficientBalance;
      case TokenErrorType.networkError:
        return ContestJoinErrorCode.networkError;
      case TokenErrorType.backendError:
        return ContestJoinErrorCode.backendError;
      case TokenErrorType.unauthorized:
        return ContestJoinErrorCode.unexpectedError;
      case TokenErrorType.unknown:
        return ContestJoinErrorCode.unexpectedError;
    }
  }
}

/// Response model for contest join
class ContestJoinResponse {
  final bool success;
  final String message;
  final double newBalance;
  final String transactionId;

  ContestJoinResponse({
    required this.success,
    required this.message,
    required this.newBalance,
    required this.transactionId,
  });

  @override
  String toString() => '''
ContestJoinResponse(
  success: $success,
  message: $message,
  newBalance: $newBalance,
  transactionId: $transactionId,
)''';
}

/// Error codes for contest join failures
enum ContestJoinErrorCode {
  insufficientBalance,
  backendError,
  networkError,
  cacheError,
  unexpectedError,
}

/// Custom exception for contest join errors
class ContestJoinException implements Exception {
  final String message;
  final ContestJoinErrorCode code;

  ContestJoinException(this.message, this.code);

  @override
  String toString() => 'ContestJoinException: $message (code: ${code.name})';

  /// Check if error is due to insufficient balance
  bool get isInsufficientBalance =>
      code == ContestJoinErrorCode.insufficientBalance;

  /// Check if error is network related
  bool get isNetworkError => code == ContestJoinErrorCode.networkError;
}

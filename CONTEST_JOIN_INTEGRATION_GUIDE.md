# Contest Join Integration Guide - Game Tokens Debit

## Overview
This guide shows how to integrate the `ContestJoinService` for handling game tokens debit when users join contests.

## Service Features

✅ **Local Balance Verification** - Check cached balance before backend call  
✅ **Backend Debit** - POST `/user/debit-tokens` endpoint  
✅ **Automatic Cache Update** - Updates game tokens cache with new balance  
✅ **Transaction Tracking** - Creates transaction record for audit  
✅ **Error Handling** - Specific error codes for different failure scenarios  

## Error Codes

```dart
enum ContestJoinErrorCode {
  insufficientBalance,      // User doesn't have enough tokens
  backendError,              // Server returned error
  networkError,              // Network/connectivity issue
  invalidResponse,           // Backend response couldn't be parsed
  unknown,                   // Unexpected error
}
```

## Integration Points

### 1. **In `join_contest_bottomsheet.dart`** (Current join flow)

Add the service to handle game tokens debit before/after calling existing `joinContest()`:

```dart
import 'package:get_it/get_it.dart';
import 'package:unified_dream247/features/fantasy/accounts/data/services/contest_join_service.dart';

// In _JoinContestBottomsheetState
final contestJoinService = getIt<ContestJoinService>();

void joinContest(BuildContext ctx) async {
  if (!mounted) return;
  setState(() => isJoining = true);

  try {
    // Step 1: Verify wallet (existing code - keep as is)
    final isVerified = Provider.of<WalletDetailsProvider>(
          context,
          listen: false,
        ).walletData?.allverify == 1;
    final isVerificationRequired =
        AppSingleton.singleton.appData.verificationOnJoinContest == true;

    if (isVerificationRequired && !isVerified) {
      if (isVerified == -1) {
        await accountsUsecases.myWalletDetails(context);
      } else {
        appToast(
          'Please complete your verification to join the contest',
          context,
        );
        AppNavigation.gotoVerifyDetailsScreen(context).then((_) {
          if (mounted) setState(() => isJoining = false);
        });
      }
      return;
    }

    // Step 2: Check cash balance for contest entry (keep existing)
    final hasSufficientBalance = (usableBalance ?? 0) >= (entryfee ?? 0);
    if (!hasSufficientBalance) {
      AppNavigation.gotoAddCashScreen(context);
      setState(() => isJoining = false);
      return;
    }

    // Step 3: [NEW] Check game tokens balance for debit on join
    final entryFeeAsDouble = (entryfee ?? 0).toDouble();
    final hasEnoughGameTokens = 
        await contestJoinService.hasEnoughTokens(entryFeeAsDouble);
    
    if (!hasEnoughGameTokens) {
      final currentBalance = contestJoinService.getCurrentBalance();
      appToast(
        'Insufficient game tokens! Need: ₹${entryFeeAsDouble.toStringAsFixed(2)}, Have: ₹${currentBalance.toStringAsFixed(2)}',
        context,
      );
      AppNavigation.gotoAddCashScreen(context);
      setState(() => isJoining = false);
      return;
    }

    // Step 4: Join contest with existing flow
    await handleContestJoin(ctx);

  } catch (e) {
    printX('Error in join contest: $e');
    appToast('Something went wrong. Please try again.', context);
  } finally {
    if (mounted) setState(() => isJoining = false);
  }
}

Future<void> handleContestJoin(BuildContext context) async {
  try {
    final Map<String, dynamic>? data;
    if (widget.fantasyType == 'Cricket') {
      if (widget.isClosedContestNew == true) {
        data = await upcomingMatchUsecase.closedContestJoin(
          context,
          (entryfee ?? 0).toInt(),
          int.parse(widget.winAmount ?? '0'),
          int.parse(widget.maximumUser ?? '1'),
          widget.discount.toString(),
          widget.selectedTeam,
        );
      } else {
        data = await upcomingMatchUsecase.joinContest(
          context,
          widget.challengeId,
          widget.discount ?? 0,
          widget.selectedTeam,
        );
      }
    } else {
      return;
    }

    if (data != null && data['success'] == true) {
      // Step 5: [NEW] Debit game tokens after successful contest join
      try {
        final entryFeeAsDouble = (entryfee ?? 0).toDouble();
        final response = await contestJoinService.joinContest(
          contestId: widget.challengeId,
          entryFee: entryFeeAsDouble,
        );
        
        // Show success with new balance
        appToast(
          '✅ Joined! New balance: ₹${response.newBalance.toStringAsFixed(2)}',
          context,
        );
        debugPrint('Contest joined successfully. Transaction: ${response.transactionId}');
      } on ContestJoinException catch (e) {
        // Tokens debit failed - but contest join succeeded
        if (e.isInsufficientBalance) {
          appToast('⚠️ Contest joined, but insufficient game tokens for debit', context);
        } else {
          appToast('⚠️ Contest joined, but game tokens debit failed: ${e.message}', context);
        }
        debugPrint('Game tokens debit failed: ${e.message}');
      }

      // Proceed with existing flow
      if (data['data']?['is_private'] == 1) {
        sharePrivateContest(data['data']['referCode']);
      } else if (data['success'] == false && data['is_closed'] == true) {
        showContestFilledSheet(context, data);
      } else {
        widget.removePage();
        Navigator.of(context).pop();
        if (widget.fantasyType == 'H2H') Navigator.of(context).pop();
      }
    } else {
      widget.removePage();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  } catch (e) {
    printX('Error joining contest: $e');
  }
}
```

### 2. **Alternative: Create a Dedicated Method for Game Tokens Debit**

If you prefer a cleaner approach, create a separate method:

```dart
Future<bool> debitGameTokensForContest({
  required String contestId,
  required double entryFee,
}) async {
  try {
    final response = await contestJoinService.joinContest(
      contestId: contestId,
      entryFee: entryFee,
    );
    
    appToast(
      '✅ Entry confirmed! New balance: ₹${response.newBalance.toStringAsFixed(2)}',
      context,
    );
    return true;
  } on ContestJoinException catch (e) {
    if (e.isInsufficientBalance) {
      appToast('❌ Insufficient game tokens', context);
    } else {
      appToast('❌ Failed to debit tokens: ${e.message}', context);
    }
    return false;
  }
}
```

## Usage Pattern

### Pattern 1: Check Balance First

```dart
// Before showing contest details
final canJoin = await contestJoinService.hasEnoughTokens(50.0);
if (!canJoin) {
  showDialog('Need 50 tokens but you have ${contestJoinService.getCurrentBalance()}');
}
```

### Pattern 2: Try to Join

```dart
// On join button tap
try {
  final response = await contestJoinService.joinContest(
    contestId: contest.id,
    entryFee: contest.entryFee,
  );
  print('✅ Joined! New balance: ${response.newBalance}');
} on ContestJoinException catch (e) {
  print('❌ Error: ${e.message}');
}
```

### Pattern 3: Get Current Balance

```dart
// Display user balance
final currentBalance = contestJoinService.getCurrentBalance();
print('Current tokens: ₹$currentBalance');
```

## Response Model

```dart
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
}
```

## Exception Handling

```dart
try {
  final response = await contestJoinService.joinContest(
    contestId: 'contest123',
    entryFee: 50.0,
  );
} on ContestJoinException catch (e) {
  // Check specific error code
  if (e.errorCode == ContestJoinErrorCode.insufficientBalance) {
    // Handle insufficient balance
    showAddMoneyScreen();
  } else if (e.errorCode == ContestJoinErrorCode.networkError) {
    // Handle network error
    retryJoinContest();
  } else {
    // Handle other errors
    showErrorDialog(e.message);
  }
}
```

## Backend Endpoint Requirements

The service calls: `POST /user/debit-tokens`

**Request Body:**
```json
{
  "amount": 50.0,
  "type": "contest_join",
  "reference_id": "contest123",
  "description": "Entry fee for contest xyz"
}
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "balance": 450.0,
    "transaction_id": "txn_123456",
    "timestamp": "2026-01-17T10:30:00Z"
  }
}
```

## Next Steps

1. ✅ Service created and registered in DI
2. ⏳ Integrate into `join_contest_bottomsheet.dart`
3. ⏳ Test balance verification flow
4. ⏳ Test backend debit call
5. ⏳ Test cache update after debit
6. ⏳ Test error scenarios

## Cache Behavior

- Cache expires after 5 minutes
- Cache auto-updates after successful debit
- Cache includes transaction history
- Cache can be manually refreshed via `GameTokensService.refreshGameTokens()`

## Debugging

Enable logging in `contest_join_service.dart` to debug flow:

```dart
// All steps are logged with debugPrint:
// - Balance check
// - Backend call details
// - Cache update
// - Error details
```

Check debug console output for the complete flow.

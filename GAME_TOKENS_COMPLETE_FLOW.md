# Complete Game Tokens Flow - Implementation & Testing Guide

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│  GAME TOKENS UNIFIED SYSTEM                                │
├─────────────────────────────────────────────────────────────┤
│  Services Layer:                                            │
│  • GameTokensService (fetch/cache on startup)              │
│  • ContestJoinService (debit on contest join)              │
│  • GameTokensErrorHandler (error categorization)           │
│                                                             │
│  Cache Layer:                                              │
│  • GameTokensCache (5-minute expiry)                       │
│  • SharedPreferences (persistence)                         │
│                                                             │
│  UI Layer:                                                 │
│  • MyBalancePage (display balance)                         │
│  • AddMoneyPage (Razorpay topup)                           │
│  • JoinContestBottomsheet (debit on join)                  │
└─────────────────────────────────────────────────────────────┘
```

---

## FLOW 1: APP STARTUP

### Sequence Diagram
```
App Initialization
  ↓
main.dart
  └─→ GameTokensService.fetchGameTokensOnStartup()
       ├─→ Call: GET /user/wallet-details
       ├─→ Response: {success: true, data: {balance: 1000.0}}
       ├─→ Create: GameTokens(balance: 1000.0, transactions: [])
       ├─→ Cache: Save to GameTokensCache
       ├─→ Log: "✅ Tokens synced from backend: 1000.0"
       └─→ Return: GameTokens instance
  ↓
MyBalancePage Loaded
  └─→ Display: "₹1000.0" in wallet
```

### Code Implementation

**main.dart** - App Initialization
```dart
void main() async {
  // ... other initialization
  
  // Fetch game tokens on startup
  final gameTokensService = getIt<GameTokensService>();
  await gameTokensService.fetchGameTokensOnStartup();
  
  runApp(const MyApp());
}
```

**game_tokens_service.dart** - Startup Fetch
```dart
Future<GameTokens?> fetchGameTokensOnStartup() async {
  debugPrint('🔄 [GAME_TOKENS_SERVICE] Fetching on startup...');
  
  try {
    // Priority 1: Backend
    final tokens = await _fetchFromBackend();
    if (tokens != null) {
      await _cache.saveTokens(tokens);
      return tokens;
    }
  } catch (e) {
    final tokenError = GameTokensErrorHandler.categorizeError(e);
    debugPrint('❌ Backend failed: ${tokenError.message}');
  }
  
  // Fallback: Cache
  try {
    final cached = await _cache.getTokens();
    if (cached != null) {
      debugPrint('⚠️ Using cached tokens: ${cached.balance}');
      return cached;
    }
  } catch (e) {
    debugPrint('❌ Cache fallback failed');
  }
  
  // Fallback: Empty
  return null;
}
```

### Testing Checklist
- [ ] App starts and GameTokensService is registered in GetIt
- [ ] Backend call succeeds → Balance displayed
- [ ] Backend call fails → Cache is used
- [ ] Cache empty → Graceful fallback to 0.0 balance
- [ ] Check console logs for correct flow

---

## FLOW 2: RAZORPAY TOPUP (Add Money)

### Sequence Diagram
```
User Opens Add Money Screen
  ↓
Show Razorpay Payment Gateway
  ↓
User Completes Payment
  ├─→ Payment ID: pay_xyz123
  └─→ Signature verified
  ↓
_handlePaymentSuccess() Called
  ├─→ Call: GET /user/wallet-details (fetch fresh)
  │   └─→ Response: {balance: 1500.0} (500 added)
  ├─→ Update Cache: GameTokensCache.saveTokens(new balance)
  ├─→ Update SharedPreferences: Direct update
  ├─→ Update UI: setState() with new balance
  └─→ Show Toast: "✅ ₹500 added to game tokens"
  ↓
MyBalancePage Updated
  └─→ Display: "₹1500.0"
```

### Code Implementation

**add_money_page.dart** - Razorpay Success Handler
```dart
Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
  try {
    // Step 1: Verify payment (existing code)
    final paymentVerified = await verifyRazorpayPayment(response.paymentId);
    
    if (!paymentVerified) {
      appToast('Payment verification failed', context);
      return;
    }
    
    // Step 2: Fetch fresh game tokens from backend
    final response = await accountsUsecases.fetchGameTokensAfterPayment(context);
    
    if (response != null && response['success']) {
      final newBalance = response['data']['balance'].toDouble();
      
      // Step 3: Update cache
      await gameTokensCache.saveTokens(
        GameTokens(balance: newBalance, transactions: [], lastUpdated: DateTime.now())
      );
      
      // Step 4: Update SharedPreferences
      await _updateSharedPreferencesBalance(newBalance);
      
      // Step 5: Refresh UI
      setState(() {
        _currentBalance = newBalance;
      });
      
      // Step 6: Show success
      appToast('✅ ₹${amount} added to game tokens', context);
      
      // Navigate back
      Navigator.pop(context);
    }
  } catch (e) {
    final tokenError = GameTokensErrorHandler.categorizeError(e);
    appToast('Error: ${tokenError.message}', context);
  }
}
```

### Testing Checklist
- [ ] Initiate Razorpay payment in test environment
- [ ] Complete mock payment
- [ ] Backend call triggered after payment
- [ ] Balance updated in UI
- [ ] Cache updated with new balance
- [ ] SharedPreferences has new value
- [ ] Toast shows success message
- [ ] Can see new balance in MyBalancePage

---

## FLOW 3: CONTEST JOIN (Game Tokens Debit)

### Sequence Diagram
```
User Opens Contest & Clicks "Join"
  ↓
JoinContestBottomsheet.joinContest() Called
  ├─→ Step 1: Verify wallet (existing check)
  ├─→ Step 2: Check cash balance (existing check)
  └─→ Step 3: Check game tokens balance (NEW)
       ├─→ Call: gameTokensCache.getTokens()
       ├─→ Check: cached.balance >= entryFee
       └─→ If insufficient: Show error + Go to Topup
  ↓
User Has Sufficient Tokens
  ↓
handleContestJoin() Called
  ├─→ Call existing backend: joinContest()
  │   └─→ POST /contest-join
  └─→ Response: {success: true, data: {...}}
  ↓
Game Tokens Debit (NEW)
  ├─→ Call: ContestJoinService.joinContest()
  │   ├─→ POST /user/debit-tokens
  │   ├─→ {amount: 50, type: "contest_join", reference_id: "contest123"}
  │   └─→ Response: {success: true, data: {balance: 950, transaction_id: "txn_123"}}
  ├─→ Create Transaction: {amount: 50, type: "debit", timestamp: now}
  ├─→ Update Cache: new balance + transaction
  └─→ Log: "Transaction ID: txn_123"
  ↓
Success
  ├─→ Close bottomsheet
  ├─→ Navigate to contest
  └─→ MyBalancePage shows new balance: ₹950
```

### Code Implementation

**join_contest_bottomsheet.dart** - Game Tokens Check & Debit
```dart
void joinContest(BuildContext ctx) async {
  if (!mounted) return;
  setState(() => isJoining = true);

  try {
    // Step 1 & 2: Existing verification (wallet, cash balance)
    final isVerified = /* existing check */;
    final hasSufficientBalance = /* existing check */;
    
    // Step 3: NEW - Check game tokens balance
    final entryFeeAsDouble = (entryfee ?? 0).toDouble();
    final hasEnoughGameTokens = 
        await _contestJoinService.hasEnoughTokens(entryFeeAsDouble);
    
    if (!hasEnoughGameTokens) {
      final currentBalance = _contestJoinService.getCurrentBalance();
      appToast(
        'Insufficient game tokens! Need: ₹${entryFeeAsDouble}, Have: ₹${currentBalance}',
        context,
      );
      AppNavigation.gotoAddCashScreen(context);
      return;
    }

    // Proceed with contest join
    await handleContestJoin(ctx);
    
  } finally {
    if (mounted) setState(() => isJoining = false);
  }
}

Future<void> handleContestJoin(BuildContext context) async {
  try {
    // Call existing backend: joinContest()
    final Map<String, dynamic>? data = await upcomingMatchUsecase.joinContest(
      context,
      widget.challengeId,
      widget.discount ?? 0,
      widget.selectedTeam,
    );

    if (data != null && data['success'] == true) {
      // NEW: Debit game tokens after successful contest join
      try {
        final entryFeeAsDouble = (entryfee ?? 0).toDouble();
        final response = await _contestJoinService.joinContest(
          contestId: widget.challengeId,
          entryFee: entryFeeAsDouble,
        );
        
        printX('✅ Tokens debited. Transaction: ${response.transactionId}');
      } on ContestJoinException catch (e) {
        // Non-fatal: Contest joined, but tokens debit failed
        if (e.isInsufficientBalance) {
          appToast('⚠️ Contest joined, but insufficient tokens for debit', context);
        } else {
          printX('⚠️ Tokens debit failed (non-blocking): ${e.message}');
        }
      }

      // Continue with existing flow
      if (data['data']?['is_private'] == 1) {
        sharePrivateContest(data['data']['referCode']);
      } else {
        widget.removePage();
        Navigator.of(context).pop();
      }
    }
  } catch (e) {
    printX('❌ Error joining contest: $e');
  }
}
```

**contest_join_service.dart** - Debit Logic
```dart
Future<ContestJoinResponse> joinContest({
  required String contestId,
  required double entryFee,
}) async {
  debugPrint('🎮 [CONTEST_JOIN] Joining contest: $contestId, Fee: $entryFee');

  try {
    // Verify balance locally first
    final cachedTokens = await _cache.getTokens();
    if (cachedTokens == null || cachedTokens.balance < entryFee) {
      throw ContestJoinException(
        'Insufficient tokens',
        ContestJoinErrorCode.insufficientBalance,
      );
    }

    // Call backend debit
    final response = await _debitTokensFromBackend(
      amount: entryFee,
      contestId: contestId,
    );

    // Parse response
    final newBalance = response['data']['balance'].toDouble();
    final transactionId = response['data']['transaction_id'];

    // Update cache with transaction
    await _cache.addTransaction(
      Transaction(
        amount: entryFee,
        type: 'debit',
        timestamp: DateTime.now(),
        description: 'Contest entry',
        transactionId: transactionId,
      ),
    );

    // Update balance in cache
    await _cache.updateBalance(newBalance);

    debugPrint('✅ [CONTEST_JOIN] Successfully debited $entryFee tokens');

    return ContestJoinResponse(
      success: true,
      message: 'Successfully joined',
      newBalance: newBalance,
      transactionId: transactionId,
    );
  } on ContestJoinException {
    rethrow;
  } catch (e) {
    final tokenError = GameTokensErrorHandler.categorizeError(e);
    GameTokensErrorHandler.logError(tokenError, 'ContestJoinService.joinContest');
    
    throw ContestJoinException(
      tokenError.message,
      _mapTokenErrorToContestError(tokenError.type),
    );
  }
}
```

### Testing Checklist
- [ ] User has sufficient game tokens
- [ ] Game tokens balance check passes
- [ ] Backend debit call succeeds
- [ ] Cache updated with new balance
- [ ] Transaction recorded in cache
- [ ] Transaction ID returned and logged
- [ ] User can see new balance in MyBalancePage
- [ ] User has insufficient game tokens
- [ ] Shows error message with balance needed
- [ ] Redirects to Add Money screen

---

## FLOW 4: ERROR SCENARIOS

### 4.1 Network Error

**Scenario:** No internet connection during app startup
```
GameTokensService.fetchGameTokensOnStartup()
  ├─→ Attempt: GET /user/wallet-details
  ├─→ Error: SocketException (no internet)
  ├─→ Categorize: GameTokensErrorHandler.categorizeError()
  │   └─→ Type: TokenErrorType.networkError
  │   └─→ Message: "No internet connection. Using cached data."
  ├─→ Fallback: Use cache if available
  └─→ Display: Last known balance (cached)
```

**Code:**
```dart
// In GameTokensErrorHandler
if (error is SocketException) {
  return TokenError(
    type: TokenErrorType.networkError,
    message: 'No internet connection. Using cached data.',
    originalError: error,
  );
}
```

**Testing:**
- [ ] Disable internet/WiFi
- [ ] Start app → Should use cached balance
- [ ] Enable internet → Should sync fresh balance on next refresh
- [ ] UI shows cached balance with warning

### 4.2 Insufficient Game Tokens

**Scenario:** User tries to join contest but has insufficient tokens
```
JoinContestBottomsheet.joinContest()
  ├─→ Check: cache.balance (₹30) < entryFee (₹50)
  ├─→ Error: Insufficient balance
  ├─→ Show: "Insufficient game tokens! Need: ₹50, Have: ₹30"
  └─→ Navigate: gotoAddCashScreen()
```

**Code:**
```dart
final hasEnoughGameTokens = await _contestJoinService.hasEnoughTokens(50.0);
if (!hasEnoughGameTokens) {
  appToast('Insufficient game tokens! Need: ₹50, Have: ₹30', context);
  AppNavigation.gotoAddCashScreen(context);
  return;
}
```

**Testing:**
- [ ] Set cache balance to ₹30
- [ ] Try to join contest with ₹50 entry fee
- [ ] See error message with exact amounts
- [ ] Redirected to Add Money screen

### 4.3 Backend Error

**Scenario:** Server returns 500 error on debit attempt
```
ContestJoinService.joinContest()
  ├─→ Call: POST /user/debit-tokens
  ├─→ Response: 500 Internal Server Error
  ├─→ Categorize: TokenErrorType.backendError
  ├─→ Message: "Backend error. Please try again later."
  ├─→ Handle: Non-blocking (contest join already succeeded)
  └─→ Show: "⚠️ Contest joined, but tokens debit failed"
```

**Code:**
```dart
if (error.response?.statusCode == 500) {
  return TokenError(
    type: TokenErrorType.backendError,
    message: 'Backend error. Please try again later.',
    originalError: error,
  );
}
```

**Testing:**
- [ ] Mock backend to return 500 on debit call
- [ ] Contest join succeeds, debit fails
- [ ] Show warning but allow contest to proceed
- [ ] User not charged tokens
- [ ] Can retry debit later

### 4.4 Session Expired

**Scenario:** User's authentication token expires
```
GameTokensService._fetchFromBackend()
  ├─→ Call: GET /user/wallet-details
  ├─→ Response: 401 Unauthorized
  ├─→ Categorize: TokenErrorType.unauthorized
  ├─→ Message: "Session expired. Please login again."
  ├─→ Action: Clear cache
  └─→ Redirect: Login screen
```

**Code:**
```dart
if (error.response?.statusCode == 401) {
  return TokenError(
    type: TokenErrorType.unauthorized,
    message: 'Session expired. Please login again.',
    originalError: error,
  );
}
```

**Testing:**
- [ ] Mock 401 response
- [ ] App detects session expired
- [ ] Cache cleared
- [ ] User redirected to login
- [ ] After re-login, tokens fetched again

### 4.5 Timeout Error

**Scenario:** Network timeout while fetching tokens
```
GameTokensService._fetchFromBackend()
  ├─→ Call: GET /user/wallet-details
  ├─→ Error: TimeoutException
  ├─→ Categorize: TokenErrorType.networkError
  ├─→ Fallback: Use cache
  ├─→ UI: Show "Using cached data" indicator
  └─→ Offer: Manual retry button
```

**Code:**
```dart
if (error is TimeoutException) {
  return TokenError(
    type: TokenErrorType.networkError,
    message: 'Network timeout. Please check your connection.',
    originalError: error,
  );
}
```

**Testing:**
- [ ] Simulate network timeout
- [ ] App uses cache gracefully
- [ ] Shows cache indicator
- [ ] Provides retry option
- [ ] Retry succeeds when network recovers

---

## Integration Testing Guide

### Test Case 1: Full Happy Path
```
1. Launch app
   ✓ GameTokensService fetches balance: ₹1000
   ✓ MyBalancePage shows: ₹1000

2. User topups ₹500
   ✓ Razorpay payment succeeds
   ✓ Balance updated: ₹1500
   ✓ Cache updated
   ✓ Toast shows: "✅ ₹500 added"

3. User joins contest (₹50 entry)
   ✓ Game tokens check passes
   ✓ Contest join succeeds
   ✓ Tokens debited: ₹1450
   ✓ Transaction logged
   ✓ MyBalancePage shows: ₹1450

4. User joins another contest (₹50 entry)
   ✓ Balance check passes (still ₹1450)
   ✓ Contest join succeeds
   ✓ Tokens debited: ₹1400
   ✓ MyBalancePage shows: ₹1400
```

### Test Case 2: Offline to Online
```
1. Disable internet
   ✓ App starts with cached balance: ₹1000

2. Try to topup
   ✓ Network error shown
   ✓ Cache indicator visible

3. Enable internet
   ✓ Refresh button works
   ✓ Syncs fresh balance from backend: ₹1000

4. Topup succeeds
   ✓ New balance: ₹1500
```

### Test Case 3: Insufficient Balance
```
1. Cache balance: ₹30

2. Try to join contest (₹50 entry)
   ✓ Error: "Insufficient game tokens! Need: ₹50, Have: ₹30"
   ✓ Cannot proceed to contest
   ✓ Redirected to Add Money

3. User topups ₹100
   ✓ New balance: ₹130
   ✓ Back to contest list
   ✓ Now can join (sufficient balance)
```

### Test Case 4: Backend Debit Failure
```
1. User joins contest (₹50 entry)
   ✓ Contest join succeeds
   ✓ Backend returns 500 on debit

2. UI shows: "⚠️ Contest joined, but tokens debit failed"
   ✓ Contest ID saved (user is in contest)
   ✓ Tokens not charged to user
   ✓ Can retry debit later

3. Retry debit
   ✓ Succeeds
   ✓ Tokens deducted: ₹50
```

---

## Cache Behavior

### Cache Validation
```
User opens MyBalancePage
  ├─→ Check: Is cache valid? (created < 5 minutes ago)
  ├─→ If valid: Use cached balance (fast)
  ├─→ If invalid: Fetch fresh from backend
  └─→ Update cache with new balance
```

### Cache Update Triggers
```
1. Contest Join Success
   └─→ Automatically update cache with new balance

2. Razorpay Topup Success
   └─→ Fetch fresh balance + update cache

3. App Startup
   └─→ Fetch from backend + cache

4. Manual Refresh
   └─→ Clear cache + fetch fresh
```

### Cache Fallback
```
If Backend Error:
  ├─→ Use cached data if available
  ├─→ Show warning: "Using cached data"
  └─→ Offer retry option

If Cache Also Fails:
  ├─→ Return default: balance = 0.0
  └─→ Show: "Unable to load balance"
```

---

## Debugging Checklist

### Enable Logging
```dart
// All logs start with [GAME_TOKENS_SERVICE], [CONTEST_JOIN], etc.
// Search console for:
// ✅ Success logs
// ❌ Error logs
// ⚠️ Warning/fallback logs
// 🔄 Network calls
```

### Check SharedPreferences
```dart
// View cached tokens:
// Key: "game_tokens_cache"
// Value: {balance: 1000.0, transactions: [...], lastUpdated: ...}
```

### Monitor Cache Expiry
```dart
// Cache expires after 5 minutes
// Check: DateTime.now().difference(lastUpdated) > Duration(minutes: 5)
```

### Verify Error Categorization
```
Network Error:
  └─→ Type: TokenErrorType.networkError
  └─→ Action: Use cache

Backend Error:
  └─→ Type: TokenErrorType.backendError
  └─→ Action: Show retry

Insufficient Balance:
  └─→ Type: TokenErrorType.insufficientBalance
  └─→ Action: Redirect to topup
```

---

## Summary: Key Components

| Component | File | Purpose |
|-----------|------|---------|
| **GameTokensService** | `game_tokens_service.dart` | Fetch/cache on startup, refresh |
| **GameTokensCache** | `game_tokens_cache.dart` | Local persistence with 5-min expiry |
| **ContestJoinService** | `contest_join_service.dart` | Debit tokens on contest join |
| **GameTokensErrorHandler** | `game_tokens_error_handler.dart` | Error categorization & user messages |
| **MyBalancePage** | `my_balance_page.dart` | Display balance, refresh option |
| **AddMoneyPage** | `add_money_page.dart` | Razorpay topup, sync tokens |
| **JoinContestBottomsheet** | `join_contest_bottomsheet.dart` | Check balance, debit on join |

---

## Related Documentation

- `CONTEST_JOIN_INTEGRATION_GUIDE.md` - Detailed contest join flow
- `UNIFIED_WALLET_IMPLEMENTATION.md` - Wallet architecture
- `AUTHENTICATION_IMPLEMENTATION.md` - Auth flow

# Game Tokens System - Developer Quick Reference

## 🚀 Quick Start

### Services Registration (GetIt)
```dart
// Already registered in injection_container.dart:
getIt.registerLazySingleton(() => GameTokensCache());
getIt.registerLazySingleton(() => GameTokensService(...));
getIt.registerLazySingleton(() => ContestJoinService(...));
```

### Using in Code
```dart
// Get service
final gameTokensService = getIt<GameTokensService>();
final contestJoinService = getIt<ContestJoinService>();

// Check balance
final balance = await gameTokensService.getGameTokens();
print('Balance: ${balance.balance}');

// Join contest with debit
try {
  final response = await contestJoinService.joinContest(
    contestId: 'contest123',
    entryFee: 50.0,
  );
  print('✅ Joined! New balance: ${response.newBalance}');
} on ContestJoinException catch (e) {
  print('❌ Error: ${e.message}');
}
```

---

## 🔄 Complete Request/Response Flows

### Flow 1: Fetch Game Tokens (Startup/Refresh)
**Request:**
```
GET /user/wallet-details
Headers: Authorization: Bearer {token}
```

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "balance": 1000.0,
    "userId": "user123"
  }
}
```

**Response Failure (500):**
```json
{
  "success": false,
  "message": "Backend error"
}
```

**Dart Handling:**
```dart
// In game_tokens_service.dart
try {
  final response = await _apiClient.get(url);
  final balance = (response.data['data']['balance'] ?? 0).toDouble();
  final tokens = GameTokens(balance: balance, transactions: [], lastUpdated: DateTime.now());
  await _cache.saveTokens(tokens);
  return tokens;
} catch (e) {
  final error = GameTokensErrorHandler.categorizeError(e);
  // Use cache fallback
  return await _cache.getTokens();
}
```

---

### Flow 2: Debit Tokens (Contest Join)
**Request:**
```
POST /user/debit-tokens
Headers: Authorization: Bearer {token}
Body:
{
  "amount": 50.0,
  "type": "contest_join",
  "reference_id": "contest123",
  "description": "Entry fee for cricket contest"
}
```

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "balance": 950.0,
    "transaction_id": "txn_xyz123",
    "timestamp": "2026-01-17T10:30:00Z"
  }
}
```

**Response Failure - Insufficient Balance (400):**
```json
{
  "success": false,
  "message": "Insufficient game tokens"
}
```

**Dart Handling:**
```dart
// In contest_join_service.dart
try {
  final response = await _debitTokensFromBackend(
    amount: entryFee,
    contestId: contestId,
  );
  
  if (!response['success']) {
    throw ContestJoinException(
      response['message'],
      ContestJoinErrorCode.backendError,
    );
  }
  
  final newBalance = response['data']['balance'].toDouble();
  await _cache.updateBalance(newBalance);
  await _cache.addTransaction(Transaction(...));
  
  return ContestJoinResponse(
    success: true,
    newBalance: newBalance,
    transactionId: response['data']['transaction_id'],
  );
} on ContestJoinException {
  rethrow;
} catch (e) {
  final tokenError = GameTokensErrorHandler.categorizeError(e);
  throw ContestJoinException(tokenError.message, ...);
}
```

---

### Flow 3: Razorpay Topup Success
**Event:** PaymentSuccessResponse received
**Handler:** `_handlePaymentSuccess(PaymentSuccessResponse response)`

**Steps:**
```dart
1. Verify Razorpay signature
   └─→ POST /verify-razorpay-payment

2. Fetch updated balance
   └─→ GET /user/wallet-details
   └─→ Returns: {balance: 1500.0} (500 added)

3. Update local cache
   └─→ gameTokensCache.saveTokens(new GameTokens(...))

4. Update SharedPreferences
   └─→ Direct wallet balance update

5. Refresh UI
   └─→ setState(() { _balance = newBalance; })

6. Show success
   └─→ appToast('✅ ₹500 added to game tokens')
```

---

## ⚠️ Error Handling Reference

### Error Types
```dart
enum TokenErrorType {
  insufficientBalance,  // User lacks tokens
  networkError,         // No internet/timeout
  backendError,         // Server 5xx error
  unauthorized,         // Session expired (401)
  unknown              // Other errors
}
```

### Error Mapping
```
Exception Type → TokenErrorType → User Message → Action
─────────────────────────────────────────────────────────
SocketException → networkError → "No internet" → Use cache
TimeoutException → networkError → "Timeout" → Show retry
DioException 401 → unauthorized → "Login again" → Redirect
DioException 400 → insufficientBalance → "Need more tokens" → Topup
DioException 500 → backendError → "Try later" → Retry
Other → unknown → "Error occurred" → Show error
```

### Usage
```dart
try {
  // Backend call
} catch (e) {
  final error = GameTokensErrorHandler.categorizeError(e);
  final message = GameTokensErrorHandler.getUserMessage(error);
  
  if (error.type == TokenErrorType.insufficientBalance) {
    gotoTopupScreen();
  } else if (error.type == TokenErrorType.networkError) {
    showRetryButton();
  } else if (error.type == TokenErrorType.unauthorized) {
    gotoLoginScreen();
  }
}
```

---

## 📊 Cache Management

### Cache Key
```
"game_tokens_cache"
```

### Cache Structure
```dart
GameTokens {
  balance: 1000.0,
  transactions: [
    Transaction(amount: 50, type: "debit", timestamp: ..., transactionId: "txn_123"),
    Transaction(amount: 500, type: "credit", timestamp: ..., transactionId: "pay_456"),
  ],
  lastUpdated: 2026-01-17 10:30:00
}
```

### Cache Expiry
```dart
// Cache valid for 5 minutes
Duration cacheExpiry = Duration(minutes: 5);

// Check if valid
bool isValid = DateTime.now().difference(lastUpdated) < cacheExpiry;
```

### Cache Operations
```dart
// Save
await cache.saveTokens(gameTokens);

// Get
final tokens = await cache.getTokens();

// Check if valid
final isValid = await cache.isCacheValid();

// Add transaction
await cache.addTransaction(transaction);

// Update balance
await cache.updateBalance(newBalance);

// Clear
await cache.clearCache();
```

---

## 🎯 Common Patterns

### Pattern 1: Check Balance Before Action
```dart
final hasEnough = await contestJoinService.hasEnoughTokens(50.0);
if (!hasEnough) {
  appToast('Insufficient tokens', context);
  return;
}
```

### Pattern 2: Perform Action with Error Handling
```dart
try {
  final response = await contestJoinService.joinContest(
    contestId: contest.id,
    entryFee: contest.entryFee,
  );
  appToast('✅ Joined! Balance: ${response.newBalance}', context);
} on ContestJoinException catch (e) {
  if (e.isInsufficientBalance) {
    gotoTopup();
  } else {
    appToast('❌ Error: ${e.message}', context);
  }
}
```

### Pattern 3: Get Balance for Display
```dart
final gameTokens = await gameTokensService.getGameTokens();
setState(() {
  _balance = gameTokens.balance;
});
```

### Pattern 4: Refresh on Screen Open
```dart
@override
void initState() {
  super.initState();
  _refreshBalance();
}

Future<void> _refreshBalance() async {
  final tokens = await gameTokensService.refreshGameTokens();
  if (tokens != null) {
    setState(() => _balance = tokens.balance);
  }
}
```

---

## 🧪 Testing Scenarios

### Test 1: Happy Path
```
1. App starts
2. Balance fetched & cached
3. User topups ₹500
4. Balance updated
5. User joins contest (₹50)
6. Tokens debited
7. New balance shown
```

### Test 2: No Internet
```
1. Disable internet
2. App starts
3. Backend call fails
4. Cache used
5. Show cached balance
6. Enable internet
7. Refresh works
```

### Test 3: Insufficient Balance
```
1. Cache balance: ₹30
2. Try join contest (₹50)
3. Error shown
4. Topup ₹100
5. Retry join
6. Success
```

### Test 4: Backend Error
```
1. Contest join succeeds
2. Debit call returns 500
3. User NOT charged
4. Show warning
5. Retry debit later
```

---

## 📝 Logging

### Key Log Points
```dart
// Startup
🔄 [GAME_TOKENS_SERVICE] Fetching on startup...
✅ [GAME_TOKENS_SERVICE] Tokens synced: 1000.0
⚠️ [GAME_TOKENS_SERVICE] Using cached tokens

// Contest join
🎮 [CONTEST_JOIN] Joining contest: contest123, Fee: 50.0
✅ [CONTEST_JOIN] Balance verified: 1000.0
✅ [CONTEST_JOIN] Tokens debited, new balance: 950.0

// Errors
❌ [GAME_TOKENS_SERVICE] Backend failed: No internet
⚠️ [CONTEST_JOIN] Insufficient balance: Need 50, Have 30
```

### Debug Tips
```dart
// Search logs for:
// ✅ Success flows
// ❌ Error flows
// ⚠️ Fallback flows
// 🔄 Network calls

// Common issues:
// - Token not found in cache → Check key: "game_tokens_cache"
// - Balance not updating → Check: _cache.updateBalance() called
// - UI not refreshing → Check: setState() called
// - Backend error → Check: Error response format
```

---

## 🔗 Related Files

| File | Purpose |
|------|---------|
| `lib/core/di/injection_container.dart` | Service registration |
| `lib/features/fantasy/accounts/data/services/game_tokens_service.dart` | Fetch/cache service |
| `lib/features/fantasy/accounts/data/services/game_tokens_error_handler.dart` | Error handling |
| `lib/features/fantasy/accounts/data/services/contest_join_service.dart` | Debit service |
| `lib/features/fantasy/accounts/data/managers/game_tokens_cache.dart` | Cache manager |
| `lib/features/fantasy/accounts/data/models/game_tokens_model.dart` | Data models |
| `lib/features/fantasy/accounts/presentation/screens/my_balance_page.dart` | Display balance |
| `lib/features/fantasy/accounts/presentation/screens/add_money_page.dart` | Razorpay topup |
| `lib/features/fantasy/upcoming_matches/presentation/widgets/join_contest_bottomsheet.dart` | Contest join UI |

---

## 📚 Documentation

- `GAME_TOKENS_COMPLETE_FLOW.md` - Complete flow with testing guide
- `CONTEST_JOIN_INTEGRATION_GUIDE.md` - Detailed contest join flow
- `UNIFIED_WALLET_IMPLEMENTATION.md` - Wallet architecture

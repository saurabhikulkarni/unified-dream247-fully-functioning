# Fix: UserId Not Passed to Fantasy Features

## 🔴 The Issue

After successful login, when you click the **GAME ZONE** card, the Fantasy features don't have access to the `userId`. This breaks API calls because:

1. Fantasy API calls need the `userId` in headers
2. The GameObject needs to know which user is playing
3. Fantasy storage isn't synced with Shop storage properly

---

## 🎯 Root Cause

The unified authentication system saves userId to **Shop storage** but the Fantasy module reads from **different storage keys**.

### Storage Key Mismatch:

```dart
// Shop saves to:
'user_id' → userId  (SharedPreferences)
'shop_user_id' → userId
'user_id_fantasy' → userId

// Fantasy looks for:
'userId' → ??? (AppStorage - not saved by Shop)
'user' → ???
'token' → saved (good)
```

---

## ✅ Solution

We need to ensure Fantasy can access userId that Shop saved. There are two approaches:

### Approach 1: Fantasy Reads Shop Storage (Recommended)

Fantasy reads the userId that Shop already saved:

```dart
// In Fantasy feature code:
final prefs = await SharedPreferences.getInstance();
final userId = prefs.getString('user_id') ?? prefs.getString('shop_user_id') ?? '';
```

### Approach 2: Sync Storage on Login

After Shop login succeeds, ensure userId is saved to multiple keys so both modules can access it:

```dart
// After OTP verification succeeds:
await prefs.setString('user_id', userId);           // Shop format
await prefs.setString('shop_user_id', userId);      // Shop explicit
await prefs.setString('user_id_fantasy', userId);   // Fantasy legacy
await prefs.setString('userId', userId);            // Fantasy modern
```

---

## 🔧 Implementation - Get UserId in Fantasy

Add this helper function in Fantasy:

```dart
// lib/features/fantasy/core/utils/user_id_helper.dart
import 'package:shared_preferences/shared_preferences.dart';

class UserIdHelper {
  /// Get userId that was set by Shop login
  static Future<String> getUnifiedUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Try all possible keys where Shop might have saved it
      final userId = 
        prefs.getString('user_id') ??           // Shop primary
        prefs.getString('shop_user_id') ??      // Shop explicit
        prefs.getString('user_id_fantasy') ??   // Fantasy legacy
        prefs.getString('userId') ??            // Fantasy modern
        '';
      
      if (userId.isEmpty) {
        debugPrint('⚠️ [FANTASY] No userId found in storage!');
        return '';
      }
      
      debugPrint('✅ [FANTASY] UserId found: $userId');
      return userId;
    } catch (e) {
      debugPrint('❌ [FANTASY] Error getting userId: $e');
      return '';
    }
  }
}
```

Use it in Fantasy features:

```dart
// In Fantasy landing page or any feature:
final userId = await UserIdHelper.getUnifiedUserId();
if (userId.isEmpty) {
  // Redirect to login
  context.go('/login');
  return;
}

debugPrint('Fantasy loaded with userId: $userId');
// Now use this userId for API calls
```

---

## 📋 Checklist to Fix

### Step 1: Ensure Shop Saves All Keys
Update `lib/features/shop/services/auth_service.dart` in `saveLoginSession()`:

```dart
// After successful login, save to all keys:
await prefs.setString('user_id', userId);
await prefs.setString('shop_user_id', userId);
await prefs.setString('user_id_fantasy', userId);
await prefs.setString('userId', userId);
```

**File to check:**
[lib/features/shop/services/auth_service.dart](lib/features/shop/services/auth_service.dart#L146)

---

### Step 2: Create UserId Helper in Fantasy
Create new file: `lib/features/fantasy/core/utils/user_id_helper.dart`

This helper will try multiple storage keys to find the userId.

---

### Step 3: Update Fantasy Features to Use Helper

Update all Fantasy features that need userId:

#### A. Fantasy Landing Page
**File:** `lib/features/fantasy/landing/presentation/screens/landing_page.dart`

```dart
@override
void initState() {
  super.initState();
  _loadUserId();
}

Future<void> _loadUserId() async {
  final userId = await UserIdHelper.getUnifiedUserId();
  setState(() {
    _userId = userId;
  });
  
  if (_userId.isEmpty) {
    // Redirect to login
    if (mounted) {
      context.go('/login');
    }
  }
}
```

#### B. Fantasy API Calls
**Files affected:**
- `lib/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart`
- `lib/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart`

Update API headers:

```dart
// In api_impl.dart or api_impl_header.dart
final userId = await UserIdHelper.getUnifiedUserId();

final headers = {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $token',
  'X-User-ID': userId,  // Add userId header
  'X-Firebase-Token': ftoken,
};
```

#### C. Game Tokens Service
**File:** `lib/features/fantasy/accounts/data/services/game_tokens_service.dart`

```dart
@override
Future<void> initialize() async {
  _userId = await UserIdHelper.getUnifiedUserId();
  if (_userId.isEmpty) {
    debugPrint('❌ [GAME_TOKENS_SERVICE] No userId available!');
    throw Exception('User not authenticated');
  }
  // Continue with initialization
}
```

---

## 🧪 Testing

After implementation:

1. **Login with OTP** in Shop
   - Verify userId is saved in SharedPreferences
   
2. **Click GAME ZONE card**
   - Verify Fantasy page loads
   - Check logs for "✅ [FANTASY] UserId found"
   
3. **Check Game Tokens**
   - Verify wallet balance loads correctly
   - Check that userId is sent in API headers
   
4. **Create Team**
   - Verify userId is used in team creation
   - Check Fantasy API responses

---

## 📊 Data Flow After Fix

```
Shop Login
    ↓
OTP Verified ✅
    ↓
Backend returns userId
    ↓
Shop saves to multiple keys:
  • user_id
  • shop_user_id
  • user_id_fantasy
  • userId
    ↓
Click GAME ZONE card
    ↓
Fantasy page loads
    ↓
UserIdHelper.getUnifiedUserId()
    ↓
Finds userId in one of the keys
    ↓
Fantasy features initialized with userId
    ↓
Game tokens fetched with userId header ✅
    ↓
Fantasy fully functional!
```

---

## 🎯 Key Files to Update

| File | Action | Priority |
|------|--------|----------|
| `lib/core/services/auth_service.dart` | Ensure userId saved to all keys | HIGH |
| `lib/features/shop/services/auth_service.dart` | Sync all storage keys on login | HIGH |
| `lib/features/fantasy/core/utils/user_id_helper.dart` | Create this new helper file | HIGH |
| `lib/features/fantasy/landing/presentation/screens/landing_page.dart` | Use helper to load userId | HIGH |
| `lib/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart` | Add userId header | MEDIUM |
| `lib/features/fantasy/accounts/data/services/game_tokens_service.dart` | Initialize with userId | MEDIUM |

---

## 🐛 Debugging Tips

If userId still not available:

1. **Check SharedPreferences:**
```dart
final prefs = await SharedPreferences.getInstance();
print(prefs.getKeys()); // See all saved keys
print(prefs.getString('user_id')); // Check each key
print(prefs.getString('shop_user_id'));
print(prefs.getString('user_id_fantasy'));
print(prefs.getString('userId'));
```

2. **Check Auth Response:**
Verify backend returns `userId` in login/OTP response

3. **Check Storage Save:**
Add logs in `saveLoginSession()` to confirm all keys are saved

4. **Check Fantasy Read:**
Add logs in `UserIdHelper` to see which key was found

---

## 📞 Summary

| Problem | Root Cause | Solution |
|---------|-----------|----------|
| userId not available in Fantasy | Storage key mismatch | Create UserIdHelper to read from multiple keys |
| Fantasy API calls fail | No userId in headers | Add userId to API request headers |
| Game tokens don't load | Missing userId in request | Use helper in GameTokensService |

Once the UserIdHelper is in place and all features use it, the userId will be available throughout the Fantasy module! 🚀

---

**Status:** ⚠️ Needs Implementation  
**Estimated Time:** 30-45 minutes  
**Difficulty:** Easy to Medium

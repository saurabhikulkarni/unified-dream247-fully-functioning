# 🔗 UNIFIED AUTHENTICATION SYSTEM

## Overview

The Dream247 app now uses a **SINGLE UNIFIED AUTHENTICATION SYSTEM** for both Shopping and Fantasy modules.

- **One Login**: MSG91 OTP-based authentication from Shop module
- **One User ID**: Same user identification across Shop and Fantasy
- **One Session**: Login to Shop = automatic access to Fantasy
- **One Logout**: Logout from either module logs out from both

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    UNIFIED AUTH SYSTEM                           │
│                                                                   │
│  ┌──────────────────────┐          ┌──────────────────────────┐  │
│  │  SHOP LOGIN SCREEN   │          │   FANTASY APP            │  │
│  │  (MSG91 OTP)         │          │   (uses Shop user ID)    │  │
│  │                      │          │                          │  │
│  │  1. Phone number     │          │  Reads user ID from:     │  │
│  │  2. OTP verification │  ───────→│  - SharedPreferences     │  │
│  │  3. Create/Get User  │          │  - AppStorage            │  │
│  │  4. Get User ID      │          │                          │  │
│  └──────────────────────┘          └──────────────────────────┘  │
│         │                                     ▲                   │
│         │ saveUnifiedLoginSession()           │                   │
│         └─────────────────────────────────────┘                   │
│                                                                   │
│  SHARED: user_id, auth_token, phone, name                        │
│  LOCATION: SharedPreferences + AppStorage                        │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Implementation Details

### 1. **Shop Module - Authentication Entry Point**
- Location: `lib/features/authentication/` (Login/OTP screens)
- Flow: Phone → OTP → User ID creation
- Use Case: `VerifyOtpUseCase` calls shop auth service
- Result: `AuthBloc` saves unified session

### 2. **User ID Assignment**
- When OTP is verified, backend returns/creates a unique user ID
- This user ID is saved to:
  - SharedPreferences (Shop primary storage)
  - AppStorage (Fantasy storage)
  - Core AuthService (system-wide service)

### 3. **Fantasy Module - Reads Shop User ID**
- Fantasy NO LONGER has its own login
- Fantasy directly reads user ID from SharedPreferences/AppStorage
- Fantasy API calls automatically use the same user ID
- Fantasy users = Shop users (one-to-one mapping)

### 4. **Session Storage**

**Keys saved after successful Shop login:**

```dart
// Shop Storage (SharedPreferences)
'user_id' → userId
'auth_token' → authToken
'user_phone' → phoneNumber
'is_logged_in' → true
'phone_verified' → true

// Fantasy Storage (AppStorage)
'userId' → userId  // Same ID
'authToken' → authToken
'loginToken' → authToken
'userPhone' → phoneNumber
'isLoggedIn' → true

// For API Headers
'token' → authToken  // Used by Fantasy API calls
'user_id_fantasy' → userId  // Legacy key
```

---

## Key Methods

### In `lib/features/shop/services/auth_service.dart`:

#### `saveUnifiedLoginSession()`
Saves user data to both Shop and Fantasy storage after successful login.
```dart
await shopAuthService.saveUnifiedLoginSession(
  phone: '+919876543210',
  name: 'John Doe',
  userId: 'user_12345',
  email: 'john@example.com',
  authToken: 'jwt_token_here',
  phoneVerified: true,
);
```

#### `isUnifiedLoggedIn()`
Checks if user is logged in (from Shop perspective - the only login).
```dart
final isLoggedIn = await authService.isUnifiedLoggedIn();
// Returns true if Shop login exists and user ID is present
```

#### `getUnifiedUserId()`
Returns the same user ID used by both Shop and Fantasy.
```dart
final userId = await authService.getUnifiedUserId();
// Returns user ID to be used for all API calls
```

#### `getUnifiedAuthToken()`
Returns the auth token for API calls (used by Fantasy).
```dart
final token = await authService.getUnifiedAuthToken();
```

#### `unifiedLogout()`
Clears authentication from both Shop and Fantasy.
```dart
await authService.unifiedLogout();
// Clears: Shop keys, Fantasy keys, AppStorage keys
// Result: Both modules are logged out
```

---

## Fantasy Integration

### Fantasy API Headers
Fantasy automatically uses the unified user ID in API calls:

**Location:** `lib/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart`

```dart
// Reads token from AppStorage (saved by Shop login)
String? token = prefs.getString(AppStorageKeys.authToken);

// Uses in headers
final headers = {
  'Authorization': 'Bearer $token',  // Same token as Shop
  // Fantasy API backend receives authenticated user ID
};
```

### Fantasy Routing
- Fantasy NO LONGER has a splash or login screen
- Fantasy landing page directly shows content if logged in
- If not logged in, user is redirected to Shop login

---

## Login Flow

```
1. User launches app
   ↓
2. Splash Screen (Shop)
   - Checks isUnifiedLoggedIn()
   ↓
3. If logged in:
   - Shows Unified Home → User can access Shop or Fantasy
   ↓
4. If NOT logged in:
   - Shows Login Screen (Shop MSG91 OTP)
   ↓
5. User enters phone + verifies OTP
   ↓
6. Backend authenticates, returns user ID
   ↓
7. AuthBloc calls saveUnifiedLoginSession()
   - Saves user ID to SharedPreferences
   - Saves user ID to AppStorage (Fantasy)
   - Saves auth token to both storages
   ↓
8. Navigates to Unified Home
   ↓
9. User can now access:
   - Shop module (with user ID)
   - Fantasy module (with same user ID from AppStorage)
```

---

## Logout Flow

```
1. User taps Logout (from Shop or Fantasy)
   ↓
2. Calls unifiedLogout() from Shop AuthService
   ↓
3. Clears all auth keys from:
   - SharedPreferences (Shop)
   - AppStorage (Fantasy)
   ↓
4. Results:
   - Shop: No user ID available
   - Fantasy: No token available
   - Both modules: User logged out
   ↓
5. Redirects to Login Screen
```

---

## Files Modified

| File | Change |
|------|--------|
| `lib/features/shop/services/auth_service.dart` | Added saveUnifiedLoginSession(), isUnifiedLoggedIn(), getUnifiedUserId(), unifiedLogout() |
| `lib/features/shop/splash/splash_screen.dart` | Updated to check unified login status |
| `lib/core/services/auth_service.dart` | Added documentation for unified auth |
| `lib/features/fantasy/api_server_constants/api_server_utils.dart` | Updated to use unifiedLogout() |
| `lib/features/authentication/presentation/bloc/auth_bloc.dart` | Already saves unified session (no changes needed) |

---

## Storage Keys Reference

### SharedPreferences Keys (Shop Primary)
- `user_id` - User ID (source of truth)
- `auth_token` - Authentication token
- `user_phone` - Phone number
- `user_name` - User name
- `is_logged_in` - Boolean login status
- `phone_verified` - Boolean phone verification status
- `user_email` - Email address
- `token` - Backup token key for Fantasy
- `user_id_fantasy` - Fantasy user ID (same as user_id)
- `is_logged_in_fantasy` - Fantasy login status (same as is_logged_in)

### AppStorage Keys (Fantasy Storage)
- `userId` - User ID (synced from Shop)
- `authToken` - Auth token (synced from Shop)
- `loginToken` - Login token (synced from Shop)
- `userPhone` - Phone (synced from Shop)
- `userName` - Name (synced from Shop)
- `isLoggedIn` - Login status (synced from Shop)

---

## Testing Unified Auth

### Test Case 1: Login Flow
1. Launch app → See splash screen
2. Go to login screen
3. Enter test phone number
4. Verify OTP
5. Should navigate to Unified Home
6. Verify both `/shop/home` and `/fantasy/home` work
7. Check SharedPreferences in app to see user_id

### Test Case 2: Logout
1. Login (as per Test Case 1)
2. Tap logout (from any module)
3. Should redirect to login screen
4. Check SharedPreferences - should be empty
5. Try accessing `/fantasy/home` - should redirect to login

### Test Case 3: App Restart
1. Login
2. Close and reopen app
3. Should show Unified Home (not splash)
4. Verify user is still logged in

### Test Case 4: User ID Consistency
1. Login
2. Check SharedPreferences: `user_id`
3. Check AppStorage: `userId`
4. Both should have the same value

---

## FAQ

**Q: Can users have separate accounts for Shop and Fantasy?**
A: No. One phone number = one user ID = one account across both modules.

**Q: What if a user is logged into Shop but not Fantasy?**
A: If they're logged into Shop, they're automatically logged into Fantasy too (same user ID).

**Q: If I update user info in Shop, does it update in Fantasy?**
A: Yes, because they share the same user ID in backend.

**Q: What happens if auth token expires?**
A: Both modules will redirect to login. User needs to re-verify OTP to get a new token.

**Q: Can Fantasy have its own login URL?**
A: No, Fantasy no longer has a separate login. All authentication goes through Shop.

---

## Migration Notes

If migrating from separate Shop/Fantasy logins:
1. Existing Shop users automatically have Fantasy access (via user ID)
2. Fantasy tokens are now synced with Shop tokens
3. Logout from Fantasy now logs out Shop (and vice versa)
4. User ID is the single source of truth for both modules

---

## Security Notes

✅ **Implemented:**
- JWT token management with expiration check
- User ID uniqueness per phone number
- Unified session validation
- Secure SharedPreferences storage

⚠️ **Additional Considerations:**
- Keep auth tokens short-lived (ideally < 1 hour)
- Implement token refresh mechanism in backend
- Use HTTPS for all API calls
- Monitor for suspicious login attempts

---

## Support

For issues with unified authentication:
1. Check logs for: `UNIFIED LOGIN SUCCESSFUL` or `UNIFIED AUTH` messages
2. Verify user ID exists: `getUnifiedUserId()`
3. Verify auth token: `getUnifiedAuthToken()`
4. Check SharedPreferences keys manually
5. Try logging out and back in

---

**Status**: ✅ IMPLEMENTED AND ACTIVE  
**Date**: January 16, 2026  
**Author**: Development Team

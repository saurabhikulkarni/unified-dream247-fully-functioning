# Token Validation and Refresh Implementation

## Overview

This implementation adds token validation and automatic token refresh capabilities to the Flutter frontend, integrating with both Shop and Fantasy backends.

## Key Changes

### 1. AuthService (lib/core/services/auth_service.dart)

**Added Methods:**
- `getRefreshToken()`: Retrieves stored refresh token
- `isTokenValid()`: Validates JWT token locally by checking expiration
- `getValidToken(backendUrl)`: Returns valid token, auto-refreshes if expired
- `refreshAccessToken(backendUrl)`: Refreshes access token using refresh token
- `validateToken(backendUrl)`: Validates token with backend server

**Updated Methods:**
- `saveUserSession()`: Now accepts optional `refreshToken` parameter
- `logout()`: Now clears refresh token from storage

**Removed Methods:**
- `validateTokenWithBackend()`: Replaced with `validateToken(backendUrl)`
- `refreshToken()`: Replaced with `refreshAccessToken(backendUrl)`

### 2. Login Form (lib/features/shop/screens/auth/views/components/login_form.dart)

**Updated:**
- `verifyOtpUnified()`: Now extracts and saves `refreshToken` from backend response

### 3. HTTP Interceptor (lib/core/network/http_interceptor.dart) - NEW FILE

**Created:**
- `AuthenticatedHttpClient` class with GET and POST methods
- Automatic token validation before requests
- 401 error handling with automatic token refresh retry

### 4. GraphQL Client (lib/core/network/graphql_client.dart)

**Updated:**
- `AuthLink.getToken()`: Now uses `getValidToken()` for automatic token refresh

### 5. Fantasy API Client (lib/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart)

**Updated:**
- `getHeaders()`: Now uses `getValidToken()` for automatic token refresh
- `_request()`: Added 401 error handling with automatic token refresh retry

### 6. Environment Files

**Updated:**
- `.env.dev`: Added `/graphql` suffix to HYGRAPH_ENDPOINT
- `.env.prod`: Added `/graphql` suffix to HYGRAPH_ENDPOINT

## How It Works

### Token Lifecycle

1. **Login**: User logs in via OTP, receives both access token (15 min) and refresh token (30 days)
2. **Storage**: Both tokens stored in SharedPreferences
3. **Usage**: When making API calls:
   - `getValidToken()` checks if token is expired locally
   - If expired, automatically calls `refreshAccessToken()`
   - If refresh succeeds, returns new access token
   - If refresh fails, returns null (user needs to re-login)
4. **Logout**: Both access and refresh tokens cleared

### Local JWT Validation

The `isTokenValid()` method decodes the JWT token locally and checks the `exp` claim without making a network request. This reduces server load and improves performance.

### Auto-Refresh Pattern

All network clients (HTTP, GraphQL, Dio) use `getValidToken()` which:
1. Checks if current token is valid
2. Returns it if valid
3. Attempts refresh if expired
4. Returns new token or null

### 401 Retry Logic

When a request receives a 401 response:
1. Client attempts to refresh the token
2. If refresh succeeds, retries the original request
3. If refresh fails, returns 401 to caller

## Benefits

1. ✅ **Better Security**: Short-lived access tokens (15 min)
2. ✅ **Better UX**: Automatic token refresh, no forced re-login
3. ✅ **Seamless**: User doesn't notice token refreshes
4. ✅ **Robust**: Handles token expiry gracefully
5. ✅ **Consistent**: Works with both Shop and Fantasy backends

## Usage Examples

### Using AuthenticatedHttpClient

```dart
import 'package:unified_dream247/core/network/http_interceptor.dart';

final client = AuthenticatedHttpClient();

// GET request with auto-refresh
final response = await client.get('https://api.example.com/data');

// POST request with auto-refresh
final response = await client.post(
  'https://api.example.com/data',
  body: jsonEncode({'key': 'value'}),
);
```

### Direct Token Validation

```dart
import 'package:unified_dream247/core/services/auth_service.dart';
import 'package:unified_dream247/core/constants/api_constants.dart';

final authService = AuthService();
await authService.initialize();

// Check if token is valid locally
final isValid = await authService.isTokenValid();

// Get valid token (auto-refreshes if needed)
final token = await authService.getValidToken(ApiConstants.shopBackendUrl);

// Validate with backend
final isValidOnBackend = await authService.validateToken(ApiConstants.shopBackendUrl);
```

## Testing

To test the implementation:

1. Login and verify tokens are stored
2. Wait for access token to expire (or manually expire it)
3. Make an API call and verify token is automatically refreshed
4. Logout and verify both tokens are cleared

## Future Enhancements

- Add token refresh in background before expiry
- Add analytics for token refresh events
- Add retry logic for network failures during refresh
- Add biometric authentication for re-authentication

# Unified Authentication Backend Integration - Implementation Summary

## Overview

This implementation integrates the Flutter frontend with the unified authentication backend system. The backend provides JWT tokens with module access control, and the frontend now stores and uses this information throughout the application.

## Changes Made

### 1. Core Auth Service (`lib/core/services/auth_service.dart`)

**Added Module Access Fields:**
- `fantasyUserId` - MongoDB user ID for Fantasy module
- `shopEnabled` - Boolean flag for Shop module access
- `fantasyEnabled` - Boolean flag for Fantasy module access
- `modules` - List of enabled module names

**Updated `saveUserSession` Method:**
- Now accepts optional `fantasyUserId` parameter
- Accepts `shopEnabled`, `fantasyEnabled` with default `true`
- Accepts `modules` list with default `['shop', 'fantasy']`
- Stores all module access information in SharedPreferences

**Added Getter Methods:**
- `getFantasyUserId()` - Returns MongoDB user ID
- `isShopEnabled()` - Returns shop access status (default: true)
- `isFantasyEnabled()` - Returns fantasy access status (default: true)
- `getModules()` - Returns list of enabled modules

**Updated `logout` Method:**
- Calls backend `/api/auth/logout` endpoint with Bearer token
- Clears all session data including new module access fields
- Gracefully handles API errors and clears local storage

### 2. API Constants (`lib/core/constants/api_constants.dart`)

**Added Environment-Based Backend URLs:**
```dart
static const String shopBackendUrl = String.fromEnvironment(
  'SHOP_BACKEND_URL',
  defaultValue: 'http://localhost:3000',
);

static const String fantasyBackendUrl = String.fromEnvironment(
  'FANTASY_API_URL',
  defaultValue: 'http://localhost:3001',
);

static const String hygraphEndpoint = String.fromEnvironment(
  'HYGRAPH_ENDPOINT',
  defaultValue: 'https://ap-south-1.cdn.hygraph.com/content/cmj85rtgv038n07uo8egj5fkb/master',
);
```

**Updated Endpoint Paths:**
- `verifyOtpEndpoint` changed to `/api/auth/verify-otp`
- `logoutEndpoint` changed to `/api/auth/logout`

### 3. Storage Constants (`lib/core/constants/storage_constants.dart`)

**Added New Storage Keys:**
```dart
// Module access control
static const String fantasyUserId = 'fantasy_user_id';
static const String shopEnabled = 'shop_enabled';
static const String fantasyEnabled = 'fantasy_enabled';
static const String modules = 'modules';
```

### 4. Login Form (`lib/features/shop/screens/auth/views/components/login_form.dart`)

**Added Unified OTP Verification:**
- Created `verifyOtpUnified()` method
- Calls backend `/api/auth/verify-otp` endpoint
- Parses unified response with user data and token
- Stores all authentication data including:
  - `userId` (Hygraph ID)
  - `fantasyUserId` (MongoDB ID)
  - `shopEnabled`, `fantasyEnabled` flags
  - `modules` array

**Implementation:**
```dart
Future<Map<String, dynamic>> verifyOtpUnified() async {
  final response = await http.post(
    Uri.parse('${ApiConstants.shopBackendUrl}${ApiConstants.verifyOtpEndpoint}'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'mobileNumber': phone,
      'otp': otp,
    }),
  );
  
  final data = jsonDecode(response.body);
  
  if (data['success'] == true) {
    await coreAuthService.saveUserSession(
      userId: user['id'],
      authToken: token,
      mobileNumber: phone,
      name: name,
      fantasyUserId: user['fantasy_user_id'],
      shopEnabled: user['shop_enabled'] ?? true,
      fantasyEnabled: user['fantasy_enabled'] ?? true,
      modules: List<String>.from(user['modules'] ?? ['shop', 'fantasy']),
    );
  }
}
```

### 5. Fantasy API Client (`lib/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart`)

**Added Unified Token to Headers:**
- Created `getHeaders()` method
- Retrieves token from core AuthService
- Adds `Authorization: Bearer <token>` header to all requests

**Implementation:**
```dart
Future<Map<String, String>> getHeaders() async {
  final authService = core_auth.AuthService();
  await authService.initialize();
  final token = authService.getAuthToken();
  
  return {
    'Content-Type': 'application/json',
    'Authorization': token != null ? 'Bearer $token' : '',
    'Accept': 'application/json',
  };
}
```

### 6. GraphQL Client (`lib/core/network/graphql_client.dart`)

**Updated Token Retrieval:**
- Changed from FlutterSecureStorage to core AuthService
- Uses unified token for all GraphQL requests

**Implementation:**
```dart
final authLink = AuthLink(
  getToken: () async {
    final authService = core_auth.AuthService();
    await authService.initialize();
    final token = authService.getAuthToken();
    return token != null ? 'Bearer $token' : null;
  },
);
```

### 7. Splash Screen (`lib/features/shop/splash/splash_screen.dart`)

**Updated Login Check:**
- Uses core AuthService instead of shop-specific service
- Checks for token presence along with login status
- Simplified navigation logic

### 8. Unified Home Page (`lib/features/home/presentation/pages/unified_home_page.dart`)

**Added Module Access Control:**
- Created `_navigateToShop()` method with access check
- Created `_navigateToFantasy()` method with access check
- Shows SnackBar message if module is not enabled
- All navigation points updated to use access-controlled methods

**Implementation:**
```dart
void _navigateToShop() {
  if (!_authService.isShopEnabled()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Shop module is not enabled for your account')),
    );
    return;
  }
  
  context.go('/shop/entry_point');
}
```

### 9. Environment Configuration Files

**Created `.env.dev`:**
```env
SHOP_BACKEND_URL=http://localhost:3000
FANTASY_API_URL=http://localhost:3001
HYGRAPH_ENDPOINT=https://ap-south-1.cdn.hygraph.com/content/cmj85rtgv038n07uo8egj5fkb/master
```

**Created `.env.prod`:**
```env
SHOP_BACKEND_URL=https://your-shop-backend.com
FANTASY_API_URL=https://your-fantasy-backend.com
HYGRAPH_ENDPOINT=https://ap-south-1.cdn.hygraph.com/content/cmj85rtgv038n07uo8egj5fkb/master
```

## Backend API Integration

### Expected Backend Response Format

**POST `/api/auth/verify-otp`:**
```json
{
  "success": true,
  "token": "jwt_token_here",
  "user": {
    "id": "hygraph_user_id",
    "fantasy_user_id": "mongodb_user_id",
    "shop_enabled": true,
    "fantasy_enabled": true,
    "modules": ["shop", "fantasy"]
  }
}
```

**POST `/api/auth/logout`:**
- Requires `Authorization: Bearer <token>` header
- Invalidates the token on backend
- Frontend clears local storage regardless of response

## Data Flow

### Login Flow:
1. User enters phone number and OTP
2. Frontend calls `/api/auth/verify-otp`
3. Backend validates OTP and returns unified token
4. Frontend stores:
   - `userId` (Hygraph ID)
   - `fantasy_user_id` (MongoDB ID)
   - `authToken` (JWT)
   - `shop_enabled`, `fantasy_enabled` flags
   - `modules` array
5. User is redirected to home page

### API Request Flow (Shop):
1. GraphQL client initializes
2. AuthLink retrieves token from core AuthService
3. Token added to `Authorization` header
4. Request sent to Hygraph with token

### API Request Flow (Fantasy):
1. API method called (get, post, etc.)
2. `getHeaders()` retrieves token from core AuthService
3. Token added to `Authorization` header
4. Request sent to Fantasy backend with token

### Logout Flow:
1. User triggers logout
2. Frontend retrieves current token
3. Frontend calls `/api/auth/logout` with token
4. Backend invalidates token (if successful)
5. Frontend clears all local storage
6. User redirected to login page

### Module Access Control:
1. User navigates to Shop or Fantasy
2. Navigation method checks module access
3. If disabled, shows error message and prevents navigation
4. If enabled, proceeds with navigation

## Testing Checklist

- [ ] User can login via Shop screen and receive unified token
- [ ] Token is stored in SharedPreferences with all fields
- [ ] Shop module APIs include unified token in headers
- [ ] Fantasy module APIs include unified token in headers
- [ ] GraphQL requests include unified token
- [ ] Logout calls backend endpoint and clears local storage
- [ ] Module access control prevents unauthorized navigation
- [ ] Session persists across app restarts
- [ ] Splash screen correctly identifies logged-in users

## Configuration Notes

### Environment Variables

To use custom backend URLs, pass them as compile-time constants:

```bash
# Development
flutter run --dart-define=SHOP_BACKEND_URL=http://localhost:3000 \
            --dart-define=FANTASY_API_URL=http://localhost:3001

# Production
flutter build --dart-define=SHOP_BACKEND_URL=https://api.example.com \
              --dart-define=FANTASY_API_URL=https://fantasy.example.com
```

### Dependencies

All required dependencies are already present in `pubspec.yaml`:
- `http: ^1.1.0` - For HTTP requests
- `shared_preferences: ^2.2.0` - For local storage
- `graphql_flutter: ^5.1.2` - For GraphQL
- `dio: ^5.9.0` - For Fantasy API

## Breaking Changes

### For Existing Users:
- First login after update will require re-authentication
- Old session data will be invalid
- New fields will be initialized with defaults

### For Backend:
- Must implement `/api/auth/verify-otp` endpoint
- Must implement `/api/auth/logout` endpoint
- Must return expected response format
- Must handle Fantasy user sync internally

## Migration Path

1. **Backend Team:**
   - Implement unified authentication endpoints
   - Test with mock data
   - Deploy to staging environment

2. **Frontend Team:**
   - Deploy this implementation
   - Test against staging backend
   - Verify all flows work correctly

3. **QA Team:**
   - Test login flow
   - Test module access control
   - Test logout flow
   - Test session persistence

4. **Production Deployment:**
   - Update environment variables
   - Deploy backend first
   - Deploy frontend after backend verification
   - Monitor error logs

## Troubleshooting

### Token Not Stored:
- Check if `AuthService.initialize()` is called
- Verify backend response format matches expected
- Check SharedPreferences permissions

### API Requests Unauthorized:
- Verify token is present in storage
- Check token format (should be JWT)
- Ensure `Authorization` header is included
- Verify backend token validation

### Module Access Control Not Working:
- Check if module flags are stored correctly
- Verify default values (both should be `true`)
- Check if AuthService is initialized before navigation

### Logout Not Working:
- Check network connectivity
- Verify backend endpoint is accessible
- Note: Local storage is cleared regardless of API success

## Future Enhancements

1. **Token Refresh:**
   - Implement automatic token refresh
   - Add refresh token handling
   - Handle token expiration gracefully

2. **Enhanced Security:**
   - Add token encryption in storage
   - Implement certificate pinning
   - Add biometric authentication

3. **Better Error Handling:**
   - Add specific error messages for each failure case
   - Implement retry logic for network failures
   - Add user-friendly error dialogs

4. **Analytics:**
   - Track login success/failure rates
   - Monitor module access patterns
   - Track logout events

## Support

For issues or questions:
- Check backend logs for API errors
- Check Flutter console for client errors
- Verify environment variables are set correctly
- Ensure backend and frontend versions are compatible

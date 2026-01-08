# Unified Dream247 Integration Guide

## Overview

This document explains how the unified Dream247 app integrates e-commerce and fantasy gaming features from two separate source repositories into a single cohesive application.

## Source Repositories

### E-commerce App (Shop)
- **Repository**: `saurabhikulkarni/brighthex-dream24-7`
- **Branch**: `test-user-id`
- **Backend**: GraphQL-based (Hygraph)
- **Key Features**:
  - Product catalog with search and filtering
  - Shopping cart and wishlist
  - Order management
  - Razorpay payment integration

### Fantasy Gaming App
- **Repository**: `DeepakPareek-Flutter/Dream247`
- **Branch**: `deepak_Dev`
- **Backend**: REST API (Dio-based)
- **Key Features**:
  - Match listings (cricket)
  - Team creation
  - Contest participation
  - Leaderboards and rankings

## Integration Architecture

### 1. Unified Authentication

The app uses a **single authentication system** that serves both modules:

```dart
// User session is stored in SharedPreferences
class UserService {
  String? getUserId();
  String? getUserEmail();
  bool isLoggedIn();
  
  Future<void> setUserSession({
    required String userId,
    required String email,
    String? phone,
  });
}
```

**Flow**:
1. User logs in through the unified login page
2. Authentication token and user ID are stored in secure storage
3. Both GraphQL (ecommerce) and REST (gaming) clients use the same token
4. User session is maintained across app restarts

### 2. Navigation Structure

```
Splash Screen
    ↓
Login/Register (if not authenticated)
    ↓
Unified Home Dashboard
    ↓
   ┌─────────────┬──────────────┬─────────┐
   ↓             ↓              ↓         ↓
Shop Module   Game Module    Wallet   Profile
```

**Bottom Navigation** (4 items):
- **Home**: Unified dashboard with quick access to all features
- **Shop**: E-commerce product browsing and cart
- **Game**: Fantasy gaming matches and contests
- **Wallet**: Shared wallet for both modules

### 3. Shared Services

#### UserService
Manages user session and profile data across both modules.

```dart
final userService = getIt<UserService>();
final userId = userService.getUserId();
final isLoggedIn = userService.isLoggedIn();
```

#### AuthLocalDataSource
Handles secure storage of authentication tokens and user data.

```dart
await authLocalDataSource.saveAccessToken(token);
await authLocalDataSource.cacheUser(user);
```

### 4. State Management

**Primary**: BLoC Pattern
- Authentication: `AuthBloc`
- E-commerce features: Individual BLoCs per feature
- Gaming features: Individual BLoCs per feature

**Reasoning**: BLoC provides:
- Clear separation of business logic and UI
- Testability
- Predictable state changes
- Stream-based reactive programming

### 5. Network Layer

#### Dual Client Approach

**GraphQL Client** (for e-commerce):
```dart
class GraphQLClientService {
  GraphQLClient getClient();
  // Used for products, cart, orders
}
```

**REST Client** (for gaming):
```dart
class RestClient {
  Future<Response> get(String path);
  Future<Response> post(String path, {dynamic data});
  // Used for matches, teams, contests
}
```

Both clients share the same authentication token from secure storage.

### 6. Module Organization

```
lib/
├── features/
│   ├── authentication/      # Shared auth (splash, login, register)
│   ├── home/               # Unified dashboard
│   ├── ecommerce/          # Shop module
│   │   ├── products/
│   │   ├── cart/
│   │   └── orders/
│   ├── gaming/             # Fantasy module
│   │   ├── matches/
│   │   ├── teams/
│   │   └── contests/
│   ├── wallet/             # Shared wallet
│   └── profile/            # User profile
```

### 7. Theme and Branding

**Primary Theme**: Purple gradient
- Primary: `#6C63FF`
- Primary Dark: `#4339F2`

**Module-specific Accents**:
- E-commerce: Teal (`#00BFA5`)
- Gaming: Orange (`#FF9800`)

**Consistent Elements**:
- DREAM247 branding
- Poppins font family
- Material Design components
- Gradient backgrounds for key actions

## User Journey

### First Launch
1. **Splash Screen** (2 seconds)
   - Shows DREAM247 logo and branding
   - Checks authentication status
   
2. **Login/Register** (if not authenticated)
   - Phone number + password authentication
   - OTP verification (if required)
   - Session stored securely

3. **Unified Home Dashboard**
   - Welcome message with user name
   - Coins and gems display (100 each)
   - Banner: "Play FREE with GAME TOKENS"
   - Two main action cards:
     - **GAME ZONE** → Navigate to matches
     - **SHOP** → Navigate to products
   - Product showcases:
     - TREND STARTS HERE (horizontal scroll)
     - TOP PICKS (grid layout)

### Shopping Flow
1. Browse products with search and categories
2. Add items to cart
3. View cart and proceed to checkout
4. Make payment via Razorpay
5. Track order status

### Gaming Flow
1. Browse upcoming/live/completed matches
2. Select a match
3. Create fantasy team
4. Join contest
5. View leaderboard and winnings

## Data Flow

### E-commerce Module
```
UI → BLoC → UseCase → Repository → GraphQL Client → Hygraph API
```

### Gaming Module
```
UI → BLoC → UseCase → Repository → REST Client → Gaming API
```

### Shared Data
```
UI → UserService → SharedPreferences/SecureStorage
```

## API Integration

### E-commerce APIs (GraphQL)

**Base URL**: `https://api-ap-south-1.hygraph.com/v2/YOUR_PROJECT_ID/master`

**Key Queries**:
- `getProducts`: Fetch product catalog
- `getProductById`: Get product details
- `getCart`: Retrieve user's cart
- `getOrders`: Fetch order history

**Key Mutations**:
- `addToCart`: Add product to cart
- `removeFromCart`: Remove product from cart
- `createOrder`: Place a new order

### Gaming APIs (REST)

**Base URL**: `https://api.dream247.com/`

**Key Endpoints**:
- `GET /api/matches`: List matches
- `GET /api/matches/:id`: Match details
- `POST /api/teams`: Create team
- `GET /api/contests`: List contests
- `POST /api/contests/:id/join`: Join contest

## Security Considerations

1. **Token Storage**: Authentication tokens stored in `flutter_secure_storage`
2. **User Data**: Non-sensitive data in `shared_preferences`
3. **API Keys**: Stored in environment configuration, not in code
4. **HTTPS**: All API communication over HTTPS
5. **Input Validation**: All user inputs validated on client and server

## Testing Strategy

### Unit Tests
- Business logic in BLoCs
- Use cases
- Data models and transformations

### Widget Tests
- Individual widgets
- Page layouts
- User interactions

### Integration Tests
- Authentication flow
- Navigation between modules
- API integrations
- Payment flows

## Deployment

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Configuration Required
1. Add `google-services.json` for Android
2. Add `GoogleService-Info.plist` for iOS
3. Configure Razorpay API keys
4. Set up Hygraph API endpoint
5. Configure gaming API endpoint

## Future Enhancements

### Planned Features
1. **Social Features**
   - Share achievements
   - Invite friends
   - Social login

2. **Advanced Gaming**
   - Multiple sports support
   - Private contests
   - Team chat

3. **Enhanced Shopping**
   - Product reviews
   - Wishlist sharing
   - Flash sales

4. **Notifications**
   - Push notifications for match updates
   - Order status updates
   - Promotional offers

5. **Analytics**
   - User behavior tracking
   - Conversion tracking
   - Performance metrics

## Troubleshooting

### Common Issues

**Issue**: GraphQL client not connecting
- Check API endpoint in `api_constants.dart`
- Verify Hygraph API key
- Check network connectivity

**Issue**: REST API errors
- Verify base URL configuration
- Check authentication token
- Ensure proper headers are set

**Issue**: Navigation not working
- Verify route names in `route_names.dart`
- Check router configuration
- Ensure proper context is used

**Issue**: State not updating
- Check BLoC event emission
- Verify stream subscriptions
- Ensure proper state handling in UI

## Support

For issues or questions:
1. Check the README.md
2. Review inline code documentation
3. Check GitHub Issues
4. Contact the development team

## License

This project is proprietary. All rights reserved.

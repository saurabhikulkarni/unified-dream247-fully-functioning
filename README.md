# unified-dream247-fully-functioning

A comprehensive Flutter application that merges e-commerce functionality and fantasy gaming features into a single unified application with shared authentication and a central dashboard.

## Features

### Core Features
- ✅ **Unified Dashboard**: Central home screen with quick access to shopping and gaming
- ✅ **Splash Screen**: Animated splash screen with authentication check
- ✅ **Shared Authentication**: Single login system for both e-commerce and fantasy gaming
- ✅ **Bottom Navigation**: Easy navigation between Home, Shop, Game, and Wallet
- ✅ **User Session Management**: Shared user session across all modules

### E-commerce Features
- ✅ **Product Browsing**: Search and category-based product discovery
- ✅ **Product Grid**: Visual product display with ratings and prices
- ✅ **Wishlist**: Add products to wishlist
- 🚧 **Shopping Cart**: Add items and checkout (coming soon)
- 🚧 **Order Management**: Track orders and history (coming soon)

### Fantasy Gaming Features
- ✅ **Match Listings**: Browse upcoming, live, and completed matches
- ✅ **Featured Matches**: Highlighted matches with contest details
- ✅ **Team Information**: View team details and match statistics
- 🚧 **Team Creation**: Build your fantasy team (coming soon)
- 🚧 **Contests**: Join contests and compete (coming soon)

### Additional Features
- ✅ **Wallet**: View balance and transaction history
- ✅ **Profile**: Comprehensive user profile with stats
- ✅ **Clean Architecture**: Separation of concerns with BLoC pattern
- ✅ **Dependency Injection**: GetIt for dependency management
- ✅ **Routing**: GoRouter for declarative routing
- ✅ **Theme System**: Comprehensive theming with purple gradient branding

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # Main app configuration
├── core/                     # Core functionality
│   ├── di/                   # Dependency injection
│   ├── network/              # Network clients (GraphQL, REST)
│   ├── services/             # Shared services (UserService)
│   ├── error/                # Error handling
│   ├── constants/            # App constants
│   └── utils/                # Utilities (validators, formatters, extensions)
├── config/                   # Configuration
│   ├── theme/                # Theme configuration
│   ├── routes/               # Routing setup
│   └── env/                  # Environment configuration
├── shared/                   # Shared components
│   ├── widgets/              # Reusable widgets
│   ├── components/           # Complex components (bottom nav, drawer)
│   └── models/               # Shared models
└── features/                 # Feature modules
    ├── authentication/       # Authentication module (splash, login, register)
    ├── home/                 # Unified home dashboard
    ├── wallet/               # Wallet module
    ├── profile/              # Profile module
    ├── ecommerce/            # E-commerce features (products, cart, orders)
    └── gaming/               # Gaming features (matches, teams, contests)
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code with Flutter extensions
- Android SDK / Xcode (for iOS)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/saurabhikulkarni/unified-dream247-fully-functioning.git
cd unified-dream247-fully-functioning
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure API keys (optional - app will use placeholder values):
   - Update `lib/config/env/environment.dart` with your API keys
   - Set Razorpay key, Hygraph API key, Firebase config

4. Run the app:
```bash
flutter run
```

### Building for Production

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

## Configuration

### API Endpoints

Update the following files to configure API endpoints:
- `lib/core/constants/api_constants.dart` - API endpoint URLs
- `lib/config/env/environment.dart` - Environment-specific configuration

### Firebase Setup (Optional)

1. Add your Firebase configuration files:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

2. Uncomment Firebase initialization in `lib/main.dart`

## Testing

Run all tests:
```bash
flutter test
```

Run tests with coverage:
```bash
flutter test --coverage
```

View coverage report:
```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Architecture

This project follows **Clean Architecture** principles with **BLoC pattern** for state management:

### State Management Strategy

The app primarily uses **BLoC (Business Logic Component)** pattern for state management:
- Authentication flows use AuthBloc
- Complex features with business logic use BLoC
- Simple state can use StatefulWidget when appropriate

**Note**: While Provider and Get dependencies are included for potential future enhancements or third-party integrations, the primary state management pattern is BLoC to maintain consistency and predictability.

### Layers

1. **Presentation Layer** (`presentation/`)
   - UI components (pages, widgets)
   - BLoC for state management
   - Event and state definitions

2. **Domain Layer** (`domain/`)
   - Business logic
   - Entities (domain models)
   - Repository interfaces
   - Use cases

3. **Data Layer** (`data/`)
   - Repository implementations
   - Data sources (remote, local)
   - Data models
   - API clients

### Data Flow

```
UI -> BLoC -> UseCase -> Repository -> DataSource -> API/DB
```

## Dependencies

### Core Dependencies
- `flutter_bloc` - State management
- `get_it` - Dependency injection
- `injectable` - Code generation for DI
- `go_router` - Routing
- `dartz` - Functional programming (Either type)

### Network
- `dio` - HTTP client
- `graphql_flutter` - GraphQL client
- `connectivity_plus` - Network connectivity

### Storage
- `shared_preferences` - Simple key-value storage
- `flutter_secure_storage` - Secure storage
- `hive` - NoSQL database

### UI
- `cached_network_image` - Image caching
- `shimmer` - Loading effects
- `lottie` - Animations

### Payment
- `razorpay_flutter` - Payment gateway

## Features Implementation Status

### Completed ✅
- [x] Project structure and configuration
- [x] Core infrastructure (DI, network, error handling)
- [x] Theme and routing setup
- [x] Shared widgets and components
- [x] Authentication module (splash, login, register, OTP)
- [x] Unified home dashboard with action cards
- [x] Enhanced product listing page with search and categories
- [x] Enhanced match listing page with featured matches
- [x] Comprehensive profile page with stats
- [x] Wallet page with balance display
- [x] Bottom navigation (Home, Shop, Game, Wallet)
- [x] Drawer navigation with profile access
- [x] User session management service

### In Progress 🚧
- [ ] Shopping cart functionality
- [ ] Wishlist implementation with backend
- [ ] Order management and tracking
- [ ] Team creation for fantasy gaming
- [ ] Contest participation features
- [ ] Wallet add money and transaction history
- [ ] Firebase integration (FCM, Analytics)

### Planned 📋
- [ ] Push notifications
- [ ] Deep linking
- [ ] Analytics integration
- [ ] Offline support
- [ ] Performance optimizations
- [ ] Payment gateway integration
- [ ] Social sharing features

## Code Style

This project follows the official [Flutter style guide](https://flutter.dev/docs/development/ui/widgets-intro).

Key conventions:
- Use `const` constructors where possible
- Follow Clean Architecture principles
- Write meaningful comments
- Keep functions small and focused
- Use descriptive variable names

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

Project Link: [https://github.com/saurabhikulkarni/unified-dream247-fully-functioning](https://github.com/saurabhikulkarni/unified-dream247-fully-functioning)

## Acknowledgments

- Inspired by [brighthex-dream24-7](https://github.com/saurabhikulkarni/brighthex-dream24-7) for e-commerce
- Inspired by [Dream247](https://github.com/DeepakPareek-Flutter/Dream247) for fantasy gaming
- Clean Architecture by Robert C. Martin
- Flutter community for excellent packages and resources


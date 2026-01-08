# unified-dream247-fully-functioning

A comprehensive Flutter application that merges e-commerce functionality and fantasy gaming features into a single unified application using Clean Architecture with BLoC pattern.

## Features

- ✅ **Clean Architecture**: Separation of concerns with data, domain, and presentation layers
- ✅ **State Management**: BLoC pattern for predictable state management
- ✅ **Dependency Injection**: GetIt for dependency management
- ✅ **Routing**: GoRouter for declarative routing
- ✅ **Authentication**: Complete authentication flow with login, register, and OTP verification
- ✅ **E-commerce Module**: Product listing and detail pages
- ✅ **Gaming Module**: Match listing and detail pages
- ✅ **Shared Wallet**: Common wallet functionality across both modules
- ✅ **Theme System**: Comprehensive theming with light/dark mode support
- ✅ **Network Layer**: GraphQL and REST API clients
- ✅ **Error Handling**: Centralized error handling framework

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # Main app configuration
├── core/                     # Core functionality
│   ├── di/                   # Dependency injection
│   ├── network/              # Network clients (GraphQL, REST)
│   ├── error/                # Error handling
│   ├── constants/            # App constants
│   └── utils/                # Utilities (validators, formatters, extensions)
├── config/                   # Configuration
│   ├── theme/                # Theme configuration
│   ├── routes/               # Routing setup
│   └── env/                  # Environment configuration
├── shared/                   # Shared components
│   ├── widgets/              # Reusable widgets
│   ├── components/           # Complex components
│   └── models/               # Shared models
└── features/                 # Feature modules
    ├── authentication/       # Authentication module
    ├── home/                 # Home dashboard
    ├── wallet/               # Wallet module
    ├── profile/              # Profile module
    ├── ecommerce/            # E-commerce features
    └── gaming/               # Gaming features
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

This project follows **Clean Architecture** principles:

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
- [x] Authentication module (login, register, OTP)
- [x] Home dashboard with bottom navigation
- [x] Basic wallet page
- [x] Basic profile page
- [x] Product listing page (placeholder)
- [x] Match listing page (placeholder)

### In Progress 🚧
- [ ] Wallet functionality (add money, transactions)
- [ ] E-commerce features (cart, checkout, orders)
- [ ] Gaming features (contests, teams, leaderboards)

### Planned 📋
- [ ] Push notifications
- [ ] Deep linking
- [ ] Analytics integration
- [ ] Offline support
- [ ] Performance optimizations

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


# Development Setup Guide

## Prerequisites

1. **Flutter SDK** (>=3.0.0) - https://flutter.dev/docs/get-started/install
2. **Dart SDK** (>=3.0.0) - Comes with Flutter
3. **IDE**: Android Studio or VS Code with Flutter extensions
4. **Platform tools**: Android SDK or Xcode (for iOS)

## Installation

```bash
# Clone repository
git clone https://github.com/saurabhikulkarni/unified-dream247-fully-functioning.git
cd unified-dream247-fully-functioning

# Install dependencies
flutter pub get

# Verify setup
flutter doctor

# Run app
flutter run
```

## Configuration

Update `lib/config/env/environment.dart` with your API keys:
- Razorpay key
- Hygraph API key
- Firebase config (optional)

## Common Commands

```bash
# Development
flutter run
flutter clean

# Building
flutter build apk --release
flutter build ios --release

# Testing
flutter test
flutter test --coverage

# Linting
flutter analyze
flutter format lib/
```

## Troubleshooting

```bash
# Clear cache
flutter clean && flutter pub get

# Gradle issues
cd android && ./gradlew clean && cd ..

# iOS pods
cd ios && pod install && cd ..
```

## Resources

- [Flutter Docs](https://flutter.dev/docs)
- [Project Architecture](ARCHITECTURE.md)

# Test Directory

This directory contains all the test files for the Unified Dream247 application.

## Structure

- `core/` - Tests for core functionality (utils, network, error handling)
- `features/` - Tests for feature modules
  - `authentication/` - Authentication module tests
  - `wallet/` - Wallet module tests
  - `ecommerce/` - E-commerce module tests
  - `gaming/` - Gaming module tests

## Running Tests

Run all tests:
```bash
flutter test
```

Run specific test file:
```bash
flutter test test/core/utils/validators_test.dart
```

Run tests with coverage:
```bash
flutter test --coverage
```

## Test Guidelines

1. Follow the AAA pattern: Arrange, Act, Assert
2. Use descriptive test names
3. Test both positive and negative cases
4. Mock external dependencies
5. Keep tests isolated and independent
6. Use setUp and tearDown for common setup/cleanup

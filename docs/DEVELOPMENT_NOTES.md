# Development Notes

## Current Configuration

### Environment
- Using `.env.dev` for development
- All APIs point to staging servers
- Using test credentials for payments

### Known Limitations

1. **Firebase**:
   - Placeholder configuration
   - Run `flutterfire configure` for real setup

2. **Razorpay**:
   - Test key: `rzp_test_1DP5mmOlF5G5ag`
   - All payments in test mode

3. **Shiprocket**:
   - Test credentials
   - No real shipping orders

4. **APIs**:
   - Staging URLs may have rate limits
   - Some endpoints may not be fully functional

## Development Workflow

### Adding a New Screen

1. Create screen in appropriate module:
   - Shopping: `lib/features/shop/screens/`
   - Fantasy: `lib/features/fantasy/[feature]/presentation/screens/`

2. Add route in `lib/config/routes/app_router.dart`

3. Update navigation calls

### Adding a New Service

1. Create service in `lib/core/services/`
2. Register in DI: `lib/core/di/injection_container.dart`
3. Use `getIt<YourService>()` to access

### Adding a New Provider

1. Create provider in feature module
2. Register in `lib/app.dart` MultiProvider
3. Use `Provider.of<YourProvider>(context)` to access

## Common Issues

### Issue: "No such method: [] on null"
**Solution**: Environment variable not loaded
- Check `.env.dev` exists
- Verify `flutter_dotenv` is initialized

### Issue: Firebase initialization error
**Solution**: Run `flutterfire configure`

### Issue: Razorpay checkout not opening
**Solution**: Test key is valid, check Razorpay console

### Issue: GraphQL query failing
**Solution**: Check Hygraph endpoint in `.env.dev`

## Testing

### Run Unit Tests
```bash
flutter test
```

### Run Integration Tests
```bash
flutter test integration_test
```

### Run on Device
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios
```

## Build Commands

### Debug Build
```bash
# Android
flutter build apk --debug

# iOS
flutter build ios --debug
```

### Release Build
```bash
# Android
flutter build appbundle --release

# iOS
flutter build ios --release
```

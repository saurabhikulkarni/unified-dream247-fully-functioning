# Firebase Configuration

## Current Status
Basic Firebase configuration files are in place with placeholder values.

## To Complete Firebase Setup

1. **Install FlutterFire CLI**:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Configure Firebase**:
   ```bash
   flutterfire configure
   ```
   This will:
   - Prompt you to select your Firebase project
   - Generate `firebase_options.dart` with real values
   - Update both Android and iOS configs

3. **Enable Firebase Services**:
   - Go to Firebase Console: https://console.firebase.google.com/
   - Enable Authentication (Phone)
   - Enable Cloud Messaging (FCM)
   - Enable Analytics (optional)
   - Enable Crashlytics (optional)

4. **Test**:
   - Run the app
   - Try login with OTP
   - Check Firebase Console for users

## Test Credentials
For now, app uses placeholder Firebase config from existing `google-services.json`.

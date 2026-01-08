import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
import 'app.dart';
import 'core/di/injection_container.dart';
import 'core/services/auth_service.dart';

/// Main entry point for the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Hive for GraphQL caching
  await Hive.initFlutter();

  // Initialize dependency injection
  await configureDependencies();

  // Initialize shared authentication service
  await authService.initialize();

  // Load environment variables for fantasy app
  try {
    String envFile = kReleaseMode 
        ? 'assets/config/.env.prod' 
        : 'assets/config/.env.dev';
    await dotenv.load(fileName: envFile);
  } catch (e) {
    // Environment file not found, continue with defaults
    debugPrint('Environment file not loaded: $e');
  }

  // Initialize Firebase
  // Uncomment when Firebase configuration files are added
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // Run the app
  runApp(const MyApp());
}

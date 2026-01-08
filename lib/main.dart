import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
import 'app.dart';
import 'core/di/injection_container.dart';

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

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize dependency injection
  await configureDependencies();

  // Initialize Firebase
  // Uncomment when Firebase configuration files are added
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // Run the app
  runApp(const MyApp());
}

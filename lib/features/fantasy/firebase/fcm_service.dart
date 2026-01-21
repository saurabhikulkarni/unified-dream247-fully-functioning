import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_storage_keys.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_storage.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 🔐 Permission
    final granted = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (granted.authorizationStatus != AuthorizationStatus.authorized) {
      await AppStorage.saveToStorageBool(
          AppStorageKeys.notificationSound, false,);
    }

    // 🔔 Local notification init
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('notification_icon');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit);

    await _localNotifications.initialize(initSettings);

    // 🔔 Android channel
    const AndroidNotificationChannel soundChannel = AndroidNotificationChannel(
      'Dream247_sound',
      'Dream247 Alerts',
      description: 'Notifications with sound',
      importance: Importance.high,
      playSound: true,
    );

    const AndroidNotificationChannel silentChannel = AndroidNotificationChannel(
      'Dream247_silent',
      'Dream247 Silent Alerts',
      description: 'Notifications without sound',
      importance: Importance.low,
      playSound: false,
    );

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(soundChannel);
    await androidPlugin?.createNotificationChannel(silentChannel);

    // 📱 FCM token
    String? token = await _messaging.getToken();
    if (token != null && token.isNotEmpty) {
      debugPrint('📱 FCM Token: $token');
      await AppStorage.saveToStorageString(
        AppStorageKeys.fcmToken,
        token,
      );
    }

    // 📢 Topic subscription
    await _messaging.subscribeToTopic('All');
    debugPrint('✅ Subscribed to topic: All');

    // 🚨 FOREGROUND NOTIFICATION FIX (KEY PART)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('📩 Foreground message: ${message.notification?.title}');
      }

      if (message.notification != null) {
        _showForegroundNotification(message);
      }
    });
  }

  /// 🔔 Show notification when app is OPEN
  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    final bool playSound = await AppStorage.getStorageValueBool(
            AppStorageKeys.notificationSound,) ??
        true;

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      playSound ? 'Dream247_sound' : 'Dream247_silent',
      playSound ? 'Dream247 Alerts' : 'Dream247 Silent Alerts',
      importance: playSound ? Importance.high : Importance.low,
      priority: playSound ? Priority.high : Priority.low,
      playSound: playSound,
      icon: 'notification_icon',
    );

    final NotificationDetails details =
        NotificationDetails(android: androidDetails);

    _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? '',
      message.notification?.body ?? '',
      details,
    );
  }
}

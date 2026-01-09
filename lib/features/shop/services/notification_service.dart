import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static const String _notificationsKey = 'notifications';
  static const String _stockAlertsKey = 'stock_alerts';

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final List<Map<String, dynamic>> _notifications = [];
  final List<Map<String, dynamic>> _stockAlerts = []; // {productId, sizeId, userId}
  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load notifications
      final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];
      _notifications.clear();
      for (String json in notificationsJson) {
        try {
          _notifications.add(jsonDecode(json) as Map<String, dynamic>);
        } catch (e) {
          print('Error parsing notification: $e');
        }
      }

      // Load stock alerts
      final stockAlertsJson = prefs.getStringList(_stockAlertsKey) ?? [];
      _stockAlerts.clear();
      for (String json in stockAlertsJson) {
        try {
          _stockAlerts.add(jsonDecode(json) as Map<String, dynamic>);
        } catch (e) {
          print('Error parsing stock alert: $e');
        }
      }

      print('✓ Notification service initialized: ${_notifications.length} notifications, ${_stockAlerts.length} stock alerts');
      _isInitialized = true;
    } catch (e) {
      print('Error initializing notification service: $e');
      _isInitialized = true;
    }
  }

  /// Save to SharedPreferences
  Future<void> _saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save notifications
      final notificationsJson = _notifications.map((item) => jsonEncode(item)).toList();
      await prefs.setStringList(_notificationsKey, notificationsJson);

      // Save stock alerts
      final stockAlertsJson = _stockAlerts.map((item) => jsonEncode(item)).toList();
      await prefs.setStringList(_stockAlertsKey, stockAlertsJson);
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }

  /// Register a stock alert for a product/size
  Future<void> registerStockAlert({
    required String productId,
    required String productTitle,
    String? sizeId,
    String? sizeName,
    required String userId,
  }) async {
    await initialize();

    // Check if alert already exists
    final exists = _stockAlerts.any((alert) =>
        alert['productId'] == productId &&
        alert['sizeId'] == sizeId &&
        alert['userId'] == userId);

    if (!exists) {
      _stockAlerts.add({
        'productId': productId,
        'productTitle': productTitle,
        'sizeId': sizeId,
        'sizeName': sizeName,
        'userId': userId,
        'createdAt': DateTime.now().toIso8601String(),
      });
      await _saveToPreferences();
      print('✓ Stock alert registered for product: $productTitle (size: $sizeName)');
    }
  }

  /// Remove stock alert
  Future<void> removeStockAlert({
    required String productId,
    String? sizeId,
    required String userId,
  }) async {
    await initialize();

    _stockAlerts.removeWhere((alert) =>
        alert['productId'] == productId &&
        alert['sizeId'] == sizeId &&
        alert['userId'] == userId);
    
    await _saveToPreferences();
  }

  /// Check if user has a stock alert for this product/size
  bool hasStockAlert({
    required String productId,
    String? sizeId,
    required String userId,
  }) {
    return _stockAlerts.any((alert) =>
        alert['productId'] == productId &&
        alert['sizeId'] == sizeId &&
        alert['userId'] == userId);
  }

  /// Get all stock alerts for a user
  List<Map<String, dynamic>> getStockAlerts(String userId) {
    return _stockAlerts.where((alert) => alert['userId'] == userId).toList();
  }

  /// Create notification when stock becomes available
  Future<void> notifyStockAvailable({
    required String productId,
    required String productTitle,
    String? sizeId,
    String? sizeName,
    required String userId,
  }) async {
    await initialize();

    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': 'stock_available',
      'title': 'Back in Stock!',
      'message': sizeName != null
          ? '$productTitle (Size: $sizeName) is now available!'
          : '$productTitle is now available!',
      'productId': productId,
      'sizeId': sizeId,
      'userId': userId,
      'isRead': false,
      'createdAt': DateTime.now().toIso8601String(),
    };

    _notifications.insert(0, notification);
    await _saveToPreferences();

    // Remove the stock alert since we've notified the user
    await removeStockAlert(
      productId: productId,
      sizeId: sizeId,
      userId: userId,
    );

    print('✓ Stock available notification created for: $productTitle');
  }

  /// Check stock and notify users (to be called when stock is updated)
  Future<void> checkAndNotifyStockAvailability({
    required String productId,
    required String productTitle,
    String? sizeId,
    String? sizeName,
    required int newQuantity,
  }) async {
    await initialize();

    // If stock is now available (quantity > 0), notify all users waiting for this product/size
    if (newQuantity > 0) {
      final alertsToNotify = _stockAlerts.where((alert) =>
          alert['productId'] == productId &&
          alert['sizeId'] == sizeId).toList();

      for (var alert in alertsToNotify) {
        await notifyStockAvailable(
          productId: productId,
          productTitle: productTitle,
          sizeId: sizeId,
          sizeName: sizeName,
          userId: alert['userId'],
        );
      }
    }
  }

  /// Get all notifications for a user
  List<Map<String, dynamic>> getNotifications(String userId) {
    return _notifications.where((notif) => notif['userId'] == userId).toList();
  }

  /// Get unread notification count
  int getUnreadCount(String userId) {
    return _notifications.where((notif) => 
        notif['userId'] == userId && notif['isRead'] == false).length;
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((notif) => notif['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      await _saveToPreferences();
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    for (var notif in _notifications) {
      if (notif['userId'] == userId) {
        notif['isRead'] = true;
      }
    }
    await _saveToPreferences();
  }

  /// Clear all notifications for a user
  Future<void> clearAllNotifications(String userId) async {
    _notifications.removeWhere((notif) => notif['userId'] == userId);
    await _saveToPreferences();
  }

  /// Delete a specific notification
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((notif) => notif['id'] == notificationId);
    await _saveToPreferences();
  }
}

final notificationService = NotificationService();

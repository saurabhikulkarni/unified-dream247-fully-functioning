import 'package:flutter/material.dart';
import 'package:unified_dream247/features/shop/services/notification_service.dart';
import 'package:unified_dream247/features/shop/services/user_service.dart';
import 'package:unified_dream247/features/shop/route/route_constants.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    await notificationService.initialize();
    final userId = UserService.getCurrentUserId();
    
    if (userId != null) {
      final notifications = notificationService.getNotifications(userId);
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    final userId = UserService.getCurrentUserId();
    if (userId != null) {
      await notificationService.markAllAsRead(userId);
      await _loadNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All notifications marked as read")),
        );
      }
    }
  }

  Future<void> _clearAll() async {
    final userId = UserService.getCurrentUserId();
    if (userId != null) {
      await notificationService.clearAllNotifications(userId);
      await _loadNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All notifications cleared")),
        );
      }
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    await notificationService.deleteNotification(notificationId);
    await _loadNotifications();
  }

  Future<void> _handleNotificationTap(Map<String, dynamic> notification) async {
    // Mark as read
    await notificationService.markAsRead(notification['id']);
    
    // Navigate to product if it's a stock notification
    if (notification['type'] == 'stock_available' && notification['productId'] != null) {
      if (mounted) {
        Navigator.pushNamed(
          context,
          productDetailsScreenRoute,
          arguments: notification['productId'],
        );
      }
    }
    
    await _loadNotifications();
  }

  String _formatTime(String? isoString) {
    if (isoString == null) return '';
    
    try {
      final dateTime = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return '';
    }
  }

  IconData _getIconForNotification(Map<String, dynamic> notification) {
    switch (notification['type']) {
      case 'stock_available':
        return Icons.inventory_2;
      case 'order_confirmed':
        return Icons.check_circle;
      case 'shipment':
        return Icons.local_shipping;
      case 'offer':
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'mark_all_read') {
                _markAllAsRead();
              } else if (value == 'clear_all') {
                _clearAll();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Text('Mark all as read'),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Text('Clear all'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No notifications",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      final isRead = notification['isRead'] == true;
                      
                      return Dismissible(
                        key: Key(notification['id']),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          _deleteNotification(notification['id']);
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isRead ? Colors.grey[300] : Theme.of(context).primaryColor.withOpacity(0.2),
                            child: Icon(
                              _getIconForNotification(notification),
                              color: isRead ? Colors.grey[600] : Theme.of(context).primaryColor,
                            ),
                          ),
                          title: Text(
                            notification['title'] ?? 'Notification',
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                notification['message'] ?? '',
                                style: TextStyle(
                                  color: isRead ? Colors.grey[600] : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(notification['createdAt']),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          onTap: () => _handleNotificationTap(notification),
                          tileColor: isRead ? null : Theme.of(context).primaryColor.withOpacity(0.05),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

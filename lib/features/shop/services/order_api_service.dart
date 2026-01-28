import 'package:unified_dream247/features/shop/services/api_service.dart';

/// Backend API wrapper for order operations
/// Provides methods for all 7 order management APIs
class OrderApiService {
  
  /// POST /api/orders - Create a new order
  /// Required: userId, items, totalAmount
  /// Optional: addressId, paymentId
  static Future<Map<String, dynamic>> createOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    required int totalAmount,
    String? addressId,
    String? paymentId,
  }) {
    return ApiService.post(
      '/api/orders',
      body: {
        'userId': userId,
        'items': items,
        'totalAmount': totalAmount,
        if (addressId != null) 'addressId': addressId,
        if (paymentId != null) 'paymentId': paymentId,
      },
    );
  }

  /// GET /api/orders - Get all orders for a user with pagination
  /// Params: userId, skip (default 0), limit (default 50)
  static Future<Map<String, dynamic>> getOrders(
    String userId, {
    int skip = 0,
    int limit = 50,
  }) {
    return ApiService.get(
      '/api/orders?userId=$userId&skip=$skip&limit=$limit',
    );
  }

  /// GET /api/orders/{orderId} - Get order details
  static Future<Map<String, dynamic>> getOrder(String orderId) {
    return ApiService.get('/api/orders/$orderId');
  }

  /// PUT /api/orders/{orderId} - Update order status
  /// Body: status (PENDING, PROCESSING, SHIPPED, DELIVERED, CANCELLED)
  static Future<Map<String, dynamic>> updateOrderStatus(
    String orderId,
    String status,
  ) {
    return ApiService.put(
      '/api/orders/$orderId',
      body: {'status': status},
    );
  }

  /// DELETE /api/orders/{orderId} - Cancel/Delete an order
  static Future<Map<String, dynamic>> cancelOrder(String orderId) {
    return ApiService.delete('/api/orders/$orderId');
  }

  /// POST /api/orders/{orderId}/create-shipment - Create shipment with Shiprocket
  /// Required: email, weight, length, breadth, height
  /// Optional: orderItems
  static Future<Map<String, dynamic>> createShipment(
    String orderId, {
    required String email,
    required int weight,
    required int length,
    required int breadth,
    required int height,
    List<Map<String, dynamic>>? orderItems,
  }) {
    return ApiService.post(
      '/api/orders/$orderId/create-shipment',
      body: {
        'email': email,
        'weight': weight,
        'length': length,
        'breadth': breadth,
        'height': height,
        if (orderItems != null) 'order_items': orderItems,
      },
    );
  }

  /// GET /api/orders/{orderId}/status - Get order status
  static Future<Map<String, dynamic>> getOrderStatus(String orderId) {
    return ApiService.get('/api/orders/$orderId/status');
  }
}

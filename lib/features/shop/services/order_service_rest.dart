import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_dream247/config/api_config.dart';
import 'package:unified_dream247/features/shop/models/order_models.dart';
import 'package:unified_dream247/features/shop/services/user_service.dart';

/// OrderService with REST API integration for order placement
class OrderServiceREST {
  static final OrderServiceREST _instance = OrderServiceREST._internal();
  
  factory OrderServiceREST() {
    return _instance;
  }
  
  OrderServiceREST._internal();

  // Cache for order items
  final Map<String, List<OrderItemModel>> _orderItemsCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// Place order using REST API endpoint
  /// This replaces the GraphQL order creation with your backend API
  Future<OrderModel> placeOrder({
    required List<OrderItemModel> items,
    required double totalAmount,
    String? addressId,
    String? notes,
  }) async {
    try {
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      if (items.isEmpty) {
        throw Exception('Order must have at least one item');
      }

      if (kDebugMode) {
        print('🚀 [ORDER_REST] Placing order via REST API...');
        print('   User ID: $userId');
        print('   Items count: ${items.length}');
        print('   Total amount: $totalAmount');
        print('   Address ID: $addressId');
        print('   Notes: $notes');
      }

      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? prefs.getString('auth_token');
      
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      // Prepare request body matching your Postman example
      final requestBody = {
        'items': items.map((item) {
          return {
            'productId': item.productId,
            'quantity': item.quantity,
            'sizeId': item.sizeId ?? '',
          };
        }).toList(),
        'addressId': addressId ?? '',
        'notes': notes ?? '',
      };

      if (kDebugMode) {
        print('📦 [ORDER_REST] Request body: ${jsonEncode(requestBody)}');
      }

      // Call REST API endpoint
      final url = ApiConfig.shopPlaceOrderEndpoint;
      if (kDebugMode) {
        print('═══════════════════════════════════════════════════════');
        print('🌐 [ORDER_REST] Calling: $url');
        print('🔑 [ORDER_REST] Token: ${token.substring(0, 20)}...');
        print('📦 [ORDER_REST] Sending request to backend...');
        print('═══════════════════════════════════════════════════════');
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (kDebugMode) {
        print('═══════════════════════════════════════════════════════');
        print('📡 [ORDER_REST] Response status: ${response.statusCode}');
        print('📡 [ORDER_REST] Response body: ${response.body}');
        print('═══════════════════════════════════════════════════════');
      }

      // Handle different response status codes
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['success'] != true) {
          throw Exception(responseData['message'] ?? 'Order placement failed');
        }

        final orderData = responseData['data'];
        final orderId = orderData['orderId'] ?? orderData['id'] ?? orderData['_id'];
        final orderNumber = orderData['orderNumber'] ?? generateOrderNumber();

        if (kDebugMode) {
          print('✅ [ORDER_REST] Order placed successfully!');
          print('📝 [ORDER_REST] Order ID: $orderId');
          print('📝 [ORDER_REST] Order Number: $orderNumber');
        }

        // Construct order items from request data
        final orderItems = items.map((item) => OrderItemModel(
          id: null,
          productId: item.productId,
          sizeId: item.sizeId,
          size: item.size,
          quantity: item.quantity,
          pricePerUnit: item.pricePerUnit,
          totalPrice: item.totalPrice,
          product: item.product,
        )).toList();

        return OrderModel(
          id: orderId?.toString(),
          orderNumber: orderNumber,
          userId: userId,
          items: orderItems,
          totalAmount: totalAmount,
          orderStatus: OrderStatus.pending,
          addressId: addressId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Bad request - check your order data');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please log in again');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden - insufficient permissions');
      } else if (response.statusCode == 422) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Validation failed');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error - please try again later');
      } else {
        throw Exception('Unexpected error (status: ${response.statusCode})');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ORDER_REST] Error placing order: $e');
      }
      throw Exception('Error placing order: $e');
    }
  }

  /// Get user orders from backend
  /// This would need a corresponding GET endpoint on your backend
  Future<List<OrderModel>> getUserOrders() async {
    try {
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? prefs.getString('auth_token');
      
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      // TODO: Implement GET endpoint for user orders
      // This would call something like: GET /api/orders/user/:userId
      // For now, return empty list
      if (kDebugMode) {
        print('⚠️ [ORDER_REST] getUserOrders not implemented yet');
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ORDER_REST] Error fetching orders: $e');
      }
      return [];
    }
  }

  /// Get order by ID from backend
  /// This would need a corresponding GET endpoint on your backend
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? prefs.getString('auth_token');
      
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      // TODO: Implement GET endpoint for specific order
      // This would call something like: GET /api/orders/:orderId
      // For now, return null
      if (kDebugMode) {
        print('⚠️ [ORDER_REST] getOrderById not implemented yet');
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ORDER_REST] Error fetching order: $e');
      }
      return null;
    }
  }

  /// Generate unique order number
  String generateOrderNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'ORD${timestamp.toString().substring(7)}${DateTime.now().microsecondsSinceEpoch.toString().substring(10, 16).toUpperCase()}';
  }

  /// Clear cache (useful for testing)
  void clearCache() {
    _orderItemsCache.clear();
    _cacheTimestamps.clear();
  }
}

// Global instance
final orderServiceREST = OrderServiceREST();
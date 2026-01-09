import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:unified_dream247/features/shop/models/order_models.dart';
import 'package:unified_dream247/features/shop/models/address_model.dart';
import 'package:unified_dream247/features/shop/services/graphql_client.dart';
import 'package:unified_dream247/features/shop/services/graphql_queries.dart';
import 'package:unified_dream247/features/shop/services/user_service.dart';
import 'package:unified_dream247/features/shop/services/stock_service.dart';
import 'package:uuid/uuid.dart';

/// OrderService with GraphQL integration
class OrderServiceGraphQL {
  static final OrderServiceGraphQL _instance = OrderServiceGraphQL._internal();
  
  factory OrderServiceGraphQL() {
    return _instance;
  }
  
  OrderServiceGraphQL._internal();

  final GraphQLClient _client = GraphQLService.getClient();
  
  // Cache to prevent duplicate requests for order items
  final Map<String, List<OrderItemModel>> _orderItemsCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);
  
  // Rate limiting - track last request time to avoid hitting limits
  DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(milliseconds: 1500); // Increased to 1.5s to avoid burst limits on free tier
  
  // OPTIMIZED: Fast order creation with minimal API calls
  Future<OrderModel> createOrderOptimized({
    required List<OrderItemModel> items,
    required double totalAmount,
    String? addressId,
    OrderStatus status = OrderStatus.pending,
  }) async {
    try {
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      if (items.isEmpty) {
        throw Exception('Order must have at least one item');
      }

      final orderNumber = _generateOrderNumber();
      
      if (kDebugMode) {
        print('🚀 [OPTIMIZED] Creating order with ${items.length} items...');
      }
      
      // STEP 1: Create order (1 API call)
      final orderId = await _createOrderOnly(
        userId: userId,
        orderNumber: orderNumber,
        totalAmount: totalAmount,
        status: status,
        addressId: addressId,
      );
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      // STEP 2: Create ALL items in parallel (items.length API calls simultaneously)
      if (kDebugMode) {
        print('📦 [OPTIMIZED] Creating ${items.length} items in parallel...');
      }
      final itemIds = await _createOrderItemsParallel(orderId: orderId, items: items);
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      // STEP 3: Batch publish items + order (2 API calls total)
      if (kDebugMode) {
        print('📤 [OPTIMIZED] Publishing items and order...');
      }
      await Future.wait([
        _publishManyOrderItems(itemIds),
        _publishOrder(orderId),
      ]);
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      // STEP 4: Update stock in parallel (items.length API calls simultaneously)
      if (kDebugMode) {
        print('📊 [OPTIMIZED] Updating stock for ${items.length} items...');
      }
      await _updateStockParallel(items);
      
      if (kDebugMode) {
        print('✅ [OPTIMIZED] Order created successfully!');
      }
      
      // Return order without re-fetching to avoid rate limits
      // Construct the order object from data we already have
      final orderItems = items.map((item) => OrderItemModel(
        id: null, // Item IDs not needed for return value
        productId: item.productId,
        sizeId: item.sizeId,
        size: item.size,
        quantity: item.quantity,
        pricePerUnit: item.pricePerUnit,
        totalPrice: item.totalPrice,
        product: item.product,
      )).toList();
      
      return OrderModel(
        id: orderId,
        orderNumber: orderNumber,
        userId: userId,
        items: orderItems,
        totalAmount: totalAmount,
        orderStatus: status,
        addressId: addressId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }
  
  // Helper: Create order only (no items)
  Future<String> _createOrderOnly({
    required String userId,
    required String orderNumber,
    required double totalAmount,
    required OrderStatus status,
    String? addressId,
  }) async {
    final bool hasAddress = addressId != null && addressId.isNotEmpty;
    
    final MutationOptions options = MutationOptions(
      document: gql(hasAddress 
        ? GraphQLQueries.createOrderWithAddress 
        : GraphQLQueries.createOrderWithoutAddress),
      variables: {
        'userId': userId,
        'orderNumber': orderNumber,
        'totalAmount': totalAmount,
        'orderStatus': _orderStatusToString(status),
        if (hasAddress) 'addressId': addressId,
      },
    );

    final QueryResult result = await _client.mutate(options);
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final orderId = result.data?['createOrder']?['id']?.toString();
    if (orderId == null) {
      throw Exception('Failed to get order ID');
    }
    return orderId;
  }
  
  // Helper: Create multiple items in parallel
  Future<List<String>> _createOrderItemsParallel({
    required String orderId,
    required List<OrderItemModel> items,
  }) async {
    final futures = items.map((item) {
      return _createOrderItem(
        orderId: orderId,
        productId: item.productId,
        sizeId: item.sizeId,
        quantity: item.quantity > 0 ? item.quantity : 1,
        pricePerUnit: item.pricePerUnit >= 0 ? item.pricePerUnit : 0.0,
        totalPrice: item.totalPrice >= 0 ? item.totalPrice : (item.pricePerUnit * item.quantity),
      );
    }).toList();
    
    final itemIds = await Future.wait(futures);
    return itemIds.whereType<String>().toList();
  }
  
  // Helper: Batch publish multiple items
  Future<void> _publishManyOrderItems(List<String> itemIds) async {
    if (itemIds.isEmpty) return;
    
    try {
      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.publishManyOrderItems),
        variables: {'ids': itemIds},
      );
      
      await _client.mutate(options);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Batch publish failed, falling back to individual publishes');
      }
      // Fallback: publish individually
      for (final id in itemIds) {
        await _publishOrderItem(id);
      }
    }
  }
  
  // Helper: Update stock in parallel
  Future<void> _updateStockParallel(List<OrderItemModel> items) async {
    final stockService = StockService();
    final futures = items
        .where((item) => item.sizeId != null && item.sizeId!.isNotEmpty)
        .map((item) => stockService.reduceStock(
              sizeId: item.sizeId!,
              quantityToReduce: item.quantity,
            ))
        .toList();
    
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  // Convert OrderStatus enum to string for GraphQL
  // Hygraph expects enum values to match the schema exactly
  // Try lowercase first as that's a common pattern
  String _orderStatusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.processing:
        return 'processing';
      case OrderStatus.shipped:
        return 'shipped';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
      case OrderStatus.refunded:
        return 'refunded';
    }
  }

  // Convert string to OrderStatus enum
  OrderStatus _stringToOrderStatus(String statusStr) {
    final statusLower = statusStr.toLowerCase();
    if (statusLower == 'pending') return OrderStatus.pending;
    if (statusLower == 'confirmed') return OrderStatus.confirmed;
    if (statusLower == 'processing') return OrderStatus.processing;
    if (statusLower == 'shipped') return OrderStatus.shipped;
    if (statusLower == 'delivered') return OrderStatus.delivered;
    if (statusLower == 'cancelled') return OrderStatus.cancelled;
    if (statusLower == 'refunded') return OrderStatus.refunded;
    return OrderStatus.pending;
  }

  // Generate unique order number
  String _generateOrderNumber() {
    const uuid = Uuid();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'ORD${timestamp.toString().substring(7)}${uuid.v4().substring(0, 6).toUpperCase()}';
  }

  // Get all orders for current user
  Future<List<OrderModel>> getUserOrders() async {
    try {
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getUserOrders),
          variables: {'userId': userId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['orders'] == null) {
        return [];
      }

      final List<dynamic> ordersJson = result.data!['orders'] as List<dynamic>;
      final List<OrderModel> orders = [];
      
      // Fetch orders sequentially with delays to avoid rate limiting
      // Hygraph free tier has strict rate limits, so we need to throttle requests
      for (int i = 0; i < ordersJson.length; i++) {
        final json = ordersJson[i];
        
        // Add delay between requests to avoid rate limiting (except for first request)
        if (i > 0) {
          await Future.delayed(_minRequestInterval);
        }
        
        try {
          final order = await _orderFromGraphQL(json as Map<String, dynamic>, userId);
          orders.add(order);
        } catch (e) {
          if (kDebugMode) {
            print('Error fetching order ${json['id']}: $e');
          }
          // Continue with other orders even if one fails
          // Create a minimal order model to keep the list consistent
          try {
            final minimalOrder = OrderModel(
              id: json['id']?.toString(),
              orderNumber: json['orderNumber'] ?? json['order_number'] ?? 'N/A',
              userId: userId,
              items: [], // Empty items if fetch fails
              totalAmount: (json['totalAmount'] ?? json['total_amount'] ?? 0).toDouble(),
              orderStatus: _stringToOrderStatus(json['orderStatus']?.toString() ?? 'pending'),
              createdAt: json['createdAt'] != null
                  ? DateTime.parse(json['createdAt'])
                  : DateTime.now(),
              updatedAt: json['updatedAt'] != null
                  ? DateTime.parse(json['updatedAt'])
                  : DateTime.now(),
            );
            orders.add(minimalOrder);
          } catch (parseError) {
            if (kDebugMode) {
              print('Error creating minimal order: $parseError');
            }
            // Skip this order if we can't even create a minimal version
          }
        }
      }
      
      return orders;
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getOrderById),
          variables: {'id': orderId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['order'] == null) {
        return null;
      }

      return await _orderFromGraphQL(result.data!['order'] as Map<String, dynamic>, userId);
    } catch (e) {
      throw Exception('Error fetching order: $e');
    }
  }

  // Create new order
  Future<OrderModel> createOrder({
    required List<OrderItemModel> items,
    required double totalAmount,
    String? addressId,
    OrderStatus status = OrderStatus.pending,
  }) async {
    try {
      // Ensure minimum interval between requests to avoid rate limits
      if (_lastRequestTime != null) {
        final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
        if (timeSinceLastRequest < _minRequestInterval) {
          final waitTime = _minRequestInterval - timeSinceLastRequest;
          if (kDebugMode) {
            print('[ORDER_SERVICE] Rate limit protection: waiting ${waitTime.inMilliseconds}ms');
          }
          await Future.delayed(waitTime);
        }
      }
      _lastRequestTime = DateTime.now();
      
      final userId = UserService.getCurrentUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User not logged in. Please log in to create an order.');
      }

      // Ensure totalAmount is valid (should be >= 0)
      if (totalAmount < 0) {
        throw Exception('Total amount cannot be negative');
      }
      
      // Generate order number
      final orderNumber = _generateOrderNumber();
      
      // Create order - use different mutation based on whether address is provided
      final bool hasAddress = addressId != null && addressId.isNotEmpty;
      
      final MutationOptions options = MutationOptions(
        document: gql(hasAddress 
          ? GraphQLQueries.createOrderWithAddress 
          : GraphQLQueries.createOrderWithoutAddress),
        variables: {
          'userId': userId,
          'orderNumber': orderNumber,
          'totalAmount': totalAmount,
          'orderStatus': _orderStatusToString(status),
          if (hasAddress) 'addressId': addressId,
        },
      );

      final QueryResult result = await _client.mutate(options);

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final createdOrder = result.data?['createOrder'];
      if (createdOrder == null) {
        throw Exception('Failed to create order - no data returned');
      }

      // Create order items
      final orderId = createdOrder['id']?.toString();
      if (orderId == null) {
        throw Exception('Failed to get order ID after creation');
      }

      // Validate and prepare order items with default values
      if (items.isEmpty) {
        throw Exception('Order must have at least one item');
      }
      
      if (kDebugMode) {
        print('[ORDER_SERVICE] Creating ${items.length} order items with rate limiting...');
      }
      
      // Create each order item - if any fails, rollback the order
      final List<String> createdItemIds = [];
      try {
        for (int i = 0; i < items.length; i++) {
          final item = items[i];
          
          // Add delay BEFORE each request (including first one) to ensure spacing
          // This prevents burst requests at the start
          if (kDebugMode) {
            print('[ORDER_SERVICE] Waiting ${_minRequestInterval.inMilliseconds}ms before creating item ${i + 1}/${items.length}');
          }
          await Future.delayed(_minRequestInterval);
          
          // Validate required fields and use defaults if needed
          final productId = item.productId.isNotEmpty 
            ? item.productId 
            : throw Exception('Product ID is required for order item');
          
          final quantity = item.quantity > 0 
            ? item.quantity 
            : 1; // Default to 1 if invalid
          
          final pricePerUnit = item.pricePerUnit >= 0 
            ? item.pricePerUnit 
            : 0.0; // Default to 0 if invalid
          
          final totalPrice = item.totalPrice >= 0 
            ? item.totalPrice 
            : (pricePerUnit * quantity); // Calculate if invalid
          
          // sizeId can be null (optional field)
          final sizeId = item.sizeId;
          
          if (kDebugMode) {
            print('[ORDER_SERVICE] Creating order item ${i + 1}/${items.length}');
          }
          final itemId = await _createOrderItem(
            orderId: orderId,
            productId: productId,
            sizeId: sizeId,
            quantity: quantity,
            pricePerUnit: pricePerUnit,
            totalPrice: totalPrice,
          );
          
          if (itemId == null) {
            throw Exception('Failed to create order item - no ID returned');
          }
          
          if (kDebugMode) {
            print('[ORDER_SERVICE] Item ${i + 1} created with ID: $itemId');
          }
          
          // Delay before publishing to avoid rate limit
          if (kDebugMode) {
            print('[ORDER_SERVICE] Waiting ${_minRequestInterval.inMilliseconds}ms before publishing item ${i + 1}');
          }
          await Future.delayed(_minRequestInterval);
          
          // Publish order item
          if (kDebugMode) {
            print('[ORDER_SERVICE] Publishing order item ${i + 1}/${items.length}');
          }
          await _publishOrderItem(itemId);
          createdItemIds.add(itemId);
          if (kDebugMode) {
            print('[ORDER_SERVICE] Item ${i + 1} published successfully');
          }
        }
      } catch (e) {
        // If any item creation fails, we should ideally rollback
        // For now, throw to prevent order completion
        throw Exception('Failed to create all order items: $e');
      }

      // Delay before publishing order
      if (kDebugMode) {
        print('[ORDER_SERVICE] Waiting ${_minRequestInterval.inMilliseconds}ms before publishing order');
      }
      await Future.delayed(_minRequestInterval);
      
      // Publish order
      if (kDebugMode) {
        print('[ORDER_SERVICE] Publishing order...');
      }
      await _publishOrder(orderId);
      if (kDebugMode) {
        print('[ORDER_SERVICE] Order published successfully');
      }

      // Delay before updating stock
      if (kDebugMode) {
        print('[ORDER_SERVICE] Waiting ${_minRequestInterval.inMilliseconds}ms before updating stock');
      }
      await Future.delayed(_minRequestInterval);
      
      // Update stock for all items with sizes
      if (kDebugMode) {
        print('[ORDER_SERVICE] Updating stock...');
      }
      await _updateStockForOrder(items);
      if (kDebugMode) {
        print('[ORDER_SERVICE] Stock updated successfully');
      }

      // Return full order by fetching it
      final order = await getOrderById(orderId);
      if (order == null) {
        throw Exception('Failed to retrieve created order');
      }
      return order;
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  // Update order status
  Future<OrderModel> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.updateOrderStatus),
        variables: {
          'id': orderId,
          'orderStatus': _orderStatusToString(status),
        },
      );

      final QueryResult result = await _client.mutate(options);

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      // Get updated order
      final order = await getOrderById(orderId);
      if (order == null) {
        throw Exception('Order not found after update');
      }
      return order;
    } catch (e) {
      throw Exception('Error updating order status: $e');
    }
  }

  // Update order tracking information
  Future<OrderModel> updateOrderTracking({
    required String orderId,
    String? trackingNumber,
    String? courierName,
    String? shiprocketOrderId,
  }) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.updateOrderTracking),
        variables: {
          'id': orderId,
          'trackingNumber': trackingNumber,
          'courierName': courierName,
          'shiprocketOrderId': shiprocketOrderId,
        },
      );

      final QueryResult result = await _client.mutate(options);

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      // Get updated order
      final updatedOrder = await getOrderById(orderId);
      if (updatedOrder == null) {
        throw Exception('Order not found after update');
      }
      return updatedOrder;
    } catch (e) {
      throw Exception('Error updating order tracking: $e');
    }
  }

  // Cancel order
  Future<OrderModel> cancelOrder(String orderId) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.cancelOrder),
        variables: {'id': orderId},
      );

      final QueryResult result = await _client.mutate(options);

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      // Get updated order
      final cancelledOrder = await getOrderById(orderId);
      if (cancelledOrder == null) {
        throw Exception('Order not found after cancellation');
      }
      return cancelledOrder;
    } catch (e) {
      throw Exception('Error cancelling order: $e');
    }
  }

  // Get orders by status
  Future<List<OrderModel>> getOrdersByStatus(OrderStatus status) async {
    try {
      final orders = await getUserOrders();
      return orders.where((order) => order.orderStatus == status).toList();
    } catch (e) {
      throw Exception('Error fetching orders by status: $e');
    }
  }

  // Helper: Fetch order items separately with caching and rate limiting
  Future<List<OrderItemModel>> _fetchOrderItems(String orderId) async {
    try {
      // Check cache first
      final cacheKey = orderId;
      final cachedItems = _orderItemsCache[cacheKey];
      final cacheTime = _cacheTimestamps[cacheKey];
      
      if (cachedItems != null && cacheTime != null) {
        final age = DateTime.now().difference(cacheTime);
        if (age < _cacheExpiry) {
          if (kDebugMode) {
            print('Using cached order items for order: $orderId');
          }
          return cachedItems;
        } else {
          // Cache expired, remove it
          _orderItemsCache.remove(cacheKey);
          _cacheTimestamps.remove(cacheKey);
        }
      }
      
      // Rate limiting - wait if needed
      if (_lastRequestTime != null) {
        final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
        if (timeSinceLastRequest < _minRequestInterval) {
          final waitTime = _minRequestInterval - timeSinceLastRequest;
          if (kDebugMode) {
            print('Rate limiting: waiting ${waitTime.inMilliseconds}ms before next request');
          }
          await Future.delayed(waitTime);
        }
      }
      
      if (kDebugMode) {
        print('Fetching order items for order: $orderId');
      }
      _lastRequestTime = DateTime.now();
      
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getOrderItemsByOrderId),
          variables: {'orderId': orderId},
          fetchPolicy: FetchPolicy.cacheFirst, // Use cache first to reduce requests
        ),
      );

      if (result.hasException) {
        if (kDebugMode) {
          print('Error fetching order items: ${result.exception}');
        }
        
        // Check if it's a rate limit error
        final errorMessage = result.exception.toString().toLowerCase();
        if (errorMessage.contains('too many requests') || errorMessage.contains('rate limit')) {
          if (kDebugMode) {
            print('⚠️ Rate limit hit! Returning cached data or empty list');
          }
          // Return cached data if available even if expired
          if (cachedItems != null) {
            if (kDebugMode) {
              print('Returning expired cache due to rate limit');
            }
            return cachedItems;
          }
          // Return empty list to prevent further errors
          return [];
        }
        
        // Return cached data if available even if expired
        if (cachedItems != null) {
          if (kDebugMode) {
            print('Returning expired cache due to error');
          }
          return cachedItems;
        }
        return [];
      }

      if (result.data == null || result.data!['orderItems'] == null) {
        // Return cached data if available
        if (cachedItems != null) {
          if (kDebugMode) {
            print('No data returned, using cached items');
          }
          return cachedItems;
        }
        return [];
      }

      final List<dynamic> itemsJson = result.data!['orderItems'] as List<dynamic>;
      final items = itemsJson
          .map((itemJson) => OrderItemModel.fromJson(itemJson as Map<String, dynamic>))
          .toList();
      
      // Cache the results
      _orderItemsCache[cacheKey] = items;
      _cacheTimestamps[cacheKey] = DateTime.now();
      if (kDebugMode) {
        print('Cached ${items.length} order items for order: $orderId');
      }
      
      return items;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching order items: $e');
      }
      // Return cached data if available
      final cachedItems = _orderItemsCache[orderId];
      if (cachedItems != null) {
        if (kDebugMode) {
          print('Exception occurred, returning cached items');
        }
        return cachedItems;
      }
      return [];
    }
  }
  
  // Clear cache (useful for testing or when data changes)
  void clearOrderItemsCache() {
    _orderItemsCache.clear();
    _cacheTimestamps.clear();
  }

  // Helper: Convert GraphQL JSON to OrderModel
  Future<OrderModel> _orderFromGraphQL(Map<String, dynamic> json, String userId) async {
    final orderId = json['id']?.toString() ?? '';
    
    // Fetch items separately
    final items = await _fetchOrderItems(orderId);

    // Parse address if present
    AddressModel? address;
    if (json['address'] != null) {
      address = AddressModel.fromJson({
        ...json['address'] as Map<String, dynamic>,
        'userId': userId,
      });
    } else if (json['shippingAddress'] != null) {
      // Fallback for backward compatibility
      address = AddressModel.fromJson({
        ...json['shippingAddress'] as Map<String, dynamic>,
        'userId': userId,
      });
    }

    return OrderModel(
      id: json['id']?.toString(),
      orderNumber: json['orderNumber'] ?? json['order_number'] ?? '',
      userId: userId,
      items: items,
      totalAmount: (json['totalAmount'] ?? json['total_amount'] ?? 0).toDouble(),
      orderStatus: _stringToOrderStatus(json['orderStatus']?.toString() ?? json['status']?.toString() ?? 'pending'),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      addressId: address?.id,
      address: address,
      trackingNumber: json['trackingNumber'] ?? json['tracking_number'],
      courierName: json['courierName'] ?? json['courier_name'],
      shiprocketOrderId: json['shiprocketOrderId'] ?? json['shiprocket_order_id'],
    );
  }

  // Helper: Create order item
  Future<String?> _createOrderItem({
    required String orderId,
    required String productId,
    String? sizeId,
    required int quantity,
    required double pricePerUnit,
    required double totalPrice,
  }) async {
    try {
      // Use different mutations based on whether sizeId is provided
      final bool hasValidSizeId = sizeId != null && 
                                  sizeId.isNotEmpty && 
                                  !sizeId.startsWith('local_');
      
      final QueryResult result;
      if (hasValidSizeId) {
        result = await _client.mutate(
          MutationOptions(
            document: gql(GraphQLQueries.createOrderItemWithSize),
            variables: {
              'orderId': orderId,
              'productId': productId,
              'sizeId': sizeId,
              'quantity': quantity,
              'pricePerUnit': pricePerUnit,
              'totalPrice': totalPrice,
            },
          ),
        );
      } else {
        result = await _client.mutate(
          MutationOptions(
            document: gql(GraphQLQueries.createOrderItemWithoutSize),
            variables: {
              'orderId': orderId,
              'productId': productId,
              'quantity': quantity,
              'pricePerUnit': pricePerUnit,
              'totalPrice': totalPrice,
            },
          ),
        );
      }

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data?['createOrderItem']?['id']?.toString();
    } catch (e) {
      // Re-throw as this is critical
      throw Exception('Failed to create order item: $e');
    }
  }

  // Helper: Publish order item
  Future<void> _publishOrderItem(String itemId) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.publishOrderItem),
          variables: {'id': itemId},
        ),
      );
      
      if (result.hasException) {
        throw Exception('Failed to publish order item: ${result.exception}');
      }
    } catch (e) {
      // Re-throw as this is critical for order creation
      rethrow;
    }
  }

  // Helper: Publish order
  Future<void> _publishOrder(String orderId) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.publishOrder),
          variables: {'id': orderId},
        ),
      );
      
      if (result.hasException) {
        throw Exception('Failed to publish order: ${result.exception}');
      }
    } catch (e) {
      // Re-throw as this is critical for order creation
      rethrow;
    }
  }

  // Helper: Update stock for order items
  Future<void> _updateStockForOrder(List<OrderItemModel> items) async {
    final stockService = StockService();
    
    for (final item in items) {
      // Only update stock if item has a size
      if (item.sizeId != null && item.sizeId!.isNotEmpty) {
        try {
          await stockService.reduceStock(
            sizeId: item.sizeId!,
            quantityToReduce: item.quantity,
          );
        } catch (e) {
          // Silently handle stock reduction errors
        }
      }
    }
  }
}

// Global instance
final orderServiceGraphQL = OrderServiceGraphQL();

import 'package:flutter/foundation.dart';
import 'package:unified_dream247/features/shop/models/product_model.dart';
import 'package:unified_dream247/features/shop/services/shiprocket_service.dart';
import 'package:unified_dream247/core/services/wallet_service.dart';
import 'package:unified_dream247/core/services/shop/cart_service.dart' as core_cart;
import 'package:uuid/uuid.dart';

class OrderItem {
  final String productId;
  final String productTitle;
  final String productImage;
  final int quantity;
  final int pricePerUnit;
  final SizeModel? size;

  OrderItem({
    required this.productId,
    required this.productTitle,
    required this.productImage,
    required this.quantity,
    required this.pricePerUnit,
    this.size,
  });

  int get totalPrice => pricePerUnit * quantity;
}

class Order {
  final String id;
  final DateTime orderDate;
  final List<OrderItem> items;
  final int totalTokens;
  final String orderStatus; // pending, confirmed, shipped, delivered, cancelled
  final String? trackingNumber;
  final String? courierName;
  final ShiprocketOrderData? shiprocketData;

  Order({
    String? id,
    DateTime? orderDate,
    required this.items,
    required this.totalTokens,
    this.orderStatus = 'confirmed',
    this.trackingNumber,
    this.courierName,
    this.shiprocketData,
  })  : id = id ?? const Uuid().v4(),
        orderDate = orderDate ?? DateTime.now();

  int get itemCount => items.length;

  String get orderSummary {
    if (items.isEmpty) return 'No items';
    if (items.length == 1) {
      return '${items.first.productTitle} x${items.first.quantity}';
    }
    return '${items.length} items';
  }

  // Create a copy with updated fields
  Order copyWith({
    String? orderStatus,
    String? trackingNumber,
    String? courierName,
    ShiprocketOrderData? shiprocketData,
  }) {
    return Order(
      id: id,
      orderDate: orderDate,
      items: items,
      totalTokens: totalTokens,
      orderStatus: orderStatus ?? this.orderStatus,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      courierName: courierName ?? this.courierName,
      shiprocketData: shiprocketData ?? this.shiprocketData,
    );
  }
}

class OrderService {
  static final OrderService _instance = OrderService._internal();

  factory OrderService() {
    return _instance;
  }

  OrderService._internal();

  // In-memory storage for orders (in real app, use database/backend)
  final List<Order> _orders = [];

  // Add new order
  void addOrder(Order order) {
    _orders.insert(0, order); // Add to beginning (newest first)
  }

  // Get all orders
  List<Order> getAllOrders() {
    return List.from(_orders);
  }

  // Get order by ID
  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get orders by status
  List<Order> getOrdersByStatus(String status) {
    return _orders.where((order) => order.orderStatus == status).toList();
  }

  // Update order status
  void updateOrderStatus(String orderId, String newStatus) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final oldOrder = _orders[index];
      final updatedOrder = oldOrder.copyWith(orderStatus: newStatus);
      _orders[index] = updatedOrder;
    }
  }

  // Update order with Shiprocket data
  void updateOrderWithShiprocketData(
    String orderId,
    ShiprocketOrderData shiprocketData,
  ) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final oldOrder = _orders[index];
      
      // Map Shiprocket status to our order status
      String mappedStatus = _mapShiprocketStatus(shiprocketData.orderStatus);
      
      final updatedOrder = oldOrder.copyWith(
        orderStatus: mappedStatus,
        trackingNumber: shiprocketData.trackingNumber,
        courierName: shiprocketData.courierName,
        shiprocketData: shiprocketData,
      );
      _orders[index] = updatedOrder;
    }
  }

  // Sync order status with Shiprocket
  Future<void> syncOrderWithShiprocket(String orderId) async {
    try {
      final shiprocketData = await ShiprocketService.getOrderTracking(orderId);
      if (shiprocketData != null) {
        updateOrderWithShiprocketData(orderId, shiprocketData);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing order with Shiprocket: $e');
      }
    }
  }

  // Map Shiprocket status to our order status
  String _mapShiprocketStatus(String shiprocketStatus) {
    final status = shiprocketStatus.toLowerCase();
    
    if (status.contains('delivered') || status.contains('completed')) {
      return 'delivered';
    } else if (status.contains('transit') || status.contains('in-transit') || status.contains('out for delivery')) {
      return 'shipped';
    } else if (status.contains('cancelled') || status.contains('cancel')) {
      return 'cancelled';
    } else if (status.contains('confirmed') || status.contains('pending') || status.contains('processing')) {
      return 'confirmed';
    } else if (status.contains('picked') || status.contains('packed')) {
      return 'confirmed';
    }
    
    return 'confirmed'; // Default status
  }

  // Sync all orders with Shiprocket
  Future<void> syncAllOrdersWithShiprocket() async {
    for (final order in _orders) {
      await syncOrderWithShiprocket(order.id);
    }
  }

  // Get Shiprocket tracking data for an order
  ShiprocketOrderData? getOrderTrackingData(String orderId) {
    try {
      final order = getOrderById(orderId);
      return order?.shiprocketData;
    } catch (e) {
      return null;
    }
  }

  // Cancel order
  void cancelOrder(String orderId) {
    updateOrderStatus(orderId, 'cancelled');
  }

  // Unified order creation flow with wallet deduction and cart clearing
  // Returns the created Order if successful, or null if failed
  Future<Order?> createOrderWithPayment({
    required List<OrderItem> items,
    required int totalTokens,
    bool clearCartAfter = true,
  }) async {
    try {
      // Verify wallet has sufficient balance
      final walletService = UnifiedWalletService();
      final walletBalance = await walletService.getShopTokens();
      if (walletBalance < totalTokens) {
        throw Exception('Insufficient wallet balance');
      }

      // Deduct tokens from wallet
      final deductionSuccess = await walletService.deductShopTokens(
        totalTokens.toDouble(),
        itemName: 'Order Payment',
      );
      if (!deductionSuccess) {
        throw Exception('Failed to deduct tokens from wallet');
      }

      // Create order
      final order = Order(
        items: items,
        totalTokens: totalTokens,
        orderStatus: 'confirmed',
      );

      // Add order to service
      addOrder(order);

      // Clear cart if requested
      if (clearCartAfter) {
        await core_cart.cartService.clearCart();
      }

      return order;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating order with payment: $e');
      }
      return null;
    }
  }

  // Get recent orders (last n orders)
  List<Order> getRecentOrders({int limit = 5}) {
    return _orders.take(limit).toList();
  }

  // Clear all orders (for testing)
  void clearAll() {
    _orders.clear();
  }

  // Add sample orders for testing
  void addSampleOrders() {
    if (_orders.isNotEmpty) return; // Don't add if already have orders

    final now = DateTime.now();
    
    // Sample order 1 - Delivered
    addOrder(Order(
      orderDate: now.subtract(const Duration(days: 5)),
      items: [
        OrderItem(
          productId: '1',
          productTitle: 'Premium Cotton T-Shirt',
          productImage: 'assets/screens/shirt1.png',
          quantity: 1,
          pricePerUnit: 450,
        ),
      ],
      totalTokens: 450,
      orderStatus: 'delivered',
      trackingNumber: 'DEL123456',
      courierName: 'DELHIVERY',
      shiprocketData: ShiprocketOrderData(
        orderId: 'SR001',
        orderStatus: 'Delivered',
        courierName: 'DELHIVERY',
        trackingNumber: 'DEL123456',
        estimatedDeliveryDate: now.subtract(const Duration(days: 1)).toString(),
        currentLocation: 'Delivered to customer',
      ),
    ));

    // Sample order 2 - In Transit
    addOrder(Order(
      orderDate: now.subtract(const Duration(days: 2)),
      items: [
        OrderItem(
          productId: '3',
          productTitle: 'Classic Blue Hoodie',
          productImage: 'assets/screens/hoodie1.png',
          quantity: 1,
          pricePerUnit: 780,
        ),
      ],
      totalTokens: 780,
      orderStatus: 'shipped',
      trackingNumber: 'TRACK789012',
      courierName: 'FedEx',
      shiprocketData: ShiprocketOrderData(
        orderId: 'SR002',
        orderStatus: 'In Transit',
        courierName: 'FedEx',
        trackingNumber: 'TRACK789012',
        estimatedDeliveryDate: now.add(const Duration(days: 1)).toString(),
        currentLocation: 'Mumbai Distribution Center',
        deliveryPartner: DeliveryPartner(
          name: 'Raj Kumar',
          phone: '+91 9876543210',
          vehicleInfo: 'Maruti Swift - MH02AB1234',
          latitude: 19.0760,
          longitude: 72.8777,
        ),
      ),
    ));

    // Sample order 3 - Confirmed
    addOrder(Order(
      orderDate: now,
      items: [
        OrderItem(
          productId: '2',
          productTitle: 'Casual Striped Shirt',
          productImage: 'assets/screens/shirt2.png',
          quantity: 2,
          pricePerUnit: 520,
        ),
      ],
      totalTokens: 1040,
      orderStatus: 'confirmed',
      shiprocketData: ShiprocketOrderData(
        orderId: 'SR003',
        orderStatus: 'Processing',
        estimatedDeliveryDate: now.add(const Duration(days: 3)).toString(),
      ),
    ));
  }
}

final orderService = OrderService();

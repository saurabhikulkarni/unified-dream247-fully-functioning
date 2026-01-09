import 'package:unified_dream247/features/shop/models/product_model.dart';
import 'package:unified_dream247/features/shop/models/address_model.dart';
import 'package:unified_dream247/features/shop/services/shiprocket_service.dart';

/// OrderStatus enum for order status
enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

/// OrderItem represents an item in an order
class OrderItemModel {
  final String? id;
  final String productId;
  final ProductModel? product;
  final String? sizeId;
  final SizeModel? size;
  final int quantity;
  final double pricePerUnit;
  final double totalPrice;

  OrderItemModel({
    this.id,
    required this.productId,
    this.product,
    this.sizeId,
    this.size,
    required this.quantity,
    required this.pricePerUnit,
    double? totalPrice,
  }) : totalPrice = totalPrice ?? (pricePerUnit * quantity);

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // Handle quantity as String (from GraphQL) or int (from local storage)
    int quantity = 1;
    if (json['quantity'] != null) {
      if (json['quantity'] is String) {
        quantity = int.tryParse(json['quantity'] as String) ?? 1;
      } else if (json['quantity'] is int) {
        quantity = json['quantity'] as int;
      } else if (json['quantity'] is num) {
        quantity = (json['quantity'] as num).toInt();
      }
    }
    
    return OrderItemModel(
      id: json['id']?.toString(),
      productId: json['productId']?.toString() ?? json['product']?['id']?.toString() ?? '',
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      sizeId: json['sizeId']?.toString() ?? json['size']?['id']?.toString(),
      size: (json['size'] != null && json['size'] is Map && (json['size'] as Map).isNotEmpty)
          ? SizeModel.fromJson(json['size'] as Map<String, dynamic>)
          : null,
      quantity: quantity,
      pricePerUnit: (json['pricePerUnit'] ?? json['price_per_unit'] ?? json['product']?['price'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? json['total_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'sizeId': sizeId,
      'quantity': quantity,
      'pricePerUnit': pricePerUnit,
      'totalPrice': totalPrice,
    };
  }
}

/// OrderModel represents an order
class OrderModel {
  final String? id;
  final String orderNumber;
  final String userId;
  final List<OrderItemModel> items;
  final double totalAmount;
  final OrderStatus orderStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? addressId;
  final AddressModel? address;
  final String? trackingNumber;
  final String? courierName;
  final String? shiprocketOrderId;
  final ShiprocketOrderData? shiprocketData;

  OrderModel({
    this.id,
    required this.orderNumber,
    required this.userId,
    required this.items,
    required this.totalAmount,
    this.orderStatus = OrderStatus.pending,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.addressId,
    this.address,
    this.trackingNumber,
    this.courierName,
    this.shiprocketOrderId,
    this.shiprocketData,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Parse status string to enum
    OrderStatus parseStatus(String? statusStr) {
      if (statusStr == null) return OrderStatus.pending;
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

    return OrderModel(
      id: json['id']?.toString(),
      orderNumber: json['orderNumber'] ?? json['order_number'] ?? '',
      userId: json['userId']?.toString() ?? json['userDetail']?['id']?.toString() ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] ?? json['total_amount'] ?? 0).toDouble(),
      orderStatus: parseStatus(json['orderStatus']?.toString() ?? json['status']?.toString()),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      addressId: json['address']?['id']?.toString() ?? json['shippingAddress']?['id']?.toString(),
      address: json['address'] != null
          ? AddressModel.fromJson(json['address'] as Map<String, dynamic>)
          : (json['shippingAddress'] != null
              ? AddressModel.fromJson(json['shippingAddress'] as Map<String, dynamic>)
              : null),
      trackingNumber: json['trackingNumber'] ?? json['tracking_number'],
      courierName: json['courierName'] ?? json['courier_name'],
      shiprocketOrderId: json['shiprocketOrderId'] ?? json['shiprocket_order_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'orderStatus': orderStatus.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'trackingNumber': trackingNumber,
      'courierName': courierName,
      'shiprocketOrderId': shiprocketOrderId,
    };
  }

  int get itemCount => items.length;

  String get statusString => orderStatus.toString().split('.').last;

  String get orderSummary {
    if (items.isEmpty) return 'No items';
    try {
      if (items.length == 1) {
        final productName = items.first.product?.productName;
        final quantity = items.first.quantity;
        if (productName != null && productName.isNotEmpty) {
          return '$productName x$quantity';
        }
        return 'Item x$quantity';
      }
      return '${items.length} items';
    } catch (e) {
      return '${items.length} items';
    }
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? userId,
    List<OrderItemModel>? items,
    double? totalAmount,
    OrderStatus? orderStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? addressId,
    AddressModel? address,
    String? trackingNumber,
    String? courierName,
    String? shiprocketOrderId,
    ShiprocketOrderData? shiprocketData,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      orderStatus: orderStatus ?? this.orderStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      addressId: addressId ?? this.addressId,
      address: address ?? this.address,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      courierName: courierName ?? this.courierName,
      shiprocketOrderId: shiprocketOrderId ?? this.shiprocketOrderId,
      shiprocketData: shiprocketData ?? this.shiprocketData,
    );
  }
}

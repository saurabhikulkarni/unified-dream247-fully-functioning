/// Order model for ecommerce orders
class Order {
  final String id;
  final List<OrderItem> items;
  final Address deliveryAddress;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final double subtotal;
  final double discount;
  final double deliveryCharges;
  final double total;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String? trackingId;
  final String? trackingUrl;

  Order({
    required this.id,
    required this.items,
    required this.deliveryAddress,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.subtotal,
    required this.discount,
    required this.deliveryCharges,
    required this.total,
    required this.createdAt,
    this.deliveredAt,
    this.trackingId,
    this.trackingUrl,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      deliveryAddress: Address.fromJson(json['deliveryAddress'] as Map<String, dynamic>),
      status: OrderStatus.fromString(json['status'] as String),
      paymentMethod: PaymentMethod.fromString(json['paymentMethod'] as String),
      paymentStatus: PaymentStatus.fromString(json['paymentStatus'] as String),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      deliveryCharges: (json['deliveryCharges'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'] as String)
          : null,
      trackingId: json['trackingId'] as String?,
      trackingUrl: json['trackingUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'deliveryAddress': deliveryAddress.toJson(),
      'status': status.value,
      'paymentMethod': paymentMethod.value,
      'paymentStatus': paymentStatus.value,
      'subtotal': subtotal,
      'discount': discount,
      'deliveryCharges': deliveryCharges,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'trackingId': trackingId,
      'trackingUrl': trackingUrl,
    };
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}

class OrderItem {
  final String productId;
  final String productName;
  final String imageUrl;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      imageUrl: json['imageUrl'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
    };
  }

  double get total => price * quantity;
}

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  returned;

  String get value => name;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.returned:
        return 'Returned';
    }
  }

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value.toLowerCase(),
      orElse: () => OrderStatus.pending,
    );
  }
}

enum PaymentMethod {
  razorpay,
  cod,
  wallet;

  String get value => name;

  String get displayName {
    switch (this) {
      case PaymentMethod.razorpay:
        return 'Online Payment';
      case PaymentMethod.cod:
        return 'Cash on Delivery';
      case PaymentMethod.wallet:
        return 'Wallet';
    }
  }

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.value == value.toLowerCase(),
      orElse: () => PaymentMethod.razorpay,
    );
  }
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded;

  String get value => name;

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value.toLowerCase(),
      orElse: () => PaymentStatus.pending,
    );
  }
}

/// Cart item model for shopping cart
class CartItem {
  final String id;
  final String productId;
  final String productName;
  final double price;
  final double? discountPrice;
  final String imageUrl;
  final int quantity;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    this.discountPrice,
    required this.imageUrl,
    required this.quantity,
    required this.addedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discountPrice'] != null
          ? (json['discountPrice'] as num).toDouble()
          : null,
      imageUrl: json['imageUrl'] as String,
      quantity: json['quantity'] as int,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'price': price,
      'discountPrice': discountPrice,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  double get effectivePrice => discountPrice ?? price;
  double get totalPrice => effectivePrice * quantity;
  double get savings => (price - effectivePrice) * quantity;

  CartItem copyWith({
    String? id,
    String? productId,
    String? productName,
    double? price,
    double? discountPrice,
    String? imageUrl,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

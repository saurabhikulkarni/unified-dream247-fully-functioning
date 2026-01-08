/// Product model for ecommerce shop features
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final List<String> images;
  final int stock;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final bool featured;
  final String? categoryId;
  final String? categoryName;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.images,
    required this.stock,
    required this.rating,
    required this.reviewCount,
    required this.tags,
    required this.featured,
    this.categoryId,
    this.categoryName,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discountPrice'] != null 
          ? (json['discountPrice'] as num).toDouble() 
          : null,
      images: (json['images'] as List?)
          ?.map((img) => img['url'] as String)
          .toList() ?? [],
      stock: json['stock'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      featured: json['featured'] as bool? ?? false,
      categoryId: json['category']?['id'] as String?,
      categoryName: json['category']?['name'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'images': images.map((url) => {'url': url}).toList(),
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'tags': tags,
      'featured': featured,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  double get effectivePrice => discountPrice ?? price;
  
  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  
  double get discountPercentage {
    if (!hasDiscount) return 0;
    return ((price - discountPrice!) / price * 100).roundToDouble();
  }

  bool get inStock => stock > 0;
}

/// ProductModel represents a shopping product
class ProductModel {
  final String? id;
  final String productName;
  final String? slug;
  final String? description;
  final double price;
  final CategoryModel? category;
  final String image; // Image URL with default empty string

  ProductModel({
    this.id,
    required this.productName,
    this.slug,
    this.description,
    required this.price,
    this.category,
    this.image = '',
  });

  // For backward compatibility with existing UI
  String get title => productName;
  String get brandName => category?.categoryName ?? '';
  double? get priceAfetDiscount => null; // Add if you have discount field

  /// Factory constructor to create ProductModel from GraphQL JSON response
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Handle image field - can be string or object with url property
    String imageUrl = '';
    if (json['image'] != null) {
      if (json['image'] is String) {
        imageUrl = json['image'] as String;
      } else if (json['image'] is Map && json['image']['url'] != null) {
        imageUrl = json['image']['url'] as String;
      }
    } else if (json['imageUrl'] != null) {
      imageUrl = json['imageUrl'] as String;
    }
    
    return ProductModel(
      id: json['id']?.toString(),
      productName: json['productName'] ?? json['product_name'] ?? json['title'] ?? '',
      slug: json['slug'],
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      image: imageUrl,
    );
  }

  /// Convert ProductModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'title': productName, // Backward compatibility
      'slug': slug,
      'description': description,
      'price': price,
      'category': category?.toJson(),
      'brandName': category?.categoryName ?? '', // Backward compatibility
      'image': image, // Save as string for easier loading
      'imageUrl': image, // Backward compatibility
    };
  }
}

/// CategoryModel represents a product category
class CategoryModel {
  final String? id;
  final String categoryName;
  final String? slug;

  CategoryModel({
    this.id,
    required this.categoryName,
    this.slug,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString(),
      categoryName: json['categoryName'] ?? json['category_name'] ?? '',
      slug: json['slug'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryName': categoryName,
      'slug': slug,
    };
  }
}

/// SizeModel represents product sizes
class SizeModel {
  final String? id;
  final String sizeName;
  final int quantity;
  final String? productId;

  SizeModel({
    this.id,
    required this.sizeName,
    required this.quantity,
    this.productId,
  });

  factory SizeModel.fromJson(Map<String, dynamic> json) {
    return SizeModel(
      id: json['id']?.toString(),
      sizeName: json['sizeName'] ?? json['size_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      productId: json['product']?['id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sizeName': sizeName,
      'quantity': quantity,
    };
  }
}

/// UserDetailModel represents user information
class UserDetailModel {
  final String? id;
  final String firstName;
  final String lastName;
  final String username;
  final String mobileNumber;
  final double walletBalance;

  UserDetailModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.mobileNumber,
    this.walletBalance = 0.0,
  });

  factory UserDetailModel.fromJson(Map<String, dynamic> json) {
    return UserDetailModel(
      id: json['id']?.toString(),
      firstName: json['firstName'] ?? json['first_name'] ?? '',
      lastName: json['lastName'] ?? json['last_name'] ?? '',
      username: json['username'] ?? '',
      mobileNumber: json['mobileNumber'] ?? json['mobile_number'] ?? json['phone'] ?? '',
      walletBalance: (json['walletBalance'] ?? json['wallet_balance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'mobileNumber': mobileNumber,
      'walletBalance': walletBalance,
    };
  }

  String get fullName => '$firstName $lastName';
}

/// CartModel represents cart items
class CartModel {
  final String? id;
  final int quantity;
  final UserDetailModel? userDetail;
  final ProductModel? product;
  final SizeModel? size;

  CartModel({
    this.id,
    required this.quantity,
    this.userDetail,
    this.product,
    this.size,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
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
    
    return CartModel(
      id: json['id']?.toString(),
      quantity: quantity,
      userDetail: json['userDetail'] != null
          ? UserDetailModel.fromJson(json['userDetail'] as Map<String, dynamic>)
          : null,
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      size: json['size'] != null
          ? SizeModel.fromJson(json['size'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'userDetail': userDetail?.toJson(),
      'product': product?.toJson(),
      'size': size?.toJson(),
    };
  }
}

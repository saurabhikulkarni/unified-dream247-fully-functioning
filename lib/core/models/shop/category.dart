/// Category model for ecommerce shop features
class Category {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? iconUrl;
  final String? imageUrl;
  final int productsCount;
  final bool featured;
  final String? parentCategoryId;
  final String? parentCategoryName;
  final List<Category>? subCategories;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.iconUrl,
    this.imageUrl,
    required this.productsCount,
    required this.featured,
    this.parentCategoryId,
    this.parentCategoryName,
    this.subCategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon']?['url'] as String?,
      imageUrl: json['image']?['url'] as String?,
      productsCount: json['productsCount'] as int? ?? 0,
      featured: json['featured'] as bool? ?? false,
      parentCategoryId: json['parentCategory']?['id'] as String?,
      parentCategoryName: json['parentCategory']?['name'] as String?,
      subCategories: (json['subCategories'] as List?)
          ?.map((cat) => Category.fromJson(cat as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'icon': iconUrl != null ? {'url': iconUrl} : null,
      'image': imageUrl != null ? {'url': imageUrl} : null,
      'productsCount': productsCount,
      'featured': featured,
      'parentCategory': parentCategoryId != null
          ? {'id': parentCategoryId, 'name': parentCategoryName}
          : null,
      'subCategories': subCategories?.map((cat) => cat.toJson()).toList(),
    };
  }

  bool get hasSubCategories => subCategories != null && subCategories!.isNotEmpty;
  bool get hasParent => parentCategoryId != null;
}

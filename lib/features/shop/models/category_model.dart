class CategoryModel {
  final String title;
  final String? image, svgSrc;
  final List<CategoryModel>? subCategories;

  CategoryModel({
    required this.title,
    this.image,
    this.svgSrc,
    this.subCategories,
  });
}

/// Category banner data for home screen with shop now buttons
class CategoryBannerData {
  final String id;
  final String categoryName;
  final String subtitle;
  final String bannerImageUrl;

  CategoryBannerData({
    required this.id,
    required this.categoryName,
    required this.subtitle,
    required this.bannerImageUrl,
  });
}

final List<CategoryBannerData> demoCategoryBanners = [
  CategoryBannerData(
    id: 'mens',
    categoryName: "Men's Collection",
    subtitle: "Premium styles for men",
    bannerImageUrl: 'assets/screens/mens_collection.jpg',
  ),
  CategoryBannerData(
    id: 'womens',
    categoryName: "Women's Collection",
    subtitle: "Elegant fashion for women",
    bannerImageUrl: 'assets/screens/womens_collection.jpg',
  ),
  CategoryBannerData(
    id: 'accessories',
    categoryName: "Accessories",
    subtitle: "Complete your look",
    bannerImageUrl: 'assets/screens/accessories.jpg',
  ),
  CategoryBannerData(
    id: 'electronics',
    categoryName: "Electronics & Gadgets",
    subtitle: "Latest tech gadgets",
    bannerImageUrl: 'assets/screens/electronics.jpg',
  ),
];

final List<CategoryModel> demoCategoriesWithImage = [
  CategoryModel(title: "Woman’s", image: "https://i.imgur.com/5M89G2P.png"),
  CategoryModel(title: "Man’s", image: "https://i.imgur.com/UM3GdWg.png"),
  CategoryModel(title: "Accessories", image: "https://i.imgur.com/3mSE5sN.png"),
  CategoryModel(title: "Electronics", image: "https://i.imgur.com/9K3F8pL.png"),
];

final List<CategoryModel> demoCategories = [
  CategoryModel(
    title: "Men's Collection",
    svgSrc: "assets/icons/Man&Woman.svg",
  ),
  CategoryModel(
    title: "Women's Collection",
    svgSrc: "assets/icons/Woman.svg",
  ),
  CategoryModel(
    title: "Accessories",
    svgSrc: "assets/icons/Accessories.svg",
  ),
  CategoryModel(
    title: "Electronics & Gadgets",
    svgSrc: "assets/icons/USB.svg",
  ),
];

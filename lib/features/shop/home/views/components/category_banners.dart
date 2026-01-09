import 'package:flutter/material.dart';
import 'package:shop/components/category_banner_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/route/route_constants.dart';

class CategoryBanners extends StatelessWidget {
  const CategoryBanners({super.key});

  void _navigateToCategoryProducts(
    BuildContext context,
    String categoryId,
    String categoryName,
  ) {
    Navigator.pushNamed(
      context,
      categoryProductsScreenRoute,
      arguments: {
        'categoryName': categoryName,
        'categoryId': categoryId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: defaultPadding),
      child: Column(
        children: List.generate(
          demoCategoryBanners.length,
          (index) {
            final banner = demoCategoryBanners[index];
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding,
                vertical: defaultPadding / 2,
              ),
              child: CategoryBannerCard(
                title: banner.categoryName,
                subtitle: banner.subtitle,
                image: banner.bannerImageUrl,
                buttonText: "Shop Now",
                onPressed: () => _navigateToCategoryProducts(
                  context,
                  banner.id,
                  banner.categoryName,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

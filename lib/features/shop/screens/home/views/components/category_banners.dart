import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unified_dream247/features/shop/components/category_banner_card.dart';
import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/shop/models/category_model.dart';
import 'package:unified_dream247/features/shop/route/route_constants.dart';

class CategoryBanners extends StatelessWidget {
  const CategoryBanners({super.key});

  void _navigateToCategoryProducts(
    BuildContext context,
    String categoryId,
    String categoryName,
  ) {
    context.push('/shop/category/$categoryId?name=${Uri.encodeComponent(categoryName)}');
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

import 'package:flutter/material.dart';

import 'components/best_sellers.dart';
import 'components/category_banners_carousel.dart';
import 'components/popular_products.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Add spacing after top navigation bar
            SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
            // Category Banners Carousel at Top
            SliverToBoxAdapter(child: CategoryBannersCarousel()),
            SliverToBoxAdapter(child: PopularProducts()),
            SliverToBoxAdapter(child: BestSellers()),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unified_dream247/features/shop/components/category_banner_card.dart';
import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/shop/models/category_model.dart';

class CategoryBannersCarousel extends StatefulWidget {
  const CategoryBannersCarousel({super.key});

  @override
  State<CategoryBannersCarousel> createState() =>
      _CategoryBannersCarouselState();
}

class _CategoryBannersCarouselState extends State<CategoryBannersCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(() {
      setState(() {
        _currentIndex = _pageController.page?.round() ?? 0;
      });
    });
    
    // Preload all carousel images to prevent loading delays
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var banner in demoCategoryBanners) {
        precacheImage(
          AssetImage(banner.bannerImageUrl),
          context,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToCategoryProducts(
    BuildContext context,
    String categoryId,
    String categoryName,
  ) {
    context.push('/shop/category/$categoryId?name=${Uri.encodeComponent(categoryName)}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Carousel
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.25,
          child: PageView.builder(
            controller: _pageController,
            itemCount: demoCategoryBanners.length,
            itemBuilder: (context, index) {
              final banner = demoCategoryBanners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: CategoryBannerCard(
                  title: banner.categoryName,
                  subtitle: banner.subtitle,
                  image: banner.bannerImageUrl,
                  buttonText: 'Shop Now',
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
        const SizedBox(height: defaultPadding),
        // Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            demoCategoryBanners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 8,
              width: _currentIndex == index ? 24 : 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? primaryColor
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: defaultPadding / 2),
      ],
    );
  }
}

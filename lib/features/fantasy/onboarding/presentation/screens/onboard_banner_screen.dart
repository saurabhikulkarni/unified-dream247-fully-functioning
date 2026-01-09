import 'package:flutter/material.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/app_pages.dart';
import 'package:Dream247/features/landing/data/models/banners_get_set.dart';
import 'package:Dream247/features/onboarding/data/onboarding_datasource.dart';
import 'package:Dream247/features/onboarding/domain/use_cases/onboarding_usecases.dart';

class OnboardBannerScreen extends StatefulWidget {
  final bool isLoggedIn;

  const OnboardBannerScreen({super.key, required this.isLoggedIn});

  @override
  State<OnboardBannerScreen> createState() => _OnboardBannerScreenState();
}

class _OnboardBannerScreenState extends State<OnboardBannerScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  OnboardingUsecases onboardingUsecases = OnboardingUsecases(
    OnboardingDatasource(ApiImpl()),
  );
  List<BannersGetSet>? bannerList;

  @override
  void initState() {
    super.initState();
    getBanner();
  }

  getBanner() async {
    bannerList = await onboardingUsecases.getMainBanner(context);
    // Filter only banners where type == "splash"
    final filteredBanners = bannerList
        ?.where((banner) => banner.type?.toLowerCase() == "splash")
        .toList();
    setState(() {
      bannerList = filteredBanners;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: Stack(
        children: [
          // PageView (swipe enabled)
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: bannerList?.length,
            itemBuilder: (context, index) {
              return Image.network(
                bannerList?[index].image ??
                    "https://www.creativehatti.com/wp-content/uploads/2022/10/Portrait-template-of-a-t20-cricket-world-cup-2-small.jpg",
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              );
            },
          ),

          // Gradient overlay (non-interactive)
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.transparent,
                    AppColors.blackColor.withValues(alpha: 0.3),
                    AppColors.blackColor.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),

          // Overlay content (interactive)
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Page indicator dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    bannerList?.length ?? 0,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentIndex == index ? 12 : 8,
                      height: _currentIndex == index ? 12 : 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? AppColors.mainLightColor
                            : AppColors.greyColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Show Continue button only on the last image
                if (_currentIndex == (bannerList?.length ?? 0) - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainLightColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        widget.isLoggedIn
                            ? AppNavigation.gotoLandingScreen(context)
                            : AppNavigation.gotoLoginScreen(context);
                      },
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

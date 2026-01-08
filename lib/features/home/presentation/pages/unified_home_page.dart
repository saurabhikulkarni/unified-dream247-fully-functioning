import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/user_service.dart';
import '../../../../shared/components/app_bottom_nav_bar.dart';

/// Unified home screen that serves as the main dashboard
class UnifiedHomePage extends StatefulWidget {
  const UnifiedHomePage({super.key});

  @override
  State<UnifiedHomePage> createState() => _UnifiedHomePageState();
}

class _UnifiedHomePageState extends State<UnifiedHomePage> {
  final UserService _userService = getIt<UserService>();
  int _coins = 100;
  int _gems = 100;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final coins = await _userService.getCoins();
    final gems = await _userService.getGems();
    if (mounted) {
      setState(() {
        _coins = coins;
        _gems = gems;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar with coins and gems
              _buildTopBar(context),
              const SizedBox(height: 16),
              // Banner
              _buildPromoBanner(context),
              const SizedBox(height: 24),
              // Game Zone and Shop cards
              _buildActionCards(context),
              const SizedBox(height: 24),
              // Trend Starts Here section
              _buildTrendSection(context),
              const SizedBox(height: 24),
              // Top Picks section
              _buildTopPicksSection(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'DREAM247',
            style: TextStyles.h5.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          // Coins
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: AppColors.warning,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '$_coins',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Gems
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.diamond,
                  color: AppColors.info,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '$_gems',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Play FREE with',
                  style: TextStyles.bodyLarge.copyWith(
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'GAME TOKENS',
                  style: TextStyles.h4.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start your gaming journey today!',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.textWhite.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.rocket_launch,
            color: AppColors.textWhite,
            size: 48,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _ActionCard(
              title: 'GAME ZONE',
              icon: Icons.emoji_events,
              gradient: const LinearGradient(
                colors: [AppColors.gamingAccent, AppColors.gamingAccentLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => context.go(RouteNames.matches),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _ActionCard(
              title: 'SHOP',
              icon: Icons.card_giftcard,
              gradient: const LinearGradient(
                colors: [AppColors.ecommerceAccent, AppColors.ecommerceAccentLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => context.go(RouteNames.products),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TREND STARTS HERE',
                style: TextStyles.h5.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.go(RouteNames.products),
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: 5,
            itemBuilder: (context, index) {
              return _TrendProductCard(index: index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopPicksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOP PICKS',
                style: TextStyles.h5.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.go(RouteNames.products),
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return _TopPickCard(index: index);
            },
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppColors.textWhite,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyles.bodyLarge.copyWith(
                color: AppColors.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendProductCard extends StatelessWidget {
  final int index;

  const _TrendProductCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Icon(
                Icons.shopping_bag,
                size: 40,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product ${index + 1}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${(index + 1) * 999}',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
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

class _TopPickCard extends StatelessWidget {
  final int index;

  const _TopPickCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: Icon(
                  Icons.shopping_bag,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Pick ${index + 1}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${(index + 1) * 1499}',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
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

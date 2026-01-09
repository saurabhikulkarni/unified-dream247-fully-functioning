import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/user_service.dart';
import '../../../../shared/components/app_bottom_nav_bar.dart';
import '../../../shop/home/screens/shop_home_screen.dart';
import '../../../fantasy/landing/presentation/screens/fantasy_home_page.dart';

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
              // Top bar with user profile, coins and gems
              _buildTopBar(context),
              const SizedBox(height: 20),
              
              // Banner - Play FREE with GAME TOKENS
              _buildPromoBanner(context),
              const SizedBox(height: 24),
              
              // Game Zone and Shop cards
              _buildActionCards(context),
              const SizedBox(height: 32),
              
              // Trend Starts Here section
              _buildTrendSection(context),
              const SizedBox(height: 32),
              
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
      child: Row(
        children: [
          // User profile icon
          GestureDetector(
            onTap: () => context.go(RouteNames.profile),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF6441A5).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: Color(0xFF6441A5),
                size: 24,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Coin balance
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFA726).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFA726).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Text(
                  '🪙',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 4),
                Text(
                  '$_coins',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFA726),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Gem balance
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF29B6F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF29B6F6).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Text(
                  '💎',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 4),
                Text(
                  '$_gems',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF29B6F6),
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
      height: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6441A5),
            Color(0xFF472575),
            Color(0xFF2A0845),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6441A5).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Play FREE with',
                        style: TextStyles.bodyLarge.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'GAME TOKENS',
                        style: TextStyles.h3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          final userId = _userService.getUserId();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FantasyHomePage(userId: userId),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6441A5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Play now',
                          style: TextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Cricket players illustration
                const Icon(
                  Icons.sports_cricket,
                  size: 80,
                  color: Colors.white24,
                ),
              ],
            ),
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
              emoji: '🏆',
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6441A5),
                  Color(0xFF472575),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                final userId = _userService.getUserId();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FantasyHomePage(userId: userId),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _ActionCard(
              title: 'SHOP',
              icon: Icons.card_giftcard,
              emoji: '🎁',
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFE91E63),
                  Color(0xFFC2185B),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                final userId = _userService.getUserId();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShopHomeScreen(userId: userId),
                  ),
                );
              },
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TREND STARTS HERE',
                style: TextStyles.h5.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Shop the Latest Trends Now',
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
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
          child: Text(
            'TOP PICKS',
            style: TextStyles.h5.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
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
  final String emoji;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.emoji,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 56),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyles.h6.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
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
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(
              child: Icon(
                Icons.shopping_bag,
                size: 48,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trending Product ${index + 1}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${(index + 1) * 999}',
                  style: TextStyles.bodyMedium.copyWith(
                    color: const Color(0xFF6441A5),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 3),
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Icon(
                  Icons.shopping_bag,
                  size: 56,
                  color: AppColors.textSecondary.withOpacity(0.5),
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
                const SizedBox(height: 6),
                Text(
                  '₹${(index + 1) * 1499}',
                  style: TextStyles.bodyMedium.copyWith(
                    color: const Color(0xFF6441A5),
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

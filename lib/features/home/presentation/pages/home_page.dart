import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/text_styles.dart';
import '../../shared/components/app_bottom_nav_bar.dart';
import '../../shared/components/app_drawer.dart';
import '../../shared/components/custom_app_bar.dart';

/// Home page with bottom navigation
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Unified Dream247'),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back!',
                    style: TextStyles.h3.copyWith(color: AppColors.textWhite),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore shopping and gaming',
                    style: TextStyles.bodyMedium.copyWith(
                      color: AppColors.textWhite,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Quick access cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Access', style: TextStyles.h5),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAccessCard(
                          icon: Icons.shopping_bag,
                          title: 'Shop',
                          color: AppColors.ecommerceAccent,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _QuickAccessCard(
                          icon: Icons.sports_cricket,
                          title: 'Gaming',
                          color: AppColors.gamingAccent,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAccessCard(
                          icon: Icons.account_balance_wallet,
                          title: 'Wallet',
                          color: AppColors.primary,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _QuickAccessCard(
                          icon: Icons.person,
                          title: 'Profile',
                          color: AppColors.secondary,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(title, style: TextStyles.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

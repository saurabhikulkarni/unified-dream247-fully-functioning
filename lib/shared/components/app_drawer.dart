import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/routes/route_names.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/text_styles.dart';

/// App drawer for additional navigation
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.surface,
                  child: Icon(
                    Icons.person,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Welcome User',
                  style: TextStyles.h5.copyWith(color: AppColors.textWhite),
                ),
                const SizedBox(height: 4),
                Text(
                  'user@example.com',
                  style: TextStyles.bodySmall.copyWith(color: AppColors.textWhite),
                ),
              ],
            ),
          ),
          _DrawerItem(
            icon: Icons.home_outlined,
            title: 'Home',
            onTap: () {
              Navigator.pop(context);
              context.go(RouteNames.home);
            },
          ),
          _DrawerItem(
            icon: Icons.shopping_bag_outlined,
            title: 'Shop',
            onTap: () {
              Navigator.pop(context);
              context.go(RouteNames.products);
            },
          ),
          _DrawerItem(
            icon: Icons.sports_cricket_outlined,
            title: 'Gaming',
            onTap: () {
              Navigator.pop(context);
              context.go(RouteNames.matches);
            },
          ),
          _DrawerItem(
            icon: Icons.person_outlined,
            title: 'Profile',
            onTap: () {
              Navigator.pop(context);
              context.go(RouteNames.profile);
            },
          ),
          _DrawerItem(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Wallet',
            onTap: () {
              Navigator.pop(context);
              context.go(RouteNames.wallet);
            },
          ),
          const Divider(),
          _DrawerItem(
            icon: Icons.receipt_long_outlined,
            title: 'Orders',
            onTap: () {
              Navigator.pop(context);
              // Navigate to orders
            },
          ),
          _DrawerItem(
            icon: Icons.group_outlined,
            title: 'My Teams',
            onTap: () {
              Navigator.pop(context);
              // Navigate to teams
            },
          ),
          const Divider(),
          _DrawerItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings
            },
          ),
          _DrawerItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              Navigator.pop(context);
              // Navigate to help
            },
          ),
          _DrawerItem(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {
              Navigator.pop(context);
              // Navigate to about
            },
          ),
          const Divider(),
          _DrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              Navigator.pop(context);
              context.go(RouteNames.login);
            },
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: TextStyles.bodyMedium),
      onTap: onTap,
    );
  }
}

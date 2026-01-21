import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_pages.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/screens/my_balance_page.dart';
import 'package:unified_dream247/features/fantasy/menu_items/presentation/providers/user_data_provider.dart';
import 'package:provider/provider.dart';

class MainAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
    statusBarColor: AppColors.white,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );
  const MainAppbar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final userData =
        Provider.of<UserDataProvider>(context, listen: true).userData;
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: SizedBox(
            height: kToolbarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button and profile icon
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Back button
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: AppColors.white),
                        onPressed: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                      ),
                      const SizedBox(width: 8),
                      // Profile icon
                      GestureDetector(
                        onTap: () {
                          AppUtils.scaffoldKey.currentState?.openDrawer();
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.white.withAlpha(140),
                          backgroundImage: (userData?.image != null &&
                                  (userData?.image ?? '').isNotEmpty)
                              ? NetworkImage(userData?.image ?? '')
                              : const AssetImage(Images.imageDefalutPlayer)
                                  as ImageProvider,
                        ),
                      ),
                    ],
                  ),
                ),
                const Image(
                  image: AssetImage(Images.nameLogo),
                  color: AppColors.white,
                  height: 45,
                  width: 100,
                  fit: BoxFit.cover,
                ),
                // Right side icons
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          AppNavigation.gotoNotificationPage(context);
                        },
                        child: Image.asset(
                          Images.matchToken,
                          height: 20,
                        ),
                      ),
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const MyBalancePage()),
                          );
                        },
                        child: Image.asset(
                          Images.tokenImage,
                          // Images.imageWallet,
                          height: 25.h,
                          width: 25.w,
                          // color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

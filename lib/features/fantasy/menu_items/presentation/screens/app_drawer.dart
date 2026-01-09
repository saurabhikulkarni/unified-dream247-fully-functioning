import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:Dream247/features/onboarding/presentation/controllers/login_controller.dart';
import 'package:provider/provider.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/app_pages.dart';
import 'package:Dream247/core/app_constants/images.dart';
import 'package:Dream247/core/app_constants/strings.dart';
import 'package:Dream247/features/accounts/presentation/providers/wallet_details_provider.dart';
import 'package:Dream247/features/accounts/presentation/screens/add_money_page.dart';
import 'package:Dream247/features/accounts/presentation/screens/my_balance_page.dart';
import 'package:Dream247/features/menu_items/presentation/providers/user_data_provider.dart';
import 'package:Dream247/features/menu_items/presentation/screens/edit_profile_page.dart';
import 'package:Dream247/features/menu_items/presentation/screens/refer_and_earn_page.dart';
import 'package:Dream247/features/menu_items/presentation/screens/settings_page.dart';
import 'package:Dream247/features/menu_items/presentation/screens/support_page.dart';
import 'package:Dream247/features/menu_items/presentation/widgets/logout_dialogbox.dart';
import 'package:Dream247/features/user_verification/presentation/screens/verify_details_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userData =
        Provider.of<UserDataProvider>(context, listen: true).userData;
    final walletData =
        Provider.of<WalletDetailsProvider>(context, listen: true).walletData;
    Get.lazyPut<LoginController>(() => LoginController());

    return Drawer(
      backgroundColor: AppColors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.bgColor.withValues(alpha: 0.80),
                    AppColors.bgColor.withValues(alpha: 0.65),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border(
                  left: BorderSide(color: AppColors.greyColor, width: 0.8),
                ),
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // HEADER
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 26.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.appBarGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mainColor.withValues(alpha: 0.25),
                          offset: const Offset(0, 3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => Get.to(() => EditProfile()),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20.r,
                            backgroundColor:
                                AppColors.white.withValues(alpha: 0.55),
                            backgroundImage: (userData?.image != null &&
                                    userData!.image!.isNotEmpty)
                                ? NetworkImage(userData.image!)
                                : const AssetImage(Images.imageDefalutPlayer)
                                    as ImageProvider,
                          ),
                          14.horizontalSpace,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userData?.team ?? "User",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                5.verticalSpace,
                                Text(
                                  "${userData?.mobile ?? ""}",
                                  style: TextStyle(
                                    color:
                                        AppColors.white.withValues(alpha: 0.9),
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16.sp,
                            color: AppColors.white,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // WALLET CARD
                  Container(
                    margin: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.white.withValues(alpha: 0.85),
                          AppColors.white.withValues(alpha: 0.75),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blackColor.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => Get.to(() => MyBalancePage()),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  Images.icAddCash,
                                  color: AppColors.blackColor,
                                  width: 22.w,
                                  height: 22.h,
                                ),
                                10.horizontalSpace,
                                Text(
                                  Strings.myBalance,
                                  style: TextStyle(
                                    fontSize: 14.5.sp,
                                    color: AppColors.letterColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Image.asset(
                                  Images.matchToken,
                                  height: 15,
                                ),
                                Text(
                                  walletData?.bonus ?? "0.0",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.letterColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => Get.to(
                            () => AddMoneyPage(),
                            transition: Transition.cupertino,
                          ),
                          child: Container(
                            height: 42.h,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(18),
                                bottomRight: Radius.circular(18),
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.mainColor.withValues(alpha: 0.18),
                                  AppColors.mainColor.withValues(alpha: 0.08),
                                ],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  color: AppColors.mainColor,
                                  size: 18.sp,
                                ),
                                8.horizontalSpace,
                                Text(
                                  Strings.addCash.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.mainColor,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // MENU ITEMS
                  _drawerItem(
                    icon: Icons.verified_outlined,
                    title: "KYC (Verify Account)",
                    onTap: () => Get.to(() => VerifyDetailsPage()),
                  ),
                  _drawerItem(
                    svg: Images.referEarn,
                    title: Strings.referEarn,
                    onTap: () => Get.to(() => ReferAndEarnPage()),
                  ),
                  _drawerItem(
                    svg: Images.howToPlay,
                    title: "How to Play",
                    onTap: () => AppNavigation.gotoHowtoPlayPage(context),
                  ),
                  _drawerItem(
                    svg: Images.respplay,
                    title: "Responsible Gaming",
                    onTap: () =>
                        AppNavigation.gotoResponsibleGamingPage(context),
                  ),
                  _drawerItem(
                    svg: Images.settings,
                    title: Strings.settings,
                    onTap: () => Get.to(() => SettingsPage()),
                  ),
                  _drawerItem(
                    icon: Icons.headset_mic_outlined,
                    title: "24x7 Help & Support",
                    onTap: () => Get.to(() => SupportPage()),
                  ),
                  _drawerItem(
                    icon: Icons.logout,
                    title: Strings.logout,
                    onTap: () => Get.dialog(
                      const LogoutDialog(),
                      barrierDismissible: false,
                    ),
                  ),
                  const Divider(
                    // height: 15,
                    thickness: 0.4,
                    color: AppColors.greyColor,
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 36.h),
                    child: Center(
                      child: Image.asset(
                        Images.nameLogo,
                        colorBlendMode: BlendMode.lighten,
                        height: 150.h,
                        width: 180.w,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _drawerItem({
    IconData? icon,
    String? svg,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.mainColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 13.h),
          child: Row(
            children: [
              if (svg != null)
                SvgPicture.asset(
                  svg,
                  width: 22.w,
                  height: 22.h,
                  colorFilter: ColorFilter.mode(
                    AppColors.letterColor,
                    BlendMode.srcIn,
                  ),
                )
              else
                Icon(icon, size: 22, color: AppColors.letterColor),
              14.horizontalSpace,
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.letterColor,
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14.sp,
                color: AppColors.letterColor.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

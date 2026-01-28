// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_pages.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/screens/my_balance_page.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/presentation/widgets/upcoming_contest_timer.dart';

class UpcomingContestAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool showWalletIcon;
  final bool? showLeading;
  final Future<bool> Function()? onWillPop;
  final Function(int)? updateIndex;
  const UpcomingContestAppBar({
    super.key,
    required this.showWalletIcon,
    this.showLeading,
    this.onWillPop,
    this.updateIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(right: 10.0, top: 10.0, bottom: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () async {
                  if (onWillPop != null) {
                    bool canPop = await onWillPop!();
                    if (canPop) {
                      Navigator.pop(context);
                    }
                  } else {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      AppNavigation.gotoLandingScreen(context);
                    }
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 20,
                    color: AppColors.white,
                  ),
                ),
              ),
              UpcomingContestTimer(updateIndex: updateIndex),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
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
                                builder: (_) => const MyBalancePage(),),
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
                  // const SizedBox(width: 15.0),
                  // InkWell(
                  //   onTap: () {
                  //     AppNavigation.gotoNotificationScreen(context);
                  //   },
                  //   child: const Icon(
                  //     Icons.notifications_none,
                  //     color: Colors.white,
                  //     size: 25,
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int getNavigatorStackLength(BuildContext context) {
    return Navigator.of(context).widget.pages.length;
  }

  @override
  Size get preferredSize => const Size.fromHeight(65);
}

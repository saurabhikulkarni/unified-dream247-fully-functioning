import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_pages.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/screens/my_balance_page.dart';
import 'package:unified_dream247/features/fantasy/my_matches/presentation/widgets/live_contest_timer.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveContestAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showWalletIcon;
  final bool? showLeading;
  final String? mode;
  final bool transparent;
  const LiveContestAppBar({
    super.key,
    required this.showWalletIcon,
    this.showLeading,
    this.mode,
    this.transparent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: transparent
          ? const BoxDecoration()
          : const BoxDecoration(gradient: AppColors.appBarGradient),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(right: 10.0, top: 10.0, bottom: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        AppNavigation.gotoLandingScreen(context);
                      }
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 20,
                      color:
                          transparent ? AppColors.blackColor : AppColors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              LiveContestTimer(
                mode: mode,
                transparent: transparent,
              ),
              if (mode == 'Live')
                _liveBadge()
              else if (mode == 'Completed')
                _completedBadge()
              else if (showWalletIcon)
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

Widget _liveBadge() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.red.withOpacity(0.9),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.red.withOpacity(0.4),
          blurRadius: 6,
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 6,
          width: 6,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'LIVE',
          style: GoogleFonts.exo2(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.6,
          ),
        ),
      ],
    ),
  );
}

Widget _completedBadge() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.green.withOpacity(0.9),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.green.withOpacity(0.4),
          blurRadius: 6,
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 6,
          width: 6,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'COMPLETED',
          style: GoogleFonts.exo2(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.6,
          ),
        ),
      ],
    ),
  );
}

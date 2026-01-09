import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/features/my_matches/presentation/widgets/live_contest_appbar.dart';
import 'package:unified_dream247/features/fantasy/features/upcoming_matches/presentation/widgets/upcoming_contest_appbar.dart';

class ContestHead extends StatelessWidget {
  final bool showAppBar;
  final bool showWalletIcon;
  final Widget child;
  final bool addPadding;
  final bool? showLeading;
  final bool? isLiveContest;
  final String? mode;
  final Future<bool> Function()? onWillPop;
  final Function(int)? updateIndex;
  final Color safeAreaColor;
  final bool? extendBodyBehindAppbar;
  const ContestHead({
    super.key,
    required this.showAppBar,
    required this.showWalletIcon,
    required this.child,
    required this.addPadding,
    this.showLeading,
    this.mode,
    this.isLiveContest = true,
    this.extendBodyBehindAppbar = false,
    this.onWillPop,
    this.updateIndex,
    required this.safeAreaColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: safeAreaColor,
      child: SafeArea(
        bottom: true,
        top: false,
        child: SizedBox(
          height: double.infinity,
          child: Scaffold(
            extendBodyBehindAppBar: extendBodyBehindAppbar ?? false,
            backgroundColor: AppColors.white,
            appBar: showAppBar
                ? isLiveContest == true
                    ? PreferredSize(
                        preferredSize: const Size.fromHeight(kToolbarHeight),
                        child: LiveContestAppBar(
                          mode: mode,
                          showWalletIcon: showWalletIcon,
                          showLeading: showLeading,
                          transparent: extendBodyBehindAppbar == true,
                        ),
                      )
                    : PreferredSize(
                        preferredSize: const Size.fromHeight(kToolbarHeight),
                        child: UpcomingContestAppBar(
                          showWalletIcon: showWalletIcon,
                          showLeading: showLeading,
                          onWillPop: onWillPop,
                          updateIndex: updateIndex,
                        ),
                      )
                : AppBar(
                    toolbarHeight: 0,
                    backgroundColor: AppColors.transparent,
                  ),
            body: Padding(
              padding: addPadding
                  ? const EdgeInsets.fromLTRB(10, 15, 10, 10)
                  : const EdgeInsets.all(0),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/second_appbar.dart';

class SubContainer extends StatelessWidget {
  final bool showAppBar;
  final bool showWalletIcon;
  final Widget child;
  final String headerText;
  final bool? showTimer;
  final bool addPadding;
  final Future<bool> Function()? onBackPressed;

  const SubContainer({
    super.key,
    required this.showAppBar,
    required this.showWalletIcon,
    required this.child,
    required this.headerText,
    this.showTimer,
    required this.addPadding,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: SafeArea(
        bottom: true,
        top: false,
        child: WillPopScope(
          onWillPop: onBackPressed,
          child: SizedBox(
            height: double.infinity,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: AppColors.white,
              appBar: showAppBar
                  ? SecondAppbar(
                      showWalletIcon: showWalletIcon,
                      headerText: headerText,
                      onBackPressed: onBackPressed,
                    )
                  : AppBar(
                      toolbarHeight: 0,
                      backgroundColor: AppColors.transparent,
                    ),
              body: Padding(
                padding: addPadding
                    ? const EdgeInsets.fromLTRB(10, 10, 10, 10)
                    : const EdgeInsets.all(0),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/screens/my_balance_page.dart';

class SecondAppbar extends StatelessWidget implements PreferredSizeWidget {
  final bool showWalletIcon;
  final String headerText;
  final Future<bool> Function()? onBackPressed;

  const SecondAppbar({
    super.key,
    required this.headerText,
    required this.showWalletIcon,
    this.onBackPressed,
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
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      if (onBackPressed != null) {
                        final canGoBack = await onBackPressed!();
                        if (!canGoBack) return;
                      }
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 20,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Text(
                    headerText,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (showWalletIcon)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyBalancePage()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 8,
                    ),
                    child: Image.asset(
                      Images.icAddCash,
                      width: 30,
                      height: 30,
                      color: AppColors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(65);
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants.dart';
import '../../../../utils/responsive_extension.dart';

class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard({
    super.key,
    required this.balance,
    required this.onTabChargeBalance,
    this.shoppingTokens = 0,
  });

  final double balance;
  final int shoppingTokens;
  final VoidCallback onTabChargeBalance;

  @override
  Widget build(BuildContext context) {
    final cardHeight = context.isTablet ? context.height(25) : context.height(22);
    final titleFontSize = context.fontSize(16, minSize: 14, maxSize: 20);
    final tokenFontSize = context.fontSize(36, minSize: 28, maxSize: 44);
    final iconSize = context.isTablet ? 32.0 : 28.0;
    
    return SizedBox(
      height: cardHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(defaultPadding),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6441A5),
                Color(0xFF472575),
                Color(0xFF2A0845),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Available Shopping Token Text
              Text(
                "Available Shopping Tokens",
                style: TextStyle(
                    color: whileColor80,
                    fontWeight: FontWeight.w500,
                    fontSize: titleFontSize),
              ),
              SizedBox(height: context.responsiveSpacing),
              // Shopping Tokens - Centered
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/coin.svg',
                    width: iconSize,
                    height: iconSize,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    shoppingTokens.toString(),
                    style: TextStyle(
                      fontSize: tokenFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
}

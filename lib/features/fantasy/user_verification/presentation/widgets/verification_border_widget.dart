import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';

class VerificationBorderWidget extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Widget? child;
  final BorderRadius? borderRadius;
  final double? height;

  const VerificationBorderWidget({
    super.key,
    this.padding,
    this.margin,
    this.child,
    this.borderRadius,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        color: AppColors.white,
        border: Border.all(
          color: const Color(0xFFDfdfdf),
          width: 2.5,
        ),
      ),
      child: child,
    );
  }
}

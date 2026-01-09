import 'package:flutter/material.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';

class MainContainer extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Widget? child;
  final Color? color;
  final BorderRadius? borderRadius;
  final double? height;

  const MainContainer({
    super.key,
    this.padding,
    this.margin,
    this.child,
    this.color,
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
        color: color ?? AppColors.white,
        border: Border.all(color: AppColors.whiteFade1, width: 1.5),
      ),
      child: child,
    );
  }
}

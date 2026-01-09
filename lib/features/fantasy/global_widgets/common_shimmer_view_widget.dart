import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';

class ShimmerWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  const ShimmerWidget({
    super.key,
    this.height,
    this.width,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.whiteFade1,
      highlightColor: AppColors.lightGrey,
      child: Container(
        height: height ?? 150,
        width: width ?? double.infinity,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(10),
          color: AppColors.whiteFade1.withAlpha(102),
        ),
      ),
    );
  }
}

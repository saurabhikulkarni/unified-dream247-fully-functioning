import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/theme/app_colors.dart';

/// Loading indicator widget
class LoadingIndicator extends StatelessWidget {
  final LoadingType type;
  final double size;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.type = LoadingType.circular,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case LoadingType.circular:
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primary,
              ),
            ),
          ),
        );
      
      case LoadingType.linear:
        return LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primary,
          ),
        );
    }
  }
}

/// Shimmer loading effect for list items
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: AppColors.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Shimmer loading for card items
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerLoading(width: double.infinity, height: 150),
            SizedBox(height: 12),
            ShimmerLoading(width: 200, height: 20),
            SizedBox(height: 8),
            ShimmerLoading(width: 150, height: 16),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerLoading(width: 80, height: 16),
                ShimmerLoading(width: 60, height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading for list items
class ShimmerList extends StatelessWidget {
  final int itemCount;

  const ShimmerList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => const ShimmerCard(),
    );
  }
}

enum LoadingType { circular, linear }

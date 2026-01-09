import 'package:flutter/material.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class MyMatchShimmerViewWidget extends StatelessWidget {
  const MyMatchShimmerViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      child: Shimmer.fromColors(
        baseColor: AppColors.editTextColor,
        highlightColor: AppColors.lightCard,
        child: Container(
          height: 155,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.editTextColor, width: 0.2),
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left team section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _teamRowSkeleton(),
                          const SizedBox(height: 12),
                          _teamRowSkeleton(),
                        ],
                      ),
                    ),

                    // Divider
                    Container(height: 40, width: 2, color: AppColors.lightCard),

                    const SizedBox(width: 10),

                    // Right status area
                    Column(
                      children: [
                        _shimmerBox(height: 12, width: 50),
                        const SizedBox(height: 8),
                        _shimmerBox(height: 10, width: 60),
                      ],
                    )
                  ],
                ),
              ),

              // Divider
              Divider(
                color: AppColors.lightGrey,
                thickness: 0.3,
                height: 0.3,
              ),

              // Footer row
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _shimmerBox(height: 14, width: 40),
                        const SizedBox(width: 6),
                        _shimmerBox(height: 12, width: 50),
                        const SizedBox(width: 8),
                        _shimmerCircle(size: 8),
                        const SizedBox(width: 8),
                        _shimmerBox(height: 14, width: 40),
                        const SizedBox(width: 6),
                        _shimmerBox(height: 12, width: 50),
                      ],
                    ),
                    _shimmerBox(height: 16, width: 90),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamRowSkeleton() {
    return Row(
      children: [
        _shimmerCircle(size: 28),
        const SizedBox(width: 8),
        _shimmerBox(height: 16, width: 50),
        const SizedBox(width: 8),
        Expanded(child: _shimmerBox(height: 12)),
      ],
    );
  }

  Widget _shimmerBox({required double height, double? width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _shimmerCircle({required double size}) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

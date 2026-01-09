import 'package:flutter/material.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/global_widgets/common_shimmer_view_widget.dart';

class MatchListShimmerViewWidget extends StatelessWidget {
  const MatchListShimmerViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 160,
          margin:
              const EdgeInsets.only(top: 20, bottom: 10, left: 15, right: 15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.lightCard,
                AppColors.lightGrey,
              ],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                // Series name
                const ShimmerWidget(height: 14, width: 140),
                const SizedBox(height: 10),

                // Team Logos + Names + VS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShimmerWidget(
                        height: 26,
                        width: 26,
                        borderRadius: BorderRadius.circular(50)),
                    SizedBox(width: 6),
                    ShimmerWidget(height: 14, width: 40),
                    SizedBox(width: 5),
                    ShimmerWidget(height: 12, width: 12),
                    SizedBox(width: 6),
                    ShimmerWidget(height: 14, width: 40),
                    SizedBox(width: 6),
                    ShimmerWidget(
                        height: 26,
                        width: 26,
                        borderRadius: BorderRadius.circular(50)),
                  ],
                ),
                const SizedBox(height: 8),

                // Countdown + time
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    ShimmerWidget(height: 12, width: 50),
                    SizedBox(width: 6),
                    ShimmerWidget(height: 12, width: 40),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Left Player Image Placeholder
        // Positioned(
        //   left: 0,
        //   top: 0,
        //   child: Padding(
        //     padding: const EdgeInsets.only(left: 8.0),
        //     child: const ShimmerWidget(height: 150, width: 80),
        //   ),
        // ),

        // Right Player Image Placeholder
        // Positioned(
        //   right: 0,
        //   top: 0,
        //   child: Padding(
        //     padding: const EdgeInsets.only(right: 8.0),
        //     child: const ShimmerWidget(height: 150, width: 80),
        //   ),
        // ),

        // Bottom Bar
        // Positioned(
        //   left: 20,
        //   right: 20,
        //   bottom: 20,
        //   child: Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        //     decoration: BoxDecoration(
        //       color: AppColors.white,
        //       borderRadius: BorderRadius.circular(14),
        //       boxShadow: [
        //         BoxShadow(
        //           color: AppColors.black.withAlpha(50),
        //           blurRadius: 6,
        //           offset: const Offset(0, 2),
        //         ),
        //       ],
        //     ),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: const [
        //         ShimmerWidget(height: 14, width: 80),
        //         ShimmerWidget(height: 20, width: 120),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/common_shimmer_view_widget.dart';

class JoinedContestShimmerWidget extends StatelessWidget {
  const JoinedContestShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.all(10).copyWith(bottom: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.white,
        border: Border.all(color: AppColors.whiteFade1, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 3,
                      ),
                      child: Row(
                        children: [
                          Opacity(
                            opacity: 0.2,
                            child: Image.asset(
                              Images.verified,
                              height: 15,
                              width: 15,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const ShimmerWidget(height: 14, width: 100),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(4),
                      child: ShimmerWidget(height: 16, width: 60),
                    ),
                  ],
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                      child: Text(
                        'Entry',
                        style: TextStyle(
                          color: AppColors.letterColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(3),
                      child: ShimmerWidget(height: 16, width: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.whiteFade1.withAlpha(50),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: 0.2,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(Images.winner, height: 18, width: 18),
                          const Text(
                            '1',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.letterColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const ShimmerWidget(height: 14, width: 20),
                  ],
                ),
                const SizedBox(width: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: 0.2,
                      child: Icon(
                        Icons.emoji_events_outlined,
                        size: 16,
                        color: AppColors.letterColor,
                      ),
                    ),
                    ShimmerWidget(height: 14, width: 20),
                  ],
                ),
                const SizedBox(width: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: 0.2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const ShimmerWidget(
                          height: 12,
                          width: 20,
                        ),
                      ),
                    ),
                    const ShimmerWidget(height: 14, width: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

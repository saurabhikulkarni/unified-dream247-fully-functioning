import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/common_shimmer_view_widget.dart';

class UpcomingLeaderboardShimmerWidget extends StatelessWidget {
  const UpcomingLeaderboardShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.transparent,
                  child: ClipOval(
                      child: ShimmerWidget(
                    height: 40,
                    width: 40,
                  )),
                ),
                Flexible(
                  child: Row(
                    children: [
                      const Flexible(
                          child: ShimmerWidget(
                        height: 10,
                        width: 100,
                      )),
                      Container(
                          margin: const EdgeInsets.only(left: 5),
                          color: AppColors.lightCard,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 3, vertical: 3),
                          child: const ShimmerWidget(
                            height: 5,
                            width: 10,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

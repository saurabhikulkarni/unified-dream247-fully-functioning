import 'package:flutter/material.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/global_widgets/common_shimmer_view_widget.dart';

class LiveLeaderboardShimmerWidget extends StatelessWidget {
  const LiveLeaderboardShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.white,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.transparent,
                        child: ClipOval(
                          child: ShimmerWidget(height: 40, width: 40),
                        ),
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Flexible(
                                  child: ShimmerWidget(height: 10, width: 100),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 5),
                                  color: AppColors.bgColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                    vertical: 3,
                                  ),
                                  child: const ShimmerWidget(
                                    height: 5,
                                    width: 10,
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.all(1),
                              child: ShimmerWidget(height: 10, width: 40),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const ShimmerWidget(
                height: 20,
                margin: EdgeInsets.all(10),
                width: 30,
              ),
              const SizedBox(width: 30),
              const ShimmerWidget(
                height: 20,
                margin: EdgeInsets.all(10),
                width: 30,
              ),
            ],
          ),
        ),
        const Divider(
          color: AppColors.letterColor,
          thickness: 0.1,
          height: 0.1,
        ),
      ],
    );
  }
}

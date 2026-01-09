import 'dart:math';

import 'package:flutter/material.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/images.dart';
import 'package:Dream247/core/global_widgets/common_shimmer_view_widget.dart';

class TeamCompareShimmer extends StatelessWidget {
  const TeamCompareShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipOval(
                    child: ShimmerWidget(
                      borderRadius: BorderRadius.circular(50.0),
                      height: 30,
                      width: 30,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const ShimmerWidget(height: 12, width: 80),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const ShimmerWidget(height: 12, width: 80),
                  const SizedBox(width: 5),
                  ClipOval(
                    child: ShimmerWidget(
                      borderRadius: BorderRadius.circular(50.0),
                      height: 30,
                      width: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              const Center(
                child: Text(
                  'Total Points',
                  style: TextStyle(
                    color: AppColors.letterColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const ShimmerWidget(height: 12, width: 30),
                    Transform.rotate(
                      angle: 30 * (pi / 180),
                      child: Container(
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        width: 1,
                        height: 20,
                        color: AppColors.greyColor,
                      ),
                    ),
                    const ShimmerWidget(height: 12, width: 30),
                  ],
                ),
              ),
              const SizedBox(height: 5.0),
              const ShimmerWidget(height: 12, width: 100),
            ],
          ),
          const SizedBox(height: 15),
          const Center(
            child: Text(
              'Different Players',
              style: TextStyle(
                color: AppColors.letterColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const ShimmerWidget(height: 12, width: 120),
          Column(
            children: List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ShimmerWidget(
                            height: 20,
                            width: 30,
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          const SizedBox(width: 4),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShimmerWidget(height: 12, width: 80),
                                ShimmerWidget(height: 12, width: 60),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: SizedBox(
                              height: 24,
                              child: Image.asset(Images.imageTeamCompareBg),
                            ),
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ShimmerWidget(height: 12, width: 30),
                              SizedBox(width: 15),
                              ShimmerWidget(height: 12, width: 30),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ShimmerWidget(height: 12, width: 80),
                                ShimmerWidget(height: 12, width: 60),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          ShimmerWidget(
                            height: 20,
                            width: 30,
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 15),
          const Center(
            child: Text(
              'Captain & Vice Captain',
              style: TextStyle(
                color: AppColors.letterColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Column(
            children: List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ShimmerWidget(
                            height: 20,
                            width: 30,
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          const SizedBox(width: 4),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShimmerWidget(height: 12, width: 80),
                                ShimmerWidget(height: 12, width: 60),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: SizedBox(
                              height: 24,
                              child: Image.asset(Images.imageTeamCompareBg),
                            ),
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ShimmerWidget(height: 12, width: 30),
                              SizedBox(width: 15),
                              ShimmerWidget(height: 12, width: 30),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ShimmerWidget(height: 12, width: 80),
                                ShimmerWidget(height: 12, width: 60),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          ShimmerWidget(
                            height: 20,
                            width: 30,
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Common Players',
                  style: TextStyle(
                    color: AppColors.letterColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Column(
                children: List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ShimmerWidget(
                                height: 20,
                                width: 30,
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              const SizedBox(width: 4),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShimmerWidget(height: 12, width: 80),
                                    ShimmerWidget(height: 12, width: 60),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Center(
                                child: SizedBox(
                                  height: 24,
                                  child: Image.asset(Images.imageTeamCompareBg),
                                ),
                              ),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ShimmerWidget(height: 12, width: 30),
                                  SizedBox(width: 15),
                                  ShimmerWidget(height: 12, width: 30),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    ShimmerWidget(height: 12, width: 80),
                                    ShimmerWidget(height: 12, width: 60),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              ShimmerWidget(
                                height: 20,
                                width: 30,
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

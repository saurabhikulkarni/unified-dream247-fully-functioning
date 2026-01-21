import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/common_shimmer_view_widget.dart';

class ContestShimmerViewWidget extends StatelessWidget {
  const ContestShimmerViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.all(10).copyWith(bottom: 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.white,
            border: Border.all(color: AppColors.whiteFade1, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10).copyWith(bottom: 0),
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
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: ShimmerWidget(height: 25, width: 80),
                  ),
                  ShimmerWidget(
                    height: 12,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ShimmerWidget(height: 12, width: 60),
                        ShimmerWidget(height: 12, width: 60),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.whiteFade1.withAlpha(51),
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
        ),
        const Positioned(
          top: 40,
          right: 25,
          child: ShimmerWidget(height: 30, width: 100),
        ),
      ],
    );
  }
}

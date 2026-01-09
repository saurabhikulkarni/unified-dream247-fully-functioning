import 'package:flutter/material.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/global_widgets/common_shimmer_view_widget.dart';

class PlayerCardShimmer extends StatelessWidget {
  const PlayerCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.white),
      child: Padding(
        padding: const EdgeInsets.only(right: 10, top: 4, bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 10),
              width: 60,
              height: 60,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  ShimmerWidget(
                    borderRadius: BorderRadius.circular(100),
                    height: 50,
                    width: 50,
                  ),
                  const Align(
                    alignment: Alignment.bottomLeft,
                    child: ShimmerWidget(height: 12, width: 35),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 0,
                right: 8,
              ),
              width: MediaQuery.of(context).size.width - 250,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ShimmerWidget(
                    height: 12,
                    width: 120,
                    margin: EdgeInsets.symmetric(vertical: 2),
                  ),
                  ShimmerWidget(
                    height: 12,
                    width: 90,
                    margin: EdgeInsets.symmetric(vertical: 2),
                  ),
                  ShimmerWidget(
                    height: 10,
                    width: 70,
                    margin: EdgeInsets.symmetric(vertical: 2),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 40),
              width: 25,
              child: const ShimmerWidget(height: 14, width: 25),
            ),
            Container(
              margin: const EdgeInsets.only(right: 20),
              child: const SizedBox(
                width: 25,
                child: ShimmerWidget(height: 14, width: 25),
              ),
            ),
            ShimmerWidget(
              height: 25,
              width: 25,
              borderRadius: BorderRadius.circular(100),
            ),
          ],
        ),
      ),
    );
  }
}

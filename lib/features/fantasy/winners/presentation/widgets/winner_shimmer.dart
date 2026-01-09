import 'package:flutter/material.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/global_widgets/common_shimmer_view_widget.dart';

class WinnerShimmer extends StatelessWidget {
  const WinnerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.white,
        border: Border.all(color: AppColors.whiteFade1, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ShimmerWidget(
                  height: 20,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 25),
              Expanded(
                child: ShimmerWidget(
                  height: 20,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ShimmerWidget(
                  height: 40,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 25),
              Expanded(
                child: ShimmerWidget(
                  height: 40,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ShimmerWidget(
            height: 30,
            width: MediaQuery.of(context).size.width / 3,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 160,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              itemBuilder: (context, index) {
                return const ShimmerWidget(
                  width: 80,
                  height: 90,
                  margin: EdgeInsets.only(right: 10),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

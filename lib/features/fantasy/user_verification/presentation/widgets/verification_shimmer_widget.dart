import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/common_shimmer_view_widget.dart';
import 'package:unified_dream247/features/fantasy/user_verification/presentation/widgets/verification_border_widget.dart';

class VerificationShimmerWidget extends StatelessWidget {
  final String image;
  const VerificationShimmerWidget({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return VerificationBorderWidget(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.asset(
                image,
                height: 40,
                width: 40,
              ),
              const SizedBox(
                width: 10,
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerWidget(
                    height: 12,
                    width: 100,
                    margin: EdgeInsets.all(3),
                  ),
                  ShimmerWidget(
                    height: 12,
                    width: 80,
                    margin: EdgeInsets.all(3),
                  ),
                ],
              ),
              const Spacer(),
              const ShimmerWidget(height: 24, width: 24),
            ],
          ),
        ],
      ),
    );
  }
}

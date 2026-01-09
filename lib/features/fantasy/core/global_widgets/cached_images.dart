import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final Widget? errorWidget;
  const CachedImage({super.key, required this.imageUrl, this.errorWidget});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      placeholder: (context, url) => Center(
        child: Shimmer.fromColors(
          baseColor: AppColors.shade1White,
          highlightColor: AppColors.greyColor,
          child: SizedBox(height: 50, width: 50),
        ),
      ),
      errorWidget: (context, url, error) =>
          errorWidget ?? Image.asset(Images.logo, fit: BoxFit.cover),
    );
  }
}

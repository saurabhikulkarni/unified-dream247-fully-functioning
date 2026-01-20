import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:unified_dream247/features/shop/constants.dart';
import 'skleton/skelton.dart';

class NetworkImageWithLoader extends StatelessWidget {
  final BoxFit fit;

  const NetworkImageWithLoader(
    this.src, {
    super.key,
    this.fit = BoxFit.cover,
    this.radius = defaultPadding,
  });

  final String src;
  final double radius;

  @override
  Widget build(BuildContext context) {
    // Handle empty or invalid URLs
    if (src.isEmpty || !src.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        child: Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 40,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: CachedNetworkImage(
        fit: fit,
        imageUrl: src,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: fit,
            ),
          ),
        ),
        placeholder: (context, url) => const Skeleton(),
        errorWidget: (context, url, error) {
          debugPrint('[IMAGE_LOADER] Error loading image: $url - $error');
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 40,
                color: Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }
}

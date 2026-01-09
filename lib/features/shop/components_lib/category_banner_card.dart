import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/utils/responsive_extension.dart';

class CategoryBannerCard extends StatelessWidget {
  const CategoryBannerCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.buttonText,
    required this.onPressed,
    this.backgroundColor,
  });

  final String title;
  final String subtitle;
  final String image;
  final String buttonText;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(defaultBorderRadious),
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: image.startsWith('http')
                ? NetworkImageWithLoader(
                    image,
                    radius: defaultBorderRadious,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    image,
                    fit: BoxFit.cover,
                  ),
          ),
          // Dark overlay
          Container(
            color: Colors.black38,
          ),
          // Content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title and Subtitle Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                              fontSize: context.fontSize(12, minSize: 10, maxSize: 14),
                            ),
                      ),
                      const SizedBox(height: defaultPadding / 4),
                      // Title
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  // Shop Now Button
                  SizedBox(
                    width: context.isTablet ? 110 : 90,
                    child: ElevatedButton(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: context.responsiveSpacing / 2,
                          vertical: context.responsiveSpacing / 3,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: context.fontSize(11, minSize: 9, maxSize: 13),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

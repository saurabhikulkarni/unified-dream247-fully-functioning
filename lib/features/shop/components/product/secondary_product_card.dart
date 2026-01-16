import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/shop/utils/responsive_extension.dart';
import '../network_image_with_loader.dart';

class SecondaryProductCard extends StatelessWidget {
  const SecondaryProductCard({
    super.key,
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
    this.priceAfetDiscount,
    this.press,
    this.style,
  });
  final String image, brandName, title;
  final double price;
  final double? priceAfetDiscount;
  final VoidCallback? press;

  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final cardWidth = context.isTablet ? context.width(35) : context.width(68);
    final cardHeight = context.isTablet ? context.height(18) : context.height(14);
    final fontSize = context.fontSize(10, minSize: 8, maxSize: 12);
    final titleFontSize = context.fontSize(12, minSize: 10, maxSize: 14);
    final priceFontSize = context.fontSize(12, minSize: 10, maxSize: 14);
    final iconSize = context.isTablet ? 16.0 : 14.0;
    final smallIconSize = context.isTablet ? 14.0 : 12.0;
    
    return OutlinedButton(
      onPressed: () {},
      style: style ??
          OutlinedButton.styleFrom(
              minimumSize: Size(cardWidth, cardHeight),
              maximumSize: Size(cardWidth, cardHeight),
              padding: EdgeInsets.all(context.responsiveSpacing)),
      child: Row(
        children: [
          AspectRatio(
            aspectRatio: 1.15,
            child: Stack(
              children: [
                NetworkImageWithLoader(image, radius: defaultBorderRadious),
              ],
            ),
          ),
          const SizedBox(width: defaultPadding / 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brandName.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontSize: fontSize),
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontSize: titleFontSize),
                  ),
                  const Spacer(),
                  priceAfetDiscount != null
                      ? Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/coin.svg',
                              width: iconSize,
                              height: iconSize,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              "${priceAfetDiscount!.toInt()}",
                              style: TextStyle(
                                color: const Color(0xFF31B0D8),
                                fontWeight: FontWeight.w500,
                                fontSize: priceFontSize,
                              ),
                            ),
                            const SizedBox(width: defaultPadding / 4),
                              Opacity(
                                opacity: 0.5,
                                child: SvgPicture.asset(
                                  'assets/icons/coin.svg',
                                  width: smallIconSize,
                                  height: smallIconSize,
                                ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              "${price.toInt()}",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                                fontSize: priceFontSize - 2,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/coin.svg',
                              width: iconSize,
                              height: iconSize,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              "${price.toInt()}",
                              style: TextStyle(
                                color: const Color(0xFF31B0D8),
                                fontWeight: FontWeight.w500,
                                fontSize: priceFontSize,
                              ),
                            ),
                          ],
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

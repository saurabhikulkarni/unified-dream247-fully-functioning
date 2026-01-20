import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart';

import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/shop/utils/responsive_extension.dart';
import '../network_image_with_loader.dart';
import 'package:unified_dream247/features/shop/services/wishlist_service.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
    this.priceAfetDiscount,
    required this.press,
    this.productId,
    this.product,
    this.onWishlistChanged,
  });
  
  final String image, brandName, title;
  final double price;
  final double? priceAfetDiscount;
  final VoidCallback press;
  final String? productId;
  final dynamic product;
  final Function(bool)? onWishlistChanged;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isInWishlist = false;

  @override
  void initState() {
    super.initState();
    _checkWishlistStatus();
  }

  @override
  void didUpdateWidget(ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-check wishlist status when widget updates
    if (oldWidget.productId != widget.productId || oldWidget.product != widget.product) {
      _checkWishlistStatus();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-check wishlist status when dependencies change
    _checkWishlistStatus();
  }

  void _checkWishlistStatus() {
    // Check using productId if available
    if (widget.productId != null) {
      final inWishlist = wishlistService.isInWishlist(widget.productId!);
      if (kDebugMode) {
        print('🔍 [PRODUCT_CARD] Checking wishlist for product: ${widget.productId} - In Wishlist: $inWishlist');
      }
      setState(() {
        _isInWishlist = inWishlist;
      });
    } 
    // Otherwise check using product.id if product is available
    else if (widget.product != null && widget.product.id != null) {
      final inWishlist = wishlistService.isInWishlist(widget.product.id!);
      if (kDebugMode) {
        print('🔍 [PRODUCT_CARD] Checking wishlist for product: ${widget.product.id} - In Wishlist: $inWishlist');
      }
      setState(() {
        _isInWishlist = inWishlist;
      });
    }
  }

  Future<void> _toggleWishlist(BuildContext context) async {
    if (widget.product != null) {
      final newState = await wishlistService.toggleWishlist(widget.product);
      setState(() {
        _isInWishlist = newState;
      });
      
      widget.onWishlistChanged?.call(newState);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isInWishlist
                ? '${widget.title} added to wishlist'
                : '${widget.title} removed from wishlist',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = context.isTablet ? context.width(20) : context.width(37);
    final cardHeight = context.isTablet ? context.height(32) : context.height(27);
    final fontSize = context.fontSize(10, minSize: 8, maxSize: 14);
    final titleFontSize = context.fontSize(12, minSize: 10, maxSize: 16);
    final priceFontSize = context.fontSize(12, minSize: 10, maxSize: 14);
    final iconSize = context.isTablet ? 18.0 : 14.0;
    final smallIconSize = context.isTablet ? 16.0 : 12.0;
    final heartIconSize = context.isTablet ? 20.0 : 16.0;
    
    return Stack(
      children: [
        OutlinedButton(
          onPressed: widget.press,
          style: OutlinedButton.styleFrom(
              minimumSize: Size(cardWidth.toDouble(), cardHeight.toDouble()),
              maximumSize: Size(cardWidth.toDouble(), cardHeight.toDouble()),
              padding: EdgeInsets.all(context.responsiveSpacing)),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1.15,
                child: Stack(
                  children: [
                    NetworkImageWithLoader(widget.image, radius: defaultBorderRadious),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: context.responsiveSpacing / 2, 
                      vertical: context.responsiveSpacing / 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          widget.brandName.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontSize: fontSize),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          widget.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(fontSize: titleFontSize),
                        ),
                      ),
                      const Spacer(),
                      widget.priceAfetDiscount != null
                          ? Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/coin.svg',
                                    width: iconSize,
                                    height: iconSize,
                                  ),
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: Text(
                                      "${widget.priceAfetDiscount!.toInt()}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: const Color(0xFF31B0D8),
                                        fontWeight: FontWeight.w500,
                                        fontSize: priceFontSize,
                                      ),
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
                                  Flexible(
                                    child: Text(
                                      "${widget.price.toInt()}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                                        fontSize: priceFontSize - 2,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/coin.svg',
                                    width: iconSize,
                                    height: iconSize,
                                  ),
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: Text(
                                      "${widget.price.toInt()}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: const Color(0xFF31B0D8),
                                        fontWeight: FontWeight.w500,
                                        fontSize: priceFontSize,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Heart Icon in top-right
        if (widget.product != null)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _toggleWishlist(context),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: SvgPicture.asset(
                  'assets/icons/Wishlist.svg',
                  width: heartIconSize,
                  height: heartIconSize,
                  colorFilter: ColorFilter.mode(
                    _isInWishlist ? Colors.red : Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

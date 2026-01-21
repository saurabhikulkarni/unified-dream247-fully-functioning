import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:unified_dream247/features/shop/components/cart_button.dart';
import 'package:unified_dream247/features/shop/components/custom_modal_bottom_sheet.dart';
import 'package:unified_dream247/features/shop/components/product/product_card.dart';
import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/shop/models/product_model.dart';
import 'package:unified_dream247/features/shop/services/product_service.dart';
import 'package:unified_dream247/features/shop/services/wishlist_service.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;

import 'components/notify_me_card.dart';
import 'components/product_images.dart';
import 'components/product_info.dart';
import 'components/product_list_tile.dart';
import 'components/selected_size.dart';
import 'package:unified_dream247/features/shop/components/review_card.dart';
import 'product_buy_now_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({
    super.key,
    this.isProductAvailable = true,
    this.productId,
    this.product,
  });

  final bool isProductAvailable;
  final String? productId;
  final ProductModel? product;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ProductService _productService = ProductService();
  ProductModel? _product;
  List<SizeModel> _sizes = [];
  List<ProductModel> _relatedProducts = [];
  bool _isLoading = true;
  bool _isInWishlist = false;
  int _selectedSizeIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _product = widget.product;
      _checkWishlistStatus();
      _isLoading = false;
      _fetchSizes();
      _fetchRelatedProducts();
    } else if (widget.productId != null) {
      _fetchProductDetails();
    } else {
      _isLoading = false;
    }
  }

  void _checkWishlistStatus() {
    if (_product?.id != null) {
      setState(() {
        _isInWishlist = wishlistService.isInWishlist(_product!.id!);
      });
    }
  }

  Future<void> _fetchProductDetails() async {
    try {
      final product = await _productService.getProductById(widget.productId!);
      if (mounted) {
        setState(() {
          _product = product;
          _isLoading = false;
        });
        _fetchSizes();
        _fetchRelatedProducts();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchSizes() async {
    if (_product?.id == null) {
      debugPrint('⚠️ [PRODUCT_DETAILS] No product ID, skipping size fetch');
      return;
    }
    try {
      debugPrint('🔄 [PRODUCT_DETAILS] Fetching sizes for product: ${_product!.id}');
      final sizes = await _productService.getSizesByProduct(_product!.id!);
      debugPrint('✅ [PRODUCT_DETAILS] Fetched ${sizes.length} sizes: ${sizes.map((s) => s.sizeName).toList()}');
      if (mounted) {
        setState(() {
          _sizes = sizes;
          // Auto-select first available size
          if (_sizes.isNotEmpty) {
            final availableIndex = _sizes.indexWhere((s) => s.quantity > 0);
            _selectedSizeIndex = availableIndex >= 0 ? availableIndex : 0;
          }
        });
      }
    } catch (e) {
      debugPrint('❌ [PRODUCT_DETAILS] Error fetching sizes: $e');
    }
  }

  Future<void> _fetchRelatedProducts() async {
    try {
      final products = await _productService.getAllProducts();
      if (mounted) {
        setState(() {
          // Filter out current product and take first 5
          _relatedProducts = products
              .where((p) => p.id != _product?.id)
              .take(5)
              .toList();
        });
      }
    } catch (e) {
      // Related products not available
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Product not found')),
      );
    }

    final bool isAvailable = widget.isProductAvailable;

    return Scaffold(
      bottomNavigationBar: isAvailable
          ? CartButton(
              price: _product!.price,
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: ProductBuyNowScreen(
                    product: _product!,
                    sizes: _sizes,
                    initialSizeIndex: _selectedSizeIndex,
                  ),
                );
              },
            )
          : NotifyMeCard(
              isNotify: false,
              onChanged: (value) {},
            ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floating: true,
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              actions: [
                IconButton(
                  onPressed: () async {
                    if (_product != null) {
                      final newState = await wishlistService.toggleWishlist(_product!);
                      setState(() {
                        _isInWishlist = newState;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isInWishlist
                                ? '${_product!.title} added to wishlist'
                                : '${_product!.title} removed from wishlist',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/Wishlist.svg',
                    color: _isInWishlist
                        ? Colors.red
                        : Theme.of(context).textTheme.bodyLarge!.color,
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
            ProductImages(
              images: _product!.images.isNotEmpty
                  ? _product!.images
                  : (_product!.image.isNotEmpty 
                      ? [_product!.image]
                      : [productDemoImg1, productDemoImg2, productDemoImg3]),
            ),
            ProductInfo(
              brand: _product!.brandName,
              title: _product!.title,
              isAvailable: isAvailable,
              description: _product!.description ?? 
                  'A premium quality product with excellent durability. Made from sustainable materials with attention to detail.',
              rating: 4.4,
              numOfReviews: 126,
            ),
            // Size Selection - Above Product Details
            SliverToBoxAdapter(
              child: _sizes.isNotEmpty
                  ? SelectedSize(
                      sizes: _sizes.map((s) => s.sizeName).toList(),
                      selectedIndex: _selectedSizeIndex,
                      availableIndices: _sizes
                          .asMap()
                          .entries
                          .where((entry) => entry.value.quantity > 0)
                          .map((entry) => entry.key)
                          .toList(),
                      press: (index) {
                        setState(() {
                          _selectedSizeIndex = index;
                        });
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Size',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'One size fits all',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: defaultPadding),
                        ],
                      ),
                    ),
            ),
            ProductListTile(
              svgSrc: 'assets/icons/Product.svg',
              title: 'Product Details',
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: Scaffold(
                    appBar: AppBar(
                      title: const Text('Product Details'),
                    ),
                    body: SingleChildScrollView(
                      padding: const EdgeInsets.all(defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _product!.description ?? 'Premium quality product with excellent durability.',
                          ),
                          const SizedBox(height: defaultPadding),
                          if (_sizes.isNotEmpty) ...[
                            Text(
                              'Available Sizes',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: _sizes.map((size) => Chip(
                                label: Text(size.sizeName),
                              ),).toList(),
                            ),
                            const SizedBox(height: defaultPadding),
                          ],
                          Text(
                            'Features',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text('• High quality materials\n• Comfortable design\n• Durable construction\n• Easy to maintain'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            ProductListTile(
              svgSrc: 'assets/icons/Delivery.svg',
              title: 'Shipping Information',
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: Scaffold(
                    appBar: AppBar(
                      title: const Text('Shipping Information'),
                    ),
                    body: SingleChildScrollView(
                      padding: const EdgeInsets.all(defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shipping Methods',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Card(
                            child: ListTile(
                              title: const Text('Standard Shipping'),
                              subtitle: const Text('15-20 business days'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  svg.SvgPicture.asset(
                                    'assets/icons/coin.svg',
                                    width: 14,
                                    height: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  const Text('0'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: ReviewCard(
                  rating: 4.3,
                  numOfReviews: 128,
                  numOfFiveStar: 80,
                  numOfFourStar: 30,
                  numOfThreeStar: 5,
                  numOfTwoStar: 4,
                  numOfOneStar: 1,
                ),
              ),
            ),
            ProductListTile(
              svgSrc: 'assets/icons/Chat.svg',
              title: 'Reviews',
              isShowBottomBorder: true,
              press: () {
                // Reviews screen not yet implemented
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reviews coming soon!')),
                );
              },
            ),
            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'You may also like',
                  style: Theme.of(context).textTheme.titleSmall!,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: _relatedProducts.isEmpty
                    ? const Center(child: Text('No related products'))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _relatedProducts.length,
                        itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.only(
                              left: defaultPadding,
                              right: index == _relatedProducts.length - 1
                                  ? defaultPadding
                                  : 0,),
                          child: ProductCard(
                            image: _relatedProducts[index].image,
                            title: _relatedProducts[index].title,
                            brandName: _relatedProducts[index].brandName,
                            price: _relatedProducts[index].price,
                            product: _relatedProducts[index],
                            press: () {
                              context.push(
                                  '/shop/product/${_relatedProducts[index].id}',
                                  extra: {'product': _relatedProducts[index]},);
                            },
                          ),
                        ),
                      ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding),
            ),
          ],
        ),
      ),
    );
  }
}

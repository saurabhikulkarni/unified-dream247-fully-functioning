import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:unified_dream247/core/providers/shop_tokens_provider.dart';
import 'package:unified_dream247/features/shop/components/custom_modal_bottom_sheet.dart';
import 'package:unified_dream247/features/shop/components/network_image_with_loader.dart';
import 'package:unified_dream247/features/shop/models/product_model.dart';
import 'package:unified_dream247/features/shop/screens/product/views/added_to_cart_message_screen.dart';
import 'package:unified_dream247/features/shop/screens/product/views/components/product_list_tile.dart';
import 'package:unified_dream247/features/shop/screens/product/views/location_permission_store_availability_screen.dart';
import 'package:unified_dream247/features/shop/screens/product/views/size_guide_screen.dart';
import 'package:unified_dream247/features/shop/services/cart_service.dart';
import 'package:unified_dream247/features/shop/services/wishlist_service.dart';
import 'package:unified_dream247/features/shop/services/user_service.dart';
import 'package:unified_dream247/features/shop/services/notification_service.dart';

import 'package:unified_dream247/features/shop/constants.dart';
import 'components/product_quantity.dart';
import 'components/selected_size.dart';
import 'components/unit_price.dart';

class ProductBuyNowScreen extends StatefulWidget {
  const ProductBuyNowScreen({
    super.key,
    required this.product,
    this.sizes = const [],
    this.initialSizeIndex = 0,
  });

  final ProductModel product;
  final List<SizeModel> sizes;
  final int initialSizeIndex;

  @override
  _ProductBuyNowScreenState createState() => _ProductBuyNowScreenState();
}

class _ProductBuyNowScreenState extends State<ProductBuyNowScreen> {
  int _quantity = 1;
  late int _selectedSizeIndex;
  double walletBalance = 0.0; // User's shopping tokens
  int shoppingTokens = 0;
  bool _isInWishlist = false;

  // Default sizes if none from API
  static const List<String> _defaultSizes = ['S', 'M', 'L', 'XL', 'XXL'];

  @override
  void initState() {
    super.initState();
    
    // Validate and set initial size index
    if (widget.sizes.isNotEmpty) {
      // Check if initialSizeIndex is valid and has stock
      if (widget.initialSizeIndex < widget.sizes.length &&
          widget.sizes[widget.initialSizeIndex].quantity > 0) {
        _selectedSizeIndex = widget.initialSizeIndex;
      } else {
        // Find first size with stock
        final firstAvailableIndex = widget.sizes
            .indexWhere((size) => size.quantity > 0);
        _selectedSizeIndex = firstAvailableIndex >= 0 ? firstAvailableIndex : 0;
      }
    } else {
      _selectedSizeIndex = widget.initialSizeIndex;
    }
    
    _loadWalletBalance();
    _checkWishlistStatus();
  }

  List<String> get availableSizes {
    if (widget.sizes.isNotEmpty) {
      return widget.sizes.map((s) => s.sizeName).toList();
    }
    return _defaultSizes;
  }

  SizeModel? get selectedSize {
    if (widget.sizes.isEmpty) return null;
    if (_selectedSizeIndex >= widget.sizes.length) return null;
    return widget.sizes[_selectedSizeIndex];
  }

  String get selectedSizeName {
    if (_selectedSizeIndex < availableSizes.length) {
      return availableSizes[_selectedSizeIndex];
    }
    return 'M';
  }

  double get totalPrice => widget.product.price * _quantity;

  Future<void> _checkWishlistStatus() async {
    final isInWishlist = wishlistService.isInWishlist(widget.product.id!);
    setState(() {
      _isInWishlist = isInWishlist;
    });
  }

  Future<void> _toggleWishlist() async {
    final newState = await wishlistService.toggleWishlist(widget.product);
    
    setState(() {
      _isInWishlist = newState;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isInWishlist
                ? '${widget.product.title} added to wishlist'
                : '${widget.product.title} removed from wishlist',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _loadWalletBalance() async {
    try {
      // Use ShopTokensProvider for consistent balance across the app
      final shopTokensProvider = context.read<ShopTokensProvider>();
      await shopTokensProvider.forceRefresh();
      setState(() {
        walletBalance = shopTokensProvider.shopTokens.toDouble();
      });
      debugPrint('💰 [PRODUCT_BUY_NOW] Wallet balance from provider: $walletBalance');
    } catch (e) {
      debugPrint('⚠️ [PRODUCT_BUY_NOW] Error loading wallet balance: $e');
    }
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _addToCart() async {
    // Check if size is selected and has stock
    SizeModel? sizeToAdd = selectedSize;
    
    // If product has sizes, ensure one is selected
    if (widget.sizes.isNotEmpty && sizeToAdd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a size before adding to cart'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Check stock availability
    if (sizeToAdd != null && sizeToAdd.quantity <= 0) {
      _showOutOfStockDialog();
      return;
    }
    
    // Create a size model from selected size name if no API sizes
    if (sizeToAdd == null && availableSizes.isNotEmpty) {
      sizeToAdd = SizeModel(
        id: 'local_$selectedSizeName',
        sizeName: selectedSizeName,
        quantity: 100,
      );
    }

    try {
      // Add to local cart (also syncs with backend if logged in)
      await cartService.addToLocalCart(
        widget.product,
        sizeToAdd,
        _quantity,
      );

      // Show success message
      if (mounted) {
        customModalBottomSheet(
          context,
          isDismissible: false,
          child: const AddedToCartMessageScreen(),
        );
      }
    } catch (e) {
      // Show error message if stock is insufficient or other error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showOutOfStockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Out of Stock'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sorry, ${widget.product.title} in size ${selectedSize?.sizeName ?? selectedSizeName} is currently out of stock.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: defaultPadding),
            const Text(
              'Would you like to add it to your wishlist? We\'ll notify you when it\'s back in stock.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              context.pop();
              
              // Add to wishlist
              await _toggleWishlist();
              
              // Register stock alert
              final userId = UserService.getCurrentUserId();
              if (userId != null && widget.product.id != null) {
                await notificationService.registerStockAlert(
                  productId: widget.product.id!,
                  productTitle: widget.product.title,
                  sizeId: selectedSize?.id,
                  sizeName: selectedSize?.sizeName ?? selectedSizeName,
                  userId: userId,
                );
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('We\'ll notify you when this item is back in stock!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.favorite, size: 18),
            label: const Text('Add to Wishlist'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _handleRedeemNow() {
    // If product has sizes, ensure one is selected
    if (widget.sizes.isNotEmpty && selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a size before proceeding'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Check if size is selected and has stock
    if (selectedSize != null && selectedSize!.quantity <= 0) {
      _showOutOfStockDialog();
      return;
    }
    
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Redeem Now'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add this product to cart and proceed to checkout?'),
            const SizedBox(height: defaultPadding / 2),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/coin.svg',
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Total: ${totalPrice.toInt()} tokens',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              _processRedeemNow();
            },
            child: const Text('Yes, Add to Cart'),
          ),
        ],
      ),
    );
  }

  void _processRedeemNow() async {
    final int productPrice = totalPrice.toInt();

    if (walletBalance >= productPrice) {
      // Sufficient balance - add to cart and navigate to cart screen
      await _addToCartAndNavigate();
    } else {
      // Insufficient balance - show dialog
      final tokensShort = productPrice - walletBalance.toInt();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Insufficient Shopping Tokens'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This product costs $productPrice tokens.'),
              const SizedBox(height: defaultPadding / 2),
              Text(
                'Your wallet has: ${walletBalance.toStringAsFixed(2)} tokens',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: defaultPadding / 2),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/coin.svg',
                    width: 16,
                    height: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'You need $tokensShort more tokens',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Continue Shopping'),
            ),
            TextButton(
              onPressed: () {
                context.pop();
                // Note: Wallet redirection now to Fantasy wallet
                // Data passing no longer needed as it's a unified wallet
                context.push('/fantasy/wallet');
              },
              child: const Text('Add Tokens to Wallet'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _addToCartAndNavigate() async {
    // Check if size is selected and has stock
    SizeModel? sizeToAdd = selectedSize;
    
    // If product has sizes, ensure one is selected
    if (widget.sizes.isNotEmpty && sizeToAdd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a size before proceeding'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Check stock availability
    if (sizeToAdd != null && sizeToAdd.quantity <= 0) {
      _showOutOfStockDialog();
      return;
    }
    
    // Create a size model from selected size name if no API sizes
    if (sizeToAdd == null && availableSizes.isNotEmpty) {
      sizeToAdd = SizeModel(
        id: 'local_$selectedSizeName',
        sizeName: selectedSizeName,
        quantity: 100,
      );
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Add to local cart (also syncs with backend if logged in)
      await cartService.addToLocalCart(
        widget.product,
        sizeToAdd,
        _quantity,
      );

      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added to cart! Proceeding to checkout...'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
      // Navigate to cart screen after a brief delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      // Close the product buy now modal first
      context.pop();
      
      // Then navigate to cart screen
      context.push('/shop/checkout');
      
    } catch (e) {
      if (!mounted) return;
      
      // Close loading dialog
      context.pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to cart: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Row(
            children: [
              // Add to Cart Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: const Text('Add to Cart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: defaultPadding),
              // Redeem Now Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _handleRedeemNow,
                  icon: SvgPicture.asset(
                    'assets/icons/coin.svg',
                    width: 18,
                    height: 18,
                  ),
                  label: const Text('Redeem Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding / 2, vertical: defaultPadding,),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BackButton(),
                Expanded(
                  child: Text(
                    widget.product.title,
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  onPressed: _toggleWishlist,
                  icon: SvgPicture.asset(
                    'assets/icons/Wishlist.svg',
                    colorFilter: ColorFilter.mode(
                      _isInWishlist ? Colors.red : Theme.of(context).textTheme.bodyLarge!.color!,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: AspectRatio(
                      aspectRatio: 1.05,
                      child: widget.product.image.isNotEmpty
                          ? NetworkImageWithLoader(widget.product.image)
                          : const NetworkImageWithLoader(productDemoImg1),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: UnitPrice(
                            price: widget.product.price,
                            priceAfterDiscount: widget.product.priceAfetDiscount,
                          ),
                        ),
                        ProductQuantity(
                          numOfItem: _quantity,
                          onIncrement: _incrementQuantity,
                          onDecrement: _decrementQuantity,
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: Divider()),
                SliverToBoxAdapter(
                  child: SelectedSize(
                    sizes: availableSizes,
                    selectedIndex: _selectedSizeIndex,
                    availableIndices: widget.sizes
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
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  sliver: ProductListTile(
                    title: 'Size guide',
                    svgSrc: 'assets/icons/Sizeguid.svg',
                    isShowBottomBorder: true,
                    press: () {
                      customModalBottomSheet(
                        context,
                        height: MediaQuery.of(context).size.height * 0.9,
                        child: const SizeGuideScreen(),
                      );
                    },
                  ),
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          'Product Info',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          widget.product.description ?? 
                              'Premium quality product with excellent durability.',
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  sliver: ProductListTile(
                    title: 'Check stores',
                    svgSrc: 'assets/icons/Stores.svg',
                    isShowBottomBorder: true,
                    press: () {
                      customModalBottomSheet(
                        context,
                        height: MediaQuery.of(context).size.height * 0.92,
                        child: const LocationPermissonStoreAvailabilityScreen(),
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(
                    child: SizedBox(height: defaultPadding),),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

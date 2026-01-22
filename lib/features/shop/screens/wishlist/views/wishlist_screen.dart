import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_dream247/features/shop/components/product/product_card.dart';
import 'package:unified_dream247/features/shop/models/product_model.dart';
import 'package:unified_dream247/features/shop/services/wishlist_service.dart';
import 'package:unified_dream247/features/shop/services/cart_service.dart';
import 'package:unified_dream247/features/shop/services/user_service.dart';
import 'package:unified_dream247/features/shop/route/route_constants.dart';

import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/shop/utils/responsive_extension.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<ProductModel> _wishlistItems = [];
  bool _isLoading = true;
  bool _isEditMode = false;
  final CartService cartService = CartService();

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh wishlist when screen comes back to focus
    _loadWishlist();
  }

  void _loadWishlist() async {
    setState(() {
      _isLoading = true;
    });
    
    // Ensure user ID is set from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? prefs.getString('shop_user_id');
    
    if (userId != null && userId.isNotEmpty) {
      // Set user ID in services
      await UserService.setCurrentUserId(userId);
      wishlistService.setUserId(userId);
      
      debugPrint('📋 [WISHLIST] Loading wishlist for user: $userId');
      
      // Force reset local wishlist and sync fresh from backend
      await wishlistService.forceResetWishlist();
      await wishlistService.initialize();
      await wishlistService.syncWithBackend();
    } else {
      debugPrint('⚠️ [WISHLIST] No user ID found, showing empty wishlist');
      // Clear local wishlist if no user is logged in
      await wishlistService.forceResetWishlist();
    }
    
    if (mounted) {
      setState(() {
        _wishlistItems = wishlistService.getWishlist();
        _isLoading = false;
      });
      debugPrint('📋 [WISHLIST] Loaded ${_wishlistItems.length} items');
    }
  }

  void _removeFromWishlist(String productId) async {
    await wishlistService.removeFromWishlist(productId);
    _loadWishlist();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed from wishlist'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Check if product has stock (checking all sizes)
  bool _hasStock(ProductModel product) {
    // If no size information, assume in stock
    // You might need to add sizes field to ProductModel or fetch separately
    return true; // Implement proper stock checking based on your data model
  }

  Future<void> _addToCart(ProductModel product) async {
    try {
      // Check stock before adding
      if (!_hasStock(product)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This product is out of stock'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Add to cart without size (you can modify this if you want to show size selection)
      await cartService.addToLocalCart(product, null, 1);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.title} added to cart'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'View Cart',
              onPressed: () {
                context.push('/shop/checkout');
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _moveAllToCart() async {
    if (_wishlistItems.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });

    int addedCount = 0;
    int failedCount = 0;

    for (var product in _wishlistItems) {
      try {
        await cartService.addToLocalCart(product, null, 1);
        await wishlistService.removeFromWishlist(product.id!);
        addedCount++;
      } catch (e) {
        failedCount++;
        print('Error moving ${product.title} to cart: $e');
      }
    }

    _loadWishlist();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failedCount > 0
                ? '$addedCount items moved to cart, $failedCount failed'
                : 'All $addedCount items moved to cart',
          ),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'View Cart',
            onPressed: () {
              context.push('/shop/checkout');
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Check if we can pop, otherwise navigate to home
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/shop/entry_point');
            }
          },
        ),
        actions: [
          if (_wishlistItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: _moveAllToCart,
              tooltip: 'Move All to Cart',
            ),
          if (_wishlistItems.isNotEmpty)
            IconButton(
              icon: Icon(_isEditMode ? Icons.check : Icons.edit_outlined),
              onPressed: () {
                setState(() {
                  _isEditMode = !_isEditMode;
                });
              },
              tooltip: _isEditMode ? 'Done' : 'Edit',
            ),
          if (_wishlistItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Wishlist?'),
                    content: const Text(
                        'Are you sure you want to clear your entire wishlist?',),
                    actions: [
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          context.pop();
                          setState(() {
                            _isLoading = true;
                          });
                          await wishlistService.clearWishlist();
                          _loadWishlist();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Wishlist cleared'),
                              ),
                            );
                          }
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _wishlistItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/Wishlist.svg',
                    width: context.isTablet ? 100 : 80,
                    height: context.isTablet ? 100 : 80,
                    colorFilter: ColorFilter.mode(
                      Colors.grey.shade400,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  Text(
                    'Your wishlist is empty',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  Text(
                    'Add products you love to your wishlist',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: defaultPadding),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.all(context.responsiveSpacing),
                  sliver: SliverGrid(
                    gridDelegate:
                        SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: context.isTablet ? 250.0 : 200.0,
                      mainAxisSpacing: context.responsiveSpacing,
                      crossAxisSpacing: context.responsiveSpacing,
                      childAspectRatio: context.isTablet ? 0.62 : 0.58,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final product = _wishlistItems[index];
                        return Column(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  ProductCard(
                                    image: product.image,
                                    brandName: product.brandName,
                                    title: product.title,
                                    price: product.price,
                                    priceAfetDiscount:
                                        product.priceAfetDiscount,
                                    product: product,
                                    press: () {
                                      context.push('/shop/product/${product.id}',
                                          extra: {'product': product},);
                                    },
                                  ),
                                  if (_isEditMode && product.id != null)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            size: context.isTablet ? 20 : 18,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            _removeFromWishlist(product.id!);
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(
                                            minWidth: context.isTablet ? 40 : 36,
                                            minHeight: context.isTablet ? 40 : 36,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _addToCart(product),
                                icon: Icon(Icons.shopping_cart_outlined, 
                                  size: context.isTablet ? 18 : 16,),
                                label: Text('Add to Cart', 
                                  style: TextStyle(fontSize: context.fontSize(12, minSize: 10, maxSize: 14)),),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: context.responsiveSpacing, 
                                    vertical: context.responsiveSpacing,),
                                  minimumSize: Size(0, context.isTablet ? 36 : 32),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      childCount: _wishlistItems.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

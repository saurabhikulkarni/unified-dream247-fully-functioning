import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unified_dream247/core/services/auth_service.dart' as core_auth;
import 'package:unified_dream247/features/shop/services/product_service.dart';
import 'package:unified_dream247/features/shop/models/product_model.dart';
import 'dart:math';

class UnifiedHomePage extends StatefulWidget {
  const UnifiedHomePage({super.key});

  @override
  State<UnifiedHomePage> createState() => _UnifiedHomePageState();
}

class _UnifiedHomePageState extends State<UnifiedHomePage> {
  final ProductService _productService = ProductService();
  List<ProductModel> _products = [];
  bool _isLoading = true;
  final core_auth.AuthService _authService = core_auth.AuthService();

  @override
  void initState() {
    super.initState();
    _initAuth();
    _loadProducts();
  }

  Future<void> _initAuth() async {
    await _authService.initialize();
  }

  void _navigateToShop() {
    if (!_authService.isShopEnabled()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shop module is not enabled for your account')),
      );
      return;
    }
    
    context.go('/shop/entry_point');
  }

  Future<void> _navigateToFantasy() async {
    // First check if user is logged in
    final isLoggedIn = await _authService.isLoggedIn();
    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first to access Fantasy'),
          backgroundColor: Colors.orange,
        ),
      );
      if (mounted) {
        context.go('/login');
      }
      return;
    }
    
    // Then check if fantasy is enabled
    if (!_authService.isFantasyEnabled()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fantasy module is not enabled for your account')),
      );
      return;
    }
    
    debugPrint('🎮 [HOME] User authenticated, navigating to Fantasy');
    if (mounted) {
      context.go('/fantasy/home');
    }
  }

  Future<void> _loadProducts() async {
    try {
      final allProducts = await _productService.getAllProducts();
      if (allProducts.isNotEmpty) {
        // Shuffle and take random 4 products
        allProducts.shuffle(Random());
        setState(() {
          _products = allProducts.take(4).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive sizes
    final bannerHeight = screenHeight * 0.11;
    final cardHeight = screenHeight * 0.20;
    final iconSize = screenWidth * 0.20; // 20% of screen width
    final fontSize = screenWidth * 0.04; // 4% of screen width
    final horizontalPadding = screenWidth * 0.04;
    final cardSpacing = screenHeight * 0.01; // Spacing inside cards
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              context.go('/shop/profile');
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF6B4099),
              child: const Icon(Icons.person, size: 24, color: Colors.white),
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                const Text(
                  '100',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💎', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                const Text(
                  '100',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game Tokens Banner
            GestureDetector(
              onTap: _navigateToFantasy,
              child: Container(
                height: bannerHeight,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/game.png',
                  fit: BoxFit.fill,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.sports_cricket,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Game Zone & Shop Cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                children: [
                  // Game Zone Card
                  Expanded(
                    child: GestureDetector(
                      onTap: _navigateToFantasy,
                      child: Container(
                        height: cardHeight,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF773DD6), Color(0xFF482576), Color(0xFF341255)],
                            stops: [0.0, 0.5, 1.0],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: cardSpacing * 1.5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Stack(
                                children: [
                                  // Stroke layer (gold outline)
                                  Text(
                                    'GAME ZONE',
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 1.5
                                        ..color = const Color(0xFFD6B200),
                                    ),
                                  ),
                                  // Fill layer (white with shadow)
                                  Text(
                                    'GAME ZONE',
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    foreground: Paint()
                                      ..style = PaintingStyle.fill
                                      ..color = Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Color.fromRGBO(218, 189, 0, 0.5),
                                        offset: Offset(2, 1),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                ],
                              ),
                              Flexible(
                                child: Padding(
                                  padding: EdgeInsets.only(top: cardSpacing),
                                  child: Image.asset(
                                    'assets/images/trophyicon.png',
                                    height: iconSize,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => 
                                      Icon(Icons.emoji_events, size: iconSize, color: Color(0xFFFFC107)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Shop Card
                  Expanded(
                    child: GestureDetector(
                      onTap: _navigateToShop,
                      child: Container(
                        height: cardHeight,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF773DD6), Color(0xFF482576), Color(0xFF341255)],
                            stops: [0.0, 0.5, 1.0],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: cardSpacing * 1.5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Stack(
                                children: [
                                  // Stroke layer (gold outline)
                                  Text(
                                    'SHOP',
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 1.5
                                        ..color = const Color(0xFFD6B200),
                                    ),
                                  ),
                                  // Fill layer (white with shadow)
                                  Text(
                                    'SHOP',
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    foreground: Paint()
                                      ..style = PaintingStyle.fill
                                      ..color = Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Color.fromRGBO(218, 189, 0, 0.5),
                                        offset: Offset(2, 1),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                ],
                              ),
                              Flexible(
                                child: Padding(
                                  padding: EdgeInsets.only(top: cardSpacing),
                                  child: Image.asset(
                                    'assets/images/shoppingbags.png',
                                    height: iconSize,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => 
                                      Icon(Icons.shopping_bag, size: iconSize, color: Color(0xFFFFC107)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Trend Banner
            GestureDetector(
              onTap: _navigateToShop,
              child: Container(
                height: bannerHeight,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/trend.png',
                  fit: BoxFit.fill,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.shopping_basket,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Top Picks Section
            Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOP PICKS',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF6B4099),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Grid
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFF6B4099),
                      ),
                    ),
                  )
                : _products.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Text('No products available'),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: horizontalPadding * 0.75,
                            mainAxisSpacing: horizontalPadding * 0.75,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];

                            return GestureDetector(
                              onTap: () {
                                // Navigate to product details
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          ),
                                        ),
                                        child: product.image.isNotEmpty
                                            ? ClipRRect(
                                                borderRadius: const BorderRadius.vertical(
                                                  top: Radius.circular(12),
                                                ),
                                                child: Image.network(
                                                  product.image,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  errorBuilder: (context, error, stackTrace) => Center(
                                                    child: Icon(
                                                      Icons.image_outlined,
                                                      size: 50,
                                                      color: Colors.grey[300],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Center(
                                                child: Icon(
                                                  Icons.image_outlined,
                                                  size: 50,
                                                  color: Colors.grey[300],
                                                ),
                                              ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.category?.categoryName ?? 'BRAND',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            product.title,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                              height: 1.3,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Text('🪙', style: TextStyle(fontSize: 14)),
                                              const SizedBox(width: 4),
                                              Text(
                                                product.price.toStringAsFixed(0),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

            const SizedBox(height: 80), // Space for bottom nav
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6B4099),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Wallet',
          ),
        ],
      ),
    );
  }
}

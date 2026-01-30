import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:unified_dream247/core/services/auth_service.dart' as core_auth;
import 'package:unified_dream247/core/providers/shop_tokens_provider.dart';
import 'package:unified_dream247/features/shop/services/product_service.dart';
import 'package:unified_dream247/features/shop/models/product_model.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/providers/wallet_details_provider.dart';
import 'dart:math';
import 'dart:async';

class UnifiedHomePage extends StatefulWidget {
  const UnifiedHomePage({super.key});

  @override
  State<UnifiedHomePage> createState() => _UnifiedHomePageState();
}

class _UnifiedHomePageState extends State<UnifiedHomePage>
    with WidgetsBindingObserver, RouteAware {
  final ProductService _productService = ProductService();
  List<ProductModel> _products = [];
  bool _isLoading = true;
  final core_auth.AuthService _authService = core_auth.AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAuth();
    _loadProducts();
    _refreshShopTokens();
    _refreshGameTokens();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gameTokensRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Auto-refresh both shop and game tokens when app resumes from background
      _refreshShopTokens();
      _refreshGameTokens();
    }
  }

  /// Called when this page is pushed back to the foreground (e.g., returning from wallet screen)
  @override
  void didPopNext() {
    // Force immediate refresh of both token types when returning from another screen
    _refreshShopTokens();
    _refreshGameTokens();
    super.didPopNext();
  }

  /// Refresh shop tokens when entering home page
  void _refreshShopTokens() {
    // Use addPostFrameCallback to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final shopTokensProvider = context.read<ShopTokensProvider>();
        shopTokensProvider.forceRefresh();
      }
    });
  }

  /// Refresh game tokens when entering home page
  void _refreshGameTokens() {
    // Use addPostFrameCallback to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        try {
          // Fetch wallet details which populates WalletDetailsProvider
          final walletProvider = context.read<WalletDetailsProvider>();
          await walletProvider.refreshWalletDetails(context);
        } catch (e) {
          debugPrint('⚠️ [HOME] Error refreshing game tokens: $e');
        }
      }
    });
    
    // Also set up a periodic refresh every 15 seconds to ensure we catch token changes
    // This helps when user spends tokens in contests or games
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _startGameTokensRefreshTimer();
      }
    });
  }
  
  Timer? _gameTokensRefreshTimer;
  
  void _startGameTokensRefreshTimer() {
    // Cancel any existing timer
    _gameTokensRefreshTimer?.cancel();
    
    // Refresh game tokens every 15 seconds while on this page
    _gameTokensRefreshTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (mounted) {
        try {
          final walletProvider = context.read<WalletDetailsProvider>();
          await walletProvider.refreshWalletDetails(context);
        } catch (e) {
          debugPrint('⚠️ [HOME] Periodic refresh error: $e');
        }
      }
    });
  }

  Future<void> _initAuth() async {
    await _authService.initialize();

    // ❌ REMOVED: The 2-second delay was causing race conditions
    // ❌ REMOVED: prefs.reload() was reverting in-memory changes from signup!
    // Just get the current instance - it should have the latest values
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token'); // Direct check
    final authToken = prefs.getString('auth_token'); // Legacy check
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final isLoggedInFantasy = prefs.getBool('is_logged_in_fantasy') ?? false;

    // Check if we have any valid token
    final hasValidToken = (token != null && token.isNotEmpty) ||
        (authToken != null && authToken.isNotEmpty);
    final validToken = (token != null && token.isNotEmpty) ? token : authToken;

    // SYNC CHECK: If Fantasy logged in but Shop isn't, sync the flags
    if (isLoggedInFantasy && !isLoggedIn && hasValidToken) {
      await prefs.setBool('is_logged_in', true);
      // Ensure token is in both keys
      if (validToken != null) {
        await prefs.setString('token', validToken);
        await prefs.setString('auth_token', validToken);
      }
      await _authService.initialize(); // Re-init service
      return; // Synced!
    }

    // ZOMBIE SESSION CHECK - ONLY if SHOP is logged in but NO valid token exists
    // Do NOT logout if Fantasy is logged in but tokens are missing - just resync
    if (isLoggedIn && !hasValidToken) {
      // Shop is marked as logged in but has no tokens - this is a true zombie session

      await _authService.logout();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please log in again.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        setState(() {});
      }
    } else if (isLoggedInFantasy && !hasValidToken) {
      // Fantasy is logged in but tokens are missing - try to resync from Fantasy storage
      await prefs.remove('is_logged_in_fantasy');
      await prefs.setBool('is_logged_in', false);
    } else if (hasValidToken && validToken != null) {
      // Ensure token is synced to both keys
      if (token == null || token.isEmpty) {
        await prefs.setString('token', validToken);
      }
      if (authToken == null || authToken.isEmpty) {
        await prefs.setString('auth_token', validToken);
      }
    }
  }

  void _navigateToShop() {
    // Always allow navigation to shop - module check is optional

    context.push('/shop/entry_point');
  }

  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        // Already on Home, do nothing
        break;
      case 1:
        // Navigate to Shop
        _navigateToShop();
        break;
      case 2:
        // Navigate to Wallet (Fantasy wallet as unified wallet)
        _navigateToWallet();
        break;
    }
  }

  void _navigateToWallet() {
    context.push('/fantasy/wallet');
  }

  Future<void> _navigateToFantasy() async {
    // Remove login check: always call get-version and navigate
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Check if we have a valid token in ANY key
      String? usableToken = prefs.getString('token');
      if (usableToken == null || usableToken.isEmpty) {
        usableToken = prefs.getString('auth_token');
      }
      if (usableToken == null || usableToken.isEmpty) {
        usableToken = prefs.getString('temp_otp_token'); // From Msg91 intercept
      }

      // 2. IMPORTANT: If retrieved token appears to be a User ID (no dots, short), DO NOT USE IT
      if (usableToken != null && !usableToken.contains('.')) {
        usableToken = null;
      }

      // 3. If we found a good token, promote it
      if (usableToken != null && usableToken.isNotEmpty) {
        final currentPrimary = prefs.getString('token');
        if (currentPrimary != usableToken) {
          await prefs.setString('token', usableToken);
          await prefs.setString('auth_token', usableToken);
        }
      }

      // Sync fantasy version in background (non-blocking) to prevent 30s timeout delay
      // The endpoint is unreliable, so we don't wait for it
      _authService.syncFantasyVersion().then((data) {
      }).catchError((e) {
      });
    } catch (e) {
      debugPrint('❌ [HOME] Error in pre-navigation setup: $e');
    }
    if (mounted) {
      context.push('/fantasy/home');
    }
  }

  Future<void> _loadProducts() async {
    try {
      final allProducts = await _productService.getAllProducts();

      if (allProducts.isNotEmpty) {
        // Shuffle and take random 2 products for preview
        allProducts.shuffle(Random());
        setState(() {
          _products = allProducts.take(2).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ [UNIFIED_HOME] Error loading products: $e');
      setState(() {
        _isLoading = false;
      });
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
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFF6B4099),
              child: Icon(Icons.person, size: 24, color: Colors.white),
            ),
          ),
        ),
        actions: [
          // Shop Tokens Display - Clickable to navigate to wallet
          Consumer<ShopTokensProvider>(
            builder: (context, shopTokensProvider, child) {
              return GestureDetector(
                onTap: () => _navigateToWallet(),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/coin.svg',
                        width: 18,
                        height: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        shopTokensProvider.shopTokens.toString(),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Game Tokens Display - Clickable to navigate to wallet
          Consumer<WalletDetailsProvider>(
            builder: (context, walletProvider, child) {
              // Show game tokens (bonus) NOT shop balance
              // bonus = Game Tokens, balance = Shop Tokens
              final gameTokens = double.tryParse(walletProvider.walletData?.bonus ?? '0') ?? 0;
              
              return GestureDetector(
                onTap: () {
                  _navigateToWallet();
                },
                child: Container(
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
                      Text(
                        gameTokens.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game Tokens Banner
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
                            colors: [
                              Color(0xFF773DD6),
                              Color(0xFF482576),
                              Color(0xFF341255),
                            ],
                            stops: [0.0, 0.5, 1.0],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: cardSpacing * 1.5),
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
                                      shadows: const [
                                        Shadow(
                                          color:
                                              Color.fromRGBO(218, 189, 0, 0.5),
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
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.emoji_events,
                                            size: iconSize,
                                            color: const Color(0xFFFFC107),),
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
                            colors: [
                              Color(0xFF773DD6),
                              Color(0xFF482576),
                              Color(0xFF341255),
                            ],
                            stops: [0.0, 0.5, 1.0],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: cardSpacing * 1.5),
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
                                      shadows: const [
                                        Shadow(
                                          color:
                                              Color.fromRGBO(218, 189, 0, 0.5),
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
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.shopping_bag,
                                            size: iconSize,
                                            color: const Color(0xFFFFC107),),
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
                    onPressed: _navigateToShop,
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
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
                                // Navigate to shop product details (same as shop)
                                context.push(
                                  '/shop/product/${product.id}',
                                  extra: {'product': product},
                                );
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
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          ),
                                        ),
                                        child: product.image.isNotEmpty
                                            ? ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                  top: Radius.circular(12),
                                                ),
                                                child: Image.network(
                                                  product.image,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  errorBuilder: (context, error,
                                                          stackTrace,) =>
                                                      Center(
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.category?.categoryName ??
                                                'BRAND',
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
                                              SvgPicture.asset(
                                                'assets/icons/coin.svg',
                                                width: 16,
                                                height: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                product.price
                                                    .toStringAsFixed(0),
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
        onTap: (index) => _onBottomNavTap(index),
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

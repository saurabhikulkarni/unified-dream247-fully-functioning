import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/shop/route/screen_export.dart';
import 'package:unified_dream247/features/shop/services/cart_service.dart';
import 'package:unified_dream247/features/shop/services/wishlist_service.dart';
import 'package:unified_dream247/features/shop/services/user_service.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  double walletBalance = 0.0;
  int shoppingTokens = 0;
  int _currentIndex = 0;
  final UserService _userService = userService;

  List<Widget> get _pages => [
    const HomeScreen(),
    const DiscoverScreen(),
    const WishlistScreen(),
    const ProfileScreen(),
  ];

  int get _cartItemCount {
    // Force refresh by calling getLocalCart each time
    return CartService().getLocalCart().length;
  }

  int get _wishlistItemCount => wishlistService.getWishlistCount();

  @override
  void initState() {
    super.initState();
    _loadWalletBalance();
  }

  Future<void> _loadWalletBalance() async {
    final userId = UserService.getCurrentUserId();
    if (userId != null) {
      try {
        final balance = await _userService.getWalletBalance();
        if (mounted) {
          setState(() {
            walletBalance = balance;
            shoppingTokens = balance.toInt();
          });
          print('💰 [ENTRY_POINT] Wallet updated: Balance=$walletBalance, Tokens=$shoppingTokens');
        }
      } catch (e) {
        print('⚠️ [ENTRY_POINT] Failed to load wallet: $e');
        // Silently fail, keep current values
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SvgPicture svgIcon(String src, {Color? color}) {
      return SvgPicture.asset(
        src,
        height: 24,
        colorFilter: ColorFilter.mode(
            color ??
                Theme.of(context).iconTheme.color!.withOpacity(
                    Theme.of(context).brightness == Brightness.dark ? 0.3 : 1),
            BlendMode.srcIn),
      );
    }

    // Responsive sizing based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final double iconSize = (screenWidth * 0.055).clamp(20.0, 24.0);
    final double iconPadding = (screenWidth * 0.015).clamp(4.0, 8.0); // Reduced padding
    final double badgeFontSize = (screenWidth * 0.022).clamp(8.0, 10.0);
    final double tokenIconSize = (screenWidth * 0.05).clamp(18.0, 22.0);
    final double tokenFontSize = (screenWidth * 0.032).clamp(12.0, 14.0);
    final double tokenSpacing = (screenWidth * 0.008).clamp(2.0, 4.0);
    final double rightPadding = (screenWidth * 0.04).clamp(12.0, 20.0); // Increased to bring tokens inside

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: appPrimaryGradient,
          ),
          child: AppBar(
            // pinned: true,
            // floating: true,
            // snap: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const SizedBox(),
            leadingWidth: 0,
            centerTitle: false,
            title: SvgPicture.asset(
              "assets/logo/dream247_logo.svg",
              height: (MediaQuery.of(context).size.height * 0.035)
                  .clamp(22.0, 34.0)
                  .toDouble(),
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            actions: [
          IconButton(
            padding: EdgeInsets.symmetric(horizontal: iconPadding),
            constraints: const BoxConstraints(),
            onPressed: () {
              Navigator.pushNamed(context, searchScreenRoute);
            },
            icon: SvgPicture.asset(
              "assets/icons/Search.svg",
              height: iconSize,
              colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn),
            ),
          ),
          Stack(
            children: [
              IconButton(
                padding: EdgeInsets.symmetric(horizontal: iconPadding),
                constraints: const BoxConstraints(),
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, checkoutScreenRoute);
                  // Refresh cart count and wallet balance after returning from cart
                  if (mounted) {
                    setState(() {
                      // Update wallet if cart screen returns updated balance
                      if (result is Map) {
                        walletBalance = result['walletBalance'] ?? walletBalance;
                        shoppingTokens = result['shoppingTokens'] ?? shoppingTokens;
                      }
                    });
                  }
                },
                icon: Icon(
                  Icons.shopping_cart_outlined,
                  size: iconSize,
                  color: Colors.white,
                ),
              ),
              if (_cartItemCount > 0)
                Positioned(
                  right: iconPadding * 0.5,
                  top: iconPadding * 0.5,
                  child: Container(
                    padding: EdgeInsets.all(badgeFontSize * 0.3),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF4444),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _cartItemCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: badgeFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            padding: EdgeInsets.symmetric(horizontal: iconPadding),
            constraints: const BoxConstraints(),
            onPressed: () async {
              final result = await Navigator.pushNamed(context, walletScreenRoute, arguments: {
                'walletBalance': walletBalance,
                'shoppingTokens': shoppingTokens,
              });
              if (result is Map) {
                setState(() {
                  walletBalance = result['walletBalance'] ?? walletBalance;
                  shoppingTokens = result['shoppingTokens'] ?? shoppingTokens;
                });
                // Don't reload immediately - use the returned value which is already fresh
                // Backend sync happens in wallet screen, returned value is authoritative
              }
            },
            icon: SvgPicture.asset(
              "assets/icons/Wallet.svg",
              height: iconSize,
              colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: rightPadding),
            child: Row(
              children: [
                SvgPicture.asset(
                  "assets/icons/coin.svg",
                  height: tokenIconSize,
                  width: tokenIconSize,
                ),
                SizedBox(width: tokenSpacing),
                Text(
                  shoppingTokens.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: tokenFontSize,
                    color: const Color(0xFFFFC107),
                  ),
                ),
              ],
            ),
          ),
        ],
          ),
        ),
      ),
      // body: _pages[_currentIndex],
      body: PageTransitionSwitcher(
        duration: defaultDuration,
        transitionBuilder: (child, animation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: defaultPadding / 2),
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF101015),
        child: Stack(
          children: [
            // Gradient background for active tab
            Builder(builder: (context) {
              final width = MediaQuery.of(context).size.width;
              // We have 4 items in the bar
              const itemCount = 4;
              final itemWidth = width / itemCount;
              const horizontalInset = 6.0; // add some side breathing room
              final left = (_currentIndex * itemWidth) + horizontalInset;
              final highlightWidth = itemWidth - (horizontalInset * 2);

              return Positioned(
                left: left,
                bottom: 0,
                child: Container(
                  width: highlightWidth,
                  height: 56,
                  decoration: const BoxDecoration(
                    gradient: appPrimaryGradient,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                ),
              );
            }),
            // Navigation bar on top
            BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                if (index != _currentIndex) {
                  setState(() {
                    _currentIndex = index;
                  });
                  // Refresh wallet after navigation completes
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _loadWalletBalance();
                  });
                }
              },
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 12,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.black87,
              items: [
                BottomNavigationBarItem(
                  icon: svgIcon("assets/icons/Shop.svg"),
                  activeIcon: svgIcon("assets/icons/Shop.svg", color: Colors.white),
                  label: "Shop",
                ),
                BottomNavigationBarItem(
                  icon: svgIcon("assets/icons/Category.svg"),
                  activeIcon:
                      svgIcon("assets/icons/Category.svg", color: Colors.white),
                  label: "Discover",
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    children: [
                      svgIcon("assets/icons/Wishlist.svg"),
                      if (_wishlistItemCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              _wishlistItemCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  activeIcon: Stack(
                    children: [
                      svgIcon("assets/icons/Wishlist.svg", color: Colors.white),
                      if (_wishlistItemCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              _wishlistItemCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: "Wishlist",
                ),
                BottomNavigationBarItem(
                  icon: svgIcon("assets/icons/Profile.svg"),
                  activeIcon:
                      svgIcon("assets/icons/Profile.svg", color: Colors.white),
                  label: "Profile",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

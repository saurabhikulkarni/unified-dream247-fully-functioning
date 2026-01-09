import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/otp_verification_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/authentication/presentation/pages/splash_page.dart';
import '../../features/ecommerce/products/presentation/pages/product_detail_page.dart';
import '../../features/ecommerce/products/presentation/pages/products_page.dart';
import '../../features/gaming/matches/presentation/pages/match_detail_page.dart';
import '../../features/gaming/matches/presentation/pages/matches_page.dart';
import '../../features/home/presentation/pages/unified_home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/wallet/presentation/pages/add_money_page.dart';
import '../../features/wallet/presentation/pages/wallet_page.dart';

// Shop screen imports
import '../../features/shop/home/screens/shop_home_screen.dart';
import '../../features/shop/screens/product/views/product_details_screen.dart';
import '../../features/shop/screens/checkout/views/cart_screen.dart';
import '../../features/shop/screens/order/views/orders_screen.dart';
import '../../features/shop/screens/order/views/order_tracking_screen.dart';
import '../../features/shop/screens/wishlist/views/bookmark_screen.dart';
import '../../features/shop/screens/search/views/search_screen.dart';
import '../../features/shop/screens/profile/views/profile_screen.dart' as shop_profile;
import '../../features/shop/screens/address/views/addresses_screen.dart';
import '../../features/shop/screens/address/views/add_address_screen.dart';
import '../../features/shop/screens/discover/views/discover_screen.dart';
import '../../features/shop/screens/category/views/category_products_screen.dart';
import '../../features/shop/screens/checkout/views/address_selection_screen.dart';
import '../../features/shop/screens/checkout/views/order_confirmation_screen.dart';

// Fantasy screen imports
import '../../features/fantasy/landing/presentation/screens/landing_page.dart';
import '../../features/fantasy/upcoming_matches/presentation/screens/contest_page.dart';
import '../../features/fantasy/my_matches/presentation/screens/my_matches_page.dart';
import '../../features/fantasy/my_matches/presentation/screens/live_match_details_screen.dart';
import '../../features/fantasy/accounts/presentation/screens/my_balance_page.dart';
import '../../features/fantasy/accounts/presentation/screens/add_money_page.dart' as fantasy_add_money;
import '../../features/fantasy/accounts/presentation/screens/withdraw_screen.dart';
import '../../features/fantasy/accounts/presentation/screens/my_transactions.dart';
import '../../features/fantasy/user_verification/presentation/screens/verify_details_page.dart';
import '../../features/fantasy/menu_items/presentation/screens/edit_profile_page.dart' show EditProfile;
import '../../features/fantasy/menu_items/presentation/screens/refer_and_earn_page.dart';

import 'route_names.dart';

/// GoRouter configuration for the application
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash screen
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SplashPage(),
        ),
      ),
      
      // Authentication routes
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const RegisterPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.otpVerification,
        name: 'otp-verification',
        pageBuilder: (context, state) {
          final phone = state.extra as String? ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: OtpVerificationPage(phoneNumber: phone),
          );
        },
      ),
      
      // Main navigation routes with bottom navigation
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const UnifiedHomePage(),
        ),
      ),
      
      // E-commerce routes
      GoRoute(
        path: RouteNames.products,
        name: 'products',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ProductsPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.productDetail,
        name: 'product-detail',
        pageBuilder: (context, state) {
          final productId = state.pathParameters['id'] ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: ProductDetailPage(productId: productId),
          );
        },
      ),
      
      // Gaming routes
      GoRoute(
        path: RouteNames.matches,
        name: 'matches',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const MatchesPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.matchDetail,
        name: 'match-detail',
        pageBuilder: (context, state) {
          final matchId = state.pathParameters['id'] ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: MatchDetailPage(matchId: matchId),
          );
        },
      ),
      
      // Wallet routes
      GoRoute(
        path: RouteNames.wallet,
        name: 'wallet',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const WalletPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.addMoney,
        name: 'add-money',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const AddMoneyPage(),
        ),
      ),
      
      // Profile routes
      GoRoute(
        path: RouteNames.profile,
        name: 'profile',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ProfilePage(),
        ),
      ),
      
      // ========== Shopping Module Routes ==========
      GoRoute(
        path: '/shop/home',
        name: 'shop_home',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ShopHomeScreen(),
        ),
      ),
      GoRoute(
        path: '/shop/product/:id',
        name: 'shop_product_details',
        pageBuilder: (context, state) {
          final productId = state.pathParameters['id']!;
          return MaterialPage(
            key: state.pageKey,
            child: ProductDetailsScreen(productId: productId),
          );
        },
      ),
      GoRoute(
        path: '/shop/cart',
        name: 'shop_cart',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const CartScreen(),
        ),
      ),
      GoRoute(
        path: '/shop/checkout',
        name: 'shop_checkout',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const AddressSelectionScreen(),
        ),
      ),
      GoRoute(
        path: '/shop/orders',
        name: 'shop_orders',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const OrdersScreen(),
        ),
      ),
      GoRoute(
        path: '/shop/order/:id',
        name: 'shop_order_details',
        pageBuilder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return MaterialPage(
            key: state.pageKey,
            child: OrderTrackingScreen(orderId: orderId),
          );
        },
      ),
      GoRoute(
        path: '/shop/wishlist',
        name: 'shop_wishlist',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const BookmarkScreen(),
        ),
      ),
      GoRoute(
        path: '/shop/search',
        name: 'shop_search',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SearchScreen(),
        ),
      ),
      GoRoute(
        path: '/shop/profile',
        name: 'shop_profile',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const shop_profile.ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/shop/addresses',
        name: 'shop_addresses',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const AddressesScreen(),
        ),
      ),
      GoRoute(
        path: '/shop/address/add',
        name: 'shop_add_address',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const AddAddressScreen(),
        ),
      ),
      GoRoute(
        path: '/shop/categories',
        name: 'shop_categories',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const DiscoverScreen(),
        ),
      ),
      GoRoute(
        path: '/shop/category/:id',
        name: 'shop_category_products',
        pageBuilder: (context, state) {
          final categoryId = state.pathParameters['id']!;
          final categoryName = state.uri.queryParameters['name'] ?? 'Category';
          return MaterialPage(
            key: state.pageKey,
            child: CategoryProductsScreen(
              categoryId: categoryId,
              categoryName: categoryName,
            ),
          );
        },
      ),
      GoRoute(
        path: '/shop/order/confirmation',
        name: 'shop_order_confirmation',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const OrderConfirmationScreen(),
        ),
      ),
      
      // ========== Fantasy Gaming Module Routes ==========
      GoRoute(
        path: '/fantasy/home',
        name: 'fantasy_home',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LandingPage(),
        ),
      ),
      GoRoute(
        path: '/fantasy/match/:matchKey',
        name: 'fantasy_match_details',
        pageBuilder: (context, state) {
          final matchKey = state.pathParameters['matchKey'];
          return MaterialPage(
            key: state.pageKey,
            child: ContestPage(mode: matchKey),
          );
        },
      ),
      GoRoute(
        path: '/fantasy/my-matches',
        name: 'fantasy_my_matches',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: MyMatchesPage(updateIndex: (index) {}),
        ),
      ),
      GoRoute(
        path: '/fantasy/live-match/:matchKey',
        name: 'fantasy_live_match',
        pageBuilder: (context, state) {
          final matchKey = state.pathParameters['matchKey']!;
          return MaterialPage(
            key: state.pageKey,
            child: LiveMatchDetailsScreen(matchKey: matchKey),
          );
        },
      ),
      GoRoute(
        path: '/fantasy/wallet',
        name: 'fantasy_wallet',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const MyBalancePage(),
        ),
      ),
      GoRoute(
        path: '/fantasy/add-money',
        name: 'fantasy_add_money',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const fantasy_add_money.AddMoneyPage(),
        ),
      ),
      GoRoute(
        path: '/fantasy/withdraw',
        name: 'fantasy_withdraw',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const WithdrawScreen(),
        ),
      ),
      GoRoute(
        path: '/fantasy/transactions',
        name: 'fantasy_transactions',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const MyTransactions(),
        ),
      ),
      GoRoute(
        path: '/fantasy/kyc',
        name: 'fantasy_kyc_verification',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const VerifyDetailsPage(),
        ),
      ),
      GoRoute(
        path: '/fantasy/profile',
        name: 'fantasy_profile',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const EditProfile(),
        ),
      ),
      GoRoute(
        path: '/fantasy/refer',
        name: 'fantasy_refer_earn',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ReferAndEarnPage(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.home),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

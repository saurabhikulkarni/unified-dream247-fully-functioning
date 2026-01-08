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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Unified Wallet Screen
/// Redirects to Fantasy MyBalancePage which displays all wallet balances:
/// - Shop Tokens (for product purchases)
/// - Game Tokens (for contest entry)
/// - Winnings (withdrawable earnings)
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to Fantasy wallet (unified wallet for entire app)
    // Use context.push() to maintain back navigation stack
    Future.microtask(() {
      context.push('/fantasy/wallet');
    });
    
    // Show loading while redirecting
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

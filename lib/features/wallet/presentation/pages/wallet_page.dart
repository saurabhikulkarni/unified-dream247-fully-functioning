import 'package:flutter/material.dart';
import '../../../../features/shop/wallet/views/wallet_screen.dart';

/// Unified Wallet Page
/// Redirects to the unified wallet screen which displays:
/// - Shop Tokens (for product purchases)
/// - Game Tokens (for contest entry)
/// - Winnings (withdrawable earnings)
/// - Transaction history (Shop + Fantasy merged)
class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the unified WalletScreen from shop module
    // which redirects to Fantasy's MyBalancePage
    return const WalletScreen();
  }
}

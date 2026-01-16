import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/screens/my_balance_page.dart';

/// Unified Wallet Screen
/// Redirects to Fantasy MyBalancePage which displays all wallet balances:
/// - Shop Tokens (for product purchases)
/// - Game Tokens (for contest entry)
/// - Winnings (withdrawable earnings)
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Fantasy wallet as the unified wallet for the entire app
    return const MyBalancePage();
  }
}

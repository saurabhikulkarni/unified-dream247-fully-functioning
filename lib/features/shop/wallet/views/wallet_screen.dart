import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/accounts/presentation/screens/my_balance_page.dart';

/// Unified Wallet Screen
/// Redirects to Fantasy wallet screen which handles both Shop and Game tokens
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Fantasy wallet screen for unified wallet experience
    return const MyBalancePage();
  }
}


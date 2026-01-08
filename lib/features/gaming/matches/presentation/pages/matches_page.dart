import 'package:flutter/material.dart';
import '../../shared/components/app_bottom_nav_bar.dart';
import '../../shared/components/custom_app_bar.dart';

/// Matches page
class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Gaming'),
      body: const Center(
        child: Text('Matches Page - Coming Soon'),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }
}

import 'package:flutter/material.dart';
import '../../shared/components/app_bottom_nav_bar.dart';
import '../../shared/components/custom_app_bar.dart';

/// Products page
class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Shop'),
      body: const Center(
        child: Text('Products Page - Coming Soon'),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    );
  }
}

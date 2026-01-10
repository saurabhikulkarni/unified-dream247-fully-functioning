import 'package:flutter/material.dart';
import '../../../../../shared/components/custom_app_bar.dart';

/// Product detail page
class ProductDetailPage extends StatelessWidget {
  final String productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Product Detail'),
      body: Center(
        child: Text('Product Detail Page - ID: $productId'),
      ),
    );
  }
}

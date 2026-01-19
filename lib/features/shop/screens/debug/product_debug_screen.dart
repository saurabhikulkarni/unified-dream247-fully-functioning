import 'package:flutter/material.dart';
import 'package:unified_dream247/features/shop/services/product_service.dart';
import 'package:unified_dream247/features/shop/models/product_model.dart';

/// Debug screen to check product loading and image URLs
class ProductDebugScreen extends StatefulWidget {
  const ProductDebugScreen({super.key});

  @override
  State<ProductDebugScreen> createState() => _ProductDebugScreenState();
}

class _ProductDebugScreenState extends State<ProductDebugScreen> {
  final ProductService _productService = ProductService();
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products = await _productService.getAllProducts();
      print('[DEBUG] Loaded ${products.length} products');
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      print('[DEBUG] Error loading products: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProducts,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Product ${index + 1}: ${product.productName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('ID: ${product.id}'),
                            Text('Price: ₹${product.price}'),
                            Text('Category: ${product.brandName}'),
                            Text('Slug: ${product.slug}'),
                            const SizedBox(height: 12),
                            Container(
                              color: Colors.grey[200],
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Image URL:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.image.isEmpty
                                        ? '(EMPTY - NO IMAGE URL)'
                                        : product.image,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: product.image.isEmpty ? Colors.red : Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (product.image.isNotEmpty)
                              Container(
                                height: 150,
                                width: double.infinity,
                                color: Colors.grey[100],
                                child: Image.network(
                                  product.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.error, color: Colors.red),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Image load failed:\n$error',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

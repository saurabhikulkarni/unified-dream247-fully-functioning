import 'package:flutter/material.dart';
import 'package:unified_dream247/features/shop/components/product/product_card.dart';
import 'package:unified_dream247/features/shop/models/product_model.dart';
import 'package:unified_dream247/features/shop/services/product_service.dart';
import 'package:unified_dream247/features/shop/route/route_constants.dart';

import 'package:unified_dream247/features/shop/constants.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  final ProductService _productService = ProductService();
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final products = await _productService.getAllProducts();
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? const Center(child: Text('Error loading products'))
              : _products.isEmpty
                  ? const Center(child: Text('No bookmarked products'))
                  : CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: defaultPadding,
                              vertical: defaultPadding),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200.0,
                              mainAxisSpacing: defaultPadding,
                              crossAxisSpacing: defaultPadding,
                              childAspectRatio: 0.66,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                return ProductCard(
                                  image: _products[index].image,
                                  brandName: _products[index].brandName,
                                  title: _products[index].title,
                                  price: _products[index].price,
                                  priceAfetDiscount:
                                      _products[index].priceAfetDiscount,
                                  product: _products[index],
                                  press: () {
                                    Navigator.pushNamed(
                                        context, productDetailsScreenRoute,
                                        arguments: {'product': _products[index]});
                                  },
                                );
                              },
                              childCount: _products.length,
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}

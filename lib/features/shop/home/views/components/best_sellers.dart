import 'package:flutter/material.dart';
import 'package:unified_dream247/features/shop/components/product/product_card.dart';
import 'package:unified_dream247/features/shop/components/skleton/product/products_skelton.dart';
import 'package:unified_dream247/features/shop/models/product_model.dart';
import 'package:unified_dream247/features/shop/services/product_service.dart';
import 'package:unified_dream247/features/shop/utils/responsive_extension.dart';

import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/shop/route/route_constants.dart';

class BestSellers extends StatefulWidget {
  const BestSellers({
    super.key,
  });

  @override
  State<BestSellers> createState() => _BestSellersState();
}

class _BestSellersState extends State<BestSellers> {
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
      final products = await _productService.getBestSellers();
      if (mounted) {
        setState(() {
          // Shuffle and take only 6 random products
          _products = (products..shuffle()).take(6).toList();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            'Best sellers',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        if (_isLoading)
          const ProductsSkelton()
        else if (_error != null)
          const Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: Text('Error loading products'),
          )
        else if (_products.isEmpty)
          const Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: Text('No best sellers available'),
          )
        else
          SizedBox(
            height: context.isTablet ? context.height(32) : context.height(27),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _products.length,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(
                  left: defaultPadding,
                  right: index == _products.length - 1 ? defaultPadding : 0,
                ),
                child: ProductCard(
                  image: _products[index].image,
                  brandName: _products[index].brandName,
                  title: _products[index].title,
                  price: _products[index].price,
                  priceAfetDiscount: _products[index].priceAfetDiscount,
                  product: _products[index],
                  press: () {
                    Navigator.pushNamed(context, productDetailsScreenRoute,
                        arguments: {'product': _products[index]},);
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}

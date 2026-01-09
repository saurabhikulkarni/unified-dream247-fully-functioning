import 'package:flutter/material.dart';
import 'package:unified_dream247/features/shop/components/product/secondary_product_card.dart';
import 'package:unified_dream247/features/shop/components/skleton/product/secondery_produts_skelton.dart';
import 'package:unified_dream247/features/shop/models/product_model.dart';
import 'package:unified_dream247/features/shop/services/product_service.dart';

import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/shop/route/route_constants.dart';

class MostPopular extends StatefulWidget {
  const MostPopular({
    super.key,
  });

  @override
  State<MostPopular> createState() => _MostPopularState();
}

class _MostPopularState extends State<MostPopular> {
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
      final products = await _productService.getPopularProducts();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "Most popular",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        if (_isLoading)
          const SeconderyProductsSkelton()
        else if (_error != null)
          const Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: Text('Error loading products'),
          )
        else if (_products.isEmpty)
          const Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: Text('No popular products available'),
          )
        else
          SizedBox(
            height: 114,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _products.length,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(
                  left: defaultPadding,
                  right: index == _products.length - 1 ? defaultPadding : 0,
                ),
                child: SecondaryProductCard(
                  image: _products[index].image,
                  brandName: _products[index].brandName,
                  title: _products[index].title,
                  price: _products[index].price,
                  priceAfetDiscount: _products[index].priceAfetDiscount,
                  press: () {
                    Navigator.pushNamed(context, productDetailsScreenRoute,
                        arguments: {'product': _products[index]});
                  },
                ),
              ),
            ),
          )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:unified_dream247/features/shop/route/route_constants.dart';
import 'package:unified_dream247/features/shop/services/product_service.dart';

import '/components/Banner/M/banner_m_with_counter.dart';
import '../../../../components/product/product_card.dart';
import '../../../../components/skleton/product/products_skelton.dart';
import '../../../../constants.dart';
import '../../../../models/product_model.dart';

class FlashSale extends StatefulWidget {
  const FlashSale({
    super.key,
  });

  @override
  State<FlashSale> createState() => _FlashSaleState();
}

class _FlashSaleState extends State<FlashSale> {
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
      final products = await _productService.getFlashSaleProducts();
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
        BannerMWithCounter(
          duration: const Duration(hours: 8),
          text: "New Arrivals",
          press: () {},
        ),
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "Latest products",
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
            child: Text('No flash sale products available'),
          )
        else
          SizedBox(
            height: 220,
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
                        arguments: {'product': _products[index]});
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}

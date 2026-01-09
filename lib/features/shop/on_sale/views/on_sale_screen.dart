import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/constants.dart';

class OnSaleScreen extends StatelessWidget {
  const OnSaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final saleProducts = [
      {'name': 'Nike Air Max', 'price': 120.0, 'originalPrice': 180.0, 'discount': '33%'},
      {'name': 'Adidas Jacket', 'price': 68.0, 'originalPrice': 85.0, 'discount': '20%'},
      {'name': 'Blue T-shirt', 'price': 15.0, 'originalPrice': 25.0, 'discount': '40%'},
      {'name': 'Summer Hat', 'price': 18.0, 'originalPrice': 30.0, 'discount': '40%'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("On Sale"),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(defaultPadding),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: defaultPadding,
          crossAxisSpacing: defaultPadding,
          childAspectRatio: 0.7,
        ),
        itemCount: saleProducts.length,
        itemBuilder: (context, index) {
          final product = saleProducts[index];
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 150,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, size: 50),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product['discount'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'] as String,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/coin.svg',
                                width: 14,
                                height: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                "${(product['price'] as num).toInt()}",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              Opacity(
                                opacity: 0.5,
                                child: SvgPicture.asset(
                                  'assets/icons/coin.svg',
                                  width: 12,
                                  height: 12,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                "${(product['originalPrice'] as num).toInt()}",
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

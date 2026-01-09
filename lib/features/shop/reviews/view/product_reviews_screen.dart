import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shop/constants.dart';

class ProductReviewsScreen extends StatefulWidget {
  const ProductReviewsScreen({super.key});

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  @override
  Widget build(BuildContext context) {
    final reviews = [
      {
        'author': 'John Doe',
        'rating': 5.0,
        'date': 'Dec 10, 2024',
        'review': 'Great product! Excellent quality and fast delivery.',
      },
      {
        'author': 'Jane Smith',
        'rating': 4.0,
        'date': 'Dec 8, 2024',
        'review': 'Good value for money. Arrived on time.',
      },
      {
        'author': 'Mike Johnson',
        'rating': 5.0,
        'date': 'Dec 5, 2024',
        'review': 'Exceeded my expectations. Highly recommended!',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reviews"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              children: [
                Text(
                  "4.3",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                RatingBar.builder(
                  initialRating: 4.3,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 2),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {},
                ),
                const SizedBox(height: 8),
                Text(
                  "${reviews.length} reviews",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            review['author'] as String,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            review['date'] as String,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      RatingBar.builder(
                        initialRating: review['rating'] as double,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 2),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {},
                      ),
                      const SizedBox(height: 8),
                      Text(review['review'] as String),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Write a Review"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

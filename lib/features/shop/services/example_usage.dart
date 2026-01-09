// Example usage of GraphQL Product Service
// This file shows how to use the ProductService in your widgets

/*
import 'package:flutter/material.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/services/product_service.dart';

class ExampleProductListWidget extends StatefulWidget {
  @override
  _ExampleProductListWidgetState createState() => _ExampleProductListWidgetState();
}

class _ExampleProductListWidgetState extends State<ExampleProductListWidget> {
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
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            ElevatedButton(
              onPressed: _loadProducts,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return ListTile(
          leading: Image.network(product.image),
          title: Text(product.title),
          subtitle: Text(product.brandName),
          trailing: Text('\$${product.price.toStringAsFixed(2)}'),
        );
      },
    );
  }
}

// Example using Query widget from graphql_flutter
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/services/graphql_queries.dart';

class ExampleQueryWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(GraphQLQueries.getAllProducts),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
        if (result.hasException) {
          return Text('Error: ${result.exception.toString()}');
        }

        if (result.isLoading) {
          return CircularProgressIndicator();
        }

        final products = result.data?['products'] as List<dynamic>?;
        if (products == null || products.isEmpty) {
          return Text('No products found');
        }

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = ProductModel.fromJson(products[index] as Map<String, dynamic>);
            return ListTile(
              title: Text(product.title),
              subtitle: Text(product.brandName),
              trailing: Text('\$${product.price.toStringAsFixed(2)}'),
            );
          },
        );
      },
    );
  }
}
*/

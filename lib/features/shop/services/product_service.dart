import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:unified_dream247/features/shop/models/product_model.dart';
import 'package:unified_dream247/features/shop/services/graphql_client.dart';
import 'package:unified_dream247/features/shop/services/graphql_queries.dart';

class ProductService {
  final GraphQLClient _client = GraphQLService.getClient();

  // Fetch all products
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getAllProducts),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['products'] == null) {
        return [];
      }

      final List<dynamic> productsJson = result.data!['products'] as List<dynamic>;
      return productsJson
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  // Fetch product by ID
  Future<ProductModel?> getProductById(String id) async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getProductById),
          variables: {'id': id},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['product'] == null) {
        return null;
      }

      return ProductModel.fromJson(
          result.data!['product'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

  // Fetch products by category
  Future<List<ProductModel>> getProductsByCategory(String categoryName) async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getProductsByCategory),
          variables: {'categoryName': categoryName},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['products'] == null) {
        return [];
      }

      final List<dynamic> productsJson = result.data!['products'] as List<dynamic>;
      
      return productsJson
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching products by category: $e');
    }
  }

  // Fetch all categories
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getAllCategories),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['categories'] == null) {
        return [];
      }

      final List<dynamic> categoriesJson = result.data!['categories'] as List<dynamic>;
      return categoriesJson
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  // Fetch popular products (returns all products for now)
  Future<List<ProductModel>> getPopularProducts() async {
    return getAllProducts();
  }

  // Fetch flash sale products (returns all products for now)
  Future<List<ProductModel>> getFlashSaleProducts() async {
    return getAllProducts();
  }

  // Fetch best sellers (returns all products for now)
  Future<List<ProductModel>> getBestSellers() async {
    return getAllProducts();
  }

  // Search products
  Future<List<ProductModel>> searchProducts(String searchTerm) async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.searchProducts),
          variables: {'searchTerm': searchTerm},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['products'] == null) {
        return [];
      }

      final List<dynamic> productsJson = result.data!['products'] as List<dynamic>;
      return productsJson
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error searching products: $e');
    }
  }

  // Fetch sizes for a product
  Future<List<SizeModel>> getSizesByProduct(String productId) async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getSizesByProduct),
          variables: {'productId': productId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['sizes'] == null) {
        return [];
      }

      final List<dynamic> sizesJson = result.data!['sizes'] as List<dynamic>;
      return sizesJson
          .map((json) => SizeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching sizes: $e');
    }
  }
}

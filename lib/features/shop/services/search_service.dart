import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/services/graphql_client.dart';
import 'package:shop/services/graphql_queries.dart';

class SearchService {
  static final SearchService _instance = SearchService._internal();

  factory SearchService() {
    return _instance;
  }

  SearchService._internal();

  final GraphQLClient _client = GraphQLService.getClient();
  late SharedPreferences _prefs;
  List<String> _searchHistory = [];

  // Initialize service and load search history
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSearchHistory();
  }

  // Load search history from SharedPreferences
  Future<void> _loadSearchHistory() async {
    try {
      final historyJson = _prefs.getStringList('search_history') ?? [];
      _searchHistory = historyJson;
    } catch (e) {
      _searchHistory = [];
    }
  }

  // Save search history to SharedPreferences
  Future<void> _saveSearchHistory() async {
    try {
      await _prefs.setStringList('search_history', _searchHistory);
    } catch (e) {
      // Silently fail
    }
  }

  // Get search history
  List<String> getSearchHistory() {
    return List.from(_searchHistory);
  }

  // Add search to history
  void addToSearchHistory(String searchTerm) {
    if (searchTerm.isEmpty) return;

    // Remove if already exists
    _searchHistory.removeWhere((item) => item.toLowerCase() == searchTerm.toLowerCase());

    // Add to beginning
    _searchHistory.insert(0, searchTerm);

    // Keep only last 20 searches
    if (_searchHistory.length > 20) {
      _searchHistory = _searchHistory.sublist(0, 20);
    }

    _saveSearchHistory();
  }

  // Remove item from search history
  void removeFromSearchHistory(String searchTerm) {
    _searchHistory.remove(searchTerm);
    _saveSearchHistory();
  }

  // Clear search history
  void clearSearchHistory() {
    _searchHistory.clear();
    _saveSearchHistory();
  }

  // Search products via GraphQL
  Future<List<ProductModel>> searchProducts(String searchTerm) async {
    if (searchTerm.isEmpty) {
      return [];
    }

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
      
      final products = productsJson
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Add to search history after successful search
      if (products.isNotEmpty) {
        addToSearchHistory(searchTerm);
      }

      return products;
    } catch (e) {
      throw Exception('Error searching products: $e');
    }
  }

  // Clear all data on logout
  void clear() {
    _searchHistory.clear();
    _saveSearchHistory();
  }
}

// Global instance
final searchService = SearchService();

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing product search operations
/// Handles search history and search queries
class SearchService extends ChangeNotifier {
  static final SearchService _instance = SearchService._internal();
  factory SearchService() => _instance;
  SearchService._internal();

  List<String> _searchHistory = [];
  bool _isInitialized = false;
  String _currentQuery = '';

  List<String> get searchHistory => List.unmodifiable(_searchHistory);
  String get currentQuery => _currentQuery;
  bool get isInitialized => _isInitialized;

  /// Initialize search service and load search history
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _searchHistory = prefs.getStringList('search_history') ?? [];
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing search service: $e');
      _isInitialized = true;
    }
  }

  /// Add search query to history
  Future<void> addToHistory(String query) async {
    if (query.trim().isEmpty) return;
    
    // Remove if already exists
    _searchHistory.remove(query);
    
    // Add to beginning
    _searchHistory.insert(0, query);
    
    // Keep only last 20 searches
    if (_searchHistory.length > 20) {
      _searchHistory = _searchHistory.sublist(0, 20);
    }
    
    await _saveHistory();
    notifyListeners();
  }

  /// Remove query from history
  Future<void> removeFromHistory(String query) async {
    _searchHistory.remove(query);
    await _saveHistory();
    notifyListeners();
  }

  /// Clear search history
  Future<void> clearHistory() async {
    _searchHistory.clear();
    await _saveHistory();
    notifyListeners();
  }

  /// Set current search query
  void setQuery(String query) {
    _currentQuery = query;
    notifyListeners();
  }

  /// Save search history to local storage
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('search_history', _searchHistory);
    } catch (e) {
      debugPrint('Error saving search history: $e');
    }
  }

  /// Search products (to be implemented with GraphQL)
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    _currentQuery = query;
    notifyListeners();
    
    // TODO: Implement GraphQL search query
    debugPrint('Searching for: $query');
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [];
  }
}

// Global instance
final searchService = SearchService();

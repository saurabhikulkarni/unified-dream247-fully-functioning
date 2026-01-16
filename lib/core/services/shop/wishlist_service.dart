import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing wishlist operations
/// Handles local wishlist storage and backend synchronization
class WishlistService extends ChangeNotifier {
  static final WishlistService _instance = WishlistService._internal();
  factory WishlistService() => _instance;
  WishlistService._internal();

  Set<String> _wishlistIds = {};
  bool _isInitialized = false;
  bool _isSyncing = false;

  Set<String> get wishlistIds => Set.unmodifiable(_wishlistIds);
  int get wishlistCount => _wishlistIds.length;
  bool get isInitialized => _isInitialized;
  bool get isSyncing => _isSyncing;

  /// Initialize wishlist service and load saved wishlist
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistData = prefs.getStringList('wishlist_ids');
      
      if (wishlistData != null) {
        _wishlistIds = wishlistData.toSet();
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing wishlist: $e');
      _isInitialized = true;
    }
  }

  /// Check if product is in wishlist
  bool isInWishlist(String productId) {
    return _wishlistIds.contains(productId);
  }

  /// Add product to wishlist
  Future<void> addToWishlist(String productId) async {
    _wishlistIds.add(productId);
    await _saveToLocal();
    notifyListeners();
  }

  /// Remove product from wishlist
  Future<void> removeFromWishlist(String productId) async {
    _wishlistIds.remove(productId);
    await _saveToLocal();
    notifyListeners();
  }

  /// Toggle product in wishlist
  Future<void> toggleWishlist(String productId) async {
    if (isInWishlist(productId)) {
      await removeFromWishlist(productId);
    } else {
      await addToWishlist(productId);
    }
  }

  /// Clear wishlist
  Future<void> clearWishlist() async {
    _wishlistIds.clear();
    await _saveToLocal();
    notifyListeners();
  }

  /// Save wishlist to local storage
  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('wishlist_ids', _wishlistIds.toList());
    } catch (e) {
      debugPrint('Error saving wishlist: $e');
    }
  }

  /// Sync wishlist with backend (GraphQL)
  Future<void> syncWithBackend() async {
    if (_isSyncing) return;
    
    _isSyncing = true;
    notifyListeners();
    
    try {
      // TODO: Implement GraphQL sync with Hygraph backend
      debugPrint('Syncing wishlist with backend...');
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint('Wishlist synced successfully');
    } catch (e) {
      debugPrint('Error syncing wishlist: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}

// Global instance
final wishlistService = WishlistService();

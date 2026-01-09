import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service for managing shopping cart operations
/// Handles local cart storage and backend synchronization
class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  List<Map<String, dynamic>> _cartItems = [];
  bool _isInitialized = false;
  bool _isSyncing = false;

  List<Map<String, dynamic>> get cartItems => List.unmodifiable(_cartItems);
  int get cartCount => _cartItems.length;
  bool get isInitialized => _isInitialized;
  bool get isSyncing => _isSyncing;

  /// Initialize cart service and load saved cart
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('cart_items');
      
      if (cartData != null) {
        final decoded = jsonDecode(cartData) as List;
        _cartItems = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing cart: $e');
      _isInitialized = true;
    }
  }

  /// Add item to cart
  Future<void> addToCart(Map<String, dynamic> item) async {
    _cartItems.add(item);
    await _saveToLocal();
    notifyListeners();
  }

  /// Remove item from cart
  Future<void> removeFromCart(String itemId) async {
    _cartItems.removeWhere((item) => item['id'] == itemId);
    await _saveToLocal();
    notifyListeners();
  }

  /// Update item quantity
  Future<void> updateQuantity(String itemId, int quantity) async {
    final index = _cartItems.indexWhere((item) => item['id'] == itemId);
    if (index != -1) {
      _cartItems[index]['quantity'] = quantity;
      await _saveToLocal();
      notifyListeners();
    }
  }

  /// Clear cart
  Future<void> clearCart() async {
    _cartItems.clear();
    await _saveToLocal();
    notifyListeners();
  }

  /// Save cart to local storage
  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cart_items', jsonEncode(_cartItems));
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  /// Sync cart with backend (GraphQL)
  Future<void> syncWithBackend() async {
    if (_isSyncing) return;
    
    _isSyncing = true;
    notifyListeners();
    
    try {
      // TODO: Implement GraphQL sync with Hygraph backend
      debugPrint('Syncing cart with backend...');
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint('Cart synced successfully');
    } catch (e) {
      debugPrint('Error syncing cart: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Calculate total amount
  double get totalAmount {
    return _cartItems.fold(0.0, (sum, item) {
      final price = (item['price'] ?? 0.0) as num;
      final quantity = (item['quantity'] ?? 1) as int;
      return sum + (price.toDouble() * quantity);
    });
  }
}

// Global instance
final cartService = CartService();

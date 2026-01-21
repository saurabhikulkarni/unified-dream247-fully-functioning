import 'dart:convert';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_dream247/features/shop/models/product_model.dart';
import 'package:unified_dream247/features/shop/services/graphql_client.dart';
import 'package:unified_dream247/features/shop/services/graphql_queries.dart';
import 'package:unified_dream247/features/shop/services/user_service.dart';

class CartService {
  static final CartService _instance = CartService._internal();

  factory CartService() {
    return _instance;
  }

  CartService._internal();

  final GraphQLClient _client = GraphQLService.getClient();
  late SharedPreferences _prefs;
  String? _userId;

  // In-memory cart storage (synced with SharedPreferences)
  List<CartModel> _localCart = [];

  // Initialize service and load persisted data
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadFromSharedPreferences();
  }

  // Load cart from SharedPreferences
  Future<void> _loadFromSharedPreferences() async {
    try {
      final cartJson = _prefs.getString('cart_items');
      final userIdString = _prefs.getString('user_id');

      _userId = userIdString;
      
      if (cartJson != null && cartJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(cartJson);
        _localCart = decoded
            .map((item) => CartModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        _localCart = [];
      }
    } catch (e) {
      // Silently fail - cart will be empty
      _localCart = [];
    }
  }

  // Save cart to SharedPreferences
  Future<void> _saveToSharedPreferences() async {
    try {
      final cartJson = jsonEncode(
        _localCart.map((item) => item.toJson()).toList(),
      );
      await _prefs.setString('cart_items', cartJson);
    } catch (e) {
      // Silently fail - data still in memory
    }
  }

  // Set user ID from auth service
  void setUserId(String userId) {
    _userId = userId;
  }

  // Get local cart items
  List<CartModel> getLocalCart() {
    return _localCart;
  }

  // Add item to local cart and persist
  // Also syncs with Hygraph if user is logged in
  // Throws exception if stock unavailable
  Future<void> addToLocalCart(ProductModel product, SizeModel? size, int quantity) async {
    // Check stock availability if size is provided
    if (size != null && size.quantity < quantity) {
      throw Exception('Insufficient stock. Only ${size.quantity} items available for size ${size.sizeName}');
    }

    // Check if product already exists in cart with same size (or both null)
    final existingIndex = _localCart.indexWhere((item) {
      final sameProduct = item.product?.id == product.id;
      final sameSize = (item.size?.id == size?.id) || 
                       (item.size == null && size == null);
      return sameProduct && sameSize;
    });

    final newQuantity = existingIndex >= 0 
        ? _localCart[existingIndex].quantity + quantity 
        : quantity;

    // Validate stock again with new quantity
    if (size != null && size.quantity < newQuantity) {
      throw Exception('Insufficient stock. Cannot add more items. Available: ${size.quantity}');
    }

    // Get userId for backend sync
    final userId = UserService.getCurrentUserId() ?? _userId;

    if (existingIndex >= 0) {
      // Update quantity
      final existingItem = _localCart[existingIndex];
      
      // Update locally first
      _localCart[existingIndex] = CartModel(
        id: existingItem.id,
        quantity: newQuantity,
        product: existingItem.product,
        size: existingItem.size,
      );
      _saveToSharedPreferences();
      
      // Sync with backend if user is logged in
      if (userId != null && userId.isNotEmpty && product.id != null) {
        // Check if item has a real backend ID (not a temp numeric ID)
        final hasBackendId = existingItem.id != null && 
                             !RegExp(r'^\d+$').hasMatch(existingItem.id!);
        
        if (hasBackendId) {
          // If item has a backend ID, update it
          try {
            await updateCartQuantity(existingItem.id!, newQuantity);
          } catch (e) {
            // Continue even if backend update fails - local update succeeded
          }
        } else {
          // If item doesn't have backend ID yet, create it
          try {
            final backendCartItem = await addToCart(
              userId: userId,
              productId: product.id!,
              sizeId: size?.id,
              quantity: newQuantity,
            );
            // Update local cart with backend ID
            if (backendCartItem?.id != null) {
              _localCart[existingIndex] = CartModel(
                id: backendCartItem!.id,
                quantity: newQuantity,
                product: existingItem.product,
                size: existingItem.size,
              );
              _saveToSharedPreferences();
            }
          } catch (e) {
            print('Error creating cart item in backend: $e');
            // Continue even if backend create fails - local update succeeded
          }
        }
      }
    } else {
      // Add new item locally first
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      _localCart.add(CartModel(
        id: tempId,
        quantity: quantity,
        product: product,
        size: size,
      ),);
      _saveToSharedPreferences();
      
      // Sync with backend if user is logged in
      if (userId != null && userId.isNotEmpty && product.id != null) {
        try {
          final backendCartItem = await addToCart(
            userId: userId,
            productId: product.id!,
            sizeId: size?.id,
            quantity: quantity,
          );
          // Update local cart with backend ID
          if (backendCartItem?.id != null) {
            final newItemIndex = _localCart.indexWhere((item) => item.id == tempId);
            if (newItemIndex >= 0) {
              _localCart[newItemIndex] = CartModel(
                id: backendCartItem!.id,
                quantity: quantity,
                product: product,
                size: size,
              );
              _saveToSharedPreferences();
            }
          }
        } catch (e) {
          print('Error adding cart item to backend: $e');
          // Continue even if backend add fails - local add succeeded
        }
      }
    }
  }

  // Update cart item quantity and persist
  // Also syncs with Hygraph if user is logged in
  // Throws exception if stock is insufficient
  Future<void> updateLocalCartQuantity(String cartItemId, int quantity) async {
    if (quantity < 1) {
      throw Exception('Quantity must be at least 1');
    }

    final index = _localCart.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      final item = _localCart[index];
      
      // Check stock availability if size is provided
      if (item.size != null && item.size!.quantity < quantity) {
        throw Exception('Insufficient stock. Only ${item.size!.quantity} items available for size ${item.size!.sizeName}');
      }

      // Update locally first
      _localCart[index] = CartModel(
        id: item.id,
        quantity: quantity,
        product: item.product,
        size: item.size,
      );

      // Persist to SharedPreferences
      _saveToSharedPreferences();
      
      // Sync with backend if user is logged in and item has backend ID
      final userId = UserService.getCurrentUserId() ?? _userId;
      if (userId != null && userId.isNotEmpty && item.id != null) {
        // Check if item has a real backend ID (not a temp numeric ID)
        final hasBackendId = !RegExp(r'^\d+$').hasMatch(item.id!);
        if (hasBackendId) {
          try {
            await updateCartQuantity(item.id!, quantity);
          } catch (e) {
            // Continue even if backend update fails - local update succeeded
          }
        }
      }
    }
  }

  // Remove item from local cart and persist
  // Also removes from Hygraph if user is logged in
  Future<void> removeFromLocalCart(String cartItemId) async {
    final item = _localCart.firstWhere((item) => item.id == cartItemId, orElse: () => throw Exception('Cart item not found'));
    
    // Remove from local cart
    _localCart.removeWhere((item) => item.id == cartItemId);
    _saveToSharedPreferences();
    
    // Remove from backend if user is logged in and item has backend ID
    final userId = UserService.getCurrentUserId() ?? _userId;
    if (userId != null && userId.isNotEmpty && item.id != null) {
      // Check if item has a real backend ID (not a temp numeric ID)
      final hasBackendId = !RegExp(r'^\d+$').hasMatch(item.id!);
      if (hasBackendId) {
        try {
          await deleteCartItem(item.id!);
        } catch (e) {
          // Continue even if backend delete fails - local delete succeeded
        }
      }
    }
  }

  // Clear local cart and persist
  void clearLocalCart() {
    _localCart.clear();
    _saveToSharedPreferences();
  }

  // Clear all cart items from backend for a user
  Future<bool> clearBackendCart(String userId) async {
    try {
      print('🗑️ Clearing backend cart for user: $userId');
      
      // Get all cart items for the user from backend
      final cartItems = await getCartByUser(userId);
      
      if (cartItems.isEmpty) {
        print('✅ Backend cart is already empty');
        return true;
      }

      print('📦 Found ${cartItems.length} items to delete from backend');
      
      // Delete all items in parallel for faster execution
      final deleteFutures = cartItems
          .where((item) => item.id != null && item.id!.isNotEmpty)
          .map((item) => deleteCartItem(item.id!))
          .toList();

      if (deleteFutures.isNotEmpty) {
        await Future.wait(deleteFutures);
      }

      print('✅ Backend cart cleared successfully');
      return true;
    } catch (e) {
      print('❌ Error clearing backend cart: $e');
      return false;
    }
  }

  // Complete cart clearing - both local and backend
  Future<bool> clearCompleteCart() async {
    try {
      // Get user ID
      final userId = UserService.getCurrentUserId() ?? _userId;
      
      // Clear local cart first (immediate feedback)
      clearLocalCart();
      
      // Then clear backend if user is logged in
      if (userId != null && userId.isNotEmpty) {
        await clearBackendCart(userId);
      }
      
      print('✅ Complete cart clearing done (local + backend)');
      return true;
    } catch (e) {
      print('❌ Error during complete cart clearing: $e');
      return false;
    }
  }

  // Calculate total
  double getCartTotal() {
    return _localCart.fold(0, (sum, item) {
      final price = item.product?.price ?? 0;
      return sum + (price * item.quantity);
    });
  }

  // Get cart item count
  int getCartItemCount() {
    return _localCart.fold(0, (sum, item) => sum + item.quantity);
  }

  // ============ GraphQL Methods (for backend sync) ============

  // Fetch cart items for a user from GraphQL
  Future<List<CartModel>> getCartByUser(String userId) async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getCartByUser),
          variables: {'userId': userId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['carts'] == null) {
        return [];
      }

      final List<dynamic> cartsJson = result.data!['carts'] as List<dynamic>;
      return cartsJson
          .map((json) => CartModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching cart: $e');
    }
  }

  // Sync cart with backend (fetch latest from GraphQL)
  Future<void> syncWithBackend() async {
    // Try to get userId from internal variable or UserService
    final userId = _userId ?? UserService.getCurrentUserId();
    
    if (userId == null || userId.isEmpty) {
      return;
    }

    try {
      final backendCart = await getCartByUser(userId);
      _localCart = backendCart;
      await _saveToSharedPreferences();
    } catch (e) {
      // Keep existing local cart on error
    }
  }

  // Add item to cart via GraphQL
  Future<CartModel?> addToCart({
    required String userId,
    required String productId,
    String? sizeId,
    int quantity = 1,
  }) async {
    try {
      // Use different mutations based on whether sizeId is provided
      final bool hasValidSizeId = sizeId != null && 
                                  sizeId.isNotEmpty && 
                                  !sizeId.startsWith('local_');
      
      final QueryResult result;
      if (hasValidSizeId) {
        result = await _client.mutate(
          MutationOptions(
            document: gql(GraphQLQueries.createCartItemWithSize),
            variables: {
              'userId': userId,
              'productId': productId,
              'sizeId': sizeId,
              'quantity': quantity.toString(),
            },
          ),
        );
      } else {
        result = await _client.mutate(
          MutationOptions(
            document: gql(GraphQLQueries.createCartItemWithoutSize),
            variables: {
              'userId': userId,
              'productId': productId,
              'quantity': quantity.toString(),
            },
          ),
        );
      }

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['createCart'] == null) {
        return null;
      }

      // Publish the cart item
      final cartId = result.data!['createCart']['id'];
      await _publishCart(cartId);

      return CartModel.fromJson(
          result.data!['createCart'] as Map<String, dynamic>,);
    } catch (e) {
      throw Exception('Error adding to cart: $e');
    }
  }

  // Update cart item quantity via GraphQL
  Future<bool> updateCartQuantity(String cartId, int quantity) async {
    try {
      final QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.updateCartItem),
          variables: {
            'cartId': cartId,
            'quantity': quantity.toString(), // Convert int to String for GraphQL
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return true;
    } catch (e) {
      throw Exception('Error updating cart: $e');
    }
  }

  // Delete cart item via GraphQL
  Future<bool> deleteCartItem(String cartId) async {
    try {
      final QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.deleteCartItem),
          variables: {'cartId': cartId},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return true;
    } catch (e) {
      throw Exception('Error deleting cart item: $e');
    }
  }

  // Publish cart (required for Hygraph)
  Future<void> _publishCart(String cartId) async {
    try {
      await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.publishCart),
          variables: {'id': cartId},
        ),
      );
    } catch (e) {
      // Silently fail publish - item is still created
    }
  }
  // Clear cart on logout (only clears userId, cart data preserved for restoration)
  void clear() {
    _userId = null;
    // Don't clear _localCart - let it remain for offline access
    // Backend will be the source of truth on next login
  }
}

// Global instance
final cartService = CartService();

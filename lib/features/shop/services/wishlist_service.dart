import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_dream247/features/shop/models/product_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:convert';
import 'graphql_client.dart';
import 'graphql_queries.dart';
import 'user_service.dart';

class WishlistService {
  static final WishlistService _instance = WishlistService._internal();
  static const String _wishlistKey = 'wishlist_items';
  static const String _userIdKey = 'user_id';

  factory WishlistService() {
    return _instance;
  }

  WishlistService._internal();

  // Use public client for reads (CDN, no auth needed)
  final GraphQLClient _readClient = GraphQLService.getPublicClient();
  // Use authenticated client for mutations (create/delete)
  final GraphQLClient _writeClient = GraphQLService.getClient();

  // In-memory storage for wishlist items with their wishlist record IDs
  final List<Map<String, dynamic>> _wishlist = []; // {product, wishlistId}
  bool _isInitialized = false;
  String? _currentUserId;

  // Set current user ID for backend operations
  void setUserId(String userId) {
    _currentUserId = userId;
    UserService.setCurrentUserId(userId); // Fire and forget - no need to await
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_userIdKey, userId);
      if (kDebugMode) {
        print('✓ Wishlist service: User ID set to $userId');
      }
    });
  }

  // Initialize wishlist from SharedPreferences
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = prefs.getStringList(_wishlistKey) ?? [];
      
      // Load user ID from UserService (central source) or fallback to local storage
      _currentUserId = UserService.getCurrentUserId() ?? prefs.getString(_userIdKey);
      if (_currentUserId != null) {
        if (kDebugMode) {
          print('✓ Wishlist initialized with user ID: $_currentUserId');
        }
      } else {
        if (kDebugMode) {
          print('⚠️ Wishlist initialized but no user ID found');
        }
        // Clear any corrupted wishlist data if no user is logged in
        await prefs.remove(_wishlistKey);
        _wishlist.clear();
        _isInitialized = true;
        if (kDebugMode) {
          print('✓ Cleared wishlist (no user logged in)');
        }
        return;
      }
      
      _wishlist.clear();
      int validItems = 0;
      int invalidItems = 0;
      
      for (String json in wishlistJson) {
        try {
          final wishlistMap = jsonDecode(json) as Map<String, dynamic>;
          // Validate that the item has required product data
          if (wishlistMap['product'] != null && 
              wishlistMap['product']['id'] != null) {
            _wishlist.add(wishlistMap);
            validItems++;
          } else {
            invalidItems++;
            if (kDebugMode) {
              print('⚠️ Skipping invalid wishlist item (missing product/id)');
            }
          }
        } catch (e) {
          invalidItems++;
          if (kDebugMode) {
            print('Error parsing wishlist item: $e');
          }
        }
      }
      
      // If we had invalid items, save the cleaned list
      if (invalidItems > 0) {
        await _saveToPreferences();
        if (kDebugMode) {
          print('✓ Cleaned up $invalidItems invalid wishlist items');
        }
      }
      
      if (kDebugMode) {
        print('✓ Loaded $validItems valid wishlist items from local storage');
        print('📋 Wishlist items: ${_wishlist.map((item) => item['product']?['id']).toList()}');
      }
      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing wishlist: $e');
      }
      _isInitialized = true;
    }
  }

  /// Force clear all local wishlist data (for debugging/reset)
  Future<void> forceResetWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_wishlistKey);
      _wishlist.clear();
      _isInitialized = false;
      if (kDebugMode) {
        print('✅ Wishlist data force reset');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error resetting wishlist: $e');
      }
    }
  }

  // Save wishlist to SharedPreferences
  Future<void> _saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = _wishlist
          .map((item) => jsonEncode(item))
          .toList();
      await prefs.setStringList(_wishlistKey, wishlistJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving wishlist: $e');
      }
    }
  }

  // Add product to wishlist (local cache)
  Future<void> addToWishlist(ProductModel product, {String? sizeId}) async {
    // Check if already exists
    if (!_wishlist.any((item) => item['product']?['id'] == product.id)) {
      final productJson = product.toJson();
      
      _wishlist.insert(0, {
        'product': productJson,
        'wishlistId': null, // Will be set when synced with backend
      });
      await _saveToPreferences();
      if (kDebugMode) {
        print('✓ Product ${product.title} added to wishlist. Total items: ${_wishlist.length}');
      }
    } else {
      if (kDebugMode) {
        print('Product ${product.title} already in wishlist');
      }
    }
  }

  // Remove product from wishlist (local cache and backend)
  Future<void> removeFromWishlist(String productId) async {
    final countBefore = _wishlist.length;
    
    // Remove from backend first
    await removeFromWishlistOnBackend(productId);
    
    // Then remove locally
    _wishlist.removeWhere((item) => item['product']?['id'] == productId);
    final countAfter = _wishlist.length;
    await _saveToPreferences();
    if (kDebugMode) {
      print('✓ Product removed from wishlist. Items: $countBefore → $countAfter');
    }
  }

  // Check if product is in wishlist
  bool isInWishlist(String productId) {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('⚠️ WARNING: isInWishlist called before initialization! Product: $productId');
      }
      return false; // Return false if not initialized
    }
    return _wishlist.any((item) => item['product']?['id'] == productId);
  }
    
  // Get all wishlist items as ProductModel list
  List<ProductModel> getWishlist() {
    if (kDebugMode) {
      print('Getting wishlist: ${_wishlist.length} items');
    }
    return _wishlist
        .map((item) {
          try {
            return ProductModel.fromJson(item['product'] as Map<String, dynamic>);
          } catch (e) {
            if (kDebugMode) {
              print('Error converting wishlist item: $e');
            }
            return null;
          }
        })
        .whereType<ProductModel>()
        .toList();
  }

  // Get wishlist item count
  int getWishlistCount() {
    return _wishlist.length;
  }

  // Clear wishlist (local and backend)
  Future<void> clearWishlist() async {
    // Delete all items from backend
    final itemsToDelete = List.from(_wishlist);
    for (var item in itemsToDelete) {
      final productId = item['product']?['id'];
      if (productId != null) {
        await removeFromWishlistOnBackend(productId);
      }
    }
    
    // Then clear locally
    _wishlist.clear();
    await _saveToPreferences();
    if (kDebugMode) {
      print('✓ Wishlist cleared from local and backend');
    }
  }

  // Toggle wishlist (add if not exists, remove if exists)
  Future<bool> toggleWishlist(ProductModel product, {String? sizeId}) async {
    if (isInWishlist(product.id!)) {
      // Remove from local and backend (removeFromWishlist already calls backend)
      await removeFromWishlist(product.id!);
      return false; // Removed
    } else {
      // Add to local and backend
      await addToWishlist(product, sizeId: sizeId);
      await addToWishlistOnBackend(product.id!, sizeId: sizeId);
      // Don't sync immediately - let local data persist
      // Sync will happen on next app start or screen load
      return true; // Added
    }
  }

  // Sync wishlist with backend via GraphQL
  Future<bool> syncWithBackend() async {
    try {
      // Get userId from UserService (central source)
      final userId = UserService.getCurrentUserId();
      
      if (userId == null || userId.isEmpty) {
        if (kDebugMode) {
          print('⚠️ Cannot sync wishlist: User ID not found');
        }
        return false;
      }
      
      _currentUserId = userId;

      if (kDebugMode) {
        print('📡 Syncing wishlist for user: $userId');
      }

      // Fetch wishlist from GraphQL (from separate Wishlist collection)
      final QueryOptions options = QueryOptions(
        document: gql(GraphQLQueries.getUserWishlist),
        variables: {'userId': userId},
        fetchPolicy: FetchPolicy.networkOnly, // Always fetch from network
      );

      final QueryResult result = await _readClient.query(options);

      if (result.hasException) {
        if (kDebugMode) {
          print('❌ Error syncing wishlist with backend: ${result.exception}');
        }
        return false;
      }

      final data = result.data;
      
      if (data != null && data['wishlists'] != null) {
        final wishlistData = data['wishlists'] as List?;
        if (kDebugMode) {
          print('📋 Found ${wishlistData?.length ?? 0} wishlist items from backend');
        }
        
        if (wishlistData != null && wishlistData.isNotEmpty) {
          // Merge backend items with local - ADD ONLY, never remove during sync
          for (var item in wishlistData) {
            try {
              final wishlistItem = item as Map<String, dynamic>;
              final productData = wishlistItem['product'] as Map<String, dynamic>?;
              if (productData != null) {
                final productId = productData['id']?.toString();
                if (productId != null) {
                  // Only add if not already in local wishlist
                  if (!_wishlist.any((localItem) => localItem['product']?['id'] == productId)) {
                    // Ensure image URL is properly formatted
                    if (productData['image'] != null && productData['image'] is Map) {
                      productData['image'] = (productData['image'] as Map)['url'] ?? '';
                    }
                    
                    _wishlist.add({
                      'product': productData,
                      'wishlistId': wishlistItem['id'],
                    });
                  } else {
                    // Update wishlistId for existing items
                    final index = _wishlist.indexWhere((localItem) => localItem['product']?['id'] == productId);
                    if (index >= 0 && _wishlist[index]['wishlistId'] == null) {
                      _wishlist[index]['wishlistId'] = wishlistItem['id'];
                    }
                  }
                }
              }
            } catch (e) {
              if (kDebugMode) {
                print('❌ Error parsing wishlist item from backend: $e');
              }
            }
          }
          
          await _saveToPreferences();
          if (kDebugMode) {
            print('✅ Wishlist synced successfully. Total items: ${_wishlist.length}');
          }
        } else {
          // Backend returned empty but we have local items - keep local items
          if (kDebugMode) {
            print('⚠️ Backend empty - keeping ${_wishlist.length} local items');
          }
        }
        return true;
      }
      if (kDebugMode) {
        print('⚠️ No wishlist data found in backend response');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error syncing wishlist with backend: $e');
      }
      return false;
    }
  }

  // Add to wishlist on backend via GraphQL (creates new Wishlist record)
  Future<bool> addToWishlistOnBackend(String productId, {String? sizeId}) async {
    try {
      // Get userId from UserService (central source)
      final userId = UserService.getCurrentUserId();
      
      if (userId == null || userId.isEmpty) {
        if (kDebugMode) {
          print('❌ Cannot add to wishlist backend: User ID not found');
          print('   Item saved locally - will sync when user logs in');
        }
        return false;
      }

      if (kDebugMode) {
        print('📤 Adding product $productId to backend wishlist for user $userId');
      }

      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.addToWishlist),
        variables: {
          'userId': userId,
          'productId': productId,
        },
      );

      final QueryResult result = await _writeClient.mutate(options);

      if (result.hasException) {
        if (kDebugMode) {
          print('❌ Error adding to wishlist on backend: ${result.exception}');
          print('   Item remains in local storage only');
        }
        return false;
      }

      if (kDebugMode) {
        print('✅ Product added to backend wishlist successfully');
      }
      
      // Update local item with backend wishlistId
      if (result.data?['createWishlist']?['id'] != null) {
        final wishlistId = result.data!['createWishlist']['id'];
        final index = _wishlist.indexWhere((item) => item['product']?['id'] == productId);
        if (index >= 0) {
          _wishlist[index]['wishlistId'] = wishlistId;
          await _saveToPreferences();
        }
      }
      
      return !result.hasException;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding to wishlist on backend: $e');
        print('   Item remains in local storage only');
      }
      return false;
    }
  }

  // Remove from wishlist on backend via GraphQL (deletes Wishlist record by ID)
  Future<bool> removeFromWishlistOnBackend(String productId) async {
    try {
      // Find the wishlist record ID for this product
      final wishlistItem = _wishlist.firstWhere(
        (item) => item['product']?['id'] == productId,
        orElse: () => {},
      );

      final wishlistId = wishlistItem['wishlistId'];
      if (wishlistId == null) {
        if (kDebugMode) {
          print('Error: Wishlist ID not found for product $productId');
        }
        return false;
      }

      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.removeFromWishlist),
        variables: {
          'wishlistId': wishlistId,
        },
      );

      final QueryResult result = await _writeClient.mutate(options);

      if (result.hasException) {
        if (kDebugMode) {
          print('Error removing from wishlist on backend: ${result.exception}');
        }
        return false;
      }

      return !result.hasException;
    } catch (e) {
      if (kDebugMode) {
        print('Error removing from wishlist on backend: $e');
      }
      return false;
    }
  }

  // Clear wishlist (logout) - only clear memory, keep local storage for offline access
  Future<void> clear() async {
    try {
      // Clear in-memory list but keep SharedPreferences
      // Data will be synced from backend on next login
      _wishlist.clear();
      _currentUserId = null;
      if (kDebugMode) {
        print('✓ Wishlist memory cleared (local storage preserved for sync)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing wishlist: $e');
      }
    }
  }
}

// Global instance
final wishlistService = WishlistService();

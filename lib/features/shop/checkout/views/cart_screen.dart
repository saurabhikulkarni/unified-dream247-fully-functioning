import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_dream247/features/shop/components/gradient_button.dart';
import 'package:unified_dream247/features/shop/components/network_image_with_loader.dart';
import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/shop/models/product_model.dart';
import 'package:unified_dream247/features/shop/models/order_models.dart';
import 'package:unified_dream247/features/shop/services/cart_service.dart';
import 'package:unified_dream247/features/shop/services/address_service.dart';
import 'package:unified_dream247/features/shop/services/order_service_graphql.dart';
import 'package:unified_dream247/features/shop/route/route_constants.dart';
import 'package:unified_dream247/core/services/wallet_service.dart';
import 'package:unified_dream247/core/providers/shop_tokens_provider.dart';
import 'package:unified_dream247/features/shop/services/user_service.dart';
import 'package:unified_dream247/features/shop/services/shiprocket_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Service instances
  final CartService cartService = CartService();
  final AddressService addressService = AddressService();
  final OrderServiceGraphQL orderServiceGraphQL = OrderServiceGraphQL();
  
  // Track per-item error messages (e.g., out of stock)
  final Map<String, String> _itemErrors = {};

  @override
  void initState() {
    super.initState();
    _refreshWallet();
    _syncCart();
  }

  Future<void> _refreshWallet() async {
    // Refresh shop tokens from backend to ensure sync
    final shopTokensProvider = context.read<ShopTokensProvider>();
    await shopTokensProvider.forceRefresh();
  }

  Future<void> _syncCart() async {
    await cartService.syncWithBackend();
    if (mounted) {
      setState(() {});
    }
  }

  List<CartModel> get cartItems => cartService.getLocalCart();

  double get subtotal => cartService.getCartTotal();
  double get total => subtotal;

  // Check if a size name represents a free size product
  bool _isFreeSizeProduct(String sizeName) {
    final upperSizeName = sizeName.toUpperCase().replaceAll(' ', '');
    return standardFreeSizes.any((freeSize) => 
      freeSize.toUpperCase().replaceAll(' ', '') == upperSizeName,
    );
  }

  void _removeItem(String cartItemId) async {
    try {
      await cartService.removeFromLocalCart(cartItemId);
      if (mounted) {
        // Use Future.microtask to defer setState and avoid mouse tracker conflicts
        Future.microtask(() {
          if (mounted) setState(() {});
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing item: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _updateQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity < 1) return;
    
    // Clear any previous error for this item
    setState(() {
      _itemErrors.remove(cartItemId);
    });
    
    try {
      await cartService.updateLocalCartQuantity(cartItemId, newQuantity);
      if (mounted) {
        // Use Future.microtask to defer setState and avoid mouse tracker conflicts
        Future.microtask(() {
          if (mounted) setState(() {});
        });
      }
    } catch (e) {
      // Show error message on the specific product card
      if (mounted) {
        setState(() {
          // Extract just the error message without "Exception:" prefix
          String errorMsg = e.toString();
          if (errorMsg.startsWith('Exception: ')) {
            errorMsg = errorMsg.substring(11);
          }
          _itemErrors[cartItemId] = errorMsg;
        });
        
        // Auto-clear error after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _itemErrors.remove(cartItemId);
            });
          }
        });
      }
    }
  }

  void _proceedToPayment(BuildContext context) async {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    // Validate size selection for all items that require sizes
    final itemsWithoutSize = cartItems.where((item) {
      // Skip validation if product has free size
      if (item.size != null && _isFreeSizeProduct(item.size!.sizeName)) {
        return false;
      }
      // Check if size is missing for products that need it
      return item.product != null && item.size == null;
    }).toList();

    if (itemsWithoutSize.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select size for ${itemsWithoutSize.length} item(s) before checkout',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final totalTokensNeeded = total.toInt();
    
    // Get current wallet balance from provider
    var currentWalletBalance = context.read<ShopTokensProvider>().shopTokens;
    
    // If provider shows 0, try to fetch from SharedPreferences directly
    if (currentWalletBalance == 0) {
      final prefs = await SharedPreferences.getInstance();
      try {
        // Try as int first
        currentWalletBalance = prefs.getInt('shop_tokens') ?? 0;
      } catch (e) {
        // Try as double if int fails
        try {
          final doubleValue = prefs.getDouble('shop_tokens') ?? 0.0;
          currentWalletBalance = doubleValue.toInt();
        } catch (e2) {
          currentWalletBalance = 0;
        }
      }
    }

    debugPrint('💳 [CART] Checking balance: Provider=${ context.read<ShopTokensProvider>().shopTokens}, Actual=$currentWalletBalance, Required=$totalTokensNeeded');

    // Check if wallet has enough tokens
    if (currentWalletBalance < totalTokensNeeded) {
      final tokensShort = totalTokensNeeded - currentWalletBalance;
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Insufficient Shopping Tokens'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You need ₹$totalTokensNeeded ($totalTokensNeeded tokens) to complete this purchase.'),
              const SizedBox(height: defaultPadding / 2),
              Text(
                'Your wallet has: ₹$currentWalletBalance ($currentWalletBalance tokens)',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: defaultPadding / 2),
              Text(
                'You need ₹$tokensShort ($tokensShort tokens) more.',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Continue Shopping'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                // Navigate to wallet screen
                context.push('/fantasy/wallet').then((_) {
                  // Refresh wallet balance when returning from wallet screen
                  context.read<ShopTokensProvider>().forceRefresh().then((_) {
                    final newBalance = context.read<ShopTokensProvider>().shopTokens;
                    // If balance is now sufficient, try payment again
                    if (newBalance >= totalTokensNeeded) {
                      _proceedToPayment(context);
                    }
                  });
                });
              },
              child: const Text('Add Top-up'),
            ),
          ],
        ),
      );
      return;
    }

    // Sufficient tokens - navigate to address selection
    final selectedAddressId = await Navigator.pushNamed(
      context,
      addressSelectionScreenRoute,
    );

    // If user selected an address, proceed with order creation
    if (selectedAddressId != null && selectedAddressId is String) {
      await _createOrderFromCart(totalTokensNeeded, selectedAddressId);
    }
  }

  Future<void> _createOrderFromCart(int totalTokensNeeded, String? addressId) async {
    // Show loading indicator with message
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Processing your order...\nThis may take a few moments',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    try {
      // Get user ID
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }
      
      // NOTE: Wallet deduction is now handled by backend API automatically
      // Backend will deduct tokens when order is created via POST /api/orders/place
      
      if (kDebugMode) {
        print('🚀 Creating order - backend will handle wallet deduction');
      }

      // Convert cart items to OrderItemModel for GraphQL
      final orderItems = cartItems.map((cartItem) {
        return OrderItemModel(
          productId: cartItem.product?.id ?? cartItem.id ?? '',
          sizeId: cartItem.size?.id,
          quantity: cartItem.quantity,
          pricePerUnit: cartItem.product?.price ?? 0.0,
        );
      }).toList();

      // Create order in GraphQL with OPTIMIZED method (much faster!)
      OrderModel? order;
      int retryCount = 0;
      const maxRetries = 3;
      
      while (order == null && retryCount < maxRetries) {
        try {
          if (retryCount > 0) {
            // Wait before retry (exponential backoff)
            await Future.delayed(Duration(seconds: retryCount * 2));
            if (kDebugMode) print('🔄 Retry attempt $retryCount/$maxRetries...');
          }
          
          // Use optimized method - creates order with parallel operations
          order = await orderServiceGraphQL.createOrderOptimized(
            items: orderItems,
            totalAmount: total.toDouble(),
            addressId: addressId,
            status: OrderStatus.pending,
          );
        } catch (e) {
          retryCount++;
          if (kDebugMode) print('❌ Order creation failed (attempt $retryCount): $e');
          
          if (retryCount >= maxRetries) {
            // All retries failed - show user-friendly error
            throw Exception(
              'Unable to create order. Please check your internet connection and try again.',
            );
          }
        }
      }
      
      if (order == null) {
        throw Exception('Order creation failed after $maxRetries attempts');
      }

      // Get address details for Shiprocket
      String? shiprocketOrderId;
      if (addressId != null && addressId.isNotEmpty) {
        try {
          final address = await addressService.getAddressById(addressId);
          if (address != null) {
            // Create shipment in Shiprocket
            final shipmentItems = cartItems.map((item) {
              return {
                'name': item.product?.title ?? 'Product',
                'sku': item.product?.id ?? 'SKU-${item.id}',
                'units': item.quantity,
                'selling_price': item.product?.price ?? 0.0,
                'discount': 0.0,
              };
            }).toList();

            final shipmentResult = await ShiprocketService.createShipment(
              orderId: order.orderNumber,
              orderDate: DateTime.now().toIso8601String(),
              pickupLocation: 'Primary', // You can make this configurable
              billingCustomerName: address.fullName,
              billingAddress: address.addressLine1 + (address.addressLine2 != null ? ', ${address.addressLine2}' : ''),
              billingCity: address.city,
              billingPincode: address.pincode,
              billingState: address.state,
              billingCountry: address.country,
              billingEmail: 'customer@example.com', // AddressModel doesn't have email field
              billingPhone: address.phoneNumber,
              orderItems: shipmentItems,
              paymentMethod: 'Prepaid', // Shopping tokens = prepaid
              subTotal: total.toDouble(),
              weight: 0.5, // Default weight in kg
            );

            if (shipmentResult != null) {
              shiprocketOrderId = shipmentResult['order_id']?.toString() ?? 
                                  shipmentResult['shipment_id']?.toString();
              if (kDebugMode) print('✅ Shiprocket shipment created: $shiprocketOrderId');
              
              // Update order with Shiprocket tracking info if available
              if (shiprocketOrderId != null && order.id != null) {
                final trackingNumber = shipmentResult['awb_code']?.toString();
                final courierName = shipmentResult['courier_name']?.toString();
                
                await orderServiceGraphQL.updateOrderTracking(
                  orderId: order.id!,
                  shiprocketOrderId: shiprocketOrderId,
                  trackingNumber: trackingNumber,
                  courierName: courierName,
                );
              }
            } else {
              if (kDebugMode) print('⚠️ Failed to create Shiprocket shipment, order will use mock tracking');
            }
          }
        } catch (shiprocketError) {
          if (kDebugMode) print('⚠️ Shiprocket integration error: $shiprocketError');
          // Continue with order - Shiprocket is optional
        }
      }
      
      // NOTE: Wallet deduction is handled by backend API automatically
      // Backend deducts tokens when order is created via POST /api/orders/place
      debugPrint('✅ [CART] Order created successfully - backend handled wallet deduction');
      
      // Refresh shop tokens provider to fetch latest balance from backend
      if (mounted) {
        try {
          final shopTokensProvider = context.read<ShopTokensProvider>();
          await shopTokensProvider.refreshShopTokens();
          debugPrint('✅ [CART] ShopTokensProvider refreshed with backend balance');
        } catch (e) {
          debugPrint('⚠️ [CART] Failed to refresh ShopTokensProvider: $e');
        }
      }

      // Clear cart completely (both local and backend)
      await cartService.clearCompleteCart();

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      debugPrint('✅ [CART] 📋 NAVIGATE_TO_ORDERS: Showing order in My Orders list');
      
      // Navigate to Orders screen (same as profile > Orders)
      // This shows the list of all orders with the newly created one at the top
      await Navigator.of(context).pushNamedAndRemoveUntil(
        ordersScreenRoute,
        (route) => route.isFirst, // Keep only the home/root route
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create order: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart (${cartService.getCartItemCount()})'),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: defaultPadding),
                  Text(
                    'Your cart is empty',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: defaultPadding),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final product = item.product;
                      
                      return Dismissible(
                        key: Key(item.id ?? index.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: defaultPadding),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _removeItem(item.id!),
                        child: Padding(
                          padding: const EdgeInsets.all(defaultPadding / 2),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // Product Image
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: SizedBox(
                                          width: 80,
                                          height: 80,
                                          child: product?.image.isNotEmpty == true
                                              ? NetworkImageWithLoader(product!.image)
                                              : Container(
                                                  color: Colors.grey.shade200,
                                                  child: const Icon(Icons.image),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: defaultPadding),
                                      // Product Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product?.title ?? 'Product',
                                              style: Theme.of(context).textTheme.titleSmall,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            if (item.size != null) ...[
                                              Text(
                                                'Size: ${item.size!.sizeName}',
                                                style: Theme.of(context).textTheme.bodySmall,
                                              ),
                                              const SizedBox(height: 2),
                                              // Show stock availability
                                              if (item.size!.quantity > 0)
                                                Text(
                                                  'Stock: ${item.size!.quantity} available',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: item.size!.quantity < 5 
                                                      ? Colors.orange 
                                                      : Colors.green,
                                                    fontSize: 11,
                                                  ),
                                                )
                                              else
                                                Text(
                                                  'Out of Stock',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                            ] else
                                              Text(
                                                'Size not selected',
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Colors.red,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/icons/coin.svg',
                                                  width: 14,
                                                  height: 14,
                                                ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  '${product?.price.toInt() ?? 0}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Quantity Controls
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                key: ValueKey('dec-${item.id}'),
                                                icon: const Icon(Icons.remove_circle_outline),
                                                onPressed: item.quantity > 1 ? () {
                                                  _updateQuantity(
                                                    item.id!,
                                                    item.quantity - 1,
                                                  );
                                                } : null,
                                              ),
                                              Text(
                                                '${item.quantity}',
                                                style: Theme.of(context).textTheme.titleMedium,
                                              ),
                                              IconButton(
                                                key: ValueKey('inc-${item.id}'),
                                                icon: const Icon(Icons.add_circle_outline),
                                                onPressed: () {
                                                  _updateQuantity(
                                                    item.id!,
                                                    item.quantity + 1,
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                            key: ValueKey('del-${item.id}'),
                                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                                            onPressed: () => _removeItem(item.id!),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // Show inline error message for this specific item
                                  if (_itemErrors.containsKey(item.id)) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: Colors.red.shade200,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            color: Colors.red.shade700,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _itemErrors[item.id]!,
                                              style: TextStyle(
                                                color: Colors.red.shade700,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal'),
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/coin.svg',
                                width: 14,
                                height: 14,
                              ),
                              const SizedBox(width: 2),
                              Text('${subtotal.toInt()}'),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: defaultPadding),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/coin.svg',
                                width: 16,
                                height: 16,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${total.toInt()}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: defaultPadding),
                      GradientButton(
                        onPressed: () {
                          _proceedToPayment(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/coin.svg',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text('Redeem'),
                            const SizedBox(width: 8),
                            Text(
                              '${total.toInt()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

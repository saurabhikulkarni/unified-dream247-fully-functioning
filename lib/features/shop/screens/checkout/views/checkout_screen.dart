import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/shop/models/product_model.dart';
import 'package:unified_dream247/features/shop/models/address_model.dart';
import 'package:unified_dream247/features/shop/models/order_models.dart';
import 'package:unified_dream247/features/shop/services/cart_service.dart';
import 'package:unified_dream247/features/shop/services/address_service.dart';
import 'package:unified_dream247/features/shop/services/order_service_graphql.dart';
import 'package:unified_dream247/features/shop/services/order_service_rest.dart';
import 'package:unified_dream247/core/providers/shop_tokens_provider.dart';
import 'package:unified_dream247/core/services/wallet_service.dart';
import 'package:unified_dream247/features/shop/services/user_service.dart';
import 'package:unified_dream247/features/shop/components/network_image_with_loader.dart';

class CheckoutScreen extends StatefulWidget {
  final String selectedAddressId;
  final List<CartModel> cartItems;
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    required this.selectedAddressId,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CartService cartService = CartService();
  final AddressService addressService = AddressService();
  final OrderServiceGraphQL orderServiceGraphQL = OrderServiceGraphQL();
  final OrderServiceREST orderServiceREST = OrderServiceREST();
  final UnifiedWalletService _walletService = UnifiedWalletService();

  AddressModel? _selectedAddress;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _loadAddressDetails();
  }

  Future<void> _loadAddressDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final address =
          await addressService.getAddressById(widget.selectedAddressId);
      if (mounted) {
        setState(() {
          _selectedAddress = address;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load address details: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _placeOrder() async {
    if (_isPlacingOrder) return;

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Placing Your Order',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Please wait while we process your order\nThis may take a few moments',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );

      // Get user ID
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      if (kDebugMode) {
        print('🚀 Creating order via REST API - backend will handle wallet deduction');
      }

      // Convert cart items to OrderItemModel for REST API
      final orderItems = widget.cartItems.map((cartItem) {
        return OrderItemModel(
          productId: cartItem.product?.id ?? cartItem.id ?? '',
          sizeId: cartItem.size?.id,
          quantity: cartItem.quantity,
          pricePerUnit: cartItem.product?.price ?? 0.0,
        );
      }).toList();

      // Create order using REST API
      OrderModel order;
      try {
        order = await orderServiceREST.placeOrder(
          items: orderItems,
          totalAmount: widget.totalAmount,
          addressId: widget.selectedAddressId,
          notes: 'Order placed via mobile app',
        );
      } catch (e) {
        if (kDebugMode) {
          print('❌ Order creation failed via REST API: $e');
          print('🔄 Falling back to GraphQL method...');
        }
        
        // Fallback to GraphQL method if REST fails
        int retryCount = 0;
        const maxRetries = 3;
        OrderModel? fallbackOrder;
        
        while (fallbackOrder == null && retryCount < maxRetries) {
          try {
            if (retryCount > 0) {
              await Future.delayed(Duration(seconds: retryCount * 2));
              if (kDebugMode)
                print('🔄 GraphQL retry attempt $retryCount/$maxRetries...');
            }

            fallbackOrder = await orderServiceGraphQL.createOrderOptimized(
              items: orderItems,
              totalAmount: widget.totalAmount,
              addressId: widget.selectedAddressId,
              status: OrderStatus.pending,
            );
          } catch (fallbackError) {
            retryCount++;
            if (kDebugMode)
              print('❌ GraphQL fallback failed (attempt $retryCount): $fallbackError');

            if (retryCount >= maxRetries) {
              throw Exception(
                'Unable to create order. Please check your internet connection and try again.',
              );
            }
          }
        }
        
        order = fallbackOrder!;
      }

      // Close loading dialog
      if (mounted) {
        context.pop(); // Close loading dialog
      }

      // Clear cart after successful order
      await cartService.clearCompleteCart();

      // Navigate to order confirmation screen
      if (mounted) {
        context.go('/shop/order/confirmation', extra: {
          'orderId': order!.id,
          'order': order,
        });
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        context.pop(); // Close loading dialog
      }

      setState(() {
        _isPlacingOrder = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Review'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: defaultPadding),
                      Text(
                        _errorMessage!,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.red,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: defaultPadding),
                      ElevatedButton(
                        onPressed: _loadAddressDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Delivery Address Section
                        _buildSectionHeader('Delivery Address'),
                        _buildAddressCard(),
                        const SizedBox(height: defaultPadding),

                        // Order Summary Section
                        _buildSectionHeader('Order Summary'),
                        _buildOrderItems(),
                        const SizedBox(height: defaultPadding),

                        // Payment Summary
                        _buildSectionHeader('Payment Summary'),
                        _buildPaymentSummary(),
                        const SizedBox(height: defaultPadding * 2),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: _selectedAddress != null && !_isLoading
          ? Container(
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/coin.svg',
                              width: 18,
                              height: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.totalAmount.toInt()}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: defaultPadding),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6441A5), Color(0xFF2a0845)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton(
                        onPressed: _isPlacingOrder ? null : _placeOrder,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isPlacingOrder
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Placing Order...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/coin.svg',
                                    width: 20,
                                    height: 20,
                                    colorFilter: const ColorFilter.mode(
                                        Colors.white, BlendMode.srcIn),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Redeem',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${widget.totalAmount.toInt()}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: defaultPadding / 2),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Delivery Address',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding),
            Text(
              _selectedAddress?.fullName ?? '',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              _selectedAddress?.fullAddress ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (_selectedAddress?.phoneNumber.isNotEmpty ?? false) ...[
              const SizedBox(height: 4),
              Text(
                'Phone: ${_selectedAddress?.phoneNumber}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
            if (_selectedAddress?.isDefault ?? false) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Default Address',
                  style: TextStyle(
                    fontSize: 12,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems() {
    return Card(
      elevation: 2,
      child: Column(
        children: widget.cartItems.map((item) {
          return _buildOrderItem(item);
        }).toList(),
      ),
    );
  }

  Widget _buildOrderItem(CartModel item) {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, width: 0.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  item.product?.image != null && item.product!.image.isNotEmpty
                      ? Image.network(
                          item.product!.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                size: 24,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 24,
                            color: Colors.grey,
                          ),
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
                  item.product?.productName ?? 'Unknown Product',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.size != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Size: ${item.size?.sizeName}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          // Price
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/coin.svg',
                width: 14,
                height: 14,
              ),
              const SizedBox(width: 2),
              Text(
                '${(item.product?.price ?? 0 * item.quantity).toInt()}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            _buildSummaryRow(
                'Subtotal', '${widget.totalAmount.toInt()} tokens'),
            const Divider(),
            _buildSummaryRow(
              'Total Amount',
              '${widget.totalAmount.toInt()} tokens',
              isTotal: true,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/coin.svg',
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Payment will be deducted from your shopping tokens balance',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/coin.svg',
                width: 14,
                height: 14,
              ),
              const SizedBox(width: 2),
              Text(
                value.replaceAll(' tokens', ''),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                      color: isTotal ? primaryColor : Colors.grey,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/shop/components/network_image_with_loader.dart';
import 'package:unified_dream247/features/shop/screens/order/views/order_tracking_screen.dart';
import 'package:unified_dream247/features/shop/services/order_service_graphql.dart';
import 'package:unified_dream247/features/shop/models/order_models.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with RouteAware {
  bool _isLoading = true;
  List<OrderModel> _orders = [];
  final OrderServiceGraphQL orderService = OrderServiceGraphQL();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void didPopNext() {
    // Called when returning to this screen from another page (e.g., after order placed)
    debugPrint('🔄 [ORDERS] Returned to orders screen, refreshing list...');
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;

    try {
      debugPrint('📲 [ORDERS] 🔄 Loading orders from backend...');
      setState(() {
        _isLoading = true;
        _orders = []; // Clear previous orders while loading
      });

      final orders = await orderService.getUserOrders();

      debugPrint('✅ [ORDERS] 📦 FETCHED: ${orders.length} orders from backend');
      if (kDebugMode) {
        for (int i = 0; i < orders.length; i++) {
          final order = orders[i];
          print(
              '     Order $i: #${order.orderNumber}, id=${order.id}, items=${order.items.length}');
        }
      }

      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
        debugPrint(
            '✅ [ORDERS] 📋 DISPLAYED: ${_orders.length} orders shown in list');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Keep existing orders if available, don't clear them on error
        });
        debugPrint('❌ [ORDERS] Error loading orders: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading orders: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the entry point screen
            context.go('/shop/entry_point');
          },
        ),
      ),
      body: Builder(
        builder: (context) {
          if (kDebugMode) {
            print(
                '🔍 Building orders screen: _isLoading=$_isLoading, _orders.length=${_orders.length}');
          }

          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Debug: Show order count even if empty
          if (_orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: defaultPadding),
                  Text(
                    'No orders yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  Text(
                    'Start shopping to place your first order!',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadOrders,
            child: ListView.builder(
              padding: const EdgeInsets.all(defaultPadding),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                // Skip rendering if order is invalid
                // Only skip if both id and orderNumber are missing
                if ((order.id == null || order.id!.isEmpty) &&
                    order.orderNumber.isEmpty) {
                  if (kDebugMode)
                    print(
                        '⚠️ Skipping invalid order at index $index: id=${order.id}, orderNumber=${order.orderNumber}');
                  return const SizedBox.shrink();
                }
                // Use orderNumber if available, otherwise use id
                final displayOrderNumber = order.orderNumber.isNotEmpty
                    ? order.orderNumber
                    : (order.id ?? 'Order ${index + 1}');
                if (kDebugMode)
                  print('✅ Rendering order $index: $displayOrderNumber');
                return Card(
                  margin: const EdgeInsets.only(bottom: defaultPadding),
                  child: InkWell(
                    onTap: () {
                      final trackingId =
                          order.shiprocketOrderId ?? order.orderNumber;
                      context.push('/shop/order/$trackingId');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Order #${order.orderNumber.isNotEmpty ? order.orderNumber : (order.id ?? 'N/A')}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDate(order.createdAt),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(order.statusString)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getStatusColor(order.statusString),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _formatStatus(order.statusString),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(order.statusString),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: defaultPadding * 1.5),

                          // Product Items List
                          ...order.items.take(3).map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: defaultPadding / 2),
                                  child: Row(
                                    children: [
                                      // Product Image
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: SizedBox(
                                          width: 60,
                                          height: 60,
                                          child: item.product?.image
                                                      .isNotEmpty ==
                                                  true
                                              ? NetworkImageWithLoader(
                                                  item.product!.image)
                                              : Container(
                                                  color: Colors.grey.shade200,
                                                  child: Icon(
                                                    Icons.image,
                                                    color: Colors.grey.shade400,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: defaultPadding / 2),
                                      // Product Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.product?.title ?? 'Product',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                if (item.size != null)
                                                  Text(
                                                    'Size: ${item.size}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: Colors
                                                              .grey.shade600,
                                                        ),
                                                  ),
                                                if (item.size != null)
                                                  Text(
                                                    ' • ',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .grey.shade600),
                                                  ),
                                                Text(
                                                  'Qty: ${item.quantity}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Colors
                                                            .grey.shade600,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                          // Show "more items" indicator if there are more than 3 items
                          if (order.items.length > 3)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: defaultPadding / 2),
                              child: Text(
                                '+ ${order.items.length - 3} more item(s)',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ),

                          const Divider(height: defaultPadding),

                          // Order Total and Actions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Shopping Tokens',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/coin.svg',
                                        height: 20,
                                        width: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        order.totalAmount.toStringAsFixed(0),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  // Track button - show if order has Shiprocket order ID or tracking number
                                  if (order.shiprocketOrderId != null ||
                                      order.trackingNumber != null)
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        // Navigate to tracking screen with Shiprocket order ID or order number
                                        final trackingId =
                                            order.shiprocketOrderId ??
                                                order.orderNumber;
                                        context.push('/shop/order/$trackingId');
                                      },
                                      icon: const Icon(
                                          Icons.local_shipping_outlined,
                                          size: 18),
                                      label: const Text('Track'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                  if (order.shiprocketOrderId != null ||
                                      order.trackingNumber != null)
                                    const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonth(date.month)} ${date.year}';
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _formatStatus(String status) {
    return status.replaceFirst(
      status[0],
      status[0].toUpperCase(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
      case 'in transit':
        return Colors.blue;
      case 'confirmed':
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

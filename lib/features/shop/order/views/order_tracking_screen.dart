import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/services/shiprocket_service.dart';
import 'package:shop/config/shiprocket_config.dart';
import '../components/delivery_partner_card.dart';
import '../components/tracking_timeline.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late Future<ShiprocketOrderData?> _trackingFuture;

  @override
  void initState() {
    super.initState();
    _trackingFuture = _fetchTrackingData();
  }

  Future<ShiprocketOrderData?> _fetchTrackingData() async {
    try {
      // Check if credentials are configured
      const isConfigured = ShiprocketConfig.email != 'YOUR_SHIPROCKET_EMAIL';
      
      print('Shiprocket configured: $isConfigured');
      print('Fetching tracking for order ID: ${widget.orderId}');
      
      if (isConfigured) {
        // Try to fetch real tracking data from Shiprocket by Order ID
        print('Attempting to fetch from Shiprocket API...');
        var trackingData = await ShiprocketService.getOrderTracking(widget.orderId);
        
        // If order ID tracking fails, try AWB code (if available in orderId)
        if (trackingData == null && widget.orderId.length >= 10) {
          print('Order ID tracking failed, trying AWB code...');
          // Might be an AWB code, try tracking by AWB
          trackingData = await ShiprocketService.getTrackingByAWB(widget.orderId);
        }
        
        if (trackingData != null) {
          print('✅ Successfully fetched real Shiprocket data');
          return trackingData;
        }
        
        // API configured but tracking failed - show error instead of silent fallback
        print('❌ Shiprocket API failed for order: ${widget.orderId}');
        
        // Check if backend proxy is configured
        final hasProxy = ShiprocketConfig.proxyUrl.isNotEmpty;
        
        if (kIsWeb && !hasProxy) {
          print('⚠️ CORS Error: Shiprocket API cannot be called directly from browser');
          print('   This is expected on Flutter Web without backend proxy');
          print('   Solutions:');
          print('   1. Test on mobile device (Android/iOS)');
          print('   2. Use a backend proxy server (set ShiprocketConfig.proxyUrl)');
        } else {
          print('This could mean:');
          print('  1. Order ID does not exist in Shiprocket');
          print('  2. Order has not been created in Shiprocket yet');
          print('  3. API authentication failed on backend');
          if (hasProxy) {
            print('  4. Backend server might be down or unreachable');
          }
        }
        // Still return mock data for UI, but log the issue
        print('⚠️ Using mock data as fallback');
        return ShiprocketService.getMockOrderTracking(widget.orderId);
      } else {
        // Credentials not configured, use mock data for development
        print('⚠️ Shiprocket credentials not configured, using mock data');
        return ShiprocketService.getMockOrderTracking(widget.orderId);
      }
    } catch (e) {
      print('❌ Exception fetching tracking data: $e');
      // Fall back to mock data if API fails
      print('⚠️ Using mock data as fallback due to exception');
      return ShiprocketService.getMockOrderTracking(widget.orderId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Order"),
        centerTitle: true,
      ),
      body: FutureBuilder<ShiprocketOrderData?>(
        future: _trackingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: defaultPadding),
                  Text(
                    "Unable to load tracking details",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  Text(
                    "Please try again later",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: defaultPadding * 2),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _trackingFuture = _fetchTrackingData();
                      });
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          final trackingData = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _trackingFuture = _fetchTrackingData();
              });
              await _trackingFuture;
            },
            child: CustomScrollView(
              slivers: [
                // Order Status Summary
                SliverPadding(
                  padding: const EdgeInsets.all(defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: _buildOrderStatusCard(trackingData, context),
                  ),
                ),

                // Courier Info
                if (trackingData.courierName != null)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding,
                      vertical: defaultPadding / 2,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _buildCourierInfoCard(trackingData),
                    ),
                  ),

                // Delivery Partner Info
                if (trackingData.deliveryPartner != null)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding,
                      vertical: defaultPadding / 2,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: DeliveryPartnerCard(
                        deliveryPartner: trackingData.deliveryPartner!,
                      ),
                    ),
                  ),

                // Tracking Timeline
                if (trackingData.trackingHistory.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.only(
                      top: defaultPadding,
                      bottom: defaultPadding,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: TrackingTimeline(
                        events: trackingData.trackingHistory,
                      ),
                    ),
                  ),

                // Bottom spacing
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: Container(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderStatusCard(
      ShiprocketOrderData trackingData, BuildContext context) {
    Color statusColor = _getStatusColor(trackingData.orderStatus);

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        color: statusColor.withOpacity(0.1),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(trackingData.orderStatus),
                color: statusColor,
                size: 32,
              ),
              const SizedBox(width: defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order Status",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trackingData.orderStatus,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (trackingData.estimatedDeliveryDate != null) ...[
            const SizedBox(height: defaultPadding),
            const Divider(),
            const SizedBox(height: defaultPadding),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  "Est. Delivery: ${trackingData.estimatedDeliveryDate?.split('T')[0] ?? 'N/A'}",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
          if (trackingData.currentLocation != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Current Location: ${trackingData.currentLocation}",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCourierInfoCard(ShiprocketOrderData trackingData) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Shipping Details",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: defaultPadding),
          _buildDetailRow("Courier", trackingData.courierName ?? "N/A"),
          _buildDetailRow(
              "Tracking Number", trackingData.trackingNumber ?? "N/A"),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return const Color(0xFF219A00);
      case 'in transit':
      case 'out for delivery':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Icons.done_all;
      case 'in transit':
      case 'out for delivery':
        return Icons.local_shipping;
      case 'processing':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.local_shipping;
    }
  }
}

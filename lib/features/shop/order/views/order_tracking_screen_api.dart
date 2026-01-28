import 'dart:async';
import 'package:flutter/material.dart';
import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/shop/services/tracking_api_service.dart';
import 'package:unified_dream247/features/shop/utils/responsive_extension.dart';
import '../components/tracking_timeline.dart';

/// Updated Order Tracking Screen that integrates with backend API
/// Features:
/// - Real-time tracking updates via polling
/// - Display current status and location
/// - Show tracking timeline with all events
/// - Responsive design for tablet and mobile
class OrderTrackingScreenApi extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreenApi({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderTrackingScreenApi> createState() => _OrderTrackingScreenApiState();
}

class _OrderTrackingScreenApiState extends State<OrderTrackingScreenApi> {
  late Timer _pollingTimer;
  TrackingData? _trackingData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTracking();
    
    // Poll for updates every 10 seconds
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _fetchTracking(),
    );
  }

  @override
  void dispose() {
    _pollingTimer.cancel();
    super.dispose();
  }

  Future<void> _fetchTracking() async {
    try {
      final response = await TrackingApiService.getTracking(widget.orderId);
      
      if (mounted) {
        if (response['success'] == true || response['statusCode'] == 200) {
          setState(() {
            _trackingData = TrackingData.fromJson(response['data'] ?? response);
            _isLoading = false;
            _errorMessage = null;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = response['message'] ?? 'Failed to fetch tracking';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        centerTitle: true,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: defaultPadding),
              Text(
                'Unable to Load Tracking',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: defaultPadding),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: _fetchTracking,
              ),
            ],
          ),
        ),
      );
    }

    if (_trackingData == null) {
      return Center(
        child: Text('No tracking data available'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Status Card
          _buildStatusCard(context),
          const SizedBox(height: defaultPadding * 1.5),

          // Tracking Details
          if (_trackingData!.trackingNumber != null ||
              _trackingData!.courierName != null)
            _buildTrackingDetailsCard(context),
          const SizedBox(height: defaultPadding * 1.5),

          // Timeline
          if (_trackingData!.timeline.isNotEmpty)
            _buildTimelineSection(context),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final trackingData = _trackingData!;
    final statusColor = _getStatusColor(trackingData.currentStatus);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStatusIcon(trackingData.currentStatus),
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Status',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trackingData.currentStatus,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (trackingData.currentLocation != null) ...[
              const SizedBox(height: defaultPadding),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      trackingData.currentLocation!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
            if (trackingData.estimatedDeliveryDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Est. Delivery: ${trackingData.estimatedDeliveryDate}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingDetailsCard(BuildContext context) {
    final trackingData = _trackingData!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shipping Details',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: defaultPadding),
            _buildDetailRow(
              'Tracking Number',
              trackingData.trackingNumber ?? 'N/A',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Courier',
              trackingData.courierName ?? 'N/A',
            ),
            if (trackingData.orderId.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                'Order ID',
                trackingData.orderId,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tracking History',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: defaultPadding),
        TrackingTimeline(
          events: _trackingData!.timeline
              .map((e) => TrackingEvent(
                    timestamp: e.timestamp,
                    status: e.status,
                    location: e.location,
                    remarks: e.remarks,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    final lowerStatus = status.toLowerCase();
    
    if (lowerStatus.contains('delivered')) {
      return Colors.green;
    } else if (lowerStatus.contains('out for delivery') ||
        lowerStatus.contains('out for')) {
      return Colors.blue;
    } else if (lowerStatus.contains('transit') ||
        lowerStatus.contains('in transit')) {
      return Colors.orange;
    } else if (lowerStatus.contains('picked') ||
        lowerStatus.contains('pickup')) {
      return Colors.amber;
    } else if (lowerStatus.contains('processing') ||
        lowerStatus.contains('pending')) {
      return Colors.grey;
    } else if (lowerStatus.contains('cancelled')) {
      return Colors.red;
    }
    
    return Colors.grey;
  }

  IconData _getStatusIcon(String status) {
    final lowerStatus = status.toLowerCase();
    
    if (lowerStatus.contains('delivered')) {
      return Icons.done_all;
    } else if (lowerStatus.contains('out for delivery')) {
      return Icons.delivery_dining;
    } else if (lowerStatus.contains('transit')) {
      return Icons.directions_run;
    } else if (lowerStatus.contains('picked')) {
      return Icons.local_shipping;
    } else if (lowerStatus.contains('processing')) {
      return Icons.hourglass_bottom;
    } else if (lowerStatus.contains('cancelled')) {
      return Icons.cancel;
    }
    
    return Icons.local_shipping;
  }
}

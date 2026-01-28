import 'package:unified_dream247/features/shop/services/api_service.dart';

/// Backend API wrapper for tracking operations
/// Provides methods for all 4 tracking management APIs + event posting
class TrackingApiService {
  
  /// GET /api/tracking/{orderId} - Get complete tracking data for an order
  /// Returns: current status, location, tracking number, timeline, etc.
  static Future<Map<String, dynamic>> getTracking(String orderId) {
    return ApiService.get('/api/tracking/$orderId');
  }

  /// GET /api/tracking/{orderId}/events - Get all tracking events for an order
  /// Returns: list of tracking events with timestamps, status, location, remarks
  static Future<Map<String, dynamic>> getTrackingEvents(String orderId) {
    return ApiService.get('/api/tracking/$orderId/events');
  }

  /// GET /api/tracking/{orderId}/latest - Get the latest tracking status
  /// Returns: most recent status, location, and timestamp
  static Future<Map<String, dynamic>> getLatestStatus(String orderId) {
    return ApiService.get('/api/tracking/$orderId/latest');
  }

  /// POST /api/tracking/{orderId}/events - Add a new tracking event (testing/admin only)
  /// Required: status
  /// Optional: location, remarks
  static Future<Map<String, dynamic>> addTrackingEvent(
    String orderId, {
    required String status,
    String? location,
    String? remarks,
  }) {
    return ApiService.post(
      '/api/tracking/$orderId/events',
      body: {
        'status': status,
        if (location != null) 'location': location,
        if (remarks != null) 'remarks': remarks,
      },
    );
  }
}

/// Model for tracking event from backend
class TrackingEvent {
  final String status;
  final String timestamp;
  final String? location;
  final String? remarks;

  TrackingEvent({
    required this.status,
    required this.timestamp,
    this.location,
    this.remarks,
  });

  factory TrackingEvent.fromJson(Map<String, dynamic> json) {
    return TrackingEvent(
      status: json['status'] ?? '',
      timestamp: json['timestamp'] ?? '',
      location: json['location'],
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'timestamp': timestamp,
      if (location != null) 'location': location,
      if (remarks != null) 'remarks': remarks,
    };
  }
}

/// Model for complete tracking data from backend
class TrackingData {
  final String orderId;
  final String currentStatus;
  final String? currentLocation;
  final String? trackingNumber;
  final String? courierName;
  final String? estimatedDeliveryDate;
  final List<TrackingEvent> timeline;

  TrackingData({
    required this.orderId,
    required this.currentStatus,
    this.currentLocation,
    this.trackingNumber,
    this.courierName,
    this.estimatedDeliveryDate,
    this.timeline = const [],
  });

  factory TrackingData.fromJson(Map<String, dynamic> json) {
    final timeline = <TrackingEvent>[];
    
    // Parse timeline/events if present
    if (json['timeline'] is List) {
      timeline.addAll(
        (json['timeline'] as List)
            .map((e) => TrackingEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } else if (json['events'] is List) {
      timeline.addAll(
        (json['events'] as List)
            .map((e) => TrackingEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }

    return TrackingData(
      orderId: json['orderId'] ?? json['order_id'] ?? '',
      currentStatus: json['currentStatus'] ?? json['status'] ?? 'Unknown',
      currentLocation: json['currentLocation'] ?? json['location'],
      trackingNumber: json['trackingNumber'] ?? json['awb_code'],
      courierName: json['courierName'] ?? json['courier_name'],
      estimatedDeliveryDate: json['estimatedDeliveryDate'] ?? json['edd'],
      timeline: timeline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'currentStatus': currentStatus,
      if (currentLocation != null) 'currentLocation': currentLocation,
      if (trackingNumber != null) 'trackingNumber': trackingNumber,
      if (courierName != null) 'courierName': courierName,
      if (estimatedDeliveryDate != null) 'estimatedDeliveryDate': estimatedDeliveryDate,
      'timeline': timeline.map((e) => e.toJson()).toList(),
    };
  }
}

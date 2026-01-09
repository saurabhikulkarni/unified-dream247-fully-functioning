import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unified_dream247/features/shop/config/shiprocket_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ShiprocketOrderData {
  final String orderId;
  final String orderStatus;
  final String? courierName;
  final String? trackingNumber;
  final String? estimatedDeliveryDate;
  final List<TrackingEvent> trackingHistory;
  final DeliveryPartner? deliveryPartner;
  final String? currentLocation;

  ShiprocketOrderData({
    required this.orderId,
    required this.orderStatus,
    this.courierName,
    this.trackingNumber,
    this.estimatedDeliveryDate,
    this.trackingHistory = const [],
    this.deliveryPartner,
    this.currentLocation,
  });

  factory ShiprocketOrderData.fromJson(Map<String, dynamic> json) {
    // Handle tracking_data - it can be a List, Map, or null
    List<TrackingEvent> trackingHistory = [];
    final trackingData = json['tracking_data'];
    if (trackingData != null) {
      if (trackingData is List) {
        // If it's already a list, map it directly
        trackingHistory = trackingData
            .map((e) => TrackingEvent.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (trackingData is Map) {
        // If it's a map, check for common Shiprocket API structures
        // Some APIs return tracking_data as { "shipment_track": [...], "tracking": [...] }
        if (trackingData['shipment_track'] is List) {
          trackingHistory = (trackingData['shipment_track'] as List)
              .map((e) => TrackingEvent.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (trackingData['tracking'] is List) {
          trackingHistory = (trackingData['tracking'] as List)
              .map((e) => TrackingEvent.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (trackingData['tracking_data'] is List) {
          trackingHistory = (trackingData['tracking_data'] as List)
              .map((e) => TrackingEvent.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          // If it's a single object, try to convert it
          try {
            trackingHistory = [TrackingEvent.fromJson(trackingData as Map<String, dynamic>)];
          } catch (e) {
            print('⚠️ Could not parse tracking_data: $e');
          }
        }
      }
    }

    return ShiprocketOrderData(
      orderId: json['order_id']?.toString() ?? json['shipment_id']?.toString() ?? '',
      orderStatus: _mapStatus(json['status'] ?? json['current_status'] ?? 'Unknown'),
      courierName: json['courier_name'] ?? json['carrier_name'],
      trackingNumber: json['awb_code'] ?? json['tracking_number'] ?? json['tracking_id'],
      estimatedDeliveryDate: json['estimated_delivery_date'] ?? json['edd'],
      trackingHistory: trackingHistory,
      deliveryPartner: json['delivery_partner'] != null
          ? DeliveryPartner.fromJson(json['delivery_partner'])
          : null,
      currentLocation: json['current_location'] ?? json['location'],
    );
  }

  static String _mapStatus(String status) {
    // Map Shiprocket statuses to user-friendly statuses
    final statusLower = status.toLowerCase();
    if (statusLower.contains('delivered')) return 'Delivered';
    if (statusLower.contains('out for delivery') || statusLower.contains('ofd')) return 'Out for Delivery';
    if (statusLower.contains('in transit') || statusLower.contains('transit')) return 'In Transit';
    if (statusLower.contains('picked up') || statusLower.contains('pickup')) return 'Picked Up';
    if (statusLower.contains('processing') || statusLower.contains('processed')) return 'Processing';
    if (statusLower.contains('cancelled') || statusLower.contains('cancel')) return 'Cancelled';
    return status;
  }
}

class TrackingEvent {
  final String timestamp;
  final String status;
  final String? location;
  final String? remarks;

  TrackingEvent({
    required this.timestamp,
    required this.status,
    this.location,
    this.remarks,
  });

  factory TrackingEvent.fromJson(Map<String, dynamic> json) {
    return TrackingEvent(
      timestamp: json['timestamp'] ?? json['created_at'] ?? DateTime.now().toString(),
      status: json['status'] ?? json['current_status'] ?? '',
      location: json['location'] ?? json['city'] ?? json['hub'],
      remarks: json['remarks'] ?? json['comment'] ?? json['message'],
    );
  }
}

class DeliveryPartner {
  final String name;
  final String phone;
  final String? email;
  final String? vehicleInfo;
  final double? latitude;
  final double? longitude;
  final String? profileImage;

  DeliveryPartner({
    required this.name,
    required this.phone,
    this.email,
    this.vehicleInfo,
    this.latitude,
    this.longitude,
    this.profileImage,
  });

  factory DeliveryPartner.fromJson(Map<String, dynamic> json) {
    return DeliveryPartner(
      name: json['name'] ?? json['delivery_boy_name'] ?? 'Delivery Partner',
      phone: json['phone'] ?? json['delivery_boy_phone'] ?? '',
      email: json['email'],
      vehicleInfo: json['vehicle_info'] ?? json['vehicle_number'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      profileImage: json['profile_image'],
    );
  }
}

class ShiprocketService {
  static const String _baseUrl = ShiprocketConfig.baseUrl;
  static const String _proxyUrl = ShiprocketConfig.proxyUrl;
  static String? _authToken;
  static DateTime? _tokenExpiry;
  static bool _authFailed = false; // Track if authentication has failed
  
  /// Get the actual URL to use (backend proxy if configured, otherwise direct API)
  static String _getApiUrl(String endpoint) {
    // Use backend proxy if configured (for all platforms to avoid CORS and keep credentials secure)
    if (_proxyUrl.isNotEmpty) {
      // Map Shiprocket endpoints to backend endpoints
      if (endpoint.startsWith('/orders/show/')) {
        final orderId = endpoint.replaceAll('/orders/show/', '');
        print('🌐 Using backend proxy: $_proxyUrl/track/$orderId');
        return '$_proxyUrl/track/$orderId';
      } else if (endpoint.startsWith('/courier/track/awb/')) {
        final awbCode = endpoint.replaceAll('/courier/track/awb/', '');
        print('🌐 Using backend proxy: $_proxyUrl/track-awb/$awbCode');
        return '$_proxyUrl/track-awb/$awbCode';
      } else if (endpoint.startsWith('/orders/create/adhoc')) {
        print('🌐 Using backend proxy: $_proxyUrl/create-shipment');
        return '$_proxyUrl/create-shipment';
      }
      // For other endpoints, use proxy with original endpoint
      print('🌐 Using backend proxy: $_proxyUrl$endpoint');
      return '$_proxyUrl$endpoint';
    }
    // Direct API call (will fail on web due to CORS)
    return '$_baseUrl$endpoint';
  }
  
  /// Check if we should attempt API calls
  static bool _shouldAttemptApiCall() {
    // If backend proxy is configured, always use it (works on all platforms)
    if (_proxyUrl.isNotEmpty) {
      return true;
    }
    // Without proxy, only attempt on mobile/desktop (web will fail due to CORS)
    if (kIsWeb) {
      return false; // No proxy on web - will fail due to CORS
    }
    return true; // Mobile/desktop - no CORS issues
  }

  /// Authenticate with Shiprocket and get access token
  static Future<String?> authenticate() async {
    // Don't retry if authentication already failed
    if (_authFailed) {
      print('⚠️ Authentication previously failed, skipping retry');
      return null;
    }

    try {
      print('🔐 Attempting Shiprocket authentication...');
      print('   Endpoint: $_baseUrl/auth/login');
      print('   API User Email: ${ShiprocketConfig.email}');
      print('   Note: Using API User credentials (not main account)');
      
      // Shiprocket API v2 authentication endpoint
      // Reference: https://shiprocket.freshdesk.com/support/solutions/articles/43000337456-api-document-helpsheet
      // POST: https://apiv2.shiprocket.in/v1/external/auth/login
      // Must use API User credentials (email different from registered email)
      final response = await http.post(
        Uri.parse(_getApiUrl('/auth/login')),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': ShiprocketConfig.email,
          'password': ShiprocketConfig.password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('📡 Authentication response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        // Token is valid for 240 hours (10 days) according to Shiprocket API docs
        // Reference: https://shiprocket.freshdesk.com/support/solutions/articles/43000337456-api-document-helpsheet
        _tokenExpiry = DateTime.now().add(const Duration(hours: 240));
        _authFailed = false; // Reset failure flag on success
        print('✅ Shiprocket authentication successful');
        print('   Token expires at: $_tokenExpiry (240 hours / 10 days)');
        return _authToken;
      } else {
        final errorBody = response.body;
        print('❌ Shiprocket Auth Error: ${response.statusCode}');
        
        try {
          final errorData = jsonDecode(errorBody);
          print('   Error message: ${errorData['message']}');
          if (errorData['errors'] != null) {
            print('   Errors: ${errorData['errors']}');
          }
        } catch (e) {
          print('   Response body: $errorBody');
        }
        
        // Check for specific error types
        if (response.statusCode == 403) {
          print('⚠️ 403 Forbidden - Possible causes:');
          print('   1. Using main Shiprocket account credentials instead of API User credentials');
          print('   2. API User email is the same as your registered Shiprocket email');
          print('   3. Invalid API User email or password');
          print('   4. API User account is suspended or inactive');
          print('   5. IP address not whitelisted in Shiprocket');
          print('');
          print('💡 Solutions:');
          print('   - Create an API User at: https://app.shiprocket.in/settings/api');
          print('   - Use API User credentials (NOT your main account credentials)');
          print('   - API User email MUST be different from your registered email');
          print('   - See: https://shiprocket.freshdesk.com/support/solutions/articles/43000337456-api-document-helpsheet');
          print('   - Contact Shiprocket support if issue persists');
        } else if (response.statusCode == 401) {
          print('⚠️ 401 Unauthorized - Invalid credentials');
          print('   Please check your API User email and password');
          print('   Remember: Use API User credentials, NOT your main account!');
        } else if (response.statusCode == 404) {
          print('⚠️ 404 Not Found - Endpoint might be incorrect');
          print('   Current endpoint: $_baseUrl/auth/login');
          print('   Expected: https://apiv2.shiprocket.in/v1/external/auth/login');
          print('   See: https://shiprocket.freshdesk.com/support/solutions/articles/43000337456-api-document-helpsheet');
        }
        
        _authFailed = true; // Mark as failed to prevent retries
        return null;
      }
    } catch (e) {
      print('❌ Exception in authenticate: $e');
      _authFailed = true; // Mark as failed to prevent retries
      return null;
    }
  }

  /// Reset authentication failure flag (allows retry)
  static void resetAuthFailure() {
    _authFailed = false;
    _authToken = null;
    _tokenExpiry = null;
    print('🔄 Shiprocket authentication reset - will retry on next call');
  }

  /// Get valid auth token (authenticates if needed)
  static Future<String?> _getAuthToken() async {
    // OPTION 1: Use direct API token from config (if provided) - RECOMMENDED
    // This skips the login process and uses the token directly from dashboard
    if (ShiprocketConfig.apiToken != null && ShiprocketConfig.apiToken!.isNotEmpty) {
      print('🔑 Using direct API token from config (skipping login)');
      return ShiprocketConfig.apiToken;
    }
    
    // OPTION 2: Use email/password authentication (fallback)
    // Don't try if authentication already failed
    if (_authFailed) {
      print('⚠️ Authentication previously failed. Call resetAuthFailure() to retry.');
      return null;
    }

    // Check if token exists and is not expired
    // Token is valid for 240 hours (10 days) according to Shiprocket docs
    if (_authToken != null && 
        _tokenExpiry != null && 
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _authToken;
    }

    // Authenticate to get new token
    return await authenticate();
  }

  /// Get order tracking details by Shiprocket Order ID
  /// 
  /// Uses backend API proxy to avoid CORS issues and keep credentials secure
  /// Backend endpoint: GET /api/shiprocket/track/:orderId
  static Future<ShiprocketOrderData?> getOrderTracking(String orderId) async {
    // Check if we should attempt API call (web without proxy will fail)
    if (!_shouldAttemptApiCall()) {
      print('⚠️ Flutter Web detected without proxy - skipping API call (CORS will block)');
      print('💡 To fix: Set ShiprocketConfig.proxyUrl or test on mobile device');
      return null;
    }
    
    try {
      // Remove # if present in order ID
      final cleanOrderId = orderId.replaceAll('#', '');

      // Use backend API (authentication handled by backend)
      final response = await http.get(
        Uri.parse(_getApiUrl('/orders/show/$cleanOrderId')),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns { success: true, data: {...} }
        final trackingData = data['data'] ?? data;
        
        // Validate that trackingData is a Map before parsing
        if (trackingData is! Map<String, dynamic>) {
          print('⚠️ Invalid response format: expected Map, got ${trackingData.runtimeType}');
          return null;
        }
        
        try {
          return ShiprocketOrderData.fromJson(trackingData);
        } catch (e) {
          print('❌ Error parsing Shiprocket order data: $e');
          print('   Response data: $trackingData');
          return null;
        }
      } else {
        final errorBody = response.body;
        print('❌ Shiprocket API Error: ${response.statusCode}');
        try {
          final errorData = jsonDecode(errorBody);
          final message = errorData['message'] ?? 'Unknown error';
          print('Error message: $message');
          
          // Don't show CORS error for 404 (order not found)
          if (response.statusCode == 404) {
            print('💡 Order not found in Shiprocket. This might mean:');
            print('   1. Order ID does not exist in Shiprocket');
            print('   2. Order has not been created in Shiprocket yet');
            print('   3. Order belongs to a different Shiprocket account');
          }
        } catch (e) {
          print('Error response: $errorBody');
        }
        
        // Check for CORS-related errors (common on web without proxy)
        if (kIsWeb && response.statusCode != 404 && 
            (errorBody.contains('CORS') || errorBody.contains('cors') || 
            errorBody.contains('Access-Control') || response.statusCode == 0)) {
          print('⚠️ CORS Error detected on Flutter Web');
          print('💡 Shiprocket API does not allow direct browser requests');
          print('   Solutions:');
          print('   1. Test on mobile device (Android/iOS)');
          print('   2. Use a backend proxy server to make API calls');
          print('   3. Configure CORS on your backend server');
        }
        
        return null;
      }
    } catch (e) {
      print('Exception in getOrderTracking: $e');
      
      // Check if it's a CORS error
      if (kIsWeb && (e.toString().contains('CORS') || e.toString().contains('cors') || 
          e.toString().contains('XMLHttpRequest') || e.toString().contains('Failed to load'))) {
        print('⚠️ CORS Error: Shiprocket API cannot be called directly from browser');
        print('💡 This is expected on Flutter Web. Use mobile app or backend proxy.');
      }
      
      return null;
    }
  }

  /// Get tracking details by AWB (Airway Bill) code
  /// 
  /// Uses backend API proxy to avoid CORS issues and keep credentials secure
  /// Backend endpoint: GET /api/shiprocket/track-awb/:awbCode
  static Future<ShiprocketOrderData?> getTrackingByAWB(String awbCode) async {
    // Check if we should attempt API call (web without proxy will fail)
    if (!_shouldAttemptApiCall()) {
      print('⚠️ Flutter Web detected without proxy - skipping API call (CORS will block)');
      print('💡 To fix: Set ShiprocketConfig.proxyUrl or test on mobile device');
      return null;
    }
    
    try {
      // Use backend API (authentication handled by backend)
      final response = await http.get(
        Uri.parse(_getApiUrl('/courier/track/awb/$awbCode')),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns { success: true, data: {...} }
        final trackingData = data['data'] ?? data;
        
        // Validate that trackingData is a Map before parsing
        if (trackingData is! Map<String, dynamic>) {
          print('⚠️ Invalid response format: expected Map, got ${trackingData.runtimeType}');
          return null;
        }
        
        try {
          return ShiprocketOrderData.fromJson(trackingData);
        } catch (e) {
          print('❌ Error parsing Shiprocket AWB tracking data: $e');
          print('   Response data: $trackingData');
          return null;
        }
      } else {
        final errorBody = response.body;
        print('❌ Shiprocket AWB Tracking Error: ${response.statusCode}');
        try {
          final errorData = jsonDecode(errorBody);
          final message = errorData['message'] ?? 'Unknown error';
          print('Error message: $message');
          
          // Don't show CORS error for 404 (AWB not found)
          if (response.statusCode == 404) {
            print('💡 AWB code not found in Shiprocket. This might mean:');
            print('   1. AWB code does not exist');
            print('   2. AWB code belongs to a different Shiprocket account');
          }
        } catch (e) {
          print('Error response: $errorBody');
        }
        
        // Check for CORS-related errors (common on web without proxy)
        if (kIsWeb && response.statusCode != 404 && 
            (errorBody.contains('CORS') || errorBody.contains('cors') || 
            errorBody.contains('Access-Control') || response.statusCode == 0)) {
          print('⚠️ CORS Error detected on Flutter Web');
          print('💡 Shiprocket API does not allow direct browser requests');
          print('   Solutions:');
          print('   1. Test on mobile device (Android/iOS)');
          print('   2. Use a backend proxy server to make API calls');
          print('   3. Configure CORS on your backend server');
        }
        
        return null;
      }
    } catch (e) {
      print('Exception in getTrackingByAWB: $e');
      
      // Check if it's a type error (the one we're fixing)
      if (e.toString().contains('is not a subtype of type')) {
        print('⚠️ Type error parsing response. This might be due to unexpected API response format.');
        print('   Error: $e');
      }
      
      // Check if it's a CORS error
      if (kIsWeb && (e.toString().contains('CORS') || e.toString().contains('cors') || 
          e.toString().contains('XMLHttpRequest') || e.toString().contains('Failed to load'))) {
        print('⚠️ CORS Error: Shiprocket API cannot be called directly from browser');
        print('💡 This is expected on Flutter Web. Use mobile app or backend proxy.');
      }
      
      return null;
    }
  }

  /// Get tracking history for an order
  static Future<List<TrackingEvent>> getTrackingHistory(String orderId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        print('Failed to authenticate with Shiprocket');
        return [];
      }

      final cleanOrderId = orderId.replaceAll('#', '');

      final response = await http.get(
        Uri.parse(_getApiUrl('/orders/show/$cleanOrderId')),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final orderData = data['data'] ?? data;
        final trackingList = orderData['tracking_data'] ?? [];
        return (trackingList as List)
            .map((event) => TrackingEvent.fromJson(event))
            .toList();
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception in getTrackingHistory: $e');
      return [];
    }
  }

  /// Get delivery partner details for an order
  static Future<DeliveryPartner?> getDeliveryPartner(String orderId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        print('Failed to authenticate with Shiprocket');
        return null;
      }

      final cleanOrderId = orderId.replaceAll('#', '');

      final response = await http.get(
        Uri.parse(_getApiUrl('/orders/show/$cleanOrderId')),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final orderData = data['data'] ?? data;
        
        // Extract delivery partner info if available
        if (orderData['delivery_partner'] != null) {
          return DeliveryPartner.fromJson(orderData['delivery_partner']);
        }
        
        // Try alternative fields
        if (orderData['delivery_boy_name'] != null) {
          return DeliveryPartner(
            name: orderData['delivery_boy_name'] ?? 'Delivery Partner',
            phone: orderData['delivery_boy_phone'] ?? '',
            email: orderData['delivery_boy_email'],
            vehicleInfo: orderData['vehicle_number'],
          );
        }
        
        return null;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception in getDeliveryPartner: $e');
      return null;
    }
  }

  /// Create a shipment order in Shiprocket
  /// Uses backend API proxy to keep credentials secure
  /// Backend endpoint: POST /api/shiprocket/create-shipment
  /// Parameters match Shiprocket API requirements
  static Future<Map<String, dynamic>?> createShipment({
    required String orderId,
    required String orderDate,
    required String pickupLocation,
    required String billingCustomerName,
    required String billingAddress,
    required String billingCity,
    required String billingPincode,
    required String billingState,
    required String billingCountry,
    required String billingEmail,
    required String billingPhone,
    bool shippingIsBilling = true,
    String? shippingCustomerName,
    String? address,
    String? shippingCity,
    String? shippingPincode,
    String? shippingState,
    String? shippingCountry,
    String? shippingEmail,
    String? shippingPhone,
    required List<Map<String, dynamic>> orderItems, // [{name, sku, units, selling_price, discount}]
    required String paymentMethod, // "Prepaid" or "COD"
    required double subTotal,
    double? length,
    double? breadth,
    double? height,
    double? weight,
  }) async {
    try {
      // Check if we should attempt API call
      if (!_shouldAttemptApiCall()) {
        print('⚠️ Cannot create shipment without backend proxy (CORS will block)');
        return null;
      }

      final Map<String, dynamic> shipmentData = {
        'order_id': orderId,
        'order_date': orderDate,
        'pickup_location': pickupLocation,
        'billing_customer_name': billingCustomerName,
        'billing_address': billingAddress,
        'billing_city': billingCity,
        'billing_pincode': billingPincode,
        'billing_state': billingState,
        'billing_country': billingCountry,
        'billing_email': billingEmail,
        'billing_phone': billingPhone,
        'shipping_is_billing': shippingIsBilling,
        'order_items': orderItems,
        'payment_method': paymentMethod,
        'sub_total': subTotal,
      };

      // Add shipping address if different from billing
      if (!shippingIsBilling) {
        shipmentData['shipping_customer_name'] = shippingCustomerName ?? billingCustomerName;
        shipmentData['shipping_address'] = address ?? billingAddress;
        shipmentData['shipping_city'] = shippingCity ?? billingCity;
        shipmentData['shipping_pincode'] = shippingPincode ?? billingPincode;
        shipmentData['shipping_state'] = shippingState ?? billingState;
        shipmentData['shipping_country'] = shippingCountry ?? billingCountry;
        shipmentData['shipping_email'] = shippingEmail ?? billingEmail;
        shipmentData['shipping_phone'] = shippingPhone ?? billingPhone;
      }

      // Add dimensions if provided
      if (length != null) shipmentData['length'] = length;
      if (breadth != null) shipmentData['breadth'] = breadth;
      if (height != null) shipmentData['height'] = height;
      if (weight != null) shipmentData['weight'] = weight;

      // Use backend API (authentication handled by backend)
      final response = await http.post(
        Uri.parse(_getApiUrl('/orders/create/adhoc')),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(shipmentData),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns { success: true, data: {...} }
        final result = data['data'] ?? data;
        print('Shiprocket shipment created successfully: ${result['order_id']}');
        return result;
      } else {
        print('Error creating Shiprocket shipment: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception in createShipment: $e');
      return null;
    }
  }

  /// Mock data for development and testing (when API is not configured)
  static ShiprocketOrderData getMockOrderTracking(String orderId) {
    return ShiprocketOrderData(
      orderId: orderId,
      orderStatus: 'In Transit',
      courierName: 'DELHIVERY',
      trackingNumber: 'DEL${orderId.replaceAll('#', '')}',
      estimatedDeliveryDate: DateTime.now().add(const Duration(days: 2)).toString(),
      currentLocation: 'Mumbai Distribution Center',
      deliveryPartner: DeliveryPartner(
        name: 'Raj Kumar',
        phone: '+91 9876543210',
        email: 'raj@shiprocket.in',
        vehicleInfo: 'Maruti Swift - MH02AB1234',
        latitude: 19.0760,
        longitude: 72.8777,
        profileImage: 'https://i.imgur.com/8B0LqOo.png',
      ),
      trackingHistory: [
        TrackingEvent(
          timestamp: DateTime.now().toString(),
          status: 'Out for Delivery',
          location: 'Mumbai, MH',
          remarks: 'Package is out for delivery',
        ),
        TrackingEvent(
          timestamp: DateTime.now().subtract(const Duration(hours: 3)).toString(),
          status: 'In Transit',
          location: 'Vile Parle, Mumbai',
          remarks: 'Package in transit to delivery location',
        ),
        TrackingEvent(
          timestamp: DateTime.now().subtract(const Duration(days: 1)).toString(),
          status: 'Picked Up',
          location: 'Delhi Warehouse',
          remarks: 'Package picked up from warehouse',
        ),
        TrackingEvent(
          timestamp: DateTime.now().subtract(const Duration(days: 2)).toString(),
          status: 'Order Confirmed',
          location: 'Delhi',
          remarks: 'Order confirmed and packaged',
        ),
      ],
    );
  }

  /// Verify Shiprocket API credentials
  static Future<bool> verifyCredentials() async {
    try {
      final token = await authenticate();
      return token != null;
    } catch (e) {
      print('Exception in verifyCredentials: $e');
      return false;
    }
  }
}

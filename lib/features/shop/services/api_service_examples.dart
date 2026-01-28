/// Integration Examples for Backend APIs
/// This file demonstrates how to use the new API services in your app

import 'package:unified_dream247/features/shop/services/api_service.dart';
import 'package:unified_dream247/features/shop/services/order_api_service.dart';
import 'package:unified_dream247/features/shop/services/address_api_service.dart';
import 'package:unified_dream247/features/shop/services/tracking_api_service.dart';

/// Example 1: Create an address via backend API
Future<void> exampleCreateAddress() async {
  try {
    final response = await AddressApiService.createAddress(
      userId: 'user123',
      fullName: 'John Doe',
      phoneNumber: '+91 9876543210',
      addressLine1: '123 Main Street',
      addressLine2: 'Apartment 4B',
      city: 'Mumbai',
      state: 'Maharashtra',
      pincode: '400001',
      country: 'India',
      isDefault: true,
    );

    if (ApiService.isSuccess(response)) {
      print('✅ Address created successfully');
      print('Address ID: ${response['data']['id']}');
    } else {
      print('❌ Error: ${ApiService.getErrorMessage(response)}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}

/// Example 2: Get all addresses for a user
Future<void> exampleGetAddresses() async {
  try {
    final response = await AddressApiService.getAddresses('user123');

    if (ApiService.isSuccess(response)) {
      print('✅ Addresses retrieved');
      final addresses = response['data'] as List;
      print('Found ${addresses.length} addresses');
      
      for (var addr in addresses) {
        print('Address: ${addr['fullName']} - ${addr['city']}');
      }
    } else {
      print('❌ Error: ${ApiService.getErrorMessage(response)}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}

/// Example 3: Set default address
Future<void> exampleSetDefaultAddress() async {
  try {
    final response = await AddressApiService.setDefaultAddress(
      'address456',
      userId: 'user123',
    );

    if (ApiService.isSuccess(response)) {
      print('✅ Default address set');
    } else {
      print('❌ Error: ${ApiService.getErrorMessage(response)}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}

/// Example 4: Delete address
Future<void> exampleDeleteAddress() async {
  try {
    final response = await AddressApiService.deleteAddress('address456');

    if (ApiService.isSuccess(response)) {
      print('✅ Address deleted');
    } else {
      print('❌ Error: ${ApiService.getErrorMessage(response)}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}

/// Example 5: Create an order
Future<void> exampleCreateOrder() async {
  try {
    final orderItems = [
      {
        'productId': 'prod123',
        'productName': 'T-Shirt',
        'quantity': 2,
        'price': 500,
      },
    ];

    final response = await OrderApiService.createOrder(
      userId: 'user123',
      items: orderItems,
      totalAmount: 1000,
      addressId: 'address456',
      paymentId: 'pay789',
    );

    if (ApiService.isSuccess(response)) {
      print('✅ Order created');
      print('Order ID: ${response['data']['id']}');
      print('Order Number: ${response['data']['orderNumber']}');
    } else {
      print('❌ Error: ${ApiService.getErrorMessage(response)}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}

/// Example 6: Get orders with pagination
Future<void> exampleGetOrders() async {
  try {
    final response = await OrderApiService.getOrders(
      'user123',
      skip: 0,
      limit: 10,
    );

    if (ApiService.isSuccess(response)) {
      print('✅ Orders retrieved');
      final orders = response['data'] as List;
      print('Found ${orders.length} orders');
      
      for (var order in orders) {
        print('Order: ${order['orderNumber']} - ${order['status']}');
      }
    } else {
      print('❌ Error: ${ApiService.getErrorMessage(response)}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}

/// Example 7: Get order details
Future<void> exampleGetOrderDetails() async {
  try {
    final response = await OrderApiService.getOrder('order123');

    if (ApiService.isSuccess(response)) {
      print('✅ Order details retrieved');
      final order = response['data'];
      print('Order: ${order['orderNumber']}');
      print('Status: ${order['status']}');
      print('Total: ${order['totalAmount']}');
    } else {
      print('❌ Error: ${ApiService.getErrorMessage(response)}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}

/// Example 8: Update order status
Future<void> exampleUpdateOrderStatus() async {
  try {
    final response = await OrderApiService.updateOrderStatus(
      'order123',
      'SHIPPED',
    );

    if (ApiService.isSuccess(response)) {
      print('✅ Order status updated');
    } else {
      print('❌ Error: ${ApiService.getErrorMessage(response)}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}

/// Example 9: Create shipment with Shiprocket
Future<void> exampleCreateShipment() async {
  try {
    final response = await OrderApiService.createShipment(
      'order123',
      email: 'user@example.com',
      weight: 500,
      length: 20,
      breadth: 15,
      height: 10,
      orderItems: [
        {
          'name': 'T-Shirt',
          'sku': 'SKU123',
          'quantity': 2,
          'price': 500,
        },
      ],
    );

    if (ApiService.isSuccess(response)) {
      print('✅ Shipment created');
      print('Tracking Number: ${response['data']['trackingNumber']}');
      print('Courier: ${response['data']['courierName']}');
    } else {
      print('❌ Error: ${ApiService.getErrorMessage(response)}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}

/// Example 10: Cancel order
Future<void> exampleCancelOrder() async {
  try {
    final response = await OrderApiService.cancelOrder('order123');

    if (ApiService.isSuccess(response)) {
      print('✅ Order cancelled');
    } else {
      print('❌ Error: ${ApiService.getErrorMessage(response)}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}

/// Example 11: Get tracking data
Future<void> exampleGetTracking() async {
  try {
    final response = await TrackingApiService.getTracking('order123');

    if (ApiService.isSuccess(response)) {
      print('✅ Tracking data retrieved');
      final tracking = response['data'];
      print('Status: ${tracking['currentStatus']}');
      print('Location: ${tracking['currentLocation']}');
      print('Tracking #: ${tracking['trackingNumber']}');
      
      // Parse timeline
      if (tracking['timeline'] is List) {
        print('Timeline events: ${(tracking['timeline'] as List).length}');
      }
    } else {
      print('❌ Error: ${ApiService.getErrorMessage(response)}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}

/// Example 12: Get tracking events
Future<void> exampleGetTrackingEvents() async {
  try {
    final response = await TrackingApiService.getTrackingEvents('order123');

    if (ApiService.isSuccess(response)) {
      print('✅ Tracking events retrieved');
      final events = response['data'] as List;
      
      for (var event in events) {
        print('Event: ${event['status']} - ${event['timestamp']}');
        if (event['location'] != null) {
          print('  Location: ${event['location']}');
        }
      }
    } else {
      print('❌ Error: ${ApiService.getErrorMessage(response)}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}

/// Example 13: Get latest tracking status
Future<void> exampleGetLatestStatus() async {
  try {
    final response = await TrackingApiService.getLatestStatus('order123');

    if (ApiService.isSuccess(response)) {
      print('✅ Latest status retrieved');
      final latest = response['data'];
      print('Latest: ${latest['status']} at ${latest['timestamp']}');
    } else {
      print('❌ Error: ${ApiService.getErrorMessage(response)}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}

/// Example 14: Add tracking event (testing only)
Future<void> exampleAddTrackingEvent() async {
  try {
    final response = await TrackingApiService.addTrackingEvent(
      'order123',
      status: 'In Transit',
      location: 'Mumbai Distribution Center',
      remarks: 'Package picked up from warehouse',
    );

    if (ApiService.isSuccess(response)) {
      print('✅ Tracking event added');
    } else {
      print('❌ Error: ${ApiService.getErrorMessage(response)}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}

/// Main demonstration function
/// Call this from your app to test all APIs
Future<void> runAllExamples() async {
  print('========== ADDRESS API EXAMPLES ==========');
  await exampleCreateAddress();
  print('---');
  await exampleGetAddresses();
  print('---');
  await exampleSetDefaultAddress();
  print('---');
  await exampleDeleteAddress();

  print('\n========== ORDER API EXAMPLES ==========');
  await exampleCreateOrder();
  print('---');
  await exampleGetOrders();
  print('---');
  await exampleGetOrderDetails();
  print('---');
  await exampleUpdateOrderStatus();
  print('---');
  await exampleCreateShipment();
  print('---');
  await exampleCancelOrder();

  print('\n========== TRACKING API EXAMPLES ==========');
  await exampleGetTracking();
  print('---');
  await exampleGetTrackingEvents();
  print('---');
  await exampleGetLatestStatus();
  print('---');
  await exampleAddTrackingEvent();

  print('\n========== EXAMPLES COMPLETE ==========');
}

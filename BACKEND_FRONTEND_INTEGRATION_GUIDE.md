# 🎯 BACKEND & FRONTEND INTEGRATION GUIDE

## 📋 Quick Summary

You now have **3 complete API service wrappers** that handle all 26 backend APIs:

1. **ApiService** - Base HTTP service (GET, POST, PUT, DELETE)
2. **AddressApiService** - 7 address management APIs
3. **OrderApiService** - 7 order management APIs  
4. **TrackingApiService** - 4 tracking APIs

---

## 🚀 GETTING STARTED

### Step 1: Configure Environment

Update your `.env` file:

```env
API_BASE_URL=http://localhost:3000
```

Or set it in `ApiService`:

```dart
// lib/features/shop/services/api_service.dart
static const String defaultBaseUrl = 'http://localhost:3000';
```

### Step 2: Import Services

In your screens or widgets, import the services you need:

```dart
import 'package:unified_dream247/features/shop/services/address_api_service.dart';
import 'package:unified_dream247/features/shop/services/order_api_service.dart';
import 'package:unified_dream247/features/shop/services/tracking_api_service.dart';
import 'package:unified_dream247/features/shop/services/api_service.dart';
```

---

## 📚 API SERVICES REFERENCE

### AddressApiService (7 APIs)

All methods return `Future<Map<String, dynamic>>` with structure:
```dart
{
  'success': bool,
  'statusCode': int,
  'data': Map or List,
  'message': String,
}
```

#### Create Address
```dart
final response = await AddressApiService.createAddress(
  userId: 'user123',
  fullName: 'John Doe',
  phoneNumber: '+91 9876543210',
  addressLine1: '123 Main St',
  addressLine2: 'Apt 4B', // optional
  city: 'Mumbai',
  state: 'Maharashtra',
  pincode: '400001',
  country: 'India',
  isDefault: false, // optional
);

if (response['success']) {
  print('Address ID: ${response['data']['id']}');
}
```

#### Get All Addresses
```dart
final response = await AddressApiService.getAddresses('user123');
if (response['success']) {
  List<Map> addresses = response['data'];
  for (var addr in addresses) {
    print(addr['fullName']);
  }
}
```

#### Get Single Address
```dart
final response = await AddressApiService.getAddress('addressId');
if (response['success']) {
  var address = response['data'];
}
```

#### Update Address
```dart
final response = await AddressApiService.updateAddress(
  'addressId',
  fullName: 'Jane Doe', // optional
  phoneNumber: '+91 8765432109', // optional
  city: 'Bangalore', // optional
  state: 'Karnataka', // optional
);
```

#### Delete Address
```dart
final response = await AddressApiService.deleteAddress('addressId');
if (response['success']) {
  print('Address deleted');
}
```

#### Set Default Address
```dart
final response = await AddressApiService.setDefaultAddress(
  'addressId',
  userId: 'user123',
);
```

#### Get Default Address
```dart
final response = await AddressApiService.getDefaultAddress('user123');
if (response['success']) {
  var defaultAddr = response['data'];
}
```

---

### OrderApiService (7 APIs)

#### Create Order
```dart
final response = await OrderApiService.createOrder(
  userId: 'user123',
  items: [
    {
      'productId': 'prod1',
      'productName': 'T-Shirt',
      'quantity': 2,
      'price': 500,
    },
  ],
  totalAmount: 1000,
  addressId: 'addr123', // optional
  paymentId: 'pay123', // optional
);

if (response['success']) {
  print('Order ID: ${response['data']['id']}');
  print('Order Number: ${response['data']['orderNumber']}');
}
```

#### Get Orders (with pagination)
```dart
final response = await OrderApiService.getOrders(
  'user123',
  skip: 0,
  limit: 10,
);

if (response['success']) {
  List<Map> orders = response['data'];
}
```

#### Get Order Details
```dart
final response = await OrderApiService.getOrder('orderId');
if (response['success']) {
  var order = response['data'];
  print('Status: ${order['status']}');
  print('Total: ${order['totalAmount']}');
}
```

#### Update Order Status
```dart
final response = await OrderApiService.updateOrderStatus(
  'orderId',
  'SHIPPED', // PENDING, PROCESSING, SHIPPED, DELIVERED, CANCELLED
);
```

#### Cancel Order
```dart
final response = await OrderApiService.cancelOrder('orderId');
if (response['success']) {
  print('Order cancelled');
}
```

#### Create Shipment
```dart
final response = await OrderApiService.createShipment(
  'orderId',
  email: 'user@example.com',
  weight: 500,
  length: 20,
  breadth: 15,
  height: 10,
  orderItems: [ // optional
    {
      'name': 'T-Shirt',
      'sku': 'SKU123',
      'quantity': 2,
      'price': 500,
    },
  ],
);

if (response['success']) {
  print('Tracking #: ${response['data']['trackingNumber']}');
  print('Courier: ${response['data']['courierName']}');
}
```

#### Get Order Status
```dart
final response = await OrderApiService.getOrderStatus('orderId');
if (response['success']) {
  print('Status: ${response['data']['status']}');
}
```

---

### TrackingApiService (4 APIs)

#### Get Complete Tracking Data
```dart
final response = await TrackingApiService.getTracking('orderId');
if (response['success']) {
  var tracking = TrackingData.fromJson(response['data']);
  print('Status: ${tracking.currentStatus}');
  print('Location: ${tracking.currentLocation}');
  print('Tracking #: ${tracking.trackingNumber}');
  
  // Timeline events
  for (var event in tracking.timeline) {
    print('${event.status} - ${event.timestamp}');
  }
}
```

#### Get Tracking Events
```dart
final response = await TrackingApiService.getTrackingEvents('orderId');
if (response['success']) {
  List<Map> events = response['data'];
  for (var event in events) {
    print('${event['status']} at ${event['timestamp']}');
    if (event['location'] != null) {
      print('Location: ${event['location']}');
    }
  }
}
```

#### Get Latest Status
```dart
final response = await TrackingApiService.getLatestStatus('orderId');
if (response['success']) {
  print('Latest: ${response['data']['status']}');
  print('Time: ${response['data']['timestamp']}');
}
```

#### Add Tracking Event (Testing)
```dart
final response = await TrackingApiService.addTrackingEvent(
  'orderId',
  status: 'In Transit',
  location: 'Mumbai DC', // optional
  remarks: 'Package picked up', // optional
);
```

---

## 🎨 EXAMPLE: Complete Order Flow

### 1. Create Address Screen Integration

```dart
class AddAddressScreen extends StatefulWidget {
  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  String userId = 'user123'; // Get from auth
  bool _isLoading = false;

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await AddressApiService.createAddress(
        userId: userId,
        fullName: 'John Doe',
        phoneNumber: '+91 9876543210',
        addressLine1: '123 Main St',
        city: 'Mumbai',
        state: 'Maharashtra',
        pincode: '400001',
        country: 'India',
        isDefault: false,
      );

      if (mounted) {
        if (ApiService.isSuccess(response)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address saved successfully')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ApiService.getErrorMessage(response))),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Address')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Form fields here
              ElevatedButton(
                onPressed: _isLoading ? null : _saveAddress,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : const Text('Save Address'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 2. Checkout with Order Creation

```dart
Future<void> createOrder() async {
  try {
    // 1. Get user's default address
    final addrResponse = await AddressApiService.getDefaultAddress(userId);
    if (!ApiService.isSuccess(addrResponse)) {
      throw 'Please add an address first';
    }
    final addressId = addrResponse['data']['id'];

    // 2. Create order
    final orderResponse = await OrderApiService.createOrder(
      userId: userId,
      items: cartItems,
      totalAmount: cartTotal,
      addressId: addressId,
      paymentId: paymentId,
    );

    if (!ApiService.isSuccess(orderResponse)) {
      throw ApiService.getErrorMessage(orderResponse);
    }

    final orderId = orderResponse['data']['id'];

    // 3. Create shipment
    final shipmentResponse = await OrderApiService.createShipment(
      orderId,
      email: userEmail,
      weight: 500,
      length: 20,
      breadth: 15,
      height: 10,
    );

    if (ApiService.isSuccess(shipmentResponse)) {
      // Navigate to tracking
      Navigator.pushNamed(
        context,
        '/order-tracking-api',
        arguments: {'orderId': orderId},
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

### 3. Real-time Tracking with Polling

```dart
class TrackingPolling extends StatefulWidget {
  final String orderId;

  @override
  State<TrackingPolling> createState() => _TrackingPollingState();
}

class _TrackingPollingState extends State<TrackingPolling> {
  late Timer _timer;
  TrackingData? _tracking;

  @override
  void initState() {
    super.initState();
    _fetchTracking();
    
    // Poll every 10 seconds
    _timer = Timer.periodic(Duration(seconds: 10), (_) {
      _fetchTracking();
    });
  }

  Future<void> _fetchTracking() async {
    final response = await TrackingApiService.getTracking(widget.orderId);
    if (mounted && ApiService.isSuccess(response)) {
      setState(() {
        _tracking = TrackingData.fromJson(response['data']);
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_tracking == null) return const CircularProgressIndicator();
    
    return Column(
      children: [
        Text('Status: ${_tracking!.currentStatus}'),
        Text('Location: ${_tracking!.currentLocation}'),
        // TrackingTimeline widget
      ],
    );
  }
}
```

---

## ✅ RESPONSE FORMAT

All API methods return the same structure:

```dart
Map<String, dynamic> {
  'success': bool,           // true if status 200-299
  'statusCode': int,         // HTTP status code
  'message': String,         // Success or error message
  'data': dynamic,          // Response data (Map or List)
}
```

**Check Success:**
```dart
if (response['success'] == true || response['statusCode'] == 200) {
  // Success
  var data = response['data'];
} else {
  // Error
  String error = response['message'];
}
```

**Or use helpers:**
```dart
if (ApiService.isSuccess(response)) {
  // Success
} else {
  print(ApiService.getErrorMessage(response));
}
```

---

## 🐛 DEBUGGING

### Enable Logging
All API calls log to console. Check `[ApiService]` prefix:

```
[ApiService] GET: http://localhost:3000/api/addresses?userId=user123
[ApiService] Status Code: 200
[ApiService] Response: {"success":true,"data":[...]}
```

### Test with Examples
Run provided examples:

```dart
import 'package:unified_dream247/features/shop/services/api_service_examples.dart';

// In your code:
runAllExamples(); // Tests all 26 APIs
```

---

## 📁 FILES CREATED

✅ `lib/features/shop/services/api_service.dart` - Base HTTP service  
✅ `lib/features/shop/services/address_api_service.dart` - 7 address APIs  
✅ `lib/features/shop/services/order_api_service.dart` - 7 order APIs  
✅ `lib/features/shop/services/tracking_api_service.dart` - 4 tracking APIs + models  
✅ `lib/features/shop/services/api_service_examples.dart` - 14 working examples  
✅ `lib/features/shop/order/views/order_tracking_screen_api.dart` - Real-time tracking UI  

---

## 🔄 INTEGRATION CHECKLIST

### Phase 1: Setup
- [ ] Configure `.env` with correct API_BASE_URL
- [ ] Backend running at `http://localhost:3000`
- [ ] Test API endpoints with Postman first

### Phase 2: Address Management
- [ ] Import AddressApiService
- [ ] Update AddressScreen to use APIs
- [ ] Test create, read, update, delete
- [ ] Test set/get default address

### Phase 3: Order Management  
- [ ] Import OrderApiService
- [ ] Implement order creation in checkout
- [ ] Add shipment creation after order
- [ ] Show order list with pagination
- [ ] Implement order status updates

### Phase 4: Real-time Tracking
- [ ] Import TrackingApiService
- [ ] Use OrderTrackingScreenApi (new)
- [ ] Implement polling (10s interval)
- [ ] Display TrackingTimeline component
- [ ] Test with real Shiprocket webhooks

### Phase 5: Testing & Polish
- [ ] End-to-end flow (address → order → shipment → tracking)
- [ ] Error handling & user feedback
- [ ] Loading states & animations
- [ ] Performance optimization
- [ ] UI polish & responsiveness

---

## 🚨 COMMON ISSUES

### "Network error"
- Check backend is running: `npm start`
- Verify API_BASE_URL in ApiService
- Check localhost:3000 in browser

### "Failed to parse response"  
- Backend might be returning HTML error page
- Check backend logs for errors
- Verify request format matches API spec

### "CORS error" (Web only)
- Need backend proxy for Shiprocket (see CONFIG)
- Or test on mobile device
- Browser blocks direct Shiprocket API calls

### Tracking data not updating
- Check polling interval (currently 10s)
- Verify orderId is correct
- Check if Shiprocket webhook is configured
- Look at backend logs

---

## 📞 NEXT STEPS

1. **Test APIs with Postman** - Before Flutter integration
2. **Start with Address API** - Simplest to implement
3. **Move to Orders** - More complex but builds on address
4. **Implement Tracking** - Use provided OrderTrackingScreenApi
5. **Polish UI** - Make it look great

---

**You're all set!** 🎉 Start with the examples and integrate one service at a time.


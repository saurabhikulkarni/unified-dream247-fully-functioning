# ⚡ QUICK API REFERENCE - COPY & PASTE READY

## 🔗 Import These Services

```dart
import 'package:unified_dream247/features/shop/services/api_service.dart';
import 'package:unified_dream247/features/shop/services/address_api_service.dart';
import 'package:unified_dream247/features/shop/services/order_api_service.dart';
import 'package:unified_dream247/features/shop/services/tracking_api_service.dart';
```

---

## 📍 ADDRESS MANAGEMENT (7 APIs)

### Create Address
```dart
final res = await AddressApiService.createAddress(
  userId: 'user123',
  fullName: 'John Doe',
  phoneNumber: '+91 9876543210',
  addressLine1: '123 Street',
  city: 'Mumbai',
  state: 'Maharashtra',
  pincode: '400001',
  country: 'India',
);
if (ApiService.isSuccess(res)) print('✅ Created: ${res['data']['id']}');
```

### Get All Addresses
```dart
final res = await AddressApiService.getAddresses('user123');
if (ApiService.isSuccess(res)) {
  List addresses = res['data'];
  print('✅ Found ${addresses.length} addresses');
}
```

### Get One Address
```dart
final res = await AddressApiService.getAddress('addressId');
if (ApiService.isSuccess(res)) print('✅ ${res['data']['fullName']}');
```

### Update Address
```dart
final res = await AddressApiService.updateAddress(
  'addressId',
  fullName: 'Jane Doe',
  city: 'Bangalore',
);
if (ApiService.isSuccess(res)) print('✅ Updated');
```

### Delete Address
```dart
final res = await AddressApiService.deleteAddress('addressId');
if (ApiService.isSuccess(res)) print('✅ Deleted');
```

### Set Default Address
```dart
final res = await AddressApiService.setDefaultAddress('addressId', userId: 'user123');
if (ApiService.isSuccess(res)) print('✅ Set as default');
```

### Get Default Address
```dart
final res = await AddressApiService.getDefaultAddress('user123');
if (ApiService.isSuccess(res)) print('✅ Default: ${res['data']['fullName']}');
```

---

## 📦 ORDER MANAGEMENT (7 APIs)

### Create Order
```dart
final res = await OrderApiService.createOrder(
  userId: 'user123',
  items: [{'productId': 'p1', 'quantity': 2, 'price': 500}],
  totalAmount: 1000,
  addressId: 'addr123',
);
if (ApiService.isSuccess(res)) print('✅ Order: ${res['data']['orderNumber']}');
```

### Get All Orders
```dart
final res = await OrderApiService.getOrders('user123', skip: 0, limit: 10);
if (ApiService.isSuccess(res)) {
  List orders = res['data'];
  print('✅ ${orders.length} orders');
}
```

### Get Order Details
```dart
final res = await OrderApiService.getOrder('orderId');
if (ApiService.isSuccess(res)) {
  print('✅ Status: ${res['data']['status']}');
  print('   Total: ${res['data']['totalAmount']}');
}
```

### Update Order Status
```dart
final res = await OrderApiService.updateOrderStatus('orderId', 'SHIPPED');
if (ApiService.isSuccess(res)) print('✅ Status updated');
```

### Cancel Order
```dart
final res = await OrderApiService.cancelOrder('orderId');
if (ApiService.isSuccess(res)) print('✅ Order cancelled');
```

### Create Shipment
```dart
final res = await OrderApiService.createShipment(
  'orderId',
  email: 'user@example.com',
  weight: 500,
  length: 20,
  breadth: 15,
  height: 10,
);
if (ApiService.isSuccess(res)) print('✅ Track: ${res['data']['trackingNumber']}');
```

### Get Order Status
```dart
final res = await OrderApiService.getOrderStatus('orderId');
if (ApiService.isSuccess(res)) print('✅ ${res['data']['status']}');
```

---

## 🚚 TRACKING (4 APIs)

### Get Full Tracking
```dart
final res = await TrackingApiService.getTracking('orderId');
if (ApiService.isSuccess(res)) {
  final tracking = TrackingData.fromJson(res['data']);
  print('✅ Status: ${tracking.currentStatus}');
  print('   Location: ${tracking.currentLocation}');
  print('   Events: ${tracking.timeline.length}');
}
```

### Get All Events
```dart
final res = await TrackingApiService.getTrackingEvents('orderId');
if (ApiService.isSuccess(res)) {
  List events = res['data'];
  for (var e in events) {
    print('${e['status']} - ${e['timestamp']}');
  }
}
```

### Get Latest Status
```dart
final res = await TrackingApiService.getLatestStatus('orderId');
if (ApiService.isSuccess(res)) {
  print('✅ Latest: ${res['data']['status']} at ${res['data']['timestamp']}');
}
```

### Add Event (Testing)
```dart
final res = await TrackingApiService.addTrackingEvent(
  'orderId',
  status: 'In Transit',
  location: 'Mumbai DC',
);
if (ApiService.isSuccess(res)) print('✅ Event added');
```

---

## ✅ COMMON PATTERNS

### Error Handling
```dart
final res = await AddressApiService.createAddress(...);

// Check success
if (ApiService.isSuccess(res)) {
  // Success: res['data'] contains the response
  var data = res['data'];
} else {
  // Error: res['message'] contains error message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(ApiService.getErrorMessage(res))),
  );
}
```

### Loading State
```dart
bool _isLoading = false;

Future<void> _loadData() async {
  setState(() => _isLoading = true);
  try {
    final res = await OrderApiService.getOrders(userId);
    if (ApiService.isSuccess(res)) {
      setState(() => orders = res['data']);
    }
  } finally {
    setState(() => _isLoading = false);
  }
}

// In build:
if (_isLoading) return const CircularProgressIndicator();
```

### Polling (Real-time)
```dart
late Timer _timer;

@override
void initState() {
  super.initState();
  _timer = Timer.periodic(Duration(seconds: 10), (_) {
    _fetchTracking();
  });
}

@override
void dispose() {
  _timer.cancel();
  super.dispose();
}

Future<void> _fetchTracking() async {
  final res = await TrackingApiService.getTracking(orderId);
  if (ApiService.isSuccess(res)) {
    setState(() => tracking = TrackingData.fromJson(res['data']));
  }
}
```

### Pagination
```dart
Future<void> _loadMore() async {
  final res = await OrderApiService.getOrders(
    userId,
    skip: currentOrders.length,
    limit: 10,
  );
  if (ApiService.isSuccess(res)) {
    setState(() => currentOrders.addAll(res['data']));
  }
}
```

---

## 📊 RESPONSE STRUCTURE

Every API returns:
```dart
{
  'success': bool,         // true for 200-299 status
  'statusCode': int,       // HTTP status
  'message': String,       // Status message
  'data': dynamic,        // Response body
}
```

**Success example:**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Success",
  "data": {"id": "123", "name": "Address"}
}
```

**Error example:**
```json
{
  "success": false,
  "statusCode": 400,
  "message": "Invalid address",
  "data": null
}
```

---

## 🎯 HELPER METHODS

```dart
// Check if successful
if (ApiService.isSuccess(response)) { }

// Get error message
String error = ApiService.getErrorMessage(response);

// Check status code
if (response['statusCode'] == 200) { }

// Get data
var data = response['data'];
```

---

## 🧪 TEST ALL APIS AT ONCE

```dart
import 'package:unified_dream247/features/shop/services/api_service_examples.dart';

// In your code:
await runAllExamples();
```

This tests all 26 APIs with example data and prints results.

---

## 🚨 TROUBLESHOOTING

| Problem | Solution |
|---------|----------|
| "Network error" | Check backend running on localhost:3000 |
| "Failed to parse" | Backend might be returning HTML error page |
| No tracking data | Check orderId is correct, wait for webhook |
| CORS error (web) | Test on mobile device or use backend proxy |
| API takes too long | Check network, increase timeout if needed |

---

## 💡 PRO TIPS

1. **Always check `success` flag** before accessing `data`
2. **Use provided `TrackingData` model** for parsing tracking
3. **Implement polling with 10+ second intervals** to avoid server overload
4. **Show loading spinners** while API calls are in progress
5. **Add error messages** to UI for debugging
6. **Test with Postman first** before Flutter integration
7. **Use flutter_dotenv** to manage API_BASE_URL

---

Ready to implement? Copy-paste any code above! 🚀


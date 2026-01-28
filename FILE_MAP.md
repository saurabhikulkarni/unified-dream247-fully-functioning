# 📁 PROJECT STRUCTURE & FILE MAP

## Directory Layout After Integration

```
unified-dream247-fully-functioning/
├── lib/
│   └── features/
│       └── shop/
│           ├── services/
│           │   ├── api_service.dart ✨ NEW
│           │   ├── address_api_service.dart ✨ NEW
│           │   ├── order_api_service.dart ✨ NEW
│           │   ├── tracking_api_service.dart ✨ NEW
│           │   ├── api_service_examples.dart ✨ NEW
│           │   ├── address_service.dart (EXISTING - for GraphQL)
│           │   ├── order_service.dart (EXISTING - local logic)
│           │   ├── shiprocket_service.dart (EXISTING - keep)
│           │   └── ... other services
│           │
│           ├── order/
│           │   ├── views/
│           │   │   ├── order_tracking_screen.dart (EXISTING)
│           │   │   └── order_tracking_screen_api.dart ✨ NEW
│           │   │
│           │   └── components/
│           │       └── tracking_timeline.dart (EXISTING - already using)
│           │
│           ├── screens/
│           │   ├── addresses/ (update to use AddressApiService)
│           │   ├── orders/ (update to use OrderApiService)
│           │   └── checkout/ (update to use OrderApiService)
│           │
│           └── ... other folders
│
├── BACKEND_FRONTEND_INTEGRATION_GUIDE.md ✨ NEW
├── API_QUICK_REFERENCE.md ✨ NEW
├── IMPLEMENTATION_COMPLETE.md ✨ NEW
└── ... existing docs
```

---

## 🔗 How Everything Connects

### API Layer Flow

```
┌─────────────────────────────────────────────────┐
│           UI Screens & Widgets                  │
│  (addresses/, orders/, checkout/, etc.)         │
└──────────────────┬──────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────┐
│      API Service Wrappers (New)                 │
│                                                 │
│  ├─ AddressApiService (7 endpoints)             │
│  ├─ OrderApiService (7 endpoints)               │
│  ├─ TrackingApiService (4 endpoints)            │
│  └─ ApiService (HTTP base client)               │
└──────────────────┬──────────────────────────────┘
                   │
                   ↓
        ┌──────────────────────┐
        │   HTTP Client        │
        │  (http package)      │
        └──────────┬───────────┘
                   │
                   ↓
     ┌─────────────────────────────┐
     │  Backend REST API           │
     │                             │
     │  localhost:3000             │
     │  ├─ /api/addresses (7)      │
     │  ├─ /api/orders (7)         │
     │  └─ /api/tracking (4)       │
     └─────────────────────────────┘
                   │
                   ↓
        ┌──────────────────────┐
        │  Shiprocket API      │
        │  (via backend)       │
        └──────────────────────┘
```

---

## 📊 Service Usage Map

### For Address Management

```
┌─────────────────────────────────────────────┐
│  Address Screens (addresses_screen.dart)    │
│  Add Address Screen (add_address_screen.dart)
└────────────────┬────────────────────────────┘
                 │
                 ↓
        AddressApiService
                 │
         ┌───────┴────────────────┬─────────────────┬──────────────────┐
         ↓                        ↓                 ↓                  ↓
    POST /api/addresses  GET /api/addresses  PUT /api/addresses  DELETE ...
    (create)            (list)               (update)            (delete)
```

### For Order Management

```
┌──────────────────────────────────────────────┐
│  Checkout Screen (checkout_screen.dart)      │
│  Orders List Screen (orders_screen.dart)     │
│  Order Details Screen (order_details_screen) │
└────────────────┬─────────────────────────────┘
                 │
                 ↓
        OrderApiService
                 │
    ┌────────────┼────────────┬──────────────┬────────────┐
    ↓            ↓            ↓              ↓            ↓
 POST /api/  GET /api/   PUT /api/    POST /api/orders/  DELETE
 orders     orders      orders/{id}   {id}/create-ship   /api/orders/{id}
 (create)   (list)      (update)      (shipment)         (cancel)
```

### For Tracking

```
┌─────────────────────────────────────────────────┐
│  Order Tracking Screen Api                      │
│  (order_tracking_screen_api.dart)               │
│                                                 │
│  Features:                                      │
│  • Real-time polling (10s interval)             │
│  • Status display with colors                   │
│  • Shipping details                             │
│  • Timeline component integration               │
└────────────────┬────────────────────────────────┘
                 │
                 ↓
        TrackingApiService
                 │
    ┌────────────┼────────────┬──────────────────┐
    ↓            ↓            ↓                  ↓
 GET /api/  GET /api/   GET /api/          POST /api/
 tracking   tracking/   tracking/           tracking/
 {orderId}  {orderId}/  {orderId}/          {orderId}/
            events      latest              events
```

---

## 🔄 Data Flow Examples

### Address Creation Flow

```
User fills form in AddAddressScreen
        ↓
Validates input (form validation)
        ↓
Calls AddressApiService.createAddress()
        ↓
AddressApiService builds request body
        ↓
Calls ApiService.post('/api/addresses', body: {...})
        ↓
ApiService sends HTTP POST to localhost:3000/api/addresses
        ↓
Backend receives request → validates → saves to database → Shiprocket sync
        ↓
Backend returns JSON response
        ↓
ApiService parses response → returns Map with success, data, message
        ↓
AddAddressScreen receives response
        ↓
If success: Show snackbar "Address saved" → Navigate back
If error: Show snackbar with error message → Stay on screen
```

### Order Creation & Shipment Flow

```
User clicks "Checkout"
        ↓
Get selected/default address from AddressApiService
        ↓
Prepare cart items
        ↓
Call OrderApiService.createOrder(userId, items, totalAmount, addressId)
        ↓
Backend creates order in database
        ↓
Response includes orderId
        ↓
Call OrderApiService.createShipment(orderId, weight, dimensions, email)
        ↓
Backend calls Shiprocket API to create shipment
        ↓
Shiprocket returns tracking number, courier info, shipment id
        ↓
Backend stores in order database
        ↓
Response includes trackingNumber, courierName, estimatedDeliveryDate
        ↓
Navigate to OrderTrackingScreenApi with orderId
        ↓
Screen starts polling TrackingApiService every 10 seconds
        ↓
Real-time tracking updates display as Shiprocket webhook sends events
```

### Real-time Tracking Flow

```
User navigates to OrderTrackingScreenApi
        ↓
Screen calls _fetchTracking() in initState()
        ↓
Calls TrackingApiService.getTracking(orderId)
        ↓
Backend queries Shiprocket for order tracking
        ↓
Backend returns current status, location, timeline, events
        ↓
Screen parses response into TrackingData object
        ↓
Displays current status card + timeline
        ↓
Every 10 seconds, timer calls _fetchTracking() again
        ↓
New data arrives → setState updates UI
        ↓
User sees live updates as delivery progresses
        ↓
When user navigates away or order delivered, dispose() stops timer
```

---

## 📚 Documentation Map

| Document | Purpose | Who Should Read |
|----------|---------|-----------------|
| [IMPLEMENTATION_COMPLETE.md](./IMPLEMENTATION_COMPLETE.md) | Overview of complete integration | Everyone - START HERE |
| [BACKEND_FRONTEND_INTEGRATION_GUIDE.md](./BACKEND_FRONTEND_INTEGRATION_GUIDE.md) | Detailed integration guide | Frontend developers |
| [API_QUICK_REFERENCE.md](./API_QUICK_REFERENCE.md) | Copy-paste code snippets | Developers implementing screens |
| API service files (*.dart) | Actual implementation | Developers writing code |

---

## 🎯 Implementation Order

### Week 1: Setup & Address APIs
```
Day 1: Setup
  ├─ Configure .env or ApiService baseUrl
  ├─ Ensure backend running on localhost:3000
  └─ Test with Postman

Days 2-3: Address Management
  ├─ Import AddressApiService
  ├─ Update addresses_screen.dart
  ├─ Update add_address_screen.dart
  ├─ Test all 7 address APIs
  └─ Implement error handling
```

### Week 2: Order Management
```
Days 1-2: Order Creation
  ├─ Import OrderApiService
  ├─ Update checkout_screen.dart
  ├─ Implement createOrder + createShipment flow
  └─ Test order creation end-to-end

Days 3-4: Order Management
  ├─ Update orders_screen.dart to list orders
  ├─ Update order_details_screen.dart
  ├─ Implement pagination
  ├─ Add order cancellation
  └─ Test all order operations
```

### Week 3: Tracking & Polish
```
Days 1-2: Real-time Tracking
  ├─ Use provided OrderTrackingScreenApi OR
  ├─ Integrate TrackingApiService manually
  ├─ Implement polling logic
  ├─ Test with real Shiprocket data
  └─ Adjust polling interval if needed

Days 3-4: Final Testing & Polish
  ├─ End-to-end testing (address → order → shipment → tracking)
  ├─ Error message refinement
  ├─ Loading state improvements
  ├─ UI polish and responsiveness
  └─ Performance optimization
```

---

## 🔧 How to Update Existing Screens

### Pattern 1: Replace Old Service Call

**BEFORE (Old GraphQL way):**
```dart
// OLD CODE - Don't use anymore
final addresses = await addressService.getUserAddresses();
```

**AFTER (New REST API way):**
```dart
// NEW CODE
final response = await AddressApiService.getAddresses(userId);
if (ApiService.isSuccess(response)) {
  final addresses = response['data'];
  // Use addresses list
} else {
  // Handle error
  showError(ApiService.getErrorMessage(response));
}
```

### Pattern 2: Add Loading & Error States

**BEFORE:**
```dart
@override
void initState() {
  super.initState();
  _loadData();
}

Future<void> _loadData() async {
  // No error handling
  addresses = await service.getAddresses();
}
```

**AFTER:**
```dart
@override
void initState() {
  super.initState();
  _loadAddresses();
}

bool _isLoading = false;
String? _error;

Future<void> _loadAddresses() async {
  setState(() { _isLoading = true; _error = null; });
  try {
    final res = await AddressApiService.getAddresses(userId);
    if (mounted) {
      if (ApiService.isSuccess(res)) {
        setState(() { addresses = res['data']; _isLoading = false; });
      } else {
        setState(() { _error = ApiService.getErrorMessage(res); _isLoading = false; });
      }
    }
  } catch (e) {
    if (mounted) setState(() { _error = 'Error: $e'; _isLoading = false; });
  }
}

@override
Widget build(BuildContext context) {
  if (_isLoading) return CircularProgressIndicator();
  if (_error != null) return ErrorWidget(_error!, _loadAddresses);
  return AddressesList(addresses);
}
```

---

## 📱 Testing Each Component

### Test ApiService directly
```dart
// In main.dart or test file
import 'package:unified_dream247/features/shop/services/api_service_examples.dart';

void main() async {
  // Test all 26 APIs
  await runAllExamples();
  
  // Then start app
  runApp(MyApp());
}
```

### Test individual service
```dart
// Quick test
final res = await AddressApiService.getAddresses('user123');
print('Success: ${ApiService.isSuccess(res)}');
print('Data: ${res['data']}');
print('Message: ${res['message']}');
```

### Test in UI context
```dart
// In widget build method
if (_isLoading) return CircularProgressIndicator();

ElevatedButton(
  onPressed: () async {
    final res = await AddressApiService.getAddresses(userId);
    print('Response: $res');
  },
  child: Text('Test API'),
),
```

---

## ✅ Verification Checklist

### Code Structure ✓
- [ ] api_service.dart exists with all HTTP methods
- [ ] address_api_service.dart has 7 methods
- [ ] order_api_service.dart has 7 methods
- [ ] tracking_api_service.dart has 4 methods + models
- [ ] api_service_examples.dart has working examples
- [ ] order_tracking_screen_api.dart created

### Documentation ✓
- [ ] IMPLEMENTATION_COMPLETE.md created
- [ ] BACKEND_FRONTEND_INTEGRATION_GUIDE.md created
- [ ] API_QUICK_REFERENCE.md created
- [ ] This file (FILE_MAP.md) created

### Integration Ready ✓
- [ ] Backend running on localhost:3000
- [ ] All 26 API endpoints working (test with Postman)
- [ ] Services can be imported in Flutter
- [ ] Examples run without errors
- [ ] Error handling implemented
- [ ] Response parsing working

---

## 🎓 Learning Path

**If you're new to this:**

1. Start with [IMPLEMENTATION_COMPLETE.md](./IMPLEMENTATION_COMPLETE.md)
2. Read [BACKEND_FRONTEND_INTEGRATION_GUIDE.md](./BACKEND_FRONTEND_INTEGRATION_GUIDE.md) - full context
3. Look at [API_QUICK_REFERENCE.md](./API_QUICK_REFERENCE.md) - copy-paste code
4. Check api_service_examples.dart - see all examples
5. Start implementing - begin with address APIs

**If you're experienced:**

1. Check [API_QUICK_REFERENCE.md](./API_QUICK_REFERENCE.md) - quick snippets
2. Look at service files directly - understand implementation
3. Use api_service_examples.dart as reference
4. Implement screens using patterns shown

---

## 🚀 Ready to Implement?

Everything is set up! Follow this order:

1. ✅ Backend configured? → Start with address screens
2. ✅ Address working? → Move to order screens
3. ✅ Orders working? → Integrate tracking screen
4. ✅ Everything working? → Polish and test

**Good luck! 🎉**


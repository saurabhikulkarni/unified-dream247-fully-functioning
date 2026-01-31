# Shop Order Service REST API Integration

## Overview
This implementation adds REST API support for order placement while maintaining backward compatibility with the existing GraphQL service.

## Key Features

### 1. New REST API Service
- **File**: `lib/features/shop/services/order_service_rest.dart`
- **Purpose**: Handles order placement via your backend REST API
- **Endpoint**: `POST http://134.209.158.211:3000/api/orders/place`

### 2. Fallback Mechanism
The checkout process now uses a smart fallback approach:
1. **Primary**: Try REST API first (your new endpoint)
2. **Fallback**: If REST fails, automatically fall back to GraphQL
3. **User Experience**: Seamless transition without user interruption

## API Request Format

The service sends requests in the exact format you specified:

```json
{
  "items": [
    {
      "productId": "cmkgt9kn700pp07nyzfj1lm4w",
      "quantity": 1,
      "sizeId": "ssdfghsdfhsdfgh"
    }
  ],
  "addressId": "cml0xs4wi06hp07oa17rs350g",
  "notes": "my first order"
}
```

## Headers
- `Authorization: Bearer <your-jwt-token>`
- `Content-Type: application/json`

## Response Handling

The service expects responses in this format:
```json
{
  "success": true,
  "data": {
    "orderId": "generated-order-id",
    "orderNumber": "ORD123456"
  }
}
```

## Error Handling

### HTTP Status Codes:
- **200/201**: Success
- **400**: Bad request (validation errors)
- **401**: Unauthorized (token issues)
- **403**: Forbidden (permissions)
- **422**: Validation failed
- **500+**: Server errors

### Fallback Logic:
If REST API fails, the system automatically tries GraphQL with exponential backoff (up to 3 retries).

## Integration Points

### 1. Checkout Screen
**File**: `lib/features/shop/screens/checkout/views/checkout_screen.dart`

The `_placeOrder()` method now:
1. Attempts REST API call first
2. Falls back to GraphQL if REST fails
3. Maintains all existing UI/UX behavior

### 2. Service Usage
```dart
// Import the service
import 'package:unified_dream247/features/shop/services/order_service_rest.dart';

// Use in your code
final orderService = OrderServiceREST();

// Place order
final order = await orderService.placeOrder(
  items: orderItems,
  totalAmount: widget.totalAmount,
  addressId: selectedAddressId,
  notes: 'Order notes',
);
```

## Testing

### Unit Tests
Run the included tests:
```bash
flutter test test/features/shop/services/order_service_rest_test.dart
```

### Manual Testing
1. Add items to cart
2. Proceed to checkout
3. Select address
4. Confirm order
5. Check if order is created via REST API

## Debugging

The service includes comprehensive logging in debug mode:
- Request details
- Response data
- Error messages
- Fallback attempts

To enable debug logging, run in debug mode:
```bash
flutter run --debug
```

## Future Enhancements

### Pending Features:
1. **GET Orders**: Implement endpoints to fetch user orders
2. **Order Details**: Add endpoint for specific order details
3. **Order Status Updates**: Real-time status tracking
4. **Cancel Order**: API endpoint for order cancellation

### Suggested Backend Endpoints:
```http
GET /api/orders/user/:userId     # Get user orders
GET /api/orders/:orderId         # Get specific order
PUT /api/orders/:orderId/cancel  # Cancel order
PUT /api/orders/:orderId/status  # Update order status
```

## Migration Path

### Current State:
✅ REST API order placement (primary)
✅ GraphQL fallback (backup)
✅ Backward compatibility maintained

### Next Steps:
1. Implement GET endpoints on backend
2. Update service to use REST for all order operations
3. Gradually deprecate GraphQL order mutations
4. Add real-time order status updates

## Troubleshooting

### Common Issues:

1. **"User not logged in"**
   - Ensure user is authenticated
   - Check token validity

2. **"Authentication token not found"**
   - Verify SharedPreferences contain valid token
   - Check token refresh logic

3. **"Order must have at least one item"**
   - Ensure cart is not empty
   - Validate cart items before checkout

4. **Network errors**
   - Check internet connection
   - Verify backend server is running
   - Confirm API endpoint is correct

### Debug Information:
Enable debug mode to see detailed logs:
```dart
if (kDebugMode) {
  print('Debug information here');
}
```

## Configuration

The service uses your existing `ApiConfig`:
- **Base URL**: `http://134.209.158.211:3000`
- **API Path**: `/api/orders/place`
- **Environment**: Automatically detected (dev/prod)

## Security Notes

- All requests include JWT authentication
- Tokens are retrieved from SharedPreferences
- Sensitive data is properly handled
- Error messages don't expose internal details
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_dream247/features/shop/models/order_models.dart';
import 'package:unified_dream247/features/shop/services/order_service_rest.dart';

void main() {
  group('OrderServiceREST', () {
    late OrderServiceREST orderService;

    setUp(() {
      orderService = OrderServiceREST();
    });

    test('should generate valid order number', () {
      final orderNumber = orderService.generateOrderNumber();
      
      // Order number should start with ORD
      expect(orderNumber.startsWith('ORD'), true);
      
      // Order number should be reasonably long
      expect(orderNumber.length > 10, true);
      
      // Order number should be unique (test multiple generations)
      final orderNumber2 = orderService.generateOrderNumber();
      expect(orderNumber, isNot(equals(orderNumber2)));
    });

    test('should create OrderItemModel correctly', () {
      final orderItem = OrderItemModel(
        productId: 'test-product-id',
        sizeId: 'test-size-id',
        quantity: 2,
        pricePerUnit: 100.0,
      );

      expect(orderItem.productId, 'test-product-id');
      expect(orderItem.sizeId, 'test-size-id');
      expect(orderItem.quantity, 2);
      expect(orderItem.pricePerUnit, 100.0);
      expect(orderItem.totalPrice, 200.0); // 2 * 100.0
    });

    test('should clear cache correctly', () {
      // This is a simple test to ensure the method exists and doesn't throw
      expect(() => orderService.clearCache(), returnsNormally);
    });
  });
}
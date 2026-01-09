import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Mobile (Android/iOS) implementation of Razorpay
class RazorpayPlatform {
  late Razorpay _razorpay;

  void init({
    required Function(Map<String, dynamic>) onSuccess,
    required Function(String) onError,
    required Function() onDismiss,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) {
      onSuccess({
        'razorpay_payment_id': response.paymentId,
        'razorpay_order_id': response.orderId,
        'razorpay_signature': response.signature,
      });
    });
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
      onError(response.message ?? 'Payment failed. Please try again.');
    });
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse response) {
      onDismiss();
    });
  }

  void open(Map<String, dynamic> options) {
    _razorpay.open(options);
  }

  void dispose() {
    _razorpay.clear();
  }
}

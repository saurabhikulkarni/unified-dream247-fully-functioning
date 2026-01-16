import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:convert';
import 'package:unified_dream247/features/shop/config/razorpay_config.dart';
import 'package:unified_dream247/features/shop/config/razorpay_backend_config.dart';
import 'package:unified_dream247/features/shop/models/payment_model.dart';
import 'package:http/http.dart' as http;

typedef PaymentSuccessCallback = void Function(RazorpayPaymentResponse response);
typedef PaymentErrorCallback = void Function(String error);
typedef PaymentDismissCallback = void Function();

class RazorpayService {
  static final RazorpayService _instance = RazorpayService._internal();
  late Razorpay _razorpay;

  PaymentSuccessCallback? _onSuccess;
  PaymentErrorCallback? _onError;
  PaymentDismissCallback? _onDismiss;

  RazorpayService._internal() {
    _initRazorpay();
  }

  factory RazorpayService() {
    return _instance;
  }

  /// Initialize Razorpay
  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  /// Handle payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    final razorpayResponse = RazorpayPaymentResponse.fromMap({
      'razorpay_payment_id': response.paymentId,
      'razorpay_order_id': response.orderId,
      'razorpay_signature': response.signature,
    });

    _onSuccess?.call(razorpayResponse);
  }

  /// Handle payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    final errorMessage = response.message ?? 'Payment failed. Please try again.';
    _onError?.call(errorMessage);
  }

  /// Handle external wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet selection (e.g., PhonePe, Google Pay, etc.)
    _onDismiss?.call();
  }

  /// Open Razorpay payment modal
  Future<void> startPayment({
    required String orderId,
    required double amount,
    required String userEmail,
    required String userPhone,
    required String userName,
    required PaymentSuccessCallback onSuccess,
    required PaymentErrorCallback onError,
    required PaymentDismissCallback onDismiss,
    PaymentMethod? preferredMethod,
    Map<String, dynamic>? metadata,
  }) async {
    _onSuccess = onSuccess;
    _onError = onError;
    _onDismiss = onDismiss;

    try {
      var options = {
        'key': RazorpayConfig.keyId,
        'amount': (amount * 100).toInt(), // Amount in paise
        'currency': 'INR',
        'order_id': orderId, // This should be created on backend first
        'name': RazorpayConfig.merchantName,
        'description': RazorpayConfig.merchantDescription,
        'prefill': {
          'contact': userPhone,
          'email': userEmail,
          'name': userName,
        },
        'notes': metadata ?? {
          'orderId': orderId,
          'timestamp': DateTime.now().toIso8601String(),
        },
        'theme': {
          'color': RazorpayConfig.themeColor,
        },
        'timeout': RazorpayConfig.paymentTimeout.inSeconds,
        'retry': {
          'enabled': true,
          'max_count': 3,
        },
        'image': RazorpayConfig.logoUrl,
      };

      // Add payment method preferences if specified
      if (preferredMethod != null) {
        options['method'] = _getMethodString(preferredMethod);
      }

      _razorpay.open(options);
    } catch (e) {
      _onError?.call('Failed to open payment gateway: ${e.toString()}');
    }
  }

  /// Create payment order on backend
  Future<RazorpayOrderModel?> createOrder({
    required double amount,
    required String receipt,
    Map<String, dynamic>? notes,
  }) async {
    try {
      // Call backend API to create Razorpay order
      final response = await http.post(
        Uri.parse(RazorpayConfig.createOrderEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': 'INR',
          'receipt': receipt,
          'notes': notes,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RazorpayOrderModel.fromJson(data['data']);
      } else {
        print('Error creating order: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception in createOrder: $e');
      return null;
    }
  }

  /// Verify payment signature
  Future<bool> verifyPaymentSignature({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    try {
      // Call backend API to verify Razorpay signature
      final response = await http.post(
        Uri.parse(RazorpayConfig.verifySignatureEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'razorpay_payment_id': paymentId,
          'razorpay_order_id': orderId,
          'razorpay_signature': signature,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['verified'] ?? false;
      } else {
        print('Error verifying signature: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception in verifyPaymentSignature: $e');
      return false;
    }
  }

  /// Get payment details
  Future<PaymentModel?> getPaymentDetails({
    required String paymentId,
  }) async {
    try {
      // Call backend API to get payment details
      final response = await http.get(
        Uri.parse('${RazorpayConfig.getPaymentEndpoint}/$paymentId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaymentModel.fromJson(data['data']);
      } else {
        print('Error fetching payment details: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception in getPaymentDetails: $e');
      return null;
    }
  }

  /// Refund payment
  Future<bool> refundPayment({
    required String paymentId,
    double? amount,
    String? reason,
  }) async {
    try {
      // Call backend API to process refund
      final response = await http.post(
        Uri.parse('${RazorpayBackendConfig.baseUrl}/payments/refund'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'razorpay_payment_id': paymentId,
          'amount': amount,
          'reason': reason,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      } else {
        print('Error refunding payment: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception in refundPayment: $e');
      return false;
    }
  }

  /// Get payment methods
  List<PaymentMethod> getSupportedPaymentMethods() {
    final methods = <PaymentMethod>[];

    for (var methodStr in RazorpayConfig.enabledPaymentMethods) {
      switch (methodStr) {
        case 'card':
          methods.addAll([PaymentMethod.creditCard, PaymentMethod.debitCard]);
          break;
        case 'netbanking':
          methods.add(PaymentMethod.netBanking);
          break;
        case 'wallet':
          methods.add(PaymentMethod.wallet);
          break;
        case 'upi':
          methods.add(PaymentMethod.upi);
          break;
        case 'emi':
          methods.add(PaymentMethod.emi);
          break;
        case 'emandate':
          methods.add(PaymentMethod.payLater);
          break;
      }
    }

    return methods;
  }

  /// Format amount for display
  String formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  /// Get payment status color
  String getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return '#219A00';
      case PaymentStatus.processing:
      case PaymentStatus.pending:
        return '#FF9800';
      case PaymentStatus.failed:
      case PaymentStatus.cancelled:
        return '#F44336';
      case PaymentStatus.refunded:
        return '#2196F3';
    }
  }

  /// Get payment status text
  String getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  /// Get payment method icon
  String getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'assets/icons/credit_card.svg';
      case PaymentMethod.debitCard:
        return 'assets/icons/debit_card.svg';
      case PaymentMethod.netBanking:
        return 'assets/icons/netbanking.svg';
      case PaymentMethod.wallet:
        return 'assets/icons/wallet.svg';
      case PaymentMethod.upi:
        return 'assets/icons/upi.svg';
      case PaymentMethod.emi:
        return 'assets/icons/emi.svg';
      case PaymentMethod.payLater:
        return 'assets/icons/paylater.svg';
      case PaymentMethod.shopTokens:
        return 'assets/icons/coin.svg';
    }
  }

  /// Get payment method name
  String getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.netBanking:
        return 'Net Banking';
      case PaymentMethod.wallet:
        return 'Digital Wallet';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.emi:
        return 'EMI';
      case PaymentMethod.payLater:
        return 'Pay Later';
      case PaymentMethod.shopTokens:
        return 'Shop Tokens';
    }
  }

  /// Convert PaymentMethod to string
  String _getMethodString(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'card';
      case PaymentMethod.debitCard:
        return 'card';
      case PaymentMethod.netBanking:
        return 'netbanking';
      case PaymentMethod.wallet:
        return 'wallet';
      case PaymentMethod.upi:
        return 'upi';
      case PaymentMethod.emi:
        return 'emi';
      case PaymentMethod.payLater:
        return 'emandate';
      case PaymentMethod.shopTokens:
        return 'shopTokens';
    }
  }

  /// Dispose Razorpay instance
  void dispose() {
    _razorpay.clear();
  }
}

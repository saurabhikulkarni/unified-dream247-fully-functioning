import 'package:uuid/uuid.dart';

// Payment Status Enum
enum PaymentStatus {
  pending,      // Payment initiated but not completed
  processing,   // Payment being processed
  completed,    // Payment successful
  failed,       // Payment failed
  cancelled,    // Payment cancelled by user
  refunded,     // Payment refunded
}

// Payment Method Enum
enum PaymentMethod {
  creditCard,
  debitCard,
  netBanking,
  wallet,
  upi,
  emi,
  payLater,
}

// Payment Model
class PaymentModel {
  final String paymentId;
  final String orderId;
  final double amount;
  final String currency;
  final PaymentStatus paymentStatus;
  final PaymentMethod? method;
  final String? razorpayPaymentId;
  final String? razorpayOrderId;
  final String? razorpaySignature;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? failureReason;
  final String? receipt;
  final Map<String, dynamic>? metadata;

  PaymentModel({
    String? paymentId,
    required this.orderId,
    required this.amount,
    this.currency = 'INR',
    this.paymentStatus = PaymentStatus.pending,
    this.method,
    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.razorpaySignature,
    DateTime? createdAt,
    this.completedAt,
    this.failureReason,
    this.receipt,
    this.metadata,
  })  : paymentId = paymentId ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'orderId': orderId,
      'amount': amount,
      'currency': currency,
      'paymentStatus': paymentStatus.toString().split('.').last,
      'method': method?.toString().split('.').last,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpayOrderId': razorpayOrderId,
      'razorpaySignature': razorpaySignature,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'failureReason': failureReason,
      'receipt': receipt,
      'metadata': metadata,
    };
  }

  // Convert from JSON
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      paymentId: json['paymentId'] ?? '',
      orderId: json['orderId'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'INR',
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['paymentStatus'] ?? json['status'] ?? 'pending'),
        orElse: () => PaymentStatus.pending,
      ),
      method: json['method'] != null
          ? PaymentMethod.values.firstWhere(
              (e) => e.toString().split('.').last == json['method'],
              orElse: () => PaymentMethod.creditCard,
            )
          : null,
      razorpayPaymentId: json['razorpayPaymentId'],
      razorpayOrderId: json['razorpayOrderId'],
      razorpaySignature: json['razorpaySignature'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      failureReason: json['failureReason'],
      receipt: json['receipt'],
      metadata: json['metadata'],
    );
  }

  // Copy with
  PaymentModel copyWith({
    String? paymentId,
    String? orderId,
    double? amount,
    String? currency,
    PaymentStatus? paymentStatus,
    PaymentMethod? method,
    String? razorpayPaymentId,
    String? razorpayOrderId,
    String? razorpaySignature,
    DateTime? createdAt,
    DateTime? completedAt,
    String? failureReason,
    String? receipt,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentModel(
      paymentId: paymentId ?? this.paymentId,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      method: method ?? this.method,
      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      razorpaySignature: razorpaySignature ?? this.razorpaySignature,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      failureReason: failureReason ?? this.failureReason,
      receipt: receipt ?? this.receipt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'PaymentModel(paymentId: $paymentId, orderId: $orderId, amount: $amount, paymentStatus: $paymentStatus)';
  }
}

// Razorpay Order Model (for creating orders on backend)
class RazorpayOrderModel {
  final String razorpayOrderId;
  final double amount;
  final String currency;
  final String receipt;
  final Map<String, dynamic>? notes;
  final bool partialPayment;
  final List<String>? firstMinAmount;

  RazorpayOrderModel({
    required this.razorpayOrderId,
    required this.amount,
    required this.currency,
    required this.receipt,
    this.notes,
    this.partialPayment = false,
    this.firstMinAmount,
  });

  factory RazorpayOrderModel.fromJson(Map<String, dynamic> json) {
    return RazorpayOrderModel(
      razorpayOrderId: json['id'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'INR',
      receipt: json['receipt'] ?? '',
      notes: json['notes'],
      partialPayment: json['partial_payment'] ?? false,
    );
  }
}

// Payment Response Model (from Razorpay)
class RazorpayPaymentResponse {
  final String paymentId;
  final String orderId;
  final String signature;
  final Map<String, dynamic>? rawResponse;

  RazorpayPaymentResponse({
    required this.paymentId,
    required this.orderId,
    required this.signature,
    this.rawResponse,
  });

  factory RazorpayPaymentResponse.fromMap(Map<dynamic, dynamic> map) {
    return RazorpayPaymentResponse(
      paymentId: map['razorpay_payment_id'] ?? '',
      orderId: map['razorpay_order_id'] ?? '',
      signature: map['razorpay_signature'] ?? '',
      rawResponse: Map<String, dynamic>.from(map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'orderId': orderId,
      'signature': signature,
      'rawResponse': rawResponse,
    };
  }
}

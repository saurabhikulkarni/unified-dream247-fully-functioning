class OrderModel {
  final String id;
  final String date;
  final double total;
  final String orderStatus;
  final List<String> items;
  final String? shippingId;
  final String? courierName;
  final String? trackingNumber;

  OrderModel({
    required this.id,
    required this.date,
    required this.total,
    required this.orderStatus,
    required this.items,
    this.shippingId,
    this.courierName,
    this.trackingNumber,
  });
}

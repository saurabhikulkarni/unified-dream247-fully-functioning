import 'package:flutter/material.dart';
import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/shop/models/payment_model.dart';
import 'package:unified_dream247/features/shop/screens/checkout/components/payment_method_card.dart';
import 'package:unified_dream247/features/shop/services/razorpay_service.dart';
import 'package:unified_dream247/features/shop/services/payment_service.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  List<PaymentModel> _paymentHistory = [];
  bool _isLoading = true;
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final payments = await paymentService.getUserPayments(newestFirst: true);
      if (mounted) {
        setState(() {
          _paymentHistory = payments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading payment history: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredPayments = _getFilteredPayments();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding,
              vertical: defaultPadding / 2,
            ),
            child: Row(
              children: [
                _buildFilterChip('All', null),
                const SizedBox(width: 8),
                _buildFilterChip('Completed', PaymentStatus.completed),
                const SizedBox(width: 8),
                _buildFilterChip('Failed', PaymentStatus.failed),
                const SizedBox(width: 8),
                _buildFilterChip('Refunded', PaymentStatus.refunded),
              ],
            ),
          ),
          // Payment History List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredPayments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.payment_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: defaultPadding),
                            Text(
                              'No payments found',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: defaultPadding / 2),
                            Text(
                              'You haven\'t made any payments yet',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                    padding: const EdgeInsets.all(defaultPadding),
                    itemCount: filteredPayments.length,
                    itemBuilder: (context, index) {
                      final payment = filteredPayments[index];
                      return PaymentHistoryCard(
                        payment: payment,
                        onTap: () {
                          _showPaymentDetails(payment);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, PaymentStatus? status) {
    final isSelected = (_selectedFilter == null && status == null) ||
        _selectedFilter == status?.toString();

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedFilter = status?.toString();
          } else {
            _selectedFilter = null;
          }
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF6441A5).withOpacity(0.1),
      side: BorderSide(
        color:
            isSelected ? const Color(0xFF6441A5) : Colors.grey.shade200,
        width: isSelected ? 1.5 : 1,
      ),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF6441A5) : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  List<PaymentModel> _getFilteredPayments() {
    if (_selectedFilter == null) {
      return _paymentHistory;
    }

    return _paymentHistory
        .where((payment) => payment.paymentStatus.toString() == _selectedFilter)
        .toList();
  }

  void _showPaymentDetails(PaymentModel payment) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Payment Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding),
            const Divider(),
            const SizedBox(height: defaultPadding),
            _buildDetailRow('Order ID', payment.orderId),
            _buildDetailRow(
              'Amount',
              RazorpayService().formatAmount(payment.amount),
            ),
            _buildDetailRow(
              'Status',
              RazorpayService().getStatusText(payment.paymentStatus),
            ),
            _buildDetailRow(
              'Payment Method',
              payment.method != null
                  ? RazorpayService().getPaymentMethodName(payment.method!)
                  : 'N/A',
            ),
            _buildDetailRow(
              'Payment ID',
              payment.razorpayPaymentId ?? 'N/A',
            ),
            _buildDetailRow(
              'Order ID (Razorpay)',
              payment.razorpayOrderId ?? 'N/A',
            ),
            _buildDetailRow(
              'Date',
              payment.createdAt.toString().split('.')[0],
            ),
            if (payment.completedAt != null)
              _buildDetailRow(
                'Completed At',
                payment.completedAt.toString().split('.')[0],
              ),
            if (payment.failureReason != null)
              _buildDetailRow('Failure Reason', payment.failureReason!),
            const SizedBox(height: defaultPadding * 2),
            if (payment.paymentStatus == PaymentStatus.failed)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to payment retry
                },
                child: const Text('Retry Payment'),
              ),
            if (payment.paymentStatus == PaymentStatus.completed)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Open download receipt
                      },
                      child: const Text('Download Receipt'),
                    ),
                  ),
                  const SizedBox(width: defaultPadding / 2),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Request refund
                      },
                      child: const Text('Request Refund'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2A0845),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

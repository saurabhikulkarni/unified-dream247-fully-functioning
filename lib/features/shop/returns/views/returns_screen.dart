import 'package:flutter/material.dart';
import 'package:unified_dream247/features/shop/constants.dart';

class ReturnRequest {
  final String orderId;
  final String productName;
  final String reason;
  final String status; // pending, approved, rejected
  final DateTime requestDate;
  final String? approvalDate;

  ReturnRequest({
    required this.orderId,
    required this.productName,
    required this.reason,
    required this.status,
    required this.requestDate,
    this.approvalDate,
  });
}

class ReturnsScreen extends StatefulWidget {
  const ReturnsScreen({super.key});

  @override
  State<ReturnsScreen> createState() => _ReturnsScreenState();
}

class _ReturnsScreenState extends State<ReturnsScreen> {
  late List<ReturnRequest> returns;

  @override
  void initState() {
    super.initState();
    returns = [
      ReturnRequest(
        orderId: '#ORD001',
        productName: 'Nike Air Max',
        reason: 'Size did not fit',
        status: 'approved',
        requestDate: DateTime.now().subtract(const Duration(days: 5)),
        approvalDate: DateTime.now().subtract(const Duration(days: 3)).toString(),
      ),
      ReturnRequest(
        orderId: '#ORD002',
        productName: 'Adidas Jacket',
        reason: 'Defective product',
        status: 'pending',
        requestDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ReturnRequest(
        orderId: '#ORD003',
        productName: 'Blue T-shirt',
        reason: 'Changed mind',
        status: 'rejected',
        requestDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Return Requests'),
        centerTitle: true,
      ),
      body: returns.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_return_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: defaultPadding),
                  Text(
                    'No return requests',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You haven\'t made any return requests yet',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(defaultPadding),
              itemCount: returns.length,
              itemBuilder: (context, index) {
                final returnRequest = returns[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: defaultPadding),
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with Order ID and Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Order ${returnRequest.orderId}',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(returnRequest.status)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                returnRequest.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(returnRequest.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Product Name
                        Text(
                          'Product: ${returnRequest.productName}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        // Return Reason
                        Text(
                          'Reason: ${returnRequest.reason}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 8),
                        // Dates
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Requested: ${returnRequest.requestDate.day}/${returnRequest.requestDate.month}/${returnRequest.requestDate.year}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                    ),
                              ),
                            ),
                            if (returnRequest.approvalDate != null)
                              Expanded(
                                child: Text(
                                  'Approved: ${returnRequest.approvalDate}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                        fontSize: 11,
                                      ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

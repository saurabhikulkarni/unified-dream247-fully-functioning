import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/shop/models/payment_model.dart';
import 'package:unified_dream247/features/shop/services/razorpay_service.dart';
import 'package:unified_dream247/features/shop/utils/responsive_extension.dart';

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodCard({
    super.key,
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = context.isTablet ? 40.0 : 32.0;
    final nameFontSize = context.fontSize(12, minSize: 10, maxSize: 14);
    final selectedFontSize = context.fontSize(10, minSize: 8, maxSize: 12);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(defaultBorderRadious),
          border: Border.all(
            color: isSelected ? const Color(0xFF6441A5) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? const Color(0xFF6441A5).withOpacity(0.05)
              : Colors.white,
        ),
        child: Column(
          children: [
            // Payment Method Icon
            Container(
              padding: const EdgeInsets.all(defaultPadding / 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF6441A5).withOpacity(0.1)
                    : Colors.grey.shade100,
              ),
              child: SvgPicture.asset(
                RazorpayService().getPaymentMethodIcon(method),
                height: iconSize,
                width: iconSize,
                colorFilter: ColorFilter.mode(
                  isSelected ? const Color(0xFF6441A5) : Colors.grey.shade600,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: defaultPadding / 2),
            // Payment Method Name
            Text(
              RazorpayService().getPaymentMethodName(method),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: nameFontSize,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF6441A5) : Colors.grey.shade700,
              ),
            ),
            // Selection Indicator
            if (isSelected) ...[
              const SizedBox(height: defaultPadding / 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF6441A5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Selected',
                  style: TextStyle(
                    fontSize: selectedFontSize,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PaymentHistoryCard extends StatelessWidget {
  final PaymentModel payment;
  final VoidCallback? onTap;

  const PaymentHistoryCard({
    super.key,
    required this.payment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final orderFontSize = context.fontSize(14, minSize: 12, maxSize: 16);
    final amountFontSize = context.fontSize(18, minSize: 16, maxSize: 20);
    final statusFontSize = context.fontSize(12, minSize: 10, maxSize: 14);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(defaultPadding),
        margin: const EdgeInsets.only(bottom: defaultPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(defaultBorderRadious),
          border: Border.all(color: Colors.grey.shade200),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with amount and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ${payment.orderId}',
                      style: TextStyle(
                        fontSize: orderFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      RazorpayService().formatAmount(payment.amount),
                      style: TextStyle(
                        fontSize: amountFontSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6441A5),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding / 2,
                    vertical: defaultPadding / 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color(int.parse(
                      'FF${RazorpayService().getStatusColor(payment.paymentStatus).replaceFirst('#', '')}',
                      radix: 16,
                    ),).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    RazorpayService().getStatusText(payment.paymentStatus),
                    style: TextStyle(
                      fontSize: statusFontSize,
                      fontWeight: FontWeight.bold,
                      color: Color(int.parse(
                        'FF${RazorpayService().getStatusColor(payment.paymentStatus).replaceFirst('#', '')}',
                        radix: 16,
                      ),),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding),
            const Divider(),
            const SizedBox(height: defaultPadding),
            // Payment details
            _buildDetailRow('Payment ID', payment.razorpayPaymentId ?? 'N/A'),
            _buildDetailRow(
              'Payment Method',
              payment.method != null
                  ? RazorpayService().getPaymentMethodName(payment.method!)
                  : 'N/A',
            ),
            _buildDetailRow(
              'Date',
              payment.createdAt.toString().split('.')[0],
            ),
            if (payment.failureReason != null)
              _buildDetailRow('Reason', payment.failureReason!),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2A0845),
            ),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class PaymentLoadingDialog extends StatelessWidget {
  final String message;

  const PaymentLoadingDialog({
    super.key,
    this.message = 'Processing payment...',
  });

  @override
  Widget build(BuildContext context) {
    final titleFontSize = context.fontSize(16, minSize: 14, maxSize: 18);
    final subtitleFontSize = context.fontSize(12, minSize: 10, maxSize: 14);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(defaultPadding * 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(defaultBorderRadious),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Color(0xFF6441A5)),
            ),
            const SizedBox(height: defaultPadding * 1.5),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2A0845),
              ),
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              'Please wait, do not close the app',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: subtitleFontSize,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentSuccessDialog extends StatelessWidget {
  final String orderId;
  final double amount;
  final String paymentId;
  final VoidCallback onContinue;

  const PaymentSuccessDialog({
    super.key,
    required this.orderId,
    required this.amount,
    required this.paymentId,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = context.isTablet ? 56.0 : 48.0;
    final titleFontSize = context.fontSize(20, minSize: 18, maxSize: 24);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(defaultPadding * 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(defaultBorderRadious),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(defaultPadding),
              decoration: const BoxDecoration(
                color: Color(0xFF219A00),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: iconSize,
              ),
            ),
            const SizedBox(height: defaultPadding * 1.5),
            Text(
              'Payment Successful!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2A0845),
              ),
            ),
            const SizedBox(height: defaultPadding),
            _buildDetailRow('Order ID', orderId),
            _buildDetailRow('Amount', RazorpayService().formatAmount(amount)),
            _buildDetailRow('Payment ID', paymentId),
            const SizedBox(height: defaultPadding * 2),
            ElevatedButton(
              onPressed: onContinue,
              child: const Text('Continue Shopping'),
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
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2A0845),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentErrorDialog extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  const PaymentErrorDialog({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = context.isTablet ? 56.0 : 48.0;
    final titleFontSize = context.fontSize(20, minSize: 18, maxSize: 24);
    final messageFontSize = context.fontSize(14, minSize: 12, maxSize: 16);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(defaultPadding * 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(defaultBorderRadious),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(defaultPadding),
              decoration: const BoxDecoration(
                color: Color(0xFFF44336),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: iconSize,
              ),
            ),
            const SizedBox(height: defaultPadding * 1.5),
            Text(
              'Payment Failed',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2A0845),
              ),
            ),
            const SizedBox(height: defaultPadding),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: messageFontSize,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: defaultPadding * 2),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

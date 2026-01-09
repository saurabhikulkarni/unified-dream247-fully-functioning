import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants.dart';
import '../../../../utils/responsive_extension.dart';

class TransactionHistoryCard extends StatelessWidget {
  const TransactionHistoryCard({
    super.key,
    required this.transactionType,
    required this.date,
    required this.amount,
    required this.isIncome,
  });

  final String transactionType; // "Top-up", "Withdrawal", "Transfer", "Purchase", etc.
  final String date;
  final double amount;
  final bool isIncome; // true = green/income, false = red/debit

  String _getIcon() {
    switch (transactionType.toLowerCase()) {
      case 'top-up':
        return "assets/icons/Plus1.svg";
      case 'purchase':
        return "assets/icons/Return.svg";
      default:
        return "assets/icons/Product.svg";
    }
  }

  @override
  Widget build(BuildContext context) {
    final amountStr = amount.toStringAsFixed(0);
    final containerSize = context.isTablet ? 56.0 : 48.0;
    final iconSize = context.isTablet ? 28.0 : 24.0;
    final subtitleFontSize = context.fontSize(12, minSize: 10, maxSize: 14);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 1.5,
      ),
      decoration: BoxDecoration(
        borderRadius:
            const BorderRadius.all(Radius.circular(defaultBorderRadious)),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        minLeadingWidth: containerSize,
        leading: Container(
          width: containerSize,
          height: containerSize,
          decoration: BoxDecoration(
            color: (isIncome ? Colors.green : Colors.red).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: SvgPicture.asset(
              _getIcon(),
              color: isIncome ? Colors.green : Colors.red,
              height: iconSize,
              width: iconSize,
            ),
          ),
        ),
        title: Text(
          transactionType,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(
          date,
          style: TextStyle(
            fontSize: subtitleFontSize,
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
        ),
        trailing: Text(
          isIncome ? "+ ₹$amountStr" : "- ₹$amountStr",
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

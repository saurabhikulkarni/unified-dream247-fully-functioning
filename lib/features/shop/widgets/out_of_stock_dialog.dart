import 'package:flutter/material.dart';
import 'package:unified_dream247/features/shop/models/product_model.dart';
import 'package:unified_dream247/features/shop/constants.dart';

/// OutOfStockDialog displays a beautiful modal dialog for out-of-stock items
class OutOfStockDialog extends StatelessWidget {
  final List<CartModel> outOfStockItems;
  final Function(CartModel) onRemoveItem;

  const OutOfStockDialog({
    Key? key,
    required this.outOfStockItems,
    required this.onRemoveItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
      ),
      elevation: 24,
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(defaultBorderRadious),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with project theme and close button
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6441A5),
                    Color(0xFF472575),
                    Color(0xFF2A0845),
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(defaultBorderRadious)),
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Items Unavailable',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Some items in your cart are currently unavailable',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  // Close button in top-right corner
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content section
            Flexible(
              child: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The following items are currently out of stock:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: blackColor80,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: defaultPadding),

                    // List of unavailable items with remove buttons
                    Flexible(
                      child: Container(
                        decoration: BoxDecoration(
                          color: lightGreyColor,
                          borderRadius:
                              BorderRadius.circular(defaultBorderRadious),
                          border: Border.all(
                            color: blackColor20,
                            width: 1,
                          ),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: outOfStockItems.length,
                          itemBuilder: (context, index) {
                            final item = outOfStockItems[index];
                            final product = item.product;

                            return Container(
                              margin: EdgeInsets.all(defaultPadding / 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: blackColor20,
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: defaultPadding / 2,
                                  vertical: defaultPadding / 2,
                                ),
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: blackColor10,
                                    border: Border.all(
                                      color: blackColor20,
                                      width: 1,
                                    ),
                                  ),
                                  child: product?.image != null &&
                                          product!.image.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            product.image,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Icon(
                                                Icons
                                                    .image_not_supported_outlined,
                                                color: blackColor40,
                                              );
                                            },
                                          ),
                                        )
                                      : Icon(
                                          Icons.image_not_supported_outlined,
                                          color: blackColor40,
                                        ),
                                ),
                                title: Text(
                                  product?.title ?? 'Product',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(height: 4),
                                    Text(
                                      item.size != null
                                          ? 'Size: ${item.size!.sizeName}'
                                          : 'Size: N/A',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: blackColor80,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Quantity: ${item.quantity}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: blackColor60,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        onRemoveItem(outOfStockItems[index]);
                                        // If this was the last item, close the dialog
                                        if (outOfStockItems.length == 1) {
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      icon: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                      tooltip: 'Remove Item',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              Divider(height: 1, color: blackColor20),
                        ),
                      ),
                    ),

                    SizedBox(height: defaultPadding),

                    // Information text
                    Container(
                      padding: EdgeInsets.all(defaultPadding / 2),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: primaryColor,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'These items will be removed from your cart. You can add them back when they become available.',
                              style: TextStyle(
                                fontSize: 12,
                                color: blackColor80,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension to easily show the dialog
extension OutOfStockDialogExtension on BuildContext {
  /// Shows the out-of-stock dialog
  static Future<void> showOutOfStockDialog({
    required BuildContext context,
    required List<CartModel> outOfStockItems,
    required Function(CartModel) onRemoveItem,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return OutOfStockDialog(
          outOfStockItems: outOfStockItems,
          onRemoveItem: onRemoveItem,
        );
      },
    );
  }
}

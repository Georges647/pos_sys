import 'package:flutter/material.dart';

/// A customizable card widget to display an item in the order/cart.
///
/// This widget shows the product name, quantity, unit price, and total price
/// for a single item. It also includes buttons to increase, decrease, or remove
/// the item from the order.
class OrderItemCard extends StatelessWidget {
  const OrderItemCard({
    super.key,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.onIncrease,
    this.onDecrease,
    this.onRemove,
    this.backgroundColor,
    this.textColor,
  });

  final String productName;
  final int quantity;
  final double unitPrice;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final VoidCallback? onRemove;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = quantity * unitPrice;

    return Card(
      color: backgroundColor ?? theme.cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style:
                        theme.textTheme.titleMedium?.copyWith(color: textColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '$quantity x \$${unitPrice.toStringAsFixed(2)}',
                    style:
                        theme.textTheme.bodyMedium?.copyWith(color: textColor),
                  ),
                ],
              ),
            ),
            Text(
              '\$${total.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(color: textColor),
            ),
            const SizedBox(width: 8.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: textColor ?? theme.colorScheme.primary,
                  onPressed: onDecrease,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: textColor ?? theme.colorScheme.primary,
                  onPressed: onIncrease,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: theme.colorScheme.error,
                  onPressed: onRemove,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

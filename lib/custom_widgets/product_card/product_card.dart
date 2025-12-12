import 'package:flutter/material.dart';

/// A customizable card widget to display product information.
///
/// This widget is designed to be flexible, allowing you to display
/// a product's image, name, price, and an action button (e.g., "Add to Cart").
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.productName,
    required this.price,
    this.onAddToCart,
    this.onLongPress,
    this.backgroundColor,
    this.textColor,
  });

  final String productName;
  final double price;
  final VoidCallback? onAddToCart;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: backgroundColor ?? theme.cardColor,
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: InkWell(
        onTap: onAddToCart,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 8.0),
              Text(
                productName,
                style: theme.textTheme.titleMedium?.copyWith(color: textColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4.0),
              Text('\$${price.toStringAsFixed(2)}',
                  style:
                      theme.textTheme.titleSmall?.copyWith(color: textColor)),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/product_icons.dart';

/// Shows the product's PNG from assets/icons/products. If there is no PNG
/// for the key yet, it shows the built-in fallback icon.
class ProductIconImage extends StatelessWidget {
  const ProductIconImage({
    super.key,
    required this.iconKey,
    this.size = 40,
    this.color,
  });

  final String iconKey;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/products/$iconKey.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => Icon(
        iconForKey(iconKey),
        size: size,
        color: color ?? AppColors.ink,
      ),
    );
  }
}

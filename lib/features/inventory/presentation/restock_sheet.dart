import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/inventory_data.dart';

/// Quick restock: tap a product card to change its stock. Returns the new stock.
class RestockSheet extends StatefulWidget {
  const RestockSheet({super.key, required this.item});

  final InventoryItem item;

  @override
  State<RestockSheet> createState() => _RestockSheetState();
}

class _RestockSheetState extends State<RestockSheet> {
  late int _stock = widget.item.stock;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final item = widget.item;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Restok produk',
            style: textTheme.labelMedium?.copyWith(color: AppColors.muted),
          ),
          Text(
            item.name,
            style:
                textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Stok saat ini ${item.stock} ${item.unit}',
            style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.outlined(
                onPressed: _stock > 0 ? () => setState(() => _stock--) : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              SizedBox(
                width: 96,
                child: Text(
                  '$_stock',
                  textAlign: TextAlign.center,
                  style: textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton.outlined(
                onPressed: () => setState(() => _stock++),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              for (final n in [5, 10, 20])
                ActionChip(
                  label: Text('+$n'),
                  onPressed: () => setState(() => _stock += n),
                ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(_stock),
            child: const Text('Simpan stok'),
          ),
        ],
      ),
    );
  }
}

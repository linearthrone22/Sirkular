import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/inventory_data.dart';

/// One-click publish: choose platforms, then send all selected products.
/// Pops with `true` when published.
class PublishSheet extends StatefulWidget {
  const PublishSheet({super.key, required this.items});

  final List<InventoryItem> items;

  @override
  State<PublishSheet> createState() => _PublishSheetState();
}

class _PublishSheetState extends State<PublishSheet> {
  static const _platforms = ['Tokopedia', 'Shopee', 'TikTok Shop'];

  final Map<String, bool> _chosen = {
    'Tokopedia': true,
    'Shopee': true,
    'TikTok Shop': false,
  };
  bool _publishing = false;

  int get _chosenCount => _chosen.values.where((v) => v).length;

  Future<void> _publish() async {
    setState(() => _publishing = true);
    // TODO: call each platform's publish API.
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final count = _chosenCount;
    final products = widget.items.length;
    Navigator.of(context).pop(true);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '$products produk dipublish ke $count platform',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = textTheme.bodySmall?.copyWith(color: AppColors.muted);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jual Produk',
            style:
                textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.items.length} produk dipilih. Sekali klik, publish ke semua platform yang dicentang.',
            style: muted,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in widget.items)
                Chip(
                  label: Text(item.name),
                  side: BorderSide.none,
                  backgroundColor: AppColors.mintSoft,
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (final platform in _platforms)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _chosen[platform],
              activeColor: AppColors.ink,
              title: Text(platform),
              subtitle: Text('Stok disinkronkan otomatis', style: muted),
              onChanged: _publishing
                  ? null
                  : (v) => setState(() => _chosen[platform] = v ?? false),
            ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed:
                (_publishing || _chosenCount == 0 || widget.items.isEmpty)
                    ? null
                    : _publish,
            child: _publishing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Publish ke $_chosenCount platform',
                  ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/dashboard_service.dart';

extension DashSectionLabel on DashSection {
  String get label {
    switch (this) {
      case DashSection.revenue:
        return 'Pendapatan bulan ini';
      case DashSection.metrics:
        return 'Kartu platform & deadstock';
      case DashSection.orders:
        return 'Ringkasan pesanan';
      case DashSection.stock:
        return 'Status stok';
      case DashSection.liveOrders:
        return 'Pesanan terbaru';
    }
  }
}

/// Opens the customize sheet. [onChanged] reports each switch change so the
/// dashboard updates immediately.
Future<void> showDashboardCustomize(
  BuildContext context, {
  required Set<DashSection> hidden,
  required void Function(DashSection section, bool visible) onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => _CustomizeSheet(hidden: hidden, onChanged: onChanged),
  );
}

class _CustomizeSheet extends StatefulWidget {
  const _CustomizeSheet({required this.hidden, required this.onChanged});

  final Set<DashSection> hidden;
  final void Function(DashSection section, bool visible) onChanged;

  @override
  State<_CustomizeSheet> createState() => _CustomizeSheetState();
}

class _CustomizeSheetState extends State<_CustomizeSheet> {
  late final Set<DashSection> _hidden = Set.of(widget.hidden);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Atur Dashboard',
            style:
                textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Pilih widget yang ingin ditampilkan di halaman utama.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          for (final section in DashSection.values)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(section.label),
              value: !_hidden.contains(section),
              activeTrackColor: AppColors.mint,
              activeThumbColor: Colors.white,
              onChanged: (visible) {
                setState(() {
                  if (visible) {
                    _hidden.remove(section);
                  } else {
                    _hidden.add(section);
                  }
                });
                widget.onChanged(section, visible);
              },
            ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }
}

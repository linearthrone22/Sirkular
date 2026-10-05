import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/platform_data.dart';
import 'widgets/dashboard_widgets.dart';
import 'widgets/mobile_cards.dart';

/// Text-heavy analytics for one platform, with ads and store settings.
class PlatformAnalyticsPage extends StatefulWidget {
  const PlatformAnalyticsPage({super.key, required this.data});

  final PlatformAnalytics data;

  @override
  State<PlatformAnalyticsPage> createState() => _PlatformAnalyticsPageState();
}

class _PlatformAnalyticsPageState extends State<PlatformAnalyticsPage> {
  late bool _autoReply = widget.data.autoReplyOn;
  late bool _voucher = widget.data.voucherOn;
  late double _budget = widget.data.adsBudget.toDouble();

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final textTheme = Theme.of(context).textTheme;
    final muted = textTheme.bodySmall?.copyWith(color: AppColors.muted);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Row(
              children: [
                Material(
                  color: AppColors.surface,
                  shape: const CircleBorder(
                    side: BorderSide(color: AppColors.border),
                  ),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${data.name} Analytics',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DashCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Ringkasan'),
                  const SizedBox(height: 10),
                  Text(
                    data.overview,
                    style: textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DashCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Conversion Rate Kunjungan Toko'),
                  const SizedBox(height: 12),
                  Text(
                    data.conversionRate,
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text('Kunjungan toko: ${data.visits}', style: muted),
                  const SizedBox(height: 12),
                  Text(
                    data.conversionNote,
                    style: textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DashCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(
                    data.name == 'Shopee' ? 'Shopee Ads' : 'TopAds',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kata kunci dengan klik terbanyak. ROAS di atas 3x berarti setiap Rp 1 iklan menghasilkan Rp 3 penjualan.',
                    style: muted,
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 36,
                      dataRowMinHeight: 40,
                      dataRowMaxHeight: 40,
                      columnSpacing: 24,
                      columns: [
                        DataColumn(label: Text('Kata kunci', style: muted)),
                        DataColumn(
                            label: Text('Klik', style: muted), numeric: true),
                        DataColumn(
                            label: Text('Belanja', style: muted),
                            numeric: true),
                        DataColumn(
                            label: Text('ROAS', style: muted), numeric: true),
                      ],
                      rows: [
                        for (final k in data.keywords)
                          DataRow(
                            cells: [
                              DataCell(Text(k.keyword)),
                              DataCell(Text('${k.clicks}')),
                              DataCell(Text(PlatformData.rupiah(k.spend))),
                              DataCell(Text(k.roas)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DashCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Retensi Pembeli'),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
                    child: _TrendChart(
                      values: data.retentionValues,
                      labels: data.retentionLabels,
                      color: data.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.retentionNote,
                    style: textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DashCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Waktu Belanja Tersibuk'),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
                    child: MiniBarChart(
                      values: data.peakValues,
                      labels: data.peakLabels,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.peakNote,
                    style: textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DashCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle('Pengaturan ${data.name}'),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Auto-reply chat'),
                    subtitle: Text(
                      'Balas otomatis pertanyaan stok dan pengiriman.',
                      style: muted,
                    ),
                    value: _autoReply,
                    activeTrackColor: AppColors.mint,
                    activeThumbColor: Colors.white,
                    onChanged: (v) => setState(() => _autoReply = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Voucher toko aktif'),
                    subtitle: Text(
                      'Tampilkan voucher di halaman produk.',
                      style: muted,
                    ),
                    value: _voucher,
                    activeTrackColor: AppColors.mint,
                    activeThumbColor: Colors.white,
                    onChanged: (v) => setState(() => _voucher = v),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Anggaran iklan harian: ${PlatformData.rupiah(_budget.round())}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Slider(
                    value: _budget,
                    min: 50000,
                    max: 300000,
                    divisions: 25,
                    activeColor: AppColors.ink,
                    onChanged: (v) => setState(() => _budget = v),
                  ),
                  Text(
                    'Terpakai hari ini ${PlatformData.rupiah(data.adsSpent)} dari ${PlatformData.rupiah(data.adsBudget)}',
                    style: muted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({
    required this.values,
    required this.labels,
    required this.color,
  });

  final List<double> values;
  final List<String> labels;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.muted,
        );
    return LineChart(
      LineChartData(
        minY: 0,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(labels[index], style: muted),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < values.length; i++)
                FlSpot(i.toDouble(), values[i]),
            ],
            isCurved: true,
            color: color,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

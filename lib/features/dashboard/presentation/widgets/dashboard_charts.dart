import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/dashboard_data.dart';

/// Stacked bars per day: Tokopedia (mint), Shopee (orange), POS (ink).
class OmnichannelBarChart extends StatelessWidget {
  const OmnichannelBarChart({super.key, required this.data});

  final List<ChannelSales> data;

  @override
  Widget build(BuildContext context) {
    final maxTotal = data.map((d) => d.total).reduce((a, b) => a > b ? a : b);
    final muted = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.muted,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _LegendDot(color: AppColors.mint, label: 'Tokopedia'),
            _LegendDot(color: AppColors.orange, label: 'Shopee'),
            _LegendDot(color: AppColors.ink, label: 'POS'),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: BarChart(
            BarChartData(
              maxY: maxTotal + 10,
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
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= data.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(data[index].day, style: muted),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < data.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[i].total,
                        width: 18,
                        borderRadius: BorderRadius.circular(6),
                        rodStackItems: [
                          BarChartRodStackItem(
                            0,
                            data[i].tokopedia,
                            AppColors.mint,
                          ),
                          BarChartRodStackItem(
                            data[i].tokopedia,
                            data[i].tokopedia + data[i].shopee,
                            AppColors.orange,
                          ),
                          BarChartRodStackItem(
                            data[i].tokopedia + data[i].shopee,
                            data[i].total,
                            AppColors.ink,
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Smooth line for stock health over the week.
class InventoryHealthChart extends StatelessWidget {
  const InventoryHealthChart({super.key, required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.muted,
        );
    const days = DashboardData.weekdays;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: 25,
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
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= days.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(days[index], style: muted),
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
            color: AppColors.mint,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.mint.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}

/// Donut showing how much raw material was used versus wasted.
class WasteDonutChart extends StatelessWidget {
  const WasteDonutChart({super.key, required this.usedPercent});

  final int usedPercent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      value: usedPercent.toDouble(),
                      color: AppColors.mint,
                      radius: 16,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: (100 - usedPercent).toDouble(),
                      color: AppColors.border,
                      radius: 16,
                      showTitle: false,
                    ),
                  ],
                ),
              ),
              Text(
                '$usedPercent%',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LegendDot(
                color: AppColors.mint,
                label: 'Terjual & Dimanfaatkan',
              ),
              SizedBox(height: 12),
              _LegendDot(
                color: AppColors.border,
                label: 'Waste / Terbuang',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.muted,
                ),
          ),
        ),
      ],
    );
  }
}

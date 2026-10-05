import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/user_rules.dart';
import 'dashboard_widgets.dart';

/// Metric card in the reference style: icon, label, number, sparkline, delta.
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.delta,
    this.trend = const [],
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final int? delta;
  final List<double> trend;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DashCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              const _CircleArrow(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Row(
            children: [
              if (trend.isNotEmpty)
                Expanded(
                  child: SizedBox(
                    height: 32,
                    child: Sparkline(values: trend, color: AppColors.ink),
                  ),
                )
              else
                const Spacer(),
              if (delta != null) DeltaBadge(delta: delta!),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '7 hari terakhir',
            style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class DeltaBadge extends StatelessWidget {
  const DeltaBadge({super.key, required this.delta});

  final int delta;

  @override
  Widget build(BuildContext context) {
    final positive = delta >= 0;
    final color = positive ? AppColors.mint : AppColors.danger;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        positive ? '+$delta' : '$delta',
        style: const TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _CircleArrow extends StatelessWidget {
  const _CircleArrow();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: const Icon(Icons.north_east_rounded, size: 16),
    );
  }
}

/// Orders summary on a mint card with a bar chart, like the reference.
class OrdersCard extends StatelessWidget {
  const OrdersCard({
    super.key,
    required this.stats,
    required this.values,
    required this.days,
  });

  final List<OrderStat> stats;
  final List<double> values;
  final List<String> days;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pesanan',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.tune_rounded, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final stat in stats)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stat.value,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        stat.label,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.ink.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: MiniBarChart(values: values, labels: days),
          ),
        ],
      ),
    );
  }
}

class OrderStat {
  const OrderStat({required this.value, required this.label});

  final String value;
  final String label;
}

/// Orange card with a donut of stock status, like the reference.
class StockStatusCard extends StatelessWidget {
  const StockStatusCard({super.key, required this.segments});

  final List<StockSegment> segments;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total = segments.fold<int>(0, (sum, s) => sum + s.value);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Status Stok',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.tune_rounded, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 42,
                        sections: [
                          for (final s in segments)
                            PieChartSectionData(
                              value: s.value.toDouble(),
                              color: s.color,
                              radius: 16,
                              showTitle: false,
                            ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$total',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Total Items',
                          style: textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final s in segments)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: s.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                s.label,
                                style: textTheme.labelMedium,
                              ),
                            ),
                            Text(
                              '${s.value}',
                              style: textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StockSegment {
  const StockSegment({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;
}

/// The user's rules with a working toggle per rule.
class RulesCard extends StatelessWidget {
  const RulesCard({super.key, required this.rules, required this.onToggle});

  final List<UserRule> rules;
  final void Function(UserRule rule) onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final activeCount = rules.where((r) => r.active).length;

    return DashCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Aturan Saya',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              StatusBadge(
                text: '$activeCount aktif',
                color: AppColors.mint,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Otomatisasi untuk stok, harga, dan resep.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          for (final rule in rules) ...[
            const Divider(height: 24),
            _RuleTile(rule: rule, onToggle: () => onToggle(rule)),
          ],
        ],
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  const _RuleTile({required this.rule, required this.onToggle});

  final UserRule rule;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tint = rule.isAi ? AppColors.purple : AppColors.mintDeep;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            rule.isAi ? Icons.auto_awesome : Icons.rule_rounded,
            color: tint,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rule.title,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Jika ${rule.condition}',
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
              Text(
                '→ ${rule.action}',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Terpicu ${rule.triggeredToday}x hari ini',
                style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        Switch(
          value: rule.active,
          onChanged: (_) => onToggle(),
          activeTrackColor: AppColors.mint,
          inactiveTrackColor: AppColors.border,
          activeThumbColor: Colors.white,
          inactiveThumbColor: Colors.white,
          trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ],
    );
  }
}

/// Sparkline for a small trend, with no axes.
class Sparkline extends StatelessWidget {
  const Sparkline({super.key, required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < values.length; i++)
                FlSpot(i.toDouble(), values[i]),
            ],
            isCurved: true,
            color: color,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

/// Bars with day labels. The last bar is highlighted.
class MiniBarChart extends StatelessWidget {
  const MiniBarChart({super.key, required this.values, required this.labels});

  final List<double> values;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final last = values.length - 1;

    return BarChart(
      BarChartData(
        maxY: maxValue * 1.15,
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barTouchData: const BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    labels[index],
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.ink.withValues(alpha: 0.7),
                        ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < values.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  width: 14,
                  borderRadius: BorderRadius.circular(6),
                  color: i == last
                      ? AppColors.ink
                      : AppColors.ink.withValues(alpha: 0.25),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

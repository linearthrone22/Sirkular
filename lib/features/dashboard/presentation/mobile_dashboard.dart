import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/format/format.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/data/user_repository.dart';
import '../../inventory/presentation/inventory_page.dart';
import '../data/dashboard_repository.dart';
import '../data/dashboard_service.dart';
import 'insights_page.dart';
import 'platform_analytics_page.dart';
import 'widgets/dashboard_customize_sheet.dart';
import 'widgets/dashboard_widgets.dart';
import 'widgets/mobile_cards.dart';

class MobileDashboard extends StatefulWidget {
  const MobileDashboard({super.key, required this.user});

  final User user;

  @override
  State<MobileDashboard> createState() => _MobileDashboardState();
}

class _MobileDashboardState extends State<MobileDashboard> {
  final _service = DashboardService();
  final _prefs = DashboardRepository();
  late Future<DashboardSnapshot> _future = _service.load(widget.user.id);

  void _reload() {
    setState(() => _future = _service.load(widget.user.id));
  }

  Future<void> _openCustomize(DashboardSnapshot d) async {
    await showDashboardCustomize(
      context,
      hidden: d.hidden,
      onChanged: (section, visible) async {
        await _prefs.setDashboardPref(
          widget.user.id,
          section.name,
          visible: visible,
        );
      },
    );
    _reload();
  }

  Future<void> _push(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardSnapshot>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
                child: Text('Gagal memuat dashboard: ${snapshot.error}')),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        return _buildContent(context, snapshot.requireData);
      },
    );
  }

  Widget _buildContent(BuildContext context, DashboardSnapshot d) {
    final textTheme = Theme.of(context).textTheme;
    final firstName = widget.user.name.split(' ').first;
    bool shown(DashSection s) => !d.hidden.contains(s);

    final target = d.revenueTargetIdr;
    final progress = target == 0
        ? 0.0
        : (d.revenue30DaysIdr / target).clamp(0.0, 1.0).toDouble();

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () async => _reload(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, $firstName',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                            Text(
                              'Dashboard',
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _IconCircle(
                        icon: Icons.settings_outlined,
                        onTap: () => _openCustomize(d),
                      ),
                      const SizedBox(width: 8),
                      _IconCircle(
                        icon: Icons.notifications_none_rounded,
                        onTap: () {
                          // TODO: notifications screen
                        },
                      ),
                      const SizedBox(width: 8),
                      UserAvatarMenu(user: widget.user),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (shown(DashSection.revenue)) ...[
                    DashCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Pendapatan 30 Hari',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              StatusBadge(
                                text: '+${d.efficiencyPct}% Efisiensi',
                                color: AppColors.mint,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            rupiah(d.revenue30DaysIdr),
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              color: AppColors.mint,
                              backgroundColor: AppColors.border,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Target ${rupiah(target)} · ${(progress * 100).round()}% tercapai',
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (shown(DashSection.metrics)) ...[
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.78,
                      children: [
                        MetricCard(
                          label: 'Pesanan Tokopedia',
                          value: '${d.tokopediaOrders}',
                          icon: Icons.storefront_rounded,
                          color: AppColors.mintDeep,
                          delta: d.tokopediaDelta,
                          trend: d.tokopediaTrend,
                          onTap: () => _push(
                            PlatformAnalyticsPage(
                              userId: widget.user.id,
                              platformKey: 'tokopedia',
                            ),
                          ),
                        ),
                        MetricCard(
                          label: 'Pesanan Shopee',
                          value: '${d.shopeeOrders}',
                          icon: Icons.shopping_bag_outlined,
                          color: AppColors.orange,
                          delta: d.shopeeDelta,
                          trend: d.shopeeTrend,
                          onTap: () => _push(
                            PlatformAnalyticsPage(
                              userId: widget.user.id,
                              platformKey: 'shopee',
                            ),
                          ),
                        ),
                        MetricCard(
                          label: 'Deadstock Saved',
                          value: '${d.deadstockKg.round()} kg',
                          icon: Icons.eco_outlined,
                          color: AppColors.mintDeep,
                          delta: d.deadstockDelta.round(),
                          trend: d.deadstockTrend,
                        ),
                        MetricCard(
                          label: 'Sync Status',
                          value: d.syncOk ? 'Synced' : 'Offline',
                          icon: Icons.sync_rounded,
                          color: AppColors.mintDeep,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (shown(DashSection.orders) &&
                      d.channelSales.isNotEmpty) ...[
                    OrdersCard(
                      stats: [
                        OrderStat(
                            value: '${d.tokopediaOrders}', label: 'Tokopedia'),
                        OrderStat(value: '${d.shopeeOrders}', label: 'Shopee'),
                        OrderStat(value: '${d.dikemasCount}', label: 'Dikemas'),
                        OrderStat(value: '${d.dikirimCount}', label: 'Dikirim'),
                      ],
                      values: [for (final c in d.channelSales) c.total],
                      days: [for (final c in d.channelSales) c.day],
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (shown(DashSection.stock)) ...[
                    StockStatusCard(
                      segments: [
                        StockSegment(
                          label: 'In stock',
                          value: d.stock.inStock,
                          color: AppColors.ink,
                        ),
                        StockSegment(
                          label: 'Low stock',
                          value: d.stock.low,
                          color: Colors.white,
                        ),
                        StockSegment(
                          label: 'Out of stock',
                          value: d.stock.out,
                          color: AppColors.danger,
                        ),
                        StockSegment(
                          label: 'Dead stock',
                          value: d.stock.dead,
                          color: AppColors.mintDeep,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (shown(DashSection.liveOrders)) ...[
                    const SectionTitle('Live Orders'),
                    const SizedBox(height: 12),
                    for (final order in d.liveOrders.take(3)) ...[
                      DashCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.item,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${order.platform} · ${order.time}',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  order.total,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                StatusBadge(
                                  text: order.status,
                                  color: statusColor(order.status),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                  const SizedBox(height: 96),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: _InsightPill(
                      label: '${d.alertCount} AI Alerts',
                      onTap: () => _push(InsightsPage(userId: widget.user.id)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _InventoryButton(
                    onTap: () => _push(InventoryPage(userId: widget.user.id)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color statusColor(String status) {
  switch (status) {
    case 'Dikemas':
      return AppColors.orange;
    case 'Dikirim':
      return AppColors.mint;
    default:
      return AppColors.border;
  }
}

/// Left pill of the bottom bar: dark glass pill with an AI orb.
class _InsightPill extends StatelessWidget {
  const _InsightPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: AppColors.ink.withValues(alpha: 0.86),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.purple, AppColors.mintDeep],
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Right round button of the bottom bar: large white circle, opens inventory.
class _InventoryButton extends StatelessWidget {
  const _InventoryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 68,
          height: 68,
          child:
              Icon(Icons.inventory_2_outlined, color: AppColors.ink, size: 28),
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }
}

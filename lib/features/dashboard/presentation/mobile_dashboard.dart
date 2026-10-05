import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/data/user_repository.dart';
import '../../inventory/presentation/inventory_page.dart';
import '../data/dashboard_data.dart';
import '../data/platform_data.dart';
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
  final Set<DashSection> _hidden = {};

  bool _shown(DashSection section) => !_hidden.contains(section);

  void _openCustomize() {
    showDashboardCustomize(
      context,
      hidden: _hidden,
      onChanged: (section, visible) {
        setState(() {
          if (visible) {
            _hidden.remove(section);
          } else {
            _hidden.add(section);
          }
        });
      },
    );
  }

  void _openPlatform(String name) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlatformAnalyticsPage(data: PlatformData.byName(name)),
      ),
    );
  }

  void _openInventory() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const InventoryPage()),
    );
  }

  void _openInsights() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const InsightsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final firstName = widget.user.name.split(' ').first;
    const days = DashboardData.channelSales;

    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(child: _InsightPill(onTap: _openInsights)),
              const SizedBox(width: 12),
              _InventoryButton(onTap: _openInventory),
            ],
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
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
                  onTap: _openCustomize,
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
            if (_shown(DashSection.revenue)) ...[
              DashCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Pendapatan Bulan Ini',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const StatusBadge(
                          text: DashboardData.efficiencyBadge,
                          color: AppColors.mint,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      DashboardData.totalRevenue,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: const LinearProgressIndicator(
                        value: 0.8,
                        minHeight: 8,
                        color: AppColors.mint,
                        backgroundColor: AppColors.border,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Target Rp 30.000.000 · 80% tercapai',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_shown(DashSection.metrics)) ...[
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
                    value: DashboardData.tokopediaOrders,
                    icon: Icons.storefront_rounded,
                    color: AppColors.mintDeep,
                    delta: 2,
                    trend: const [12, 18, 15, 22, 28, 31, 24],
                    onTap: () => _openPlatform('Tokopedia'),
                  ),
                  MetricCard(
                    label: 'Pesanan Shopee',
                    value: DashboardData.shopeeOrders,
                    icon: Icons.shopping_bag_outlined,
                    color: AppColors.orange,
                    delta: -3,
                    trend: const [8, 10, 12, 14, 18, 22, 19],
                    onTap: () => _openPlatform('Shopee'),
                  ),
                  const MetricCard(
                    label: 'Deadstock Saved',
                    value: DashboardData.deadstockKg,
                    icon: Icons.eco_outlined,
                    color: AppColors.mintDeep,
                    delta: 2,
                    trend: [4, 6, 5, 9, 8, 12, 15],
                  ),
                  const MetricCard(
                    label: 'Sync Status',
                    value: DashboardData.syncStatus,
                    icon: Icons.sync_rounded,
                    color: AppColors.mintDeep,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (_shown(DashSection.orders)) ...[
              OrdersCard(
                stats: const [
                  OrderStat(
                    value: DashboardData.tokopediaOrders,
                    label: 'Tokopedia',
                  ),
                  OrderStat(
                    value: DashboardData.shopeeOrders,
                    label: 'Shopee',
                  ),
                  OrderStat(value: '14', label: 'Dikemas'),
                  OrderStat(value: '3', label: 'Dikirim'),
                ],
                values: [for (final d in days) d.total],
                days: [for (final d in days) d.day],
              ),
              const SizedBox(height: 16),
            ],
            if (_shown(DashSection.stock)) ...[
              const StockStatusCard(
                segments: [
                  StockSegment(
                      label: 'In stock', value: 90, color: AppColors.ink),
                  StockSegment(
                      label: 'Low stock', value: 20, color: Colors.white),
                  StockSegment(
                    label: 'Out of stock',
                    value: 8,
                    color: AppColors.danger,
                  ),
                  StockSegment(
                    label: 'Dead stock',
                    value: 16,
                    color: AppColors.mintDeep,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (_shown(DashSection.liveOrders)) ...[
              const SectionTitle('Live Orders'),
              const SizedBox(height: 12),
              for (final order in DashboardData.liveOrders.take(3)) ...[
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

/// Left pill of the bottom bar: dark glass pill with an AI orb, like the reference.
class _InsightPill extends StatelessWidget {
  const _InsightPill({required this.onTap});

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
                      DashboardData.aiAlertsCount,
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

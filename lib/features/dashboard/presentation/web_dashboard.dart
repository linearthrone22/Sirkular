import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/data/user_repository.dart';
import '../data/dashboard_data.dart';
import 'ai_screens.dart';
import 'mobile_dashboard.dart' show statusColor;
import 'widgets/dashboard_charts.dart';
import 'widgets/dashboard_widgets.dart';

class WebDashboard extends StatelessWidget {
  const WebDashboard({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const _Sidebar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(user: user),
                  const SizedBox(height: 24),
                  _Row(
                    height: 300,
                    children: [
                      Expanded(
                        child: AiAlertBanner(
                          onTap: () => openInsights(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        flex: 2,
                        child: DashCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionTitle('Omnichannel Sales Performance'),
                              SizedBox(height: 16),
                              Expanded(
                                child: OmnichannelBarChart(
                                  data: DashboardData.channelSales,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(
                        child: KpiCard(
                          label: 'Total Revenue',
                          value: DashboardData.totalRevenue,
                          icon: Icons.account_balance_wallet_outlined,
                          color: AppColors.mintDeep,
                          badge: StatusBadge(
                            text: '+12%',
                            color: AppColors.mint,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: KpiCard(
                          label: 'Deadstock Saved',
                          value: DashboardData.deadstockSaved,
                          icon: Icons.eco_outlined,
                          color: AppColors.mintDeep,
                          badge: StatusBadge(
                            text: '+15%',
                            color: AppColors.mint,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: KpiCard(
                          label: 'Active Channels',
                          value: DashboardData.activeChannels,
                          icon: Icons.hub_outlined,
                          color: AppColors.orange,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: KpiCard(
                          label: 'AI Products Live',
                          value: DashboardData.aiProductsLive,
                          icon: Icons.auto_awesome,
                          color: AppColors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _Row(
                    height: 280,
                    children: [
                      Expanded(
                        flex: 2,
                        child: DashCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: SectionTitle('Inventory Health'),
                                  ),
                                  StatusBadge(
                                    text: '+15% Efficiency',
                                    color: AppColors.mint,
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Expanded(
                                child: InventoryHealthChart(
                                  values: DashboardData.inventoryHealth,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: DashCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionTitle('Waste Reduction Impact'),
                              SizedBox(height: 24),
                              WasteDonutChart(
                                usedPercent: DashboardData.wasteUsedPercent,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const DashCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionTitle('Live Sync Orders'),
                        SizedBox(height: 12),
                        _LiveOrdersTable(orders: DashboardData.liveOrders),
                      ],
                    ),
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

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: AppColors.sidebar,
      padding: const EdgeInsets.all(20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Brand(),
          SizedBox(height: 32),
          _NavItem(
            icon: Icons.grid_view_rounded,
            label: 'Dashboard',
            selected: true,
          ),
          _NavItem(
            icon: Icons.auto_awesome,
            label: 'AI R&D Copilot',
            aiAccent: true,
          ),
          _NavItem(icon: Icons.inventory_2_outlined, label: 'Master Inventory'),
          _NavItem(icon: Icons.hub_outlined, label: 'Omnichannel Hub'),
          _NavItem(icon: Icons.bar_chart_rounded, label: 'Analytics'),
          _NavItem(icon: Icons.settings_outlined, label: 'Settings'),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
        ),
        const SizedBox(width: 10),
        Text(
          'Sirkular',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.aiAccent = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool aiAccent;

  @override
  Widget build(BuildContext context) {
    final foreground =
        selected ? AppColors.sidebar : Colors.white.withValues(alpha: 0.75);
    final iconColor = selected
        ? AppColors.sidebar
        : (aiAccent ? AppColors.purpleLight : foreground);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? AppColors.mint : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (!selected) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Dashboard',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => startPhotoAnalysis(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.purple,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 48),
          ),
          icon: const Icon(Icons.auto_awesome, size: 18),
          label: const Text('Generate AI R&D'),
        ),
        const SizedBox(width: 12),
        UserAvatarMenu(user: user),
      ],
    );
  }
}

/// Fixed-height row that stretches its children to the same height.
class _Row extends StatelessWidget {
  const _Row({required this.height, required this.children});

  final double height;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }
}

class _LiveOrdersTable extends StatelessWidget {
  const _LiveOrdersTable({required this.orders});

  final List<LiveOrder> orders;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.muted,
        );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 40,
        dataRowMinHeight: 52,
        dataRowMaxHeight: 52,
        columnSpacing: 32,
        dividerThickness: 1,
        columns: [
          DataColumn(label: Text('Status', style: muted)),
          DataColumn(label: Text('Platform', style: muted)),
          DataColumn(label: Text('Item', style: muted)),
          DataColumn(label: Text('Total', style: muted)),
          DataColumn(label: Text('Waktu', style: muted)),
        ],
        rows: [
          for (final order in orders)
            DataRow(
              cells: [
                DataCell(
                  StatusBadge(
                    text: order.status,
                    color: statusColor(order.status),
                  ),
                ),
                DataCell(Text(order.platform)),
                DataCell(Text(order.item)),
                DataCell(Text(order.total)),
                DataCell(Text(order.time)),
              ],
            ),
        ],
      ),
    );
  }
}

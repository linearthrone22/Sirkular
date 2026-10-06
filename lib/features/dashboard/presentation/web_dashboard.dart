import 'package:flutter/material.dart';

import '../../../core/format/format.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/data/user_repository.dart';
import '../../inventory/presentation/inventory_page.dart';
import '../data/dashboard_service.dart';
import 'ai_screens.dart';
import 'insights_page.dart';
import 'mobile_dashboard.dart' show statusColor;
import 'widgets/dashboard_charts.dart';
import 'widgets/dashboard_widgets.dart';

class WebDashboard extends StatefulWidget {
  const WebDashboard({super.key, required this.user});

  final User user;

  @override
  State<WebDashboard> createState() => _WebDashboardState();
}

class _WebDashboardState extends State<WebDashboard> {
  final _service = DashboardService();
  late Future<DashboardSnapshot> _future = _service.load(widget.user.id);

  void _reload() {
    setState(() => _future = _service.load(widget.user.id));
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
                  _Header(
                    user: widget.user,
                    onInventory: () =>
                        _push(InventoryPage(userId: widget.user.id)),
                  ),
                  const SizedBox(height: 24),
                  _Row(
                    height: 300,
                    children: [
                      Expanded(
                        child: AiAlertBanner(
                          title: d.alertTitle ?? 'Semua aman hari ini',
                          body: d.alertBody ??
                              'Tidak ada peringatan baru dari AI.',
                          onTap: () => _push(
                            InsightsPage(userId: widget.user.id),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: DashCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionTitle(
                                  'Omnichannel Sales Performance'),
                              const SizedBox(height: 16),
                              Expanded(
                                child:
                                    OmnichannelBarChart(data: d.channelSales),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: KpiCard(
                          label: 'Pendapatan 30 Hari',
                          value: rupiah(d.revenue30DaysIdr),
                          icon: Icons.account_balance_wallet_outlined,
                          color: AppColors.mintDeep,
                          badge: StatusBadge(
                            text: '+${d.revenueGrowthPct}%',
                            color: AppColors.mint,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: KpiCard(
                          label: 'Deadstock Saved',
                          value: rupiah(d.deadstockSavedIdr),
                          icon: Icons.eco_outlined,
                          color: AppColors.mintDeep,
                          badge: StatusBadge(
                            text:
                                '${d.deadstockDelta >= 0 ? '+' : ''}${d.deadstockDelta.round()} kg',
                            color: AppColors.mint,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: KpiCard(
                          label: 'Active Channels',
                          value: '${d.activeChannels} Platform',
                          icon: Icons.hub_outlined,
                          color: AppColors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: KpiCard(
                          label: 'AI Products Live',
                          value: '${d.aiProductsLive}',
                          icon: Icons.auto_awesome,
                          color: AppColors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _Row(
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
                                  const Expanded(
                                    child: SectionTitle('Inventory Health'),
                                  ),
                                  StatusBadge(
                                    text: '+${d.efficiencyPct}% Efficiency',
                                    color: AppColors.mint,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: InventoryHealthChart(
                                  values: d.inventoryHealth,
                                  labels: d.healthDays,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DashCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionTitle('Waste Reduction Impact'),
                              const SizedBox(height: 24),
                              WasteDonutChart(usedPercent: d.wasteUsedPercent),
                            ],
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
                        const SectionTitle('Live Sync Orders'),
                        const SizedBox(height: 12),
                        _LiveOrdersTable(orders: d.liveOrders),
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
  const _Header({required this.user, required this.onInventory});

  final User user;
  final VoidCallback onInventory;

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
        OutlinedButton.icon(
          onPressed: onInventory,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.ink,
            minimumSize: const Size(0, 48),
          ),
          icon: const Icon(Icons.inventory_2_outlined, size: 18),
          label: const Text('Inventory'),
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

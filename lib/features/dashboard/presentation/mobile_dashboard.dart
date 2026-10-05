import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/data/user_repository.dart';
import '../data/dashboard_data.dart';
import 'ai_screens.dart';
import 'widgets/dashboard_widgets.dart';

class MobileDashboard extends StatelessWidget {
  const MobileDashboard({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final firstName = user.name.split(' ').first;

    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: _InsightPill(
                  onTap: () => openInsights(context),
                ),
              ),
              const SizedBox(width: 12),
              _CameraButton(
                onTap: () => startPhotoAnalysis(context),
              ),
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
                  icon: Icons.notifications_none_rounded,
                  onTap: () {
                    // TODO: notifications screen
                  },
                ),
                const SizedBox(width: 8),
                UserAvatarMenu(user: user),
              ],
            ),
            const SizedBox(height: 20),
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
                ],
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: const [
                KpiCard(
                  label: 'Pesanan Tokopedia',
                  value: DashboardData.tokopediaOrders,
                  icon: Icons.storefront_rounded,
                  color: AppColors.mint,
                ),
                KpiCard(
                  label: 'Pesanan Shopee',
                  value: DashboardData.shopeeOrders,
                  icon: Icons.shopping_bag_outlined,
                  color: AppColors.orange,
                ),
                KpiCard(
                  label: 'Deadstock Saved',
                  value: DashboardData.deadstockKg,
                  icon: Icons.eco_outlined,
                  color: AppColors.mint,
                ),
                KpiCard(
                  label: 'Sync Status',
                  value: DashboardData.syncStatus,
                  icon: Icons.sync_rounded,
                  color: AppColors.mintDeep,
                ),
              ],
            ),
            const SizedBox(height: 24),
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

/// Left pill of the bottom bar: AI alerts, opens the insights screen.
class _InsightPill extends StatelessWidget {
  const _InsightPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: AppColors.surface,
      elevation: 0,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.purple, AppColors.mintDeep],
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    DashboardData.aiAlertsCount,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Right button of the bottom bar: opens the camera for photo analysis.
class _CameraButton extends StatelessWidget {
  const _CameraButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.purple,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 60,
          height: 60,
          child: Icon(Icons.photo_camera_rounded, color: Colors.white),
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

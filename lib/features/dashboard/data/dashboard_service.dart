import 'package:flutter/material.dart';

import '../../../core/format/format.dart';
import '../../../core/theme/app_colors.dart';
import '../../inventory/data/inventory_repository.dart';
import 'dashboard_repository.dart';

/// Sections of the mobile dashboard that the user can show or hide.
enum DashSection { revenue, metrics, orders, stock, liveOrders }

class ChannelSales {
  const ChannelSales({
    required this.day,
    required this.tokopedia,
    required this.shopee,
    required this.pos,
  });

  final String day;
  final double tokopedia;
  final double shopee;
  final double pos;

  double get total => tokopedia + shopee + pos;
}

class LiveOrder {
  const LiveOrder({
    required this.status,
    required this.platform,
    required this.item,
    required this.total,
    required this.time,
  });

  final String status;
  final String platform;
  final String item;
  final String total;
  final String time;
}

class StockBreakdown {
  const StockBreakdown({
    required this.inStock,
    required this.low,
    required this.out,
    required this.dead,
  });

  final int inStock;
  final int low;
  final int out;
  final int dead;

  int get total => inStock + low + out + dead;
}

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.revenue30DaysIdr,
    required this.revenueTargetIdr,
    required this.revenueGrowthPct,
    required this.efficiencyPct,
    required this.tokopediaOrders,
    required this.tokopediaDelta,
    required this.tokopediaTrend,
    required this.shopeeOrders,
    required this.shopeeDelta,
    required this.shopeeTrend,
    required this.deadstockKg,
    required this.deadstockDelta,
    required this.deadstockTrend,
    required this.deadstockSavedIdr,
    required this.syncOk,
    required this.activeChannels,
    required this.aiProductsLive,
    required this.wasteUsedPercent,
    required this.channelSales,
    required this.inventoryHealth,
    required this.healthDays,
    required this.dikemasCount,
    required this.dikirimCount,
    required this.liveOrders,
    required this.stock,
    required this.alertCount,
    required this.alertTitle,
    required this.alertBody,
    required this.hidden,
  });

  final int revenue30DaysIdr;
  final int revenueTargetIdr;
  final int revenueGrowthPct;
  final int efficiencyPct;
  final int tokopediaOrders;
  final int tokopediaDelta;
  final List<double> tokopediaTrend;
  final int shopeeOrders;
  final int shopeeDelta;
  final List<double> shopeeTrend;
  final double deadstockKg;
  final double deadstockDelta;
  final List<double> deadstockTrend;
  final int deadstockSavedIdr;
  final bool syncOk;
  final int activeChannels;
  final int aiProductsLive;
  final int wasteUsedPercent;
  final List<ChannelSales> channelSales;
  final List<double> inventoryHealth;
  final List<String> healthDays;
  final int dikemasCount;
  final int dikirimCount;
  final List<LiveOrder> liveOrders;
  final StockBreakdown stock;
  final int alertCount;
  final String? alertTitle;
  final String? alertBody;
  final Set<DashSection> hidden;
}

/// Numbers and copy for one platform's analytics page.
class PlatformAnalytics {
  const PlatformAnalytics({
    required this.key,
    required this.name,
    required this.color,
    required this.overview,
    required this.conversionRate,
    required this.conversionNote,
    required this.visits,
    required this.keywords,
    required this.adsBudget,
    required this.adsSpent,
    required this.retentionLabels,
    required this.retentionValues,
    required this.retentionNote,
    required this.peakLabels,
    required this.peakValues,
    required this.peakNote,
    required this.autoReplyOn,
    required this.voucherOn,
  });

  final String key;
  final String name;
  final Color color;
  final String overview;
  final String conversionRate;
  final String conversionNote;
  final String visits;
  final List<AdKeyword> keywords;
  final int adsBudget;
  final int adsSpent;
  final List<String> retentionLabels;
  final List<double> retentionValues;
  final String retentionNote;
  final List<String> peakLabels;
  final List<double> peakValues;
  final String peakNote;
  final bool autoReplyOn;
  final bool voucherOn;
}

class AdKeyword {
  const AdKeyword({
    required this.keyword,
    required this.clicks,
    required this.spend,
    required this.roas,
  });

  final String keyword;
  final int clicks;
  final int spend;
  final String roas;
}

String platformName(String key) {
  switch (key) {
    case 'tokopedia':
      return 'Tokopedia';
    case 'shopee':
      return 'Shopee';
    case 'gofood':
      return 'GoFood';
    case 'offline':
      return 'Offline';
    case 'tiktok':
      return 'TikTok Shop';
    case 'pos':
      return 'POS';
    default:
      return key;
  }
}

/// Reads everything the dashboard shows from SQLite.
class DashboardService {
  DashboardService(
      {DashboardRepository? dashboard, InventoryRepository? inventory})
      : _dashboard = dashboard ?? DashboardRepository(),
        _inventory = inventory ?? InventoryRepository();

  final DashboardRepository _dashboard;
  final InventoryRepository _inventory;

  Future<DashboardSnapshot> load(int userId, {DateTime? now}) async {
    final clock = now ?? DateTime.now();
    final today = dayKey(clock);
    final yesterday = dayKey(clock.subtract(const Duration(days: 1)));

    final tokopedia = await _dashboard.dailyStats(userId, 'tokopedia');
    final shopee = await _dashboard.dailyStats(userId, 'shopee');
    final pos = await _dashboard.dailyStats(userId, 'pos');

    int ordersOn(List<DailyPlatformStats> list, String day) =>
        list.where((s) => s.day == day).fold(0, (sum, s) => sum + s.orders);

    final tokopediaToday = ordersOn(tokopedia, today);
    final shopeeToday = ordersOn(shopee, today);

    final channelSales = [
      for (final s in tokopedia)
        ChannelSales(
          day: weekdayShort(DateTime.parse(s.day)),
          tokopedia: ordersOn(tokopedia, s.day).toDouble(),
          shopee: ordersOn(shopee, s.day).toDouble(),
          pos: ordersOn(pos, s.day).toDouble(),
        ),
    ];

    final revenue30 = await _dashboard.revenueSince(
      userId,
      dayKey(clock.subtract(const Duration(days: 29))),
    );

    final deadstockKg = await _dashboard.latestKpi(userId, 'deadstock_kg') ?? 0;
    final deadstockYesterday =
        await _dashboard.kpiOn(userId, yesterday, 'deadstock_kg') ??
            deadstockKg;

    final items = await _inventory.items(userId, now: clock);
    var inStock = 0, low = 0, out = 0, dead = 0;
    for (final item in items) {
      if (item.stock == 0) {
        out++;
      } else if (item.soldLast30d < 10) {
        dead++;
      } else if (item.stock < 10) {
        low++;
      } else {
        inStock++;
      }
    }

    final counts = await _dashboard.orderCountsByStatus(userId);
    final recent = await _dashboard.recentOrders(userId, limit: 5);

    final insights = await _dashboard.insights(userId, limit: 20);
    final alerts = insights.where((i) => i.tone == 'alert').toList();
    final alert = alerts.isEmpty ? null : alerts.first;

    final prefs = await _dashboard.dashboardPrefs(userId);
    final hidden = <DashSection>{
      for (final section in DashSection.values)
        if (prefs[section.name] == false) section,
    };

    final healthValues = await _dashboard.kpiSeries(userId, 'inventory_health');
    final healthDays = [
      for (var i = healthValues.length - 1; i >= 0; i--)
        weekdayShort(clock.subtract(Duration(days: i))),
    ];

    return DashboardSnapshot(
      revenue30DaysIdr: revenue30,
      revenueTargetIdr:
          (await _dashboard.latestKpi(userId, 'revenue_target') ?? 0).round(),
      revenueGrowthPct:
          (await _dashboard.latestKpi(userId, 'revenue_growth_pct') ?? 0)
              .round(),
      efficiencyPct:
          (await _dashboard.latestKpi(userId, 'efficiency_pct') ?? 0).round(),
      tokopediaOrders: tokopediaToday,
      tokopediaDelta: tokopediaToday - ordersOn(tokopedia, yesterday),
      tokopediaTrend: [for (final s in tokopedia) s.orders.toDouble()],
      shopeeOrders: shopeeToday,
      shopeeDelta: shopeeToday - ordersOn(shopee, yesterday),
      shopeeTrend: [for (final s in shopee) s.orders.toDouble()],
      deadstockKg: deadstockKg,
      deadstockDelta: deadstockKg - deadstockYesterday,
      deadstockTrend: await _dashboard.kpiSeries(userId, 'deadstock_kg'),
      deadstockSavedIdr:
          (await _dashboard.latestKpi(userId, 'deadstock_saved_idr') ?? 0)
              .round(),
      syncOk: (await _dashboard.latestKpi(userId, 'sync_ok') ?? 0) == 1,
      activeChannels:
          (await _dashboard.latestKpi(userId, 'active_channels') ?? 0).round(),
      aiProductsLive:
          (await _dashboard.latestKpi(userId, 'ai_products_live') ?? 0).round(),
      wasteUsedPercent:
          (await _dashboard.latestKpi(userId, 'waste_used_percent') ?? 0)
              .round(),
      channelSales: channelSales,
      inventoryHealth: healthValues,
      healthDays: healthDays,
      dikemasCount: counts['dikemas'] ?? 0,
      dikirimCount: counts['dikirim'] ?? 0,
      liveOrders: [
        for (final o in recent)
          LiveOrder(
            status: _capitalize(o.status),
            platform: platformName(o.platform),
            item: o.itemName,
            total: rupiah(o.totalIdr),
            time: clockTime(o.orderedAt),
          ),
      ],
      stock: StockBreakdown(inStock: inStock, low: low, out: out, dead: dead),
      alertCount: alerts.length,
      alertTitle: alert?.title,
      alertBody: alert?.body,
      hidden: hidden,
    );
  }

  /// Analytics for one platform over the last 30 days, plus today's ads.
  Future<PlatformAnalytics> platform(
    int userId,
    String key, {
    DateTime? now,
  }) async {
    final clock = now ?? DateTime.now();
    final stats = await _dashboard.dailyStats(userId, key, days: 30);
    final orders = stats.fold(0, (sum, s) => sum + s.orders);
    final visits = stats.fold(0, (sum, s) => sum + s.visits);
    final conversion = visits == 0 ? 0.0 : orders / visits;
    final today = stats.where((s) => s.day == dayKey(clock)).firstOrNull;
    final settings = await _dashboard.platformSettings(userId, key);

    final keywordRows =
        await _dashboard.keywordStats(userId, key, dayKey(clock));
    final keywords = [
      for (final r in keywordRows)
        AdKeyword(
          keyword: r['keyword'] as String,
          clicks: r['clicks'] as int,
          spend: r['spend_idr'] as int,
          roas: _roas(r['revenue_idr'] as int, r['spend_idr'] as int),
        ),
    ];

    final retention = await _dashboard.seriesPoints(userId, key, 'retention');
    final peaks = await _dashboard.seriesPoints(userId, key, 'peak_hour');
    final peakTop = peaks.isEmpty
        ? null
        : peaks.reduce((a, b) => a.value >= b.value ? a : b);
    final lastRetention = retention.isEmpty ? 0.0 : retention.last.value;

    final name = platformName(key);
    return PlatformAnalytics(
      key: key,
      name: name,
      color: key == 'shopee' ? AppColors.orange : AppColors.mintDeep,
      overview: 'Hari ini $name menyumbang ${today?.orders ?? 0} pesanan. '
          'Dalam 30 hari terakhir ada $orders pesanan dari ${groupThousands(visits)} kunjungan toko.',
      conversionRate:
          '${(conversion * 100).toStringAsFixed(1).replaceAll('.', ',')}%',
      conversionNote: visits == 0
          ? 'Belum ada data kunjungan toko.'
          : 'Dari ${groupThousands(visits)} kunjungan toko dalam 30 hari, $orders berubah menjadi pesanan.',
      visits: groupThousands(visits),
      keywords: keywords,
      adsBudget: settings.adBudgetIdr,
      adsSpent: today?.adSpendIdr ?? 0,
      retentionLabels: [for (final p in retention) p.key],
      retentionValues: [for (final p in retention) p.value],
      retentionNote:
          '${lastRetention.round()}% pembeli kembali dalam ${retention.length} minggu terakhir.',
      peakLabels: [for (final p in peaks) p.key],
      peakValues: [for (final p in peaks) p.value],
      peakNote: peakTop == null
          ? 'Belum ada data jam belanja.'
          : 'Puncak pesanan ada di sekitar pukul ${peakTop.key}. Pastikan stok sudah dikemas sebelum jam itu.',
      autoReplyOn: settings.autoReply,
      voucherOn: settings.voucherOn,
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  static String _roas(int revenue, int spend) {
    if (spend == 0) return '-';
    return '${(revenue / spend).toStringAsFixed(1).replaceAll('.', ',')}x';
  }
}

import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';

class InsightRecord {
  const InsightRecord({
    required this.id,
    required this.category,
    required this.tone,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.source,
    required this.createdAt,
    required this.readAt,
  });

  factory InsightRecord.fromRow(Map<String, Object?> row) {
    return InsightRecord(
      id: row['id'] as int,
      category: row['category'] as String,
      tone: row['tone'] as String,
      title: row['title'] as String,
      body: row['body'] as String,
      actionLabel: row['action_label'] as String,
      source: row['source'] as String,
      createdAt: row['created_at'] as String,
      readAt: row['read_at'] as String?,
    );
  }

  final int id;
  final String category;
  final String tone;
  final String title;
  final String body;
  final String actionLabel;
  final String source;
  final String createdAt;
  final String? readAt;
}

class DailyPlatformStats {
  const DailyPlatformStats({
    required this.day,
    required this.visits,
    required this.orders,
    required this.revenueIdr,
    required this.adSpendIdr,
  });

  final String day;
  final int visits;
  final int orders;
  final int revenueIdr;
  final int adSpendIdr;

  /// Orders divided by visits, or 0 when there were no visits.
  double get conversionRate => visits == 0 ? 0 : orders / visits;
}

class PlatformSettingsRecord {
  const PlatformSettingsRecord({
    this.autoReply = false,
    this.voucherOn = false,
    this.adBudgetIdr = 0,
  });

  final bool autoReply;
  final bool voucherOn;
  final int adBudgetIdr;
}

class OrderRecord {
  const OrderRecord({
    required this.id,
    required this.platform,
    required this.itemName,
    required this.totalIdr,
    required this.status,
    required this.orderedAt,
  });

  factory OrderRecord.fromRow(Map<String, Object?> row) {
    return OrderRecord(
      id: row['id'] as int,
      platform: row['platform'] as String,
      itemName: row['item_name'] as String,
      totalIdr: row['total_idr'] as int,
      status: row['status'] as String,
      orderedAt: row['ordered_at'] as String,
    );
  }

  final int id;
  final String platform;
  final String itemName;
  final int totalIdr;
  final String status;
  final String orderedAt;
}

/// Insights, orders, platform analytics, platform settings, and dashboard
/// layout preferences.
class DashboardRepository {
  DashboardRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<Database> get _db => _database.database;

  // Insights

  Future<int> addInsight(
    int userId, {
    required String category,
    required String tone,
    required String title,
    required String body,
    required String actionLabel,
    String source = 'rule',
    String? createdAt,
  }) async {
    final db = await _db;
    return db.insert('insights', {
      'user_id': userId,
      'category': category,
      'tone': tone,
      'title': title,
      'body': body,
      'action_label': actionLabel,
      'source': source,
      'created_at': createdAt ?? AppDatabase.now(),
    });
  }

  /// Insights not dismissed, newest first.
  Future<List<InsightRecord>> insights(int userId, {int limit = 50}) async {
    final db = await _db;
    final rows = await db.query(
      'insights',
      where: 'user_id = ? AND dismissed_at IS NULL',
      whereArgs: [userId],
      orderBy: 'created_at DESC, id DESC',
      limit: limit,
    );
    return rows.map(InsightRecord.fromRow).toList();
  }

  Future<void> markInsightRead(int insightId) async {
    final db = await _db;
    await db.update(
      'insights',
      {'read_at': AppDatabase.now()},
      where: 'id = ? AND read_at IS NULL',
      whereArgs: [insightId],
    );
  }

  Future<void> dismissInsight(int insightId) async {
    final db = await _db;
    await db.update(
      'insights',
      {'dismissed_at': AppDatabase.now()},
      where: 'id = ?',
      whereArgs: [insightId],
    );
  }

  // Orders

  Future<int> addOrder(
    int userId, {
    required String platform,
    required String itemName,
    required int totalIdr,
    String? externalRef,
    int? itemId,
    String status = 'dikemas',
    String? orderedAt,
  }) async {
    final db = await _db;
    final now = AppDatabase.now();
    return db.insert('orders', {
      'user_id': userId,
      'platform': platform,
      'external_ref': externalRef,
      'item_id': itemId,
      'item_name': itemName,
      'total_idr': totalIdr,
      'status': status,
      'ordered_at': orderedAt ?? now,
      'updated_at': now,
    });
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    final db = await _db;
    await db.update(
      'orders',
      {'status': status, 'updated_at': AppDatabase.now()},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<List<OrderRecord>> recentOrders(int userId, {int limit = 20}) async {
    final db = await _db;
    final rows = await db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'ordered_at DESC, id DESC',
      limit: limit,
    );
    return rows.map(OrderRecord.fromRow).toList();
  }

  /// Counts of orders per status, for the status cards.
  Future<Map<String, int>> orderCountsByStatus(int userId) async {
    final db = await _db;
    final rows = await db.rawQuery(
      'SELECT status, COUNT(*) AS n FROM orders WHERE user_id = ? GROUP BY status',
      [userId],
    );
    return {for (final r in rows) r['status'] as String: r['n'] as int};
  }

  // Platform analytics

  /// Writes or replaces the stats for one platform on one day.
  Future<void> upsertDailyStats(
    int userId, {
    required String platform,
    required String day,
    required int visits,
    required int orders,
    required int revenueIdr,
    required int adSpendIdr,
  }) async {
    final db = await _db;
    await db.insert(
      'platform_daily_stats',
      {
        'user_id': userId,
        'platform': platform,
        'day': day,
        'visits': visits,
        'orders': orders,
        'revenue_idr': revenueIdr,
        'ad_spend_idr': adSpendIdr,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Stats for the last [days] days, oldest first.
  Future<List<DailyPlatformStats>> dailyStats(
    int userId,
    String platform, {
    int days = 7,
  }) async {
    final db = await _db;
    final rows = await db.query(
      'platform_daily_stats',
      where: 'user_id = ? AND platform = ?',
      whereArgs: [userId, platform],
      orderBy: 'day DESC',
      limit: days,
    );
    return [
      for (final r in rows.reversed)
        DailyPlatformStats(
          day: r['day'] as String,
          visits: r['visits'] as int,
          orders: r['orders'] as int,
          revenueIdr: r['revenue_idr'] as int,
          adSpendIdr: r['ad_spend_idr'] as int,
        ),
    ];
  }

  Future<void> upsertKeywordStats(
    int userId, {
    required String platform,
    required String day,
    required String keyword,
    required int clicks,
    required int spendIdr,
    required int revenueIdr,
  }) async {
    final db = await _db;
    await db.insert(
      'platform_keyword_stats',
      {
        'user_id': userId,
        'platform': platform,
        'day': day,
        'keyword': keyword,
        'clicks': clicks,
        'spend_idr': spendIdr,
        'revenue_idr': revenueIdr,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Top keywords for one platform on one day, by clicks.
  Future<List<Map<String, Object?>>> keywordStats(
    int userId,
    String platform,
    String day, {
    int limit = 10,
  }) async {
    final db = await _db;
    return db.query(
      'platform_keyword_stats',
      where: 'user_id = ? AND platform = ? AND day = ?',
      whereArgs: [userId, platform, day],
      orderBy: 'clicks DESC',
      limit: limit,
    );
  }

  // Platform settings

  /// Settings for one platform. Returns defaults if nothing is saved yet.
  Future<PlatformSettingsRecord> platformSettings(
    int userId,
    String platform,
  ) async {
    final db = await _db;
    final rows = await db.query(
      'platform_settings',
      where: 'user_id = ? AND platform = ?',
      whereArgs: [userId, platform],
      limit: 1,
    );
    if (rows.isEmpty) return const PlatformSettingsRecord();
    final row = rows.first;
    return PlatformSettingsRecord(
      autoReply: (row['auto_reply'] as int) == 1,
      voucherOn: (row['voucher_on'] as int) == 1,
      adBudgetIdr: row['ad_budget_idr'] as int,
    );
  }

  Future<void> savePlatformSettings(
    int userId,
    String platform,
    PlatformSettingsRecord settings,
  ) async {
    final db = await _db;
    await db.insert(
      'platform_settings',
      {
        'user_id': userId,
        'platform': platform,
        'auto_reply': settings.autoReply ? 1 : 0,
        'voucher_on': settings.voucherOn ? 1 : 0,
        'ad_budget_idr': settings.adBudgetIdr,
        'updated_at': AppDatabase.now(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Dashboard layout

  /// Section name to visible flag. Sections not saved default to visible.
  Future<Map<String, bool>> dashboardPrefs(int userId) async {
    final db = await _db;
    final rows = await db.query(
      'dashboard_prefs',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return {
      for (final r in rows) r['section'] as String: (r['visible'] as int) == 1,
    };
  }

  Future<void> setDashboardPref(
    int userId,
    String section, {
    required bool visible,
  }) async {
    final db = await _db;
    await db.insert(
      'dashboard_prefs',
      {
        'user_id': userId,
        'section': section,
        'visible': visible ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Business KPIs: one value per metric per day.

  Future<void> setKpi(
    int userId,
    String day,
    String metric,
    double value,
  ) async {
    final db = await _db;
    await db.insert(
      'business_kpis',
      {'user_id': userId, 'day': day, 'metric': metric, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Value of [metric] on [day], or null if none was recorded that day.
  Future<double?> kpiOn(int userId, String day, String metric) async {
    final db = await _db;
    final rows = await db.query(
      'business_kpis',
      columns: ['value'],
      where: 'user_id = ? AND day = ? AND metric = ?',
      whereArgs: [userId, day, metric],
      limit: 1,
    );
    return rows.isEmpty ? null : (rows.first['value'] as num).toDouble();
  }

  /// Most recent value of [metric], or null if none was ever recorded.
  Future<double?> latestKpi(int userId, String metric) async {
    final db = await _db;
    final rows = await db.query(
      'business_kpis',
      columns: ['value'],
      where: 'user_id = ? AND metric = ?',
      whereArgs: [userId, metric],
      orderBy: 'day DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : (rows.first['value'] as num).toDouble();
  }

  /// Values of [metric] for the last [days] days, oldest first.
  Future<List<double>> kpiSeries(
    int userId,
    String metric, {
    int days = 7,
  }) async {
    final db = await _db;
    final rows = await db.query(
      'business_kpis',
      columns: ['value'],
      where: 'user_id = ? AND metric = ?',
      whereArgs: [userId, metric],
      orderBy: 'day DESC',
      limit: days,
    );
    return [
      for (final r in rows.reversed) (r['value'] as num).toDouble(),
    ];
  }

  // Revenue

  /// Sum of platform revenue from [fromDay] (inclusive) to today.
  Future<int> revenueSince(int userId, String fromDay) async {
    final db = await _db;
    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM(revenue_idr), 0) AS total FROM platform_daily_stats '
      'WHERE user_id = ? AND day >= ?',
      [userId, fromDay],
    );
    return (rows.first['total'] as num).toInt();
  }

  // Platform time series: retention by week and busiest hours.

  Future<void> setSeriesPoint(
    int userId,
    String platform, {
    required String series,
    required int position,
    required String label,
    required double value,
  }) async {
    final db = await _db;
    await db.insert(
      'platform_series',
      {
        'user_id': userId,
        'platform': platform,
        'series': series,
        'position': position,
        'label': label,
        'value': value,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Points of one series, in position order.
  Future<List<MapEntry<String, double>>> seriesPoints(
    int userId,
    String platform,
    String series,
  ) async {
    final db = await _db;
    final rows = await db.query(
      'platform_series',
      columns: ['label', 'value'],
      where: 'user_id = ? AND platform = ? AND series = ?',
      whereArgs: [userId, platform, series],
      orderBy: 'position',
    );
    return [
      for (final r in rows)
        MapEntry(r['label'] as String, (r['value'] as num).toDouble()),
    ];
  }
}

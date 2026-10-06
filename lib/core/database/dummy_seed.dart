import '../../features/auth/data/user_repository.dart';
import '../../features/dashboard/data/dashboard_repository.dart';
import '../../features/inventory/data/inventory_repository.dart';
import '../../features/inventory/data/recipe_data.dart';
import '../../features/inventory/data/recipe_repository.dart';
import '../format/format.dart';
import 'app_database.dart';

/// A demo account that gets the dummy data.
class SeedAccount {
  const SeedAccount({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;
}

/// Creates the demo accounts and writes the dummy data into SQLite.
/// Each account is created only if missing, and gets data only if it has no
/// products yet, so running it again changes nothing.
class DummySeed {
  DummySeed({AppDatabase? database}) : _db = database ?? AppDatabase.instance;

  static const johanes = SeedAccount(
    name: 'Johanes',
    email: 'johanes@gmail.com',
    password: 'sirkular123',
  );
  static const jovan = SeedAccount(
    name: 'Jovan',
    email: 'jovan@gmail.com',
    password: 'sirkular123',
  );

  static const accounts = [johanes, jovan];

  static const email = 'johanes@gmail.com';
  static const password = 'sirkular123';

  final AppDatabase _db;

  /// Makes sure Johanes exists and has the dummy data. Creates the account
  /// only if it is missing, so an existing account keeps its password. The
  /// data is written only when the account has no products yet.
  /// Seeds every demo account.
  Future<void> ensureAllSeeded({DateTime? now}) async {
    for (final account in accounts) {
      await ensureAccountSeeded(account, now: now);
    }
  }

  /// Seeds Johanes only.
  Future<void> ensureSeeded({DateTime? now}) =>
      ensureAccountSeeded(johanes, now: now);

  Future<void> ensureAccountSeeded(SeedAccount account, {DateTime? now}) async {
    final d = await _db.database;
    final existing = await d.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [account.email],
      limit: 1,
    );

    final int userId;
    if (existing.isNotEmpty) {
      userId = existing.first['id'] as int;
    } else {
      final user = await UserRepository(database: _db).register(
        name: account.name,
        email: account.email,
        password: account.password,
      );
      userId = user.id;
    }

    final products = await d.rawQuery(
      'SELECT COUNT(*) AS n FROM inventory_items WHERE user_id = ?',
      [userId],
    );
    if ((products.first['n'] as int) > 0) return;

    await _seedData(userId, now ?? DateTime.now());
  }

  Future<void> _seedData(int userId, DateTime clock) async {
    final dashboard = DashboardRepository(database: _db);
    final inventory = InventoryRepository(database: _db);
    final recipes = RecipeRepository(database: _db);

    await _seedPlatforms(dashboard, userId, clock);
    await _seedKpis(dashboard, userId, clock);
    await _seedInsights(dashboard, userId, clock);
    await _seedOrders(dashboard, userId, clock);
    final itemIds = await _seedInventory(inventory, userId);
    await _seedRecipes(recipes, userId, [
      itemIds['Roti Tawar Sisa']!,
      itemIds['Susu UHT 1L']!,
    ]);
  }

  // Platforms: 30 days of orders, visits, revenue, and ad spend.

  /// Orders for the last 7 days, oldest first. The last value is today.
  static const _tokopediaRecent = [12, 18, 15, 22, 28, 22, 24];
  static const _shopeeRecent = [8, 10, 12, 14, 18, 21, 18];
  static const _posRecent = [6, 7, 9, 8, 12, 15, 11];

  /// Revenue for the last 30 days (the dashboard's "Pendapatan" card).
  static const _revenue30Days = 23876000;

  Future<void> _seedPlatforms(
    DashboardRepository dashboard,
    int userId,
    DateTime now,
  ) async {
    final channels = [
      _Channel(
        key: 'tokopedia',
        conversion: 0.038,
        avgOrderIdr: 16000,
        recent: _tokopediaRecent,
        olderOrders: (i) => 14 + (i * 5) % 11,
        todayAdSpend: 138000,
        olderAdSpend: (i) => 90000 + (i * 7000) % 60000,
      ),
      _Channel(
        key: 'shopee',
        conversion: 0.044,
        avgOrderIdr: 14000,
        recent: _shopeeRecent,
        olderOrders: (i) => 9 + (i * 3) % 8,
        todayAdSpend: 110400,
        olderAdSpend: (i) => 80000 + (i * 5000) % 40000,
      ),
      _Channel(
        key: 'pos',
        conversion: 0,
        avgOrderIdr: 12000,
        recent: _posRecent,
        olderOrders: (i) => 5 + (i * 2) % 7,
        todayAdSpend: 0,
        olderAdSpend: (_) => 0,
      ),
    ];

    // Build 30 days per channel. Revenue is scaled at the end so the total
    // matches the dummy figure exactly.
    final days = List.generate(30, (i) => now.subtract(Duration(days: 29 - i)));
    final rows = <_DayRow>[];
    for (final channel in channels) {
      for (var i = 0; i < 30; i++) {
        final isRecent = i >= 23;
        final orders =
            isRecent ? channel.recent[i - 23] : channel.olderOrders(i);
        final adSpend = isRecent && i == 29
            ? channel.todayAdSpend
            : channel.olderAdSpend(i);
        rows.add(_DayRow(
          channel: channel,
          day: days[i],
          orders: orders,
          adSpend: adSpend,
        ));
      }
    }

    final raw =
        rows.fold<int>(0, (sum, r) => sum + r.orders * r.channel.avgOrderIdr);
    final correction = _revenue30Days - raw;
    final todayTokopedia = rows.lastWhere(
      (r) => r.channel.key == 'tokopedia' && r.day == days.last,
    );

    for (final row in rows) {
      var revenue = row.orders * row.channel.avgOrderIdr;
      if (identical(row, todayTokopedia)) revenue += correction;
      await dashboard.upsertDailyStats(
        userId,
        platform: row.channel.key,
        day: dayKey(row.day),
        visits: row.channel.conversion == 0
            ? 0
            : (row.orders / row.channel.conversion).round(),
        orders: row.orders,
        revenueIdr: revenue,
        adSpendIdr: row.adSpend,
      );
    }

    // Today's keyword performance. Spend sums to today's ad spend per platform.
    final keywords = {
      'tokopedia': [
        ('roti sisa murah', 412, 58000, 4.2),
        ('roti tawar sisa', 298, 42000, 3.6),
        ('muffin roti', 176, 25000, 2.9),
        ('pudding roti', 92, 13000, 1.8),
      ],
      'shopee': [
        ('roti sisa', 356, 52000, 3.9),
        ('roti murah jakarta', 241, 36000, 3.1),
        ('crumble roti', 134, 15000, 2.2),
        ('kemasan box roti', 58, 7400, 1.4),
      ],
    };
    for (final entry in keywords.entries) {
      for (final (keyword, clicks, spend, roas) in entry.value) {
        await dashboard.upsertKeywordStats(
          userId,
          platform: entry.key,
          day: dayKey(now),
          keyword: keyword,
          clicks: clicks,
          spendIdr: spend,
          revenueIdr: (spend * roas).round(),
        );
      }
    }

    await dashboard.savePlatformSettings(
      userId,
      'tokopedia',
      const PlatformSettingsRecord(
        autoReply: true,
        voucherOn: true,
        adBudgetIdr: 150000,
      ),
    );
    await dashboard.savePlatformSettings(
      userId,
      'shopee',
      const PlatformSettingsRecord(
        autoReply: true,
        voucherOn: false,
        adBudgetIdr: 120000,
      ),
    );

    // Retention (buyers returning per week) and busiest hours.
    const weeks = ['Mg 1', 'Mg 2', 'Mg 3', 'Mg 4', 'Mg 5', 'Mg 6'];
    const hours = ['08', '11', '14', '17', '20', '23'];
    final retention = {
      'tokopedia': [18, 22, 27, 31, 34, 38],
      'shopee': [14, 19, 21, 24, 26, 29],
    };
    final peaks = {
      'tokopedia': [4, 9, 6, 11, 18, 7],
      'shopee': [3, 7, 8, 9, 14, 10],
    };
    for (final platform in ['tokopedia', 'shopee']) {
      for (var i = 0; i < weeks.length; i++) {
        await dashboard.setSeriesPoint(
          userId,
          platform,
          series: 'retention',
          position: i,
          label: weeks[i],
          value: retention[platform]![i].toDouble(),
        );
      }
      for (var i = 0; i < hours.length; i++) {
        await dashboard.setSeriesPoint(
          userId,
          platform,
          series: 'peak_hour',
          position: i,
          label: hours[i],
          value: peaks[platform]![i].toDouble(),
        );
      }
    }
  }

  // Business KPIs shown on the dashboard cards.

  Future<void> _seedKpis(
    DashboardRepository dashboard,
    int userId,
    DateTime now,
  ) async {
    final today = dayKey(now);
    final yesterday = dayKey(now.subtract(const Duration(days: 1)));

    await dashboard.setKpi(userId, today, 'revenue_target', 30000000);
    await dashboard.setKpi(userId, today, 'revenue_growth_pct', 12);
    await dashboard.setKpi(userId, today, 'efficiency_pct', 15);
    await dashboard.setKpi(userId, today, 'deadstock_saved_idr', 1450000);
    await dashboard.setKpi(userId, today, 'waste_used_percent', 85);
    await dashboard.setKpi(userId, today, 'sync_ok', 1);
    await dashboard.setKpi(userId, today, 'active_channels', 4);
    await dashboard.setKpi(userId, today, 'ai_products_live', 12);
    await dashboard.setKpi(userId, yesterday, 'deadstock_kg', 13);
    await dashboard.setKpi(userId, today, 'deadstock_kg', 15);

    const health = [72, 68, 75, 70, 81, 79, 88];
    for (var i = 0; i < health.length; i++) {
      final day = dayKey(now.subtract(Duration(days: health.length - 1 - i)));
      await dashboard.setKpi(
          userId, day, 'inventory_health', health[i].toDouble());
    }
  }

  // Insights, newest first.

  static const _insights = <_InsightSeed>[
    _InsightSeed(
      title: 'Roti tawar mendekati kedaluwarsa',
      body:
          '15 kg expired dalam 2 hari. Diskon 30% disarankan untuk Shopee dan Tokopedia.',
      category: 'Stok',
      tone: 'alert',
      action: 'Terapkan diskon',
    ),
    _InsightSeed(
      title: 'Resep turunan siap dibuat',
      body:
          'AI menemukan 3 resep dari bahan deadstock dengan potensi profit Rp 350.000.',
      category: 'AI R&D',
      tone: 'info',
      action: 'Lihat resep',
    ),
    _InsightSeed(
      title: 'Penjualan Tokopedia naik 15%',
      body: 'Sabtu jadi puncak pesanan. Tambah stok muffin untuk akhir pekan.',
      category: 'Penjualan',
      tone: 'success',
      action: 'Atur stok',
    ),
    _InsightSeed(
      title: 'Stok tepung hampir habis',
      body: 'Sisa 7 kg, cukup untuk 3 hari produksi. Buat PO sebelum Kamis.',
      category: 'Stok',
      tone: 'alert',
      action: 'Buat PO',
    ),
    _InsightSeed(
      title: 'Iklan Shopee cepat habis',
      body:
          'Anggaran iklan sudah terpakai 92% sebelum sore. Turunkan bid kata kunci "roti sisa".',
      category: 'Iklan',
      tone: 'info',
      action: 'Buka iklan',
    ),
    _InsightSeed(
      title: 'Deadstock terselamatkan',
      body: '15 kg bahan berhasil dijual ulang bulan ini, setara Rp 1.450.000.',
      category: 'Sirkular',
      tone: 'success',
      action: 'Lihat laporan',
    ),
    _InsightSeed(
      title: 'Susu UHT hampir expired',
      body:
          '4 L susu sisa 3 hari lagi. Jadikan Pudding Roti untuk menghabiskan stok.',
      category: 'Stok',
      tone: 'info',
      action: 'Buat resep',
    ),
    _InsightSeed(
      title: 'Konversi chat Shopee membaik',
      body: 'Auto-reply menaikkan konversi chat dari 40% ke 52% minggu ini.',
      category: 'Pelanggan',
      tone: 'success',
      action: 'Lihat detail',
    ),
  ];

  Future<void> _seedInsights(
    DashboardRepository dashboard,
    int userId,
    DateTime now,
  ) async {
    // Created a minute apart, so the first entry is the newest.
    for (var i = 0; i < _insights.length; i++) {
      final item = _insights[i];
      await dashboard.addInsight(
        userId,
        category: item.category,
        tone: item.tone,
        title: item.title,
        body: item.body,
        actionLabel: item.action,
        createdAt: now.subtract(Duration(minutes: i)).toIso8601String(),
      );
    }
  }

  // Orders: today's live orders plus recent history.

  Future<void> _seedOrders(
    DashboardRepository dashboard,
    int userId,
    DateTime now,
  ) async {
    DateTime at(int hour, int minute) =>
        DateTime(now.year, now.month, now.day, hour, minute);

    final live = [
      (
        'Muffin Roti Sisa - AI Recipe',
        'tokopedia',
        85000,
        'dikemas',
        at(10, 42)
      ),
      ('Roti Tawar Potong Pinggir', 'shopee', 32000, 'dikirim', at(10, 37)),
      ('Pudding Roti Gula Aren', 'gofood', 28000, 'dikirim', at(10, 21)),
      ('Crumble Roti - Paket 3', 'offline', 54000, 'dikemas', at(9, 58)),
      ('Roti Sisa Mix Box', 'shopee', 47000, 'selesai', at(9, 12)),
    ];
    for (var i = 0; i < live.length; i++) {
      final (item, platform, total, status, time) = live[i];
      await dashboard.addOrder(
        userId,
        platform: platform,
        itemName: item,
        totalIdr: total,
        status: status,
        externalRef: 'LIVE-$userId-${i + 1}',
        orderedAt: time.toIso8601String(),
      );
    }

    // Earlier orders: 12 more "dikemas" and 1 "dikirim" so the open counts
    // match the cards (14 packing, 3 shipping), plus completed history.
    final yesterday = now.subtract(const Duration(days: 1));
    const history = [
      'Roti Tawar Sisa',
      'Muffin Roti Sisa',
      'Crumble Roti',
      'Pudding Roti'
    ];
    final statuses = [
      for (var i = 0; i < 12; i++) 'dikemas',
      'dikirim',
      for (var i = 0; i < 20; i++) 'selesai',
    ];
    for (var i = 0; i < statuses.length; i++) {
      await dashboard.addOrder(
        userId,
        platform: i.isEven ? 'tokopedia' : 'shopee',
        itemName: history[i % history.length],
        totalIdr: 15000 + (i * 4000) % 40000,
        status: statuses[i],
        externalRef: 'HIST-$userId-${i + 1}',
        orderedAt: DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
          8 + i % 12,
          (i * 7) % 60,
        ).toIso8601String(),
      );
    }
  }

  // Inventory: products with their sales for the last 30 days.

  static const _products = <_ProductSeed>[
    _ProductSeed('Roti Tawar Sisa', 'Roti', 18000, 13, 'pcs', 'bakery', 142),
    _ProductSeed('Muffin Roti Sisa', 'Roti', 12000, 26, 'pcs', 'cake', 96),
    _ProductSeed('Crumble Roti', 'Roti', 15000, 8, 'pack', 'cookie', 58),
    _ProductSeed('Pudding Roti', 'Roti', 9000, 19, 'cup', 'icecream', 31),
    _ProductSeed('Tepung Terigu 1kg', 'Bahan', 14500, 7, 'kg', 'grain', 12),
    _ProductSeed('Susu UHT 1L', 'Bahan', 19000, 4, 'L', 'milk', 9),
    _ProductSeed('Gula Aren 500g', 'Bahan', 22000, 0, 'pcs', 'drop', 4),
    _ProductSeed('Kemasan Box M', 'Kemasan', 2500, 40, 'pcs', 'box', 75),
  ];

  /// Starts each product at (stock + sold), then logs the sales, so the
  /// current stock matches the dummy figure and sales show in the 30-day total.
  Future<Map<String, int>> _seedInventory(
    InventoryRepository inventory,
    int userId,
  ) async {
    final ids = <String, int>{};
    for (final p in _products) {
      final id = await inventory.addItem(
        userId,
        NewItem(
          name: p.name,
          category: p.category,
          unit: p.unit,
          stock: p.stock + p.sold30d,
          priceIdr: p.priceIdr,
          iconKey: p.iconKey,
        ),
      );
      if (p.sold30d > 0) {
        await inventory.adjustStock(
          id,
          -p.sold30d,
          reason: StockReason.sale,
          note: 'Penjualan 30 hari',
        );
      }
      ids[p.name] = id;
    }
    return ids;
  }

  /// The three AI ideas, saved as one mix-and-match request.
  Future<void> _seedRecipes(
    RecipeRepository recipes,
    int userId,
    List<int> sourceItemIds,
  ) async {
    final requestId = await recipes.startRequest(
      userId,
      kind: 'mix_match',
      input: {'items': sourceItemIds},
    );
    final ids = await recipes.saveRecipes(
      userId,
      requestId: requestId,
      sourceItemIds: sourceItemIds,
      drafts: [for (final idea in RecipeData.ideas) idea.toDraft()],
    );
    await recipes.completeRequest(requestId, output: {'recipeIds': ids});
  }
}

class _Channel {
  const _Channel({
    required this.key,
    required this.conversion,
    required this.avgOrderIdr,
    required this.recent,
    required this.olderOrders,
    required this.todayAdSpend,
    required this.olderAdSpend,
  });

  final String key;
  final double conversion;
  final int avgOrderIdr;
  final List<int> recent;
  final int Function(int index) olderOrders;
  final int todayAdSpend;
  final int Function(int index) olderAdSpend;
}

class _DayRow {
  const _DayRow({
    required this.channel,
    required this.day,
    required this.orders,
    required this.adSpend,
  });

  final _Channel channel;
  final DateTime day;
  final int orders;
  final int adSpend;
}

class _InsightSeed {
  const _InsightSeed({
    required this.title,
    required this.body,
    required this.category,
    required this.tone,
    required this.action,
  });

  final String title;
  final String body;
  final String category;
  final String tone;
  final String action;
}

class _ProductSeed {
  const _ProductSeed(
    this.name,
    this.category,
    this.priceIdr,
    this.stock,
    this.unit,
    this.iconKey,
    this.sold30d,
  );

  final String name;
  final String category;
  final int priceIdr;
  final int stock;
  final String unit;
  final String iconKey;
  final int sold30d;
}

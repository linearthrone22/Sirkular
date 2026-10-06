import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:sirkular/core/database/app_database.dart';
import 'package:sirkular/core/database/schema.dart';
import 'package:sirkular/features/dashboard/data/dashboard_repository.dart';
import 'package:sirkular/features/inventory/data/inventory_repository.dart';
import 'package:sirkular/features/inventory/data/recipe_repository.dart';

var _emailCounter = 0;

AppDatabase _openMemoryDb() {
  return AppDatabase.open(
      factory: databaseFactoryFfi, path: inMemoryDatabasePath);
}

Future<int> _createUser(AppDatabase db) async {
  _emailCounter++;
  final d = await db.database;
  return d.insert('users', {
    'name': 'Kopi Senja',
    'email': 'user$_emailCounter@senja.id',
    'password_hash': 'hash',
    'salt': 'salt',
    'created_at': AppDatabase.now(),
  });
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = _openMemoryDb();
  });

  tearDown(() async {
    await db.close();
  });

  test('opens at the current schema version with every table', () async {
    final d = await db.database;
    expect(await d.getVersion(), currentSchemaVersion);

    final rows = await d.query('sqlite_master', where: "type = 'table'");
    final tables = rows.map((r) => r['name']).toSet();
    expect(
      tables,
      containsAll([
        'users',
        'inventory_items',
        'stock_movements',
        'orders',
        'ai_requests',
        'recipes',
        'recipe_ingredients',
        'recipe_steps',
        'recipe_sources',
        'product_listings',
        'insights',
        'platform_daily_stats',
        'platform_keyword_stats',
        'platform_settings',
        'dashboard_prefs',
      ]),
    );
  });

  test('adding an item with starting stock logs an adjustment', () async {
    final userId = await _createUser(db);
    final repo = InventoryRepository(database: db);

    final id = await repo.addItem(
      userId,
      const NewItem(
          name: 'Roti Tawar Sisa',
          category: 'Roti',
          stock: 13,
          priceIdr: 18000),
    );

    final item = await repo.item(id);
    expect(item?.stock, 13);
    expect(item?.priceIdr, 18000);

    final moves = await repo.movements(id);
    expect(moves, hasLength(1));
    expect(moves.single.delta, 13);
    expect(moves.single.balanceAfter, 13);
    expect(moves.single.reason, 'adjustment');
  });

  test('stock changes update the balance and refuse to go negative', () async {
    final userId = await _createUser(db);
    final repo = InventoryRepository(database: db);
    final id = await repo.addItem(
      userId,
      const NewItem(name: 'Tepung', category: 'Bahan', stock: 5),
    );

    expect(
      await repo.adjustStock(id, 10,
          reason: StockReason.restock, note: 'Supplier'),
      15,
    );
    expect(
      await repo.adjustStock(id, -4, reason: StockReason.sale),
      11,
    );
    await expectLater(
      repo.adjustStock(id, -50, reason: StockReason.waste),
      throwsStateError,
    );

    expect((await repo.item(id))?.stock, 11);
    final moves = await repo.movements(id);
    expect(moves, hasLength(3));
    expect(moves.first.reason, 'sale');
  });

  test('items can be filtered by category and name', () async {
    final userId = await _createUser(db);
    final repo = InventoryRepository(database: db);
    await repo.addItem(userId, const NewItem(name: 'Muffin', category: 'Roti'));
    await repo.addItem(
        userId, const NewItem(name: 'Tepung', category: 'Bahan'));

    expect(await repo.items(userId, category: 'Roti'), hasLength(1));
    expect((await repo.items(userId, query: 'tep')).single.name, 'Tepung');
    expect(await repo.items(userId), hasLength(2));
  });

  test('platform listings can be set and replaced per platform', () async {
    final userId = await _createUser(db);
    final repo = InventoryRepository(database: db);
    final id = await repo.addItem(
        userId, const NewItem(name: 'Muffin', category: 'Roti'));

    await repo.setListing(id, 'tokopedia', status: 'publishing');
    await repo.setListing(id, 'tokopedia', status: 'live', externalId: 'TKP-1');
    await repo.setListing(id, 'shopee',
        status: 'failed', error: 'Gambar kurang');

    final listings = await repo.listings(id);
    expect(listings, hasLength(2));
    final tokopedia = listings.firstWhere((l) => l.platform == 'tokopedia');
    expect(tokopedia.status, 'live');
    expect(tokopedia.externalId, 'TKP-1');
    expect(tokopedia.publishedAt, isNotNull);
    expect(listings.firstWhere((l) => l.platform == 'shopee').error,
        'Gambar kurang');
  });

  test('AI request, recipe ideas, and save-to-inventory flow', () async {
    final userId = await _createUser(db);
    final inventory = InventoryRepository(database: db);
    final recipes = RecipeRepository(database: db);

    final sourceId = await inventory.addItem(
      userId,
      const NewItem(name: 'Roti Tawar Sisa', category: 'Roti', stock: 13),
    );
    final requestId = await recipes.startRequest(
      userId,
      kind: 'mix_match',
      input: {
        'items': [sourceId]
      },
    );

    final ids = await recipes.saveRecipes(
      userId,
      requestId: requestId,
      sourceItemIds: [sourceId],
      drafts: const [
        RecipeDraft(
          name: 'Pudding Roti',
          hppIdr: 4200,
          sellPriceIdr: 12000,
          difficulty: 'Mudah',
          iconKey: 'icecream',
          ingredients: ['Roti tawar 3 lembar', 'Susu UHT 200 ml'],
          steps: ['Potong roti', 'Kukus 15 menit'],
        ),
        RecipeDraft(
          name: 'Crumble Roti',
          hppIdr: 5100,
          sellPriceIdr: 15000,
          difficulty: 'Sedang',
          iconKey: 'cookie',
          ingredients: ['Roti sisa 4 lembar'],
          steps: ['Panggang 12 menit'],
        ),
      ],
    );
    expect(ids, hasLength(2));

    await recipes.completeRequest(requestId, output: {'ideas': 2});

    final detail = await recipes.recipe(ids.first);
    expect(detail?.recipe.name, 'Pudding Roti');
    expect(detail?.recipe.profitIdr, 7800);
    expect(detail?.ingredients, ['Roti tawar 3 lembar', 'Susu UHT 200 ml']);
    expect(detail?.steps, ['Potong roti', 'Kukus 15 menit']);
    expect(detail?.sourceItemIds, [sourceId]);

    final productId = await recipes.saveRecipeToInventory(userId, ids.first);
    final product = await inventory.item(productId);
    expect(product?.source, 'recipe');
    expect(product?.sellPriceIdr, 12000);
    expect((await recipes.recipe(ids.first))?.recipe.status, 'saved');
    expect(await recipes.recipes(userId, status: 'idea'), hasLength(1));
  });

  test('failed AI requests keep their error', () async {
    final userId = await _createUser(db);
    final recipes = RecipeRepository(database: db);
    final requestId = await recipes.startRequest(
      userId,
      kind: 'photo_item',
      input: {'photo': 'foto.jpg'},
    );

    await recipes.failRequest(requestId, error: 'Timeout');

    final d = await db.database;
    final row =
        (await d.query('ai_requests', where: 'id = ?', whereArgs: [requestId]))
            .single;
    expect(row['status'], 'failed');
    expect(row['error'], 'Timeout');
  });

  test('insights can be read and dismissed', () async {
    final userId = await _createUser(db);
    final repo = DashboardRepository(database: db);

    final id = await repo.addInsight(
      userId,
      category: 'Stok',
      tone: 'alert',
      title: 'Roti tawar mendekati kedaluwarsa',
      body: '15 kg expired dalam 2 hari',
      actionLabel: 'Terapkan diskon',
    );
    await repo.addInsight(
      userId,
      category: 'Penjualan',
      tone: 'success',
      title: 'Penjualan naik',
      body: 'Sabtu puncaknya',
      actionLabel: 'Atur stok',
    );

    await repo.markInsightRead(id);
    expect((await repo.insights(userId)), hasLength(2));

    await repo.dismissInsight(id);
    final remaining = await repo.insights(userId);
    expect(remaining, hasLength(1));
    expect(remaining.single.title, 'Penjualan naik');
  });

  test('orders can be added, moved through statuses, and counted', () async {
    final userId = await _createUser(db);
    final repo = DashboardRepository(database: db);

    final first = await repo.addOrder(
      userId,
      platform: 'tokopedia',
      itemName: 'Muffin Roti Sisa',
      totalIdr: 85000,
      externalRef: 'TKP-001',
    );
    await repo.addOrder(
      userId,
      platform: 'shopee',
      itemName: 'Roti Tawar',
      totalIdr: 32000,
      status: 'dikirim',
    );

    await repo.updateOrderStatus(first, 'selesai');

    final counts = await repo.orderCountsByStatus(userId);
    expect(counts, {'selesai': 1, 'dikirim': 1});
    expect((await repo.recentOrders(userId)).first.platform, 'shopee');
  });

  test('duplicate platform order references are rejected', () async {
    final userId = await _createUser(db);
    final repo = DashboardRepository(database: db);

    await repo.addOrder(
      userId,
      platform: 'tokopedia',
      itemName: 'Muffin',
      totalIdr: 1,
      externalRef: 'DUP',
    );
    await expectLater(
      repo.addOrder(
        userId,
        platform: 'tokopedia',
        itemName: 'Muffin',
        totalIdr: 1,
        externalRef: 'DUP',
      ),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('daily platform stats are replaced per day and ordered oldest first',
      () async {
    final userId = await _createUser(db);
    final repo = DashboardRepository(database: db);

    await repo.upsertDailyStats(
      userId,
      platform: 'tokopedia',
      day: '2026-10-05',
      visits: 1000,
      orders: 20,
      revenueIdr: 900000,
      adSpendIdr: 50000,
    );
    await repo.upsertDailyStats(
      userId,
      platform: 'tokopedia',
      day: '2026-10-06',
      visits: 1200,
      orders: 30,
      revenueIdr: 1400000,
      adSpendIdr: 60000,
    );
    await repo.upsertDailyStats(
      userId,
      platform: 'tokopedia',
      day: '2026-10-06',
      visits: 1200,
      orders: 36,
      revenueIdr: 1600000,
      adSpendIdr: 60000,
    );

    final stats = await repo.dailyStats(userId, 'tokopedia');
    expect(stats.map((s) => s.day), ['2026-10-05', '2026-10-06']);
    expect(stats.last.orders, 36);
    expect(stats.last.conversionRate, closeTo(0.03, 1e-9));
  });

  test('keyword stats are stored and ranked by clicks', () async {
    final userId = await _createUser(db);
    final repo = DashboardRepository(database: db);

    await repo.upsertKeywordStats(
      userId,
      platform: 'shopee',
      day: '2026-10-06',
      keyword: 'roti sisa',
      clicks: 356,
      spendIdr: 88000,
      revenueIdr: 340000,
    );
    await repo.upsertKeywordStats(
      userId,
      platform: 'shopee',
      day: '2026-10-06',
      keyword: 'crumble roti',
      clicks: 134,
      spendIdr: 30000,
      revenueIdr: 66000,
    );

    final rows = await repo.keywordStats(userId, 'shopee', '2026-10-06');
    expect(rows.first['keyword'], 'roti sisa');
    expect(rows, hasLength(2));
  });

  test('platform settings default, then save and reload', () async {
    final userId = await _createUser(db);
    final repo = DashboardRepository(database: db);

    final defaults = await repo.platformSettings(userId, 'shopee');
    expect(defaults.autoReply, isFalse);

    await repo.savePlatformSettings(
      userId,
      'shopee',
      const PlatformSettingsRecord(
          autoReply: true, voucherOn: false, adBudgetIdr: 120000),
    );

    final saved = await repo.platformSettings(userId, 'shopee');
    expect(saved.autoReply, isTrue);
    expect(saved.voucherOn, isFalse);
    expect(saved.adBudgetIdr, 120000);
  });

  test('dashboard section visibility is stored per user', () async {
    final userId = await _createUser(db);
    final repo = DashboardRepository(database: db);

    await repo.setDashboardPref(userId, 'stock', visible: false);
    await repo.setDashboardPref(userId, 'revenue', visible: true);

    expect(
        await repo.dashboardPrefs(userId), {'stock': false, 'revenue': true});
  });

  test('deleting a user removes their products, recipes, and insights',
      () async {
    final userId = await _createUser(db);
    final inventory = InventoryRepository(database: db);
    final recipes = RecipeRepository(database: db);
    final dashboard = DashboardRepository(database: db);

    final itemId = await inventory.addItem(
      userId,
      const NewItem(name: 'Muffin', category: 'Roti', stock: 3),
    );
    final requestId =
        await recipes.startRequest(userId, kind: 'mix_match', input: {});
    await recipes.saveRecipes(
      userId,
      requestId: requestId,
      sourceItemIds: [itemId],
      drafts: const [
        RecipeDraft(
          name: 'Pudding',
          hppIdr: 1,
          sellPriceIdr: 2,
          difficulty: 'Mudah',
          iconKey: 'cake',
          ingredients: [],
          steps: [],
        ),
      ],
    );
    await dashboard.addInsight(
      userId,
      category: 'Stok',
      tone: 'info',
      title: 't',
      body: 'b',
      actionLabel: 'a',
    );

    final d = await db.database;
    await d.delete('users', where: 'id = ?', whereArgs: [userId]);

    expect(await inventory.item(itemId), isNull);
    expect(await recipes.recipes(userId), isEmpty);
    expect(await dashboard.insights(userId), isEmpty);
    expect(await d.query('recipe_sources'), isEmpty);
  });

  test('foreign keys are enforced', () async {
    final d = await db.database;
    await expectLater(
      d.insert('inventory_items', {
        'user_id': 9999,
        'name': 'Hantu',
        'category': 'Roti',
        'created_at': AppDatabase.now(),
        'updated_at': AppDatabase.now(),
      }),
      throwsA(isA<DatabaseException>()),
    );
  });
}

import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';

/// Why stock changed. Stored by name in `stock_movements.reason`.
enum StockReason { restock, sale, waste, adjustment, recipeUse, produced }

class ItemRecord {
  const ItemRecord({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.unit,
    required this.stock,
    required this.priceIdr,
    required this.sellPriceIdr,
    required this.iconKey,
    required this.source,
  });

  factory ItemRecord.fromRow(Map<String, Object?> row) {
    return ItemRecord(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      name: row['name'] as String,
      category: row['category'] as String,
      unit: row['unit'] as String,
      stock: row['stock'] as int,
      priceIdr: row['price_idr'] as int,
      sellPriceIdr: row['sell_price_idr'] as int?,
      iconKey: row['icon_key'] as String,
      source: row['source'] as String,
    );
  }

  final int id;
  final int userId;
  final String name;
  final String category;
  final String unit;
  final int stock;
  final int priceIdr;
  final int? sellPriceIdr;
  final String iconKey;
  final String source;
}

class NewItem {
  const NewItem({
    required this.name,
    required this.category,
    this.unit = 'pcs',
    this.stock = 0,
    this.priceIdr = 0,
    this.sellPriceIdr,
    this.iconKey = 'inventory',
    this.source = 'manual',
  });

  final String name;
  final String category;
  final String unit;
  final int stock;
  final int priceIdr;
  final int? sellPriceIdr;
  final String iconKey;
  final String source;
}

class StockMovement {
  const StockMovement({
    required this.delta,
    required this.balanceAfter,
    required this.reason,
    required this.note,
    required this.createdAt,
  });

  final int delta;
  final int balanceAfter;
  final String reason;
  final String? note;
  final String createdAt;
}

class ListingRecord {
  const ListingRecord({
    required this.platform,
    required this.status,
    required this.externalId,
    required this.error,
    required this.publishedAt,
  });

  final String platform;
  final String status;
  final String? externalId;
  final String? error;
  final String? publishedAt;
}

/// Products, stock movements, and per-platform listings.
class InventoryRepository {
  InventoryRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<Database> get _db => _database.database;

  /// Adds a product. A starting stock above zero is logged as an adjustment.
  Future<int> addItem(int userId, NewItem item) async {
    final db = await _db;
    return db.transaction((txn) async {
      final now = AppDatabase.now();
      final id = await txn.insert('inventory_items', {
        'user_id': userId,
        'name': item.name.trim(),
        'category': item.category,
        'unit': item.unit,
        'stock': item.stock,
        'price_idr': item.priceIdr,
        'sell_price_idr': item.sellPriceIdr,
        'icon_key': item.iconKey,
        'source': item.source,
        'created_at': now,
        'updated_at': now,
      });
      if (item.stock > 0) {
        await txn.insert('stock_movements', {
          'item_id': id,
          'delta': item.stock,
          'balance_after': item.stock,
          'reason': StockReason.adjustment.name,
          'note': 'Stok awal',
          'created_at': now,
        });
      }
      return id;
    });
  }

  /// Lists a user's products, optionally filtered by category or name.
  Future<List<ItemRecord>> items(
    int userId, {
    String? category,
    String? query,
  }) async {
    final db = await _db;
    final where = <String>['user_id = ?'];
    final args = <Object?>[userId];
    if (category != null) {
      where.add('category = ?');
      args.add(category);
    }
    final search = query?.trim().toLowerCase() ?? '';
    if (search.isNotEmpty) {
      where.add('LOWER(name) LIKE ?');
      args.add('%$search%');
    }
    final rows = await db.query(
      'inventory_items',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(ItemRecord.fromRow).toList();
  }

  Future<ItemRecord?> item(int id) async {
    final db = await _db;
    final rows = await db.query(
      'inventory_items',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : ItemRecord.fromRow(rows.first);
  }

  /// Changes stock and logs the movement in one transaction.
  /// Returns the new stock. Throws if the result would be negative.
  Future<int> adjustStock(
    int itemId,
    int delta, {
    required StockReason reason,
    String? note,
  }) async {
    final db = await _db;
    return db.transaction((txn) async {
      final rows = await txn.query(
        'inventory_items',
        columns: ['stock'],
        where: 'id = ?',
        whereArgs: [itemId],
        limit: 1,
      );
      if (rows.isEmpty) {
        throw ArgumentError('Produk $itemId tidak ditemukan');
      }
      final current = rows.first['stock'] as int;
      final newStock = current + delta;
      if (newStock < 0) {
        throw StateError('Stok tidak cukup (sisa $current)');
      }
      final now = AppDatabase.now();
      await txn.update(
        'inventory_items',
        {'stock': newStock, 'updated_at': now},
        where: 'id = ?',
        whereArgs: [itemId],
      );
      await txn.insert('stock_movements', {
        'item_id': itemId,
        'delta': delta,
        'balance_after': newStock,
        'reason': reason.name,
        'note': note,
        'created_at': now,
      });
      return newStock;
    });
  }

  /// Most recent stock changes for one product, newest first.
  Future<List<StockMovement>> movements(int itemId, {int limit = 50}) async {
    final db = await _db;
    final rows = await db.query(
      'stock_movements',
      where: 'item_id = ?',
      whereArgs: [itemId],
      orderBy: 'created_at DESC, id DESC',
      limit: limit,
    );
    return [
      for (final row in rows)
        StockMovement(
          delta: row['delta'] as int,
          balanceAfter: row['balance_after'] as int,
          reason: row['reason'] as String,
          note: row['note'] as String?,
          createdAt: row['created_at'] as String,
        ),
    ];
  }

  /// Sets the publish status of one product on one platform.
  Future<void> setListing(
    int itemId,
    String platform, {
    required String status,
    String? externalId,
    String? error,
  }) async {
    final db = await _db;
    final now = AppDatabase.now();
    await db.insert(
      'product_listings',
      {
        'item_id': itemId,
        'platform': platform,
        'status': status,
        'external_id': externalId,
        'error': error,
        'published_at': status == 'live' ? now : null,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ListingRecord>> listings(int itemId) async {
    final db = await _db;
    final rows = await db.query(
      'product_listings',
      where: 'item_id = ?',
      whereArgs: [itemId],
      orderBy: 'platform',
    );
    return [
      for (final row in rows)
        ListingRecord(
          platform: row['platform'] as String,
          status: row['status'] as String,
          externalId: row['external_id'] as String?,
          error: row['error'] as String?,
          publishedAt: row['published_at'] as String?,
        ),
    ];
  }
}

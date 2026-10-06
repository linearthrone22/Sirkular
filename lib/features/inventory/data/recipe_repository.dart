import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';

/// One recipe idea from an AI response, before it is saved.
class RecipeDraft {
  const RecipeDraft({
    required this.name,
    required this.hppIdr,
    required this.sellPriceIdr,
    required this.difficulty,
    required this.iconKey,
    required this.ingredients,
    required this.steps,
  });

  final String name;
  final int hppIdr;
  final int sellPriceIdr;
  final String difficulty;
  final String iconKey;
  final List<String> ingredients;
  final List<String> steps;
}

class RecipeRecord {
  const RecipeRecord({
    required this.id,
    required this.name,
    required this.hppIdr,
    required this.sellPriceIdr,
    required this.difficulty,
    required this.iconKey,
    required this.status,
  });

  factory RecipeRecord.fromRow(Map<String, Object?> row) {
    return RecipeRecord(
      id: row['id'] as int,
      name: row['name'] as String,
      hppIdr: row['hpp_idr'] as int,
      sellPriceIdr: row['sell_price_idr'] as int,
      difficulty: row['difficulty'] as String,
      iconKey: row['icon_key'] as String,
      status: row['status'] as String,
    );
  }

  final int id;
  final String name;
  final int hppIdr;
  final int sellPriceIdr;
  final String difficulty;
  final String iconKey;
  final String status;

  int get profitIdr => sellPriceIdr - hppIdr;
}

class RecipeDetail {
  const RecipeDetail({
    required this.recipe,
    required this.ingredients,
    required this.steps,
    required this.sourceItemIds,
  });

  final RecipeRecord recipe;
  final List<String> ingredients;
  final List<String> steps;
  final List<int> sourceItemIds;
}

/// AI requests (for audit and replay), the recipe ideas they produce, and
/// the flow that turns a saved recipe into a sellable product.
class RecipeRepository {
  RecipeRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<Database> get _db => _database.database;

  /// Logs an AI call as pending. Returns the request id.
  /// [kind] is 'photo_item', 'mix_match', or 'insight'.
  Future<int> startRequest(
    int userId, {
    required String kind,
    required Map<String, Object?> input,
  }) async {
    final db = await _db;
    return db.insert('ai_requests', {
      'user_id': userId,
      'kind': kind,
      'input_json': jsonEncode(input),
      'status': 'pending',
      'created_at': AppDatabase.now(),
    });
  }

  Future<void> completeRequest(
    int requestId, {
    required Map<String, Object?> output,
  }) async {
    final db = await _db;
    await db.update(
      'ai_requests',
      {
        'output_json': jsonEncode(output),
        'status': 'done',
        'completed_at': AppDatabase.now(),
      },
      where: 'id = ?',
      whereArgs: [requestId],
    );
  }

  Future<void> failRequest(int requestId, {required String error}) async {
    final db = await _db;
    await db.update(
      'ai_requests',
      {
        'status': 'failed',
        'error': error,
        'completed_at': AppDatabase.now(),
      },
      where: 'id = ?',
      whereArgs: [requestId],
    );
  }

  /// Saves the ideas from one mix-and-match request, with the products used.
  /// Returns the new recipe ids in the same order as [drafts].
  Future<List<int>> saveRecipes(
    int userId, {
    required int requestId,
    required List<RecipeDraft> drafts,
    required List<int> sourceItemIds,
  }) async {
    final db = await _db;
    return db.transaction((txn) async {
      final now = AppDatabase.now();
      final ids = <int>[];
      for (final draft in drafts) {
        final recipeId = await txn.insert('recipes', {
          'user_id': userId,
          'request_id': requestId,
          'name': draft.name,
          'hpp_idr': draft.hppIdr,
          'sell_price_idr': draft.sellPriceIdr,
          'difficulty': draft.difficulty,
          'icon_key': draft.iconKey,
          'status': 'idea',
          'created_at': now,
        });
        ids.add(recipeId);

        for (var i = 0; i < draft.ingredients.length; i++) {
          await txn.insert('recipe_ingredients', {
            'recipe_id': recipeId,
            'position': i,
            'description': draft.ingredients[i],
          });
        }
        for (var i = 0; i < draft.steps.length; i++) {
          await txn.insert('recipe_steps', {
            'recipe_id': recipeId,
            'position': i + 1,
            'description': draft.steps[i],
          });
        }
        for (final itemId in sourceItemIds) {
          await txn.insert(
            'recipe_sources',
            {'recipe_id': recipeId, 'item_id': itemId},
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
      return ids;
    });
  }

  Future<List<RecipeRecord>> recipes(int userId, {String? status}) async {
    final db = await _db;
    final rows = await db.query(
      'recipes',
      where: status == null ? 'user_id = ?' : 'user_id = ? AND status = ?',
      whereArgs: status == null ? [userId] : [userId, status],
      orderBy: 'created_at DESC, id DESC',
    );
    return rows.map(RecipeRecord.fromRow).toList();
  }

  Future<RecipeDetail?> recipe(int recipeId) async {
    final db = await _db;
    final rows = await db.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [recipeId],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final ingredients = await db.query(
      'recipe_ingredients',
      columns: ['description'],
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
      orderBy: 'position',
    );
    final steps = await db.query(
      'recipe_steps',
      columns: ['description'],
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
      orderBy: 'position',
    );
    final sources = await db.query(
      'recipe_sources',
      columns: ['item_id'],
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );

    return RecipeDetail(
      recipe: RecipeRecord.fromRow(rows.first),
      ingredients: [for (final r in ingredients) r['description'] as String],
      steps: [for (final r in steps) r['description'] as String],
      sourceItemIds: [for (final r in sources) r['item_id'] as int],
    );
  }

  /// "Simpan ke Inventory & Siap Jual": creates a sellable product from the
  /// recipe, marks the recipe saved, and returns the new product id.
  Future<int> saveRecipeToInventory(int userId, int recipeId) async {
    final db = await _db;
    return db.transaction((txn) async {
      final rows = await txn.query(
        'recipes',
        where: 'id = ? AND user_id = ?',
        whereArgs: [recipeId, userId],
        limit: 1,
      );
      if (rows.isEmpty) {
        throw ArgumentError('Resep $recipeId tidak ditemukan');
      }
      final recipe = RecipeRecord.fromRow(rows.first);
      final now = AppDatabase.now();

      final itemId = await txn.insert('inventory_items', {
        'user_id': userId,
        'name': recipe.name,
        'category': 'Roti',
        'unit': 'pcs',
        'stock': 0,
        'price_idr': recipe.hppIdr,
        'sell_price_idr': recipe.sellPriceIdr,
        'icon_key': recipe.iconKey,
        'source': 'recipe',
        'created_at': now,
        'updated_at': now,
      });
      await txn.update(
        'recipes',
        {'status': 'saved'},
        where: 'id = ?',
        whereArgs: [recipeId],
      );
      return itemId;
    });
  }
}

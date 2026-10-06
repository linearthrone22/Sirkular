import 'dart:typed_data';

import '../../../core/ai/gemini_client.dart';
import 'inventory_data.dart';
import 'recipe_data.dart';
import 'recipe_repository.dart';

/// What the photo analysis fills into the add-item form.
class ItemDraft {
  const ItemDraft({
    required this.name,
    required this.category,
    required this.stock,
    required this.priceIdr,
  });

  final String name;
  final String category;
  final int stock;
  final int priceIdr;
}

/// Gemini-backed photo analysis and recipe ideas. Every call is logged to
/// `ai_requests`. With no API key, the mock data is used instead.
class InventoryAi {
  InventoryAi({GeminiClient? client, RecipeRepository? recipes})
      : _client = client ?? GeminiClient(),
        _recipes = recipes ?? RecipeRepository();

  final GeminiClient _client;
  final RecipeRepository _recipes;

  bool get isConfigured => _client.isConfigured;

  Future<ItemDraft> analyzePhoto(int userId, Uint8List photo) async {
    final requestId = await _recipes.startRequest(
      userId,
      kind: 'photo_item',
      input: {'bytes': photo.length},
    );
    try {
      if (!isConfigured) {
        const draft = ItemDraft(
          name: 'Sisa Adonan Croissant',
          category: 'Bahan',
          stock: 2,
          priceIdr: 6000,
        );
        await _recipes.completeRequest(requestId, output: {'mock': true});
        return draft;
      }
      final json = await _client.generateJson(_photoPrompt, image: photo);
      await _recipes.completeRequest(requestId, output: json);
      return ItemDraft(
        name: json['name'] as String,
        category: _category(json['category'] as String?),
        stock: _int(json['stock']),
        priceIdr: _int(json['price_idr']),
      );
    } catch (e) {
      await _recipes.failRequest(requestId, error: '$e');
      rethrow;
    }
  }

  /// Three ideas from the selected products. The caller logs the request.
  Future<List<RecipeDraft>> generateIdeas(List<InventoryItem> items) async {
    if (!isConfigured) {
      return [for (final idea in RecipeData.ideas) idea.toDraft()];
    }
    final list =
        items.map((i) => '- ${i.name} (stok ${i.stock} ${i.unit})').join('\n');
    final json = await _client.generateJson('$_ideasPrompt\nBahan:\n$list');
    final ideas = (json['ideas'] as List<dynamic>).take(3);
    return [
      for (final raw in ideas) _draftFrom(raw as Map<String, dynamic>),
    ];
  }

  RecipeDraft _draftFrom(Map<String, dynamic> i) {
    return RecipeDraft(
      name: i['name'] as String,
      hppIdr: _int(i['hpp_idr']),
      sellPriceIdr: _int(i['sell_price_idr']),
      difficulty: _difficulty(i['difficulty'] as String?),
      iconKey: _iconKey(i['icon_key'] as String?),
      ingredients: [for (final x in i['ingredients'] as List<dynamic>) '$x'],
      steps: [for (final x in i['steps'] as List<dynamic>) '$x'],
    );
  }

  static int _int(Object? value) => (value as num?)?.round() ?? 0;

  static String _category(String? value) {
    const known = ['Roti', 'Bahan', 'Kemasan'];
    return known.contains(value) ? value! : 'Bahan';
  }

  static String _difficulty(String? value) {
    const known = ['Mudah', 'Sedang', 'Sulit'];
    return known.contains(value) ? value! : 'Sedang';
  }

  static String _iconKey(String? value) {
    const known = [
      'bakery',
      'cake',
      'cookie',
      'icecream',
      'grain',
      'milk',
      'drop',
      'box'
    ];
    return known.contains(value) ? value! : 'cake';
  }

  static const _photoPrompt = '''
Kamu membantu inventory UMKM roti yang mengurangi limbah. Lihat foto ini
(bahan sisa, adonan, atau kemasan) lalu balas JSON saja dengan kunci:
"name" (nama barang dalam Bahasa Indonesia), "category" ("Roti", "Bahan", atau "Kemasan"),
"stock" (perkiraan jumlah sebagai bilangan bulat), dan "price_idr" (perkiraan harga beli
dalam rupiah sebagai bilangan bulat).
''';

  static const _ideasPrompt = '''
Kamu membantu UMKM roti mengubah bahan sisa menjadi produk baru. Dari bahan di bawah,
buat 3 ide produk. Balas JSON saja dengan kunci "ideas", berisi list objek dengan kunci:
"name", "hpp_idr" (biaya bahan per porsi, bilangan bulat), "sell_price_idr" (harga jual
per porsi), "difficulty" ("Mudah", "Sedang", atau "Sulit"), "icon_key" (salah satu:
bakery, cake, cookie, icecream, grain, milk, drop, box), "ingredients" (list teks),
dan "steps" (list langkah dalam Bahasa Indonesia).
''';
}

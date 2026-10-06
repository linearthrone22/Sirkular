import 'package:flutter/material.dart';

import 'recipe_repository.dart';

/// One recipe idea. Stored as a [RecipeDraft] once generated.
class RecipeIdea {
  const RecipeIdea({
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

  RecipeDraft toDraft() => RecipeDraft(
        name: name,
        hppIdr: hppIdr,
        sellPriceIdr: sellPriceIdr,
        difficulty: difficulty,
        iconKey: iconKey,
        ingredients: ingredients,
        steps: steps,
      );
}

/// Stand-in for the Gemini call. [ideas] is what it "returns" until the API
/// is connected. Everything after this point is real: ideas are saved and
/// read back through [RecipeRepository].
class RecipeData {
  RecipeData._();

  static const loadingMessages = <String>[
    'Menggabungkan bahan terpilih...',
    'Menganalisis tren pasar...',
    'Menghitung HPP & proyeksi profit...',
  ];

  static const ideas = <RecipeIdea>[
    RecipeIdea(
      name: 'Pudding Roti',
      hppIdr: 4200,
      sellPriceIdr: 12000,
      difficulty: 'Mudah',
      iconKey: 'icecream',
      ingredients: [
        'Roti tawar sisa 3 lembar',
        'Susu UHT 200 ml',
        'Telur 1 butir',
        'Gula aren 2 sdm',
      ],
      steps: [
        'Potong roti tawar menjadi dadu kecil.',
        'Kocok telur, susu, dan gula aren sampai rata.',
        'Tuang adonan ke atas roti dan diamkan 10 menit.',
        'Kukus 15 menit sampai set. Dinginkan sebelum dikemas.',
      ],
    ),
    RecipeIdea(
      name: 'Crumble Roti',
      hppIdr: 5100,
      sellPriceIdr: 15000,
      difficulty: 'Sedang',
      iconKey: 'cookie',
      ingredients: [
        'Roti sisa 4 lembar',
        'Tepung terigu 50 g',
        'Mentega 40 g',
        'Gula aren 30 g',
      ],
      steps: [
        'Remas roti sisa jadi remah kasar.',
        'Campur tepung, mentega dingin, dan gula aren dengan ujung jari sampai berbutir.',
        'Taburkan crumble di atas loyang roti yang sudah dipotong.',
        'Panggang 180 °C selama 12 menit sampai kecokelatan.',
      ],
    ),
    RecipeIdea(
      name: 'Muffin Roti Sisa',
      hppIdr: 3800,
      sellPriceIdr: 12000,
      difficulty: 'Mudah',
      iconKey: 'cake',
      ingredients: [
        'Roti tawar sisa 2 lembar',
        'Telur 1 butir',
        'Susu UHT 100 ml',
        'Tepung terigu 40 g',
      ],
      steps: [
        'Haluskan roti sisa bersama susu.',
        'Masukkan telur dan tepung, aduk sampai tidak bergerigi.',
        'Tuang ke cetakan muffin, sisakan ruang untuk mengembang.',
        'Panggang 170 °C selama 18 menit.',
      ],
    ),
  ];
}

/// Maps a stored icon key to an icon. Used by every screen that shows a product.
IconData iconForKey(String key) {
  switch (key) {
    case 'bakery':
      return Icons.bakery_dining_outlined;
    case 'cake':
      return Icons.cake_outlined;
    case 'cookie':
      return Icons.cookie_outlined;
    case 'icecream':
      return Icons.icecream_outlined;
    case 'grain':
      return Icons.grain;
    case 'milk':
      return Icons.local_drink_outlined;
    case 'drop':
      return Icons.water_drop_outlined;
    case 'box':
      return Icons.inventory_2_outlined;
    default:
      return Icons.inventory_2_outlined;
  }
}

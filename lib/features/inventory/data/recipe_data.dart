import 'package:flutter/material.dart';

class RecipeIdea {
  const RecipeIdea({
    required this.name,
    required this.hpp,
    required this.sellPrice,
    required this.profit,
    required this.difficulty,
    required this.icon,
    required this.ingredients,
    required this.steps,
  });

  final String name;
  final String hpp;
  final String sellPrice;
  final String profit;
  final String difficulty;
  final IconData icon;
  final List<String> ingredients;
  final List<String> steps;
}

/// Mock AI output. Later this comes from the Gemini request.
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
      hpp: 'Rp 4.200',
      sellPrice: 'Rp 12.000',
      profit: 'Rp 7.800',
      difficulty: 'Mudah',
      icon: Icons.icecream_outlined,
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
      hpp: 'Rp 5.100',
      sellPrice: 'Rp 15.000',
      profit: 'Rp 9.900',
      difficulty: 'Sedang',
      icon: Icons.cookie_outlined,
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
      hpp: 'Rp 3.800',
      sellPrice: 'Rp 12.000',
      profit: 'Rp 8.200',
      difficulty: 'Mudah',
      icon: Icons.cake_outlined,
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

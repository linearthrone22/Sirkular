import 'package:flutter/material.dart';

enum InventoryStatus { inStock, lowStock, outOfStock }

class InventoryItem {
  const InventoryItem({
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.unit,
    required this.icon,
  });

  final String name;
  final String category;
  final String price;
  final int stock;
  final String unit;
  final IconData icon;

  InventoryStatus get status {
    if (stock == 0) return InventoryStatus.outOfStock;
    if (stock < 10) return InventoryStatus.lowStock;
    return InventoryStatus.inStock;
  }

  String get stockLabel => 'Stok: $stock $unit';
}

/// Mock inventory. Replace with SQLite data once the inventory table exists.
class InventoryData {
  InventoryData._();

  static const categories = ['Semua', 'Roti', 'Bahan', 'Kemasan'];

  static const items = <InventoryItem>[
    InventoryItem(
      name: 'Roti Tawar Sisa',
      category: 'Roti',
      price: 'Rp 18.000',
      stock: 13,
      unit: 'pcs',
      icon: Icons.bakery_dining_outlined,
    ),
    InventoryItem(
      name: 'Muffin Roti Sisa',
      category: 'Roti',
      price: 'Rp 12.000',
      stock: 26,
      unit: 'pcs',
      icon: Icons.cake_outlined,
    ),
    InventoryItem(
      name: 'Crumble Roti',
      category: 'Roti',
      price: 'Rp 15.000',
      stock: 8,
      unit: 'pack',
      icon: Icons.cookie_outlined,
    ),
    InventoryItem(
      name: 'Pudding Roti',
      category: 'Roti',
      price: 'Rp 9.000',
      stock: 19,
      unit: 'cup',
      icon: Icons.icecream_outlined,
    ),
    InventoryItem(
      name: 'Tepung Terigu 1kg',
      category: 'Bahan',
      price: 'Rp 14.500',
      stock: 7,
      unit: 'kg',
      icon: Icons.grain,
    ),
    InventoryItem(
      name: 'Gula Aren 500g',
      category: 'Bahan',
      price: 'Rp 22.000',
      stock: 0,
      unit: 'pcs',
      icon: Icons.water_drop_outlined,
    ),
    InventoryItem(
      name: 'Kemasan Box M',
      category: 'Kemasan',
      price: 'Rp 2.500',
      stock: 40,
      unit: 'pcs',
      icon: Icons.inventory_2_outlined,
    ),
  ];
}

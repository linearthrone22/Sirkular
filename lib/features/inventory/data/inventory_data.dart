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
    required this.sold30d,
  });

  final String name;
  final String category;
  final String price;
  final int stock;
  final String unit;
  final IconData icon;

  /// Units sold in the last 30 days. Used to rank card colors.
  final int sold30d;

  InventoryStatus get status {
    if (stock == 0) return InventoryStatus.outOfStock;
    if (stock < 10) return InventoryStatus.lowStock;
    return InventoryStatus.inStock;
  }

  String get stockLabel => 'Stok: $stock $unit';

  InventoryItem copyWithStock(int newStock) {
    return InventoryItem(
      name: name,
      category: category,
      price: price,
      stock: newStock,
      unit: unit,
      icon: icon,
      sold30d: sold30d,
    );
  }
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
      sold30d: 142,
    ),
    InventoryItem(
      name: 'Muffin Roti Sisa',
      category: 'Roti',
      price: 'Rp 12.000',
      stock: 26,
      unit: 'pcs',
      icon: Icons.cake_outlined,
      sold30d: 96,
    ),
    InventoryItem(
      name: 'Crumble Roti',
      category: 'Roti',
      price: 'Rp 15.000',
      stock: 8,
      unit: 'pack',
      icon: Icons.cookie_outlined,
      sold30d: 58,
    ),
    InventoryItem(
      name: 'Pudding Roti',
      category: 'Roti',
      price: 'Rp 9.000',
      stock: 19,
      unit: 'cup',
      icon: Icons.icecream_outlined,
      sold30d: 31,
    ),
    InventoryItem(
      name: 'Tepung Terigu 1kg',
      category: 'Bahan',
      price: 'Rp 14.500',
      stock: 7,
      unit: 'kg',
      icon: Icons.grain,
      sold30d: 12,
    ),
    InventoryItem(
      name: 'Susu UHT 1L',
      category: 'Bahan',
      price: 'Rp 19.000',
      stock: 4,
      unit: 'L',
      icon: Icons.local_drink_outlined,
      sold30d: 9,
    ),
    InventoryItem(
      name: 'Gula Aren 500g',
      category: 'Bahan',
      price: 'Rp 22.000',
      stock: 0,
      unit: 'pcs',
      icon: Icons.water_drop_outlined,
      sold30d: 4,
    ),
    InventoryItem(
      name: 'Kemasan Box M',
      category: 'Kemasan',
      price: 'Rp 2.500',
      stock: 40,
      unit: 'pcs',
      icon: Icons.inventory_2_outlined,
      sold30d: 75,
    ),
  ];
}

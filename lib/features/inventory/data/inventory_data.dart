import 'package:flutter/material.dart';

import '../../../core/format/format.dart';
import 'inventory_repository.dart';
import 'product_icons.dart';

enum InventoryStatus { inStock, lowStock, outOfStock }

/// A product as the inventory screens show it, built from a database row.
class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.priceIdr,
    required this.stock,
    required this.unit,
    required this.iconKey,
    required this.sold30d,
  });

  factory InventoryItem.fromRecord(ItemRecord record) {
    return InventoryItem(
      id: record.id,
      name: record.name,
      category: record.category,
      priceIdr: record.priceIdr,
      stock: record.stock,
      unit: record.unit,
      iconKey: record.iconKey,
      sold30d: record.soldLast30d,
    );
  }

  final int id;
  final String name;
  final String category;
  final int priceIdr;
  final int stock;
  final String unit;
  final String iconKey;

  /// Units sold in the last 30 days. Used to rank card colors.
  final int sold30d;

  String get price => rupiah(priceIdr);

  IconData get icon => iconForKey(iconKey);

  InventoryStatus get status {
    if (stock == 0) return InventoryStatus.outOfStock;
    if (stock < 10) return InventoryStatus.lowStock;
    return InventoryStatus.inStock;
  }

  String get stockLabel => 'Stok: $stock $unit';
}

class InventoryData {
  InventoryData._();

  static const categories = ['Semua', 'Roti', 'Bahan', 'Kemasan'];
}

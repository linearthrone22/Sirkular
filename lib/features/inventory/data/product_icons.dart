import 'package:flutter/material.dart';

/// One placeholder product icon. Generated from docs/icon-pack.md.
/// The PNG lives at assets/icons/products/<key>.png. Until it exists, the
/// [fallback] Material icon is shown.
class ProductIcon {
  const ProductIcon({
    required this.key,
    required this.label,
    required this.group,
    required this.fallback,
  });

  final String key;
  final String label;
  final String group;
  final IconData fallback;
}

const productIcons = <ProductIcon>[
  ProductIcon(
      key: 'bakery',
      label: 'Roti tawar',
      group: 'Roti & kue',
      fallback: Icons.bakery_dining_outlined),
  ProductIcon(
      key: 'cake',
      label: 'Kue',
      group: 'Roti & kue',
      fallback: Icons.cake_outlined),
  ProductIcon(
      key: 'cookie',
      label: 'Kukis',
      group: 'Roti & kue',
      fallback: Icons.cookie_outlined),
  ProductIcon(
      key: 'icecream',
      label: 'Puding / dessert',
      group: 'Roti & kue',
      fallback: Icons.icecream_outlined),
  ProductIcon(
      key: 'muffin',
      label: 'Muffin',
      group: 'Roti & kue',
      fallback: Icons.bakery_dining_outlined),
  ProductIcon(
      key: 'croissant',
      label: 'Croissant',
      group: 'Roti & kue',
      fallback: Icons.bakery_dining_outlined),
  ProductIcon(
      key: 'donut',
      label: 'Donat',
      group: 'Roti & kue',
      fallback: Icons.donut_small_outlined),
  ProductIcon(
      key: 'bread_bun',
      label: 'Roti kecil',
      group: 'Roti & kue',
      fallback: Icons.bakery_dining_outlined),
  ProductIcon(
      key: 'rice',
      label: 'Nasi',
      group: 'Makanan',
      fallback: Icons.restaurant_outlined),
  ProductIcon(
      key: 'noodle',
      label: 'Mie',
      group: 'Makanan',
      fallback: Icons.ramen_dining_outlined),
  ProductIcon(
      key: 'sandwich',
      label: 'Sandwich',
      group: 'Makanan',
      fallback: Icons.lunch_dining_outlined),
  ProductIcon(
      key: 'burger',
      label: 'Burger',
      group: 'Makanan',
      fallback: Icons.lunch_dining_outlined),
  ProductIcon(
      key: 'pizza',
      label: 'Pizza',
      group: 'Makanan',
      fallback: Icons.local_pizza_outlined),
  ProductIcon(
      key: 'fried_chicken',
      label: 'Ayam goreng',
      group: 'Makanan',
      fallback: Icons.lunch_dining_outlined),
  ProductIcon(
      key: 'egg',
      label: 'Telur',
      group: 'Makanan',
      fallback: Icons.egg_outlined),
  ProductIcon(
      key: 'tempe',
      label: 'Tempe',
      group: 'Makanan',
      fallback: Icons.square_outlined),
  ProductIcon(
      key: 'tahu',
      label: 'Tahu',
      group: 'Makanan',
      fallback: Icons.square_outlined),
  ProductIcon(
      key: 'fish',
      label: 'Ikan',
      group: 'Makanan',
      fallback: Icons.set_meal_outlined),
  ProductIcon(
      key: 'chili',
      label: 'Cabai',
      group: 'Makanan',
      fallback: Icons.local_fire_department_outlined),
  ProductIcon(
      key: 'vegetable',
      label: 'Sayur',
      group: 'Makanan',
      fallback: Icons.eco_outlined),
  ProductIcon(
      key: 'fruit',
      label: 'Buah',
      group: 'Makanan',
      fallback: Icons.local_grocery_store_outlined),
  ProductIcon(
      key: 'snack_bag',
      label: 'Keripik',
      group: 'Makanan',
      fallback: Icons.fastfood_outlined),
  ProductIcon(
      key: 'frozen',
      label: 'Makanan beku',
      group: 'Makanan',
      fallback: Icons.ac_unit_outlined),
  ProductIcon(
      key: 'food_tray',
      label: 'Katering',
      group: 'Makanan',
      fallback: Icons.takeout_dining_outlined),
  ProductIcon(
      key: 'coffee',
      label: 'Kopi',
      group: 'Minuman',
      fallback: Icons.local_cafe_outlined),
  ProductIcon(
      key: 'tea',
      label: 'Teh',
      group: 'Minuman',
      fallback: Icons.local_cafe_outlined),
  ProductIcon(
      key: 'juice',
      label: 'Jus',
      group: 'Minuman',
      fallback: Icons.local_drink_outlined),
  ProductIcon(
      key: 'bottle',
      label: 'Botol minuman',
      group: 'Minuman',
      fallback: Icons.sports_bar_outlined),
  ProductIcon(
      key: 'boba',
      label: 'Boba',
      group: 'Minuman',
      fallback: Icons.local_bar_outlined),
  ProductIcon(
      key: 'grain',
      label: 'Tepung',
      group: 'Bahan baku',
      fallback: Icons.grain),
  ProductIcon(
      key: 'sugar',
      label: 'Gula',
      group: 'Bahan baku',
      fallback: Icons.breakfast_dining_outlined),
  ProductIcon(
      key: 'salt',
      label: 'Garam',
      group: 'Bahan baku',
      fallback: Icons.opacity_outlined),
  ProductIcon(
      key: 'spice',
      label: 'Bumbu',
      group: 'Bahan baku',
      fallback: Icons.soup_kitchen_outlined),
  ProductIcon(
      key: 'oil',
      label: 'Minyak goreng',
      group: 'Bahan baku',
      fallback: Icons.oil_barrel_outlined),
  ProductIcon(
      key: 'milk',
      label: 'Susu',
      group: 'Bahan baku',
      fallback: Icons.local_drink_outlined),
  ProductIcon(
      key: 'butter',
      label: 'Mentega',
      group: 'Bahan baku',
      fallback: Icons.breakfast_dining_outlined),
  ProductIcon(
      key: 'cheese',
      label: 'Keju',
      group: 'Bahan baku',
      fallback: Icons.breakfast_dining_outlined),
  ProductIcon(
      key: 'drop',
      label: 'Sirup / cairan',
      group: 'Bahan baku',
      fallback: Icons.water_drop_outlined),
  ProductIcon(
      key: 'honey',
      label: 'Madu',
      group: 'Bahan baku',
      fallback: Icons.hive_outlined),
  ProductIcon(
      key: 'chocolate',
      label: 'Cokelat',
      group: 'Bahan baku',
      fallback: Icons.cookie_outlined),
  ProductIcon(
      key: 'coffee_beans',
      label: 'Biji kopi',
      group: 'Bahan baku',
      fallback: Icons.coffee_maker_outlined),
  ProductIcon(
      key: 'herb',
      label: 'Rempah & jamu',
      group: 'Bahan baku',
      fallback: Icons.spa_outlined),
  ProductIcon(
      key: 'box',
      label: 'Kardus / kotak',
      group: 'Kemasan',
      fallback: Icons.inventory_2_outlined),
  ProductIcon(
      key: 'paper_bag',
      label: 'Tas kertas',
      group: 'Kemasan',
      fallback: Icons.shopping_bag_outlined),
  ProductIcon(
      key: 'jar',
      label: 'Toples',
      group: 'Kemasan',
      fallback: Icons.science_outlined),
  ProductIcon(
      key: 'pouch',
      label: 'Kemasan pouch',
      group: 'Kemasan',
      fallback: Icons.wallet_outlined),
  ProductIcon(
      key: 'label_tag',
      label: 'Label harga',
      group: 'Kemasan',
      fallback: Icons.sell_outlined),
  ProductIcon(
      key: 'shirt',
      label: 'Kemeja / kaos',
      group: 'Fashion & tekstil',
      fallback: Icons.checkroom_outlined),
  ProductIcon(
      key: 'dress',
      label: 'Gaun',
      group: 'Fashion & tekstil',
      fallback: Icons.checkroom_outlined),
  ProductIcon(
      key: 'pants',
      label: 'Celana',
      group: 'Fashion & tekstil',
      fallback: Icons.checkroom_outlined),
  ProductIcon(
      key: 'shoe',
      label: 'Sepatu',
      group: 'Fashion & tekstil',
      fallback: Icons.directions_walk_outlined),
  ProductIcon(
      key: 'bag',
      label: 'Tas',
      group: 'Fashion & tekstil',
      fallback: Icons.shopping_bag_outlined),
  ProductIcon(
      key: 'hat',
      label: 'Topi',
      group: 'Fashion & tekstil',
      fallback: Icons.checkroom_outlined),
  ProductIcon(
      key: 'batik',
      label: 'Kain batik',
      group: 'Fashion & tekstil',
      fallback: Icons.texture),
  ProductIcon(
      key: 'fabric_roll',
      label: 'Kain gulung',
      group: 'Fashion & tekstil',
      fallback: Icons.texture),
  ProductIcon(
      key: 'candle',
      label: 'Lilin',
      group: 'Kerajinan & rumah tangga',
      fallback: Icons.light_outlined),
  ProductIcon(
      key: 'soap',
      label: 'Sabun',
      group: 'Kerajinan & rumah tangga',
      fallback: Icons.clean_hands_outlined),
  ProductIcon(
      key: 'basket',
      label: 'Keranjang anyaman',
      group: 'Kerajinan & rumah tangga',
      fallback: Icons.shopping_basket_outlined),
  ProductIcon(
      key: 'vase',
      label: 'Gerabah',
      group: 'Kerajinan & rumah tangga',
      fallback: Icons.filter_vintage_outlined),
  ProductIcon(
      key: 'wood',
      label: 'Kayu',
      group: 'Kerajinan & rumah tangga',
      fallback: Icons.forest_outlined),
  ProductIcon(
      key: 'towel',
      label: 'Handuk',
      group: 'Kerajinan & rumah tangga',
      fallback: Icons.dry_cleaning_outlined),
  ProductIcon(
      key: 'cleaner',
      label: 'Pembersih',
      group: 'Kerajinan & rumah tangga',
      fallback: Icons.cleaning_services_outlined),
  ProductIcon(
      key: 'lotion',
      label: 'Lotion',
      group: 'Kecantikan & kesehatan',
      fallback: Icons.sanitizer_outlined),
  ProductIcon(
      key: 'lipstick',
      label: 'Lipstik',
      group: 'Kecantikan & kesehatan',
      fallback: Icons.brush_outlined),
  ProductIcon(
      key: 'perfume',
      label: 'Parfum',
      group: 'Kecantikan & kesehatan',
      fallback: Icons.air_outlined),
  ProductIcon(
      key: 'jamu',
      label: 'Jamu botol',
      group: 'Kecantikan & kesehatan',
      fallback: Icons.local_pharmacy_outlined),
  ProductIcon(
      key: 'face_mask',
      label: 'Masker',
      group: 'Kecantikan & kesehatan',
      fallback: Icons.masks_outlined),
  ProductIcon(
      key: 'seedling',
      label: 'Bibit',
      group: 'Pertanian',
      fallback: Icons.grass_outlined),
  ProductIcon(
      key: 'coconut',
      label: 'Kelapa',
      group: 'Pertanian',
      fallback: Icons.circle_outlined),
  ProductIcon(
      key: 'rice_sack',
      label: 'Beras',
      group: 'Pertanian',
      fallback: Icons.agriculture_outlined),
  ProductIcon(
      key: 'phone',
      label: 'Ponsel',
      group: 'Elektronik & jasa',
      fallback: Icons.smartphone_outlined),
  ProductIcon(
      key: 'laptop',
      label: 'Laptop',
      group: 'Elektronik & jasa',
      fallback: Icons.laptop_outlined),
  ProductIcon(
      key: 'battery',
      label: 'Baterai',
      group: 'Elektronik & jasa',
      fallback: Icons.battery_std_outlined),
  ProductIcon(
      key: 'cable',
      label: 'Kabel',
      group: 'Elektronik & jasa',
      fallback: Icons.cable_outlined),
  ProductIcon(
      key: 'headphone',
      label: 'Headphone',
      group: 'Elektronik & jasa',
      fallback: Icons.headphones_outlined),
  ProductIcon(
      key: 'printer',
      label: 'Printer',
      group: 'Elektronik & jasa',
      fallback: Icons.print_outlined),
  ProductIcon(
      key: 'stationery',
      label: 'Alat tulis',
      group: 'Elektronik & jasa',
      fallback: Icons.edit_outlined),
  ProductIcon(
      key: 'repair_tool',
      label: 'Perkakas',
      group: 'Elektronik & jasa',
      fallback: Icons.build_outlined),
  ProductIcon(
      key: 'pet_food',
      label: 'Makanan hewan',
      group: 'Hewan peliharaan',
      fallback: Icons.pets_outlined),
  ProductIcon(
      key: 'deadstock',
      label: 'Deadstock',
      group: 'Sirkular & limbah',
      fallback: Icons.warning_amber_outlined),
  ProductIcon(
      key: 'recycle',
      label: 'Daur ulang',
      group: 'Sirkular & limbah',
      fallback: Icons.recycling_outlined),
  ProductIcon(
      key: 'compost',
      label: 'Kompos',
      group: 'Sirkular & limbah',
      fallback: Icons.grass_outlined),
  ProductIcon(
      key: 'waste',
      label: 'Limbah',
      group: 'Sirkular & limbah',
      fallback: Icons.delete_outline),
  ProductIcon(
      key: 'eco',
      label: 'Ramah lingkungan',
      group: 'Sirkular & limbah',
      fallback: Icons.eco_outlined),
  ProductIcon(
      key: 'inventory',
      label: 'Produk umum',
      group: 'Umum',
      fallback: Icons.inventory_2_outlined),
];

/// Fallback icon for a stored key. Unknown keys get the generic box.
IconData iconForKey(String key) {
  for (final icon in productIcons) {
    if (icon.key == key) return icon.fallback;
  }
  return Icons.inventory_2_outlined;
}

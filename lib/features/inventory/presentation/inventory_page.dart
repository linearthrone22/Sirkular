import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/inventory_data.dart';
import '../data/inventory_repository.dart';
import 'add_item_sheet.dart';
import 'mix_match_pages.dart';
import 'publish_sheet.dart';
import 'restock_sheet.dart';

/// Product grid backed by SQLite. Tap a card to restock, tick the checkbox
/// to select. Cards are shaded by sales: best sellers mint, slow movers grey.
class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key, required this.userId});

  final int userId;

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final _inventory = InventoryRepository();
  final _searchController = TextEditingController();
  final Set<int> _selected = {};
  late Future<List<InventoryItem>> _future = _load();
  String _query = '';
  String _category = InventoryData.categories.first;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<InventoryItem>> _load() async {
    final records = await _inventory.items(widget.userId);
    return [for (final r in records) InventoryItem.fromRecord(r)];
  }

  void _reload() {
    setState(() => _future = _load());
  }

  List<InventoryItem> _visible(List<InventoryItem> all) {
    final query = _query.toLowerCase();
    return all.where((item) {
      final matchesCategory =
          _category == 'Semua' || item.category == _category;
      final matchesQuery = item.name.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  /// 0 for the best seller, 1 for the slowest. Based on all items.
  double _salesRank(List<InventoryItem> all, InventoryItem item) {
    final ranked = List.of(all)..sort((a, b) => b.sold30d.compareTo(a.sold30d));
    final index = ranked.indexWhere((i) => i.id == item.id);
    if (ranked.length <= 1) return 0;
    return index / (ranked.length - 1);
  }

  List<Color> _gradientFor(double rank) {
    if (rank == 0) return const [AppColors.mint, AppColors.mintDeep];
    if (rank <= 0.5) return const [AppColors.mintSoft, AppColors.surface];
    return const [Color(0xFFE4E6EA), AppColors.surface];
  }

  void _toggleSelected(InventoryItem item) {
    setState(() {
      if (!_selected.remove(item.id)) _selected.add(item.id);
    });
  }

  List<InventoryItem> _picked(List<InventoryItem> all) =>
      all.where((i) => _selected.contains(i.id)).toList();

  Future<void> _restock(InventoryItem item) async {
    final newStock = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (_) => RestockSheet(item: item),
    );
    if (newStock == null || newStock == item.stock) return;
    await _inventory.adjustStock(
      item.id,
      newStock - item.stock,
      reason: StockReason.restock,
      note: newStock > item.stock ? 'Restok manual' : 'Koreksi stok manual',
    );
    _reload();
  }

  Future<void> _addItem() async {
    final item = await showModalBottomSheet<NewItem>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const AddItemSheet(),
    );
    if (item == null) return;
    await _inventory.addItem(widget.userId, item);
    _reload();
  }

  Future<void> _openMixMatch(List<InventoryItem> all) async {
    final picked = _picked(all);
    if (picked.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Centang bahan dulu untuk dicampur.')),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            MixMatchLoadingPage(userId: widget.userId, items: picked),
      ),
    );
    _reload();
  }

  Future<void> _openPublish(List<InventoryItem> all) async {
    final picked = _picked(all);
    if (picked.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Centang produk yang akan dijual.')),
      );
      return;
    }
    final platforms = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => PublishSheet(items: picked),
    );
    if (platforms == null || platforms.isEmpty) return;

    for (final item in picked) {
      for (final name in platforms) {
        final key = _platformKey(name);
        await _inventory.setListing(
          item.id,
          key,
          status: 'live',
          externalId: 'SKU-${item.id}-$key',
        );
      }
    }
    setState(_selected.clear);
    _reload();
  }

  String _platformKey(String name) {
    switch (name) {
      case 'Shopee':
        return 'shopee';
      case 'TikTok Shop':
        return 'tiktok';
      default:
        return 'tokopedia';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder<List<InventoryItem>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
                child: Text('Gagal memuat inventory: ${snapshot.error}')),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final all = snapshot.requireData;
        final items = _visible(all);

        return Scaffold(
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        children: [
                          _RoundButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                          Expanded(
                            child: Text(
                              'Inventory',
                              textAlign: TextAlign.center,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          _RoundButton(
                            icon: Icons.more_horiz_rounded,
                            onTap: () {
                              // TODO: inventory menu
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _query = value),
                        decoration: InputDecoration(
                          hintText: 'Cari produk...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: const BorderSide(color: AppColors.ink),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 52,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        children: [
                          for (final category in InventoryData.categories)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(category),
                                selected: _category == category,
                                onSelected: (_) =>
                                    setState(() => _category = category),
                                selectedColor: AppColors.mint,
                                backgroundColor: AppColors.surface,
                                side: BorderSide.none,
                                showCheckmark: false,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                      child: Text(
                        'Ketuk kartu untuk restok · centang untuk pilih',
                        style: textTheme.labelSmall
                            ?.copyWith(color: AppColors.muted),
                      ),
                    ),
                    Expanded(
                      child: items.isEmpty
                          ? Center(
                              child: Text(
                                all.isEmpty
                                    ? 'Belum ada produk. Tekan + untuk menambah.'
                                    : 'Produk tidak ditemukan',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.muted,
                                ),
                              ),
                            )
                          : GridView.count(
                              crossAxisCount: 2,
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.66,
                              children: [
                                for (final item in items)
                                  _ItemCard(
                                    item: item,
                                    selected: _selected.contains(item.id),
                                    gradient:
                                        _gradientFor(_salesRank(all, item)),
                                    onSelect: () => _toggleSelected(item),
                                    onRestock: () => _restock(item),
                                  ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 12,
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 6,
                        shadowColor: Colors.black.withValues(alpha: 0.3),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _addItem,
                          child: const SizedBox(
                            width: 60,
                            height: 60,
                            child: Icon(
                              Icons.add_rounded,
                              color: AppColors.ink,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openMixMatch(all),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.purple,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 60),
                            shape: const StadiumBorder(),
                          ),
                          icon: const Icon(Icons.auto_awesome, size: 18),
                          label: Text(
                            _selected.isEmpty
                                ? 'Buat Resep AI'
                                : 'Buat Resep AI (${_selected.length})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () => _openPublish(all),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 60),
                          shape: const StadiumBorder(),
                        ),
                        icon: const Icon(Icons.storefront_outlined, size: 18),
                        label: const Text('Jual'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.selected,
    required this.gradient,
    required this.onSelect,
    required this.onRestock,
  });

  final InventoryItem item;
  final bool selected;
  final List<Color> gradient;
  final VoidCallback onSelect;
  final VoidCallback onRestock;

  Color get _statusColor {
    switch (item.status) {
      case InventoryStatus.inStock:
        return AppColors.mintDeep;
      case InventoryStatus.lowStock:
        return AppColors.orange;
      case InventoryStatus.outOfStock:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onRestock,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(24),
          border:
              selected ? Border.all(color: AppColors.ink, width: 1.5) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onSelect,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: _Checkbox(selected: selected),
                  ),
                ),
                const Spacer(),
                Text(
                  item.category,
                  style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(item.icon, size: 40, color: AppColors.ink),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              '${item.price} · terjual ${item.sold30d}x',
              style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                item.stockLabel,
                style:
                    textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.ink : Colors.transparent,
        border: Border.all(color: AppColors.ink, width: 1.2),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
          : null,
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon),
        ),
      ),
    );
  }
}

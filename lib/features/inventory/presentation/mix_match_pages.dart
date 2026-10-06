import 'package:flutter/material.dart';

import '../../../core/format/format.dart';
import '../../../core/theme/app_colors.dart';
import '../../dashboard/presentation/widgets/dashboard_widgets.dart';
import '../data/inventory_data.dart';
import '../data/recipe_data.dart';
import '../data/recipe_repository.dart';

/// Full-screen loading with a pulsing AI spark and cycling status text.
/// Saves the ideas to SQLite, then opens the results.
class MixMatchLoadingPage extends StatefulWidget {
  const MixMatchLoadingPage({
    super.key,
    required this.userId,
    required this.items,
  });

  final int userId;
  final List<InventoryItem> items;

  @override
  State<MixMatchLoadingPage> createState() => _MixMatchLoadingPageState();
}

class _MixMatchLoadingPageState extends State<MixMatchLoadingPage>
    with SingleTickerProviderStateMixin {
  final _recipes = RecipeRepository();

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  int _step = 0;

  @override
  void initState() {
    super.initState();
    _run();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final sourceIds = [for (final i in widget.items) i.id];
    final requestId = await _recipes.startRequest(
      widget.userId,
      kind: 'mix_match',
      input: {'items': sourceIds},
    );
    try {
      for (var i = 0; i < RecipeData.loadingMessages.length; i++) {
        if (!mounted) return;
        setState(() => _step = i);
        await Future<void>.delayed(const Duration(milliseconds: 1200));
      }

      // TODO: replace RecipeData.ideas with the Gemini response.
      final recipeIds = await _recipes.saveRecipes(
        widget.userId,
        requestId: requestId,
        sourceItemIds: sourceIds,
        drafts: [for (final idea in RecipeData.ideas) idea.toDraft()],
      );
      await _recipes
          .completeRequest(requestId, output: {'recipeIds': recipeIds});

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MixMatchResultsPage(
            userId: widget.userId,
            recipeIds: recipeIds,
            sourceNames: [for (final i in widget.items) i.name],
          ),
        ),
      );
    } catch (e) {
      await _recipes.failRequest(requestId, error: '$e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat resep: $e')),
      );
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.purple, AppColors.mintDeep],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.9, end: 1.12).animate(
                      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 96,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      RecipeData.loadingMessages[_step],
                      key: ValueKey<int>(_step),
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${widget.items.length} bahan dipilih',
                    style:
                        textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The saved ideas for one request, loaded from SQLite.
class MixMatchResultsPage extends StatelessWidget {
  const MixMatchResultsPage({
    super.key,
    required this.userId,
    required this.recipeIds,
    required this.sourceNames,
  });

  final int userId;
  final List<int> recipeIds;
  final List<String> sourceNames;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final recipes = RecipeRepository();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                const _BackButton(),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ide Produk Baru',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Dari ${sourceNames.length} bahan: ${sourceNames.join(', ')}',
              style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<RecipeDetail?>>(
              future:
                  Future.wait([for (final id in recipeIds) recipes.recipe(id)]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return Column(
                  children: [
                    for (final detail in snapshot.requireData)
                      if (detail != null) ...[
                        _IdeaCard(
                          detail: detail,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RecipeDetailPage(
                                userId: userId,
                                recipeId: detail.recipe.id,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _IdeaCard extends StatelessWidget {
  const _IdeaCard({required this.detail, required this.onTap});

  final RecipeDetail detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final recipe = detail.recipe;
    final easy = recipe.difficulty == 'Mudah';

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: DashCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.mintSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(iconForKey(recipe.iconKey), color: AppColors.ink),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    recipe.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                StatusBadge(
                  text: 'Kesulitan: ${recipe.difficulty}',
                  color: easy ? AppColors.mint : AppColors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _Metric(label: 'HPP', value: rupiah(recipe.hppIdr)),
                _Metric(
                    label: 'Harga jual', value: rupiah(recipe.sellPriceIdr)),
                _Metric(
                  label: 'Potensi profit',
                  value: rupiah(recipe.profitIdr),
                  highlight: true,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Lihat langkah pembuatan →',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: highlight ? AppColors.mintDeep : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// One saved idea with its steps and the main action.
class RecipeDetailPage extends StatelessWidget {
  const RecipeDetailPage({
    super.key,
    required this.userId,
    required this.recipeId,
  });

  final int userId;
  final int recipeId;

  Future<void> _saveToInventory(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final name = await _name();
    await RecipeRepository().saveRecipeToInventory(userId, recipeId);
    // Pop detail, results, and back to the inventory.
    navigator
      ..pop()
      ..pop();
    messenger.showSnackBar(
      SnackBar(content: Text('$name disimpan ke Inventory & siap dijual')),
    );
  }

  Future<String> _name() async {
    final detail = await RecipeRepository().recipe(recipeId);
    return detail?.recipe.name ?? 'Produk';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: FutureBuilder<RecipeDetail?>(
        future: RecipeRepository().recipe(recipeId),
        builder: (context, snapshot) {
          final detail = snapshot.data;
          if (detail == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final recipe = detail.recipe;
          return Column(
            children: [
              Expanded(
                child: SafeArea(
                  bottom: false,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    children: [
                      Row(
                        children: [
                          const _BackButton(),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              recipe.name,
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DashCard(
                        child: Row(
                          children: [
                            _Metric(label: 'HPP', value: rupiah(recipe.hppIdr)),
                            _Metric(
                              label: 'Harga jual',
                              value: rupiah(recipe.sellPriceIdr),
                            ),
                            _Metric(
                              label: 'Profit',
                              value: rupiah(recipe.profitIdr),
                              highlight: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const SectionTitle('Bahan'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final ingredient in detail.ingredients)
                            Chip(
                              label: Text(ingredient),
                              side: BorderSide.none,
                              backgroundColor: AppColors.surface,
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const SectionTitle('Langkah pembuatan'),
                      const SizedBox(height: 10),
                      for (var i = 0; i < detail.steps.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DashCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.ink,
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    detail.steps[i],
                                    style: textTheme.bodyMedium
                                        ?.copyWith(height: 1.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: ElevatedButton.icon(
                    onPressed: recipe.status == 'saved'
                        ? null
                        : () => _saveToInventory(context),
                    icon: const Icon(Icons.inventory_2_outlined, size: 18),
                    label: Text(
                      recipe.status == 'saved'
                          ? 'Sudah ada di Inventory'
                          : 'Simpan ke Inventory & Siap Jual',
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Navigator.of(context).maybePop(),
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(Icons.arrow_back_rounded),
        ),
      ),
    );
  }
}

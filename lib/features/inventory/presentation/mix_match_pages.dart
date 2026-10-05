import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../dashboard/presentation/widgets/dashboard_widgets.dart';
import '../data/inventory_data.dart';
import '../data/recipe_data.dart';

/// Full-screen loading with a pulsing AI spark and cycling status text.
class MixMatchLoadingPage extends StatefulWidget {
  const MixMatchLoadingPage({super.key, required this.items});

  final List<InventoryItem> items;

  @override
  State<MixMatchLoadingPage> createState() => _MixMatchLoadingPageState();
}

class _MixMatchLoadingPageState extends State<MixMatchLoadingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  int _step = 0;

  @override
  void initState() {
    super.initState();
    _runSteps();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _runSteps() async {
    for (var i = 0; i < RecipeData.loadingMessages.length; i++) {
      if (!mounted) return;
      setState(() => _step = i);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
    }
    if (!mounted) return;
    // TODO: replace the timer with the real Gemini response.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MixMatchResultsPage(items: widget.items),
      ),
    );
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

/// Three product ideas built from the selected ingredients.
class MixMatchResultsPage extends StatelessWidget {
  const MixMatchResultsPage({super.key, required this.items});

  final List<InventoryItem> items;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sources = items.map((i) => i.name).join(', ');

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                _BackButton(),
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
              'Dari ${items.length} bahan: $sources',
              style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            for (final idea in RecipeData.ideas) ...[
              _IdeaCard(
                idea: idea,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => RecipeDetailPage(idea: idea)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _IdeaCard extends StatelessWidget {
  const _IdeaCard({required this.idea, required this.onTap});

  final RecipeIdea idea;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final easy = idea.difficulty == 'Mudah';

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
                  child: Icon(idea.icon, color: AppColors.ink),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    idea.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                StatusBadge(
                  text: 'Kesulitan: ${idea.difficulty}',
                  color: easy ? AppColors.mint : AppColors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _Metric(label: 'HPP', value: idea.hpp),
                _Metric(label: 'Harga jual', value: idea.sellPrice),
                _Metric(
                  label: 'Potensi profit',
                  value: idea.profit,
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

/// Step-by-step recipe with the main action at the bottom.
class RecipeDetailPage extends StatelessWidget {
  const RecipeDetailPage({super.key, required this.idea});

  final RecipeIdea idea;

  void _saveToInventory(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    // Pop detail, results, and the inventory's loading path back to inventory.
    Navigator.of(context)
      ..pop()
      ..pop();
    messenger.showSnackBar(
      SnackBar(
          content: Text('${idea.name} disimpan ke Inventory & siap dijual')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: ElevatedButton.icon(
            onPressed: () => _saveToInventory(context),
            icon: const Icon(Icons.inventory_2_outlined, size: 18),
            label: const Text('Simpan ke Inventory & Siap Jual'),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          children: [
            Row(
              children: [
                _BackButton(),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    idea.name,
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
                  _Metric(label: 'HPP', value: idea.hpp),
                  _Metric(label: 'Harga jual', value: idea.sellPrice),
                  _Metric(
                    label: 'Profit',
                    value: idea.profit,
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
                for (final ingredient in idea.ingredients)
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
            for (var i = 0; i < idea.steps.length; i++)
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
                          idea.steps[i],
                          style: textTheme.bodyMedium?.copyWith(height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
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

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/insight_data.dart';

/// Story-style viewer for the insight cards: full-screen slides, progress
/// bars, tap or swipe to move, and auto-advance. Hold to pause.
class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage>
    with SingleTickerProviderStateMixin {
  static const _slideDuration = Duration(seconds: 6);

  final _pageController = PageController();
  final _items = InsightData.items;
  int _index = 0;

  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: _slideDuration,
  )..addStatusListener((status) {
      if (status == AnimationStatus.completed) _next();
    });

  @override
  void initState() {
    super.initState();
    _progress.forward();
  }

  @override
  void dispose() {
    _progress.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _index = index);
    _progress
      ..stop()
      ..forward(from: 0);
  }

  void _previous() {
    if (_index == 0) {
      _progress.forward(from: 0);
      return;
    }
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _next() {
    if (_index == _items.length - 1) {
      Navigator.of(context).maybePop();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _pause() => _progress.stop();

  void _resume() => _progress.forward();

  @override
  Widget build(BuildContext context) {
    final current = _items[_index];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _items.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (_, i) => _InsightSlide(insight: _items[i]),
          ),
          // Tap zones: left third goes back, the rest goes forward.
          Positioned.fill(
            bottom: 120,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _previous,
                    onLongPressStart: (_) => _pause(),
                    onLongPressEnd: (_) => _resume(),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _next,
                    onLongPressStart: (_) => _pause(),
                    onLongPressEnd: (_) => _resume(),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < _items.length; i++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: _ProgressSegment(
                              state: i < _index
                                  ? _SegmentState.done
                                  : i == _index
                                      ? _SegmentState.active
                                      : _SegmentState.todo,
                              progress: _progress,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Insights',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '${_index + 1}/${_items.length}',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        color: Colors.white,
                        tooltip: 'Tutup',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: SafeArea(
              top: false,
              child: Center(
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () {
                      // TODO: run the insight's action
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${current.action} — segera hadir'),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            current.action,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.ink,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _SegmentState { done, active, todo }

class _ProgressSegment extends StatelessWidget {
  const _ProgressSegment({required this.state, required this.progress});

  final _SegmentState state;
  final AnimationController progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 3,
        color: Colors.white.withValues(alpha: 0.35),
        child: AnimatedBuilder(
          animation: progress,
          builder: (context, _) {
            final factor = switch (state) {
              _SegmentState.done => 1.0,
              _SegmentState.active => progress.value,
              _SegmentState.todo => 0.0,
            };
            return FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: factor,
              child: Container(color: Colors.white),
            );
          },
        ),
      ),
    );
  }
}

/// One full-screen story slide: big title, body, and a tone-based gradient.
class _InsightSlide extends StatelessWidget {
  const _InsightSlide({required this.insight});

  final Insight insight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = _styleFor(insight);

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 120, 28, 110),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: style.colors,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: style.fg.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(insight.icon, color: style.fg, size: 36),
          ),
          const Spacer(),
          Text(
            insight.category.toUpperCase(),
            style: textTheme.labelLarge?.copyWith(
              color: style.fg.withValues(alpha: 0.75),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            insight.title,
            style: textTheme.displaySmall?.copyWith(
              color: style.fg,
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            insight.body,
            style: textTheme.headlineSmall?.copyWith(
              color: style.fg.withValues(alpha: 0.88),
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideStyle {
  const _SlideStyle(this.colors, this.fg);

  final List<Color> colors;
  final Color fg;
}

_SlideStyle _styleFor(Insight insight) {
  // Purple is reserved for AI, so only the AI R&D insight uses it.
  if (insight.category == 'AI R&D') {
    return const _SlideStyle(
      [AppColors.purple, AppColors.mintDeep],
      Colors.white,
    );
  }
  switch (insight.tone) {
    case InsightTone.alert:
      return const _SlideStyle(
        [Color(0xFFFFD9B0), AppColors.orange],
        AppColors.ink,
      );
    case InsightTone.info:
      return const _SlideStyle(
        [AppColors.ink, Color(0xFF3A3A3A)],
        Colors.white,
      );
    case InsightTone.success:
      return const _SlideStyle(
        [AppColors.mint, Color(0xFFBDF2DC)],
        AppColors.ink,
      );
  }
}

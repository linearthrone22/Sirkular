import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sirkular/core/theme/app_theme.dart';
import 'package:sirkular/features/auth/data/user_repository.dart';
import 'package:sirkular/features/dashboard/data/platform_data.dart';
import 'package:sirkular/features/dashboard/presentation/home_page.dart';
import 'package:sirkular/features/dashboard/presentation/insights_page.dart';
import 'package:sirkular/features/dashboard/presentation/platform_analytics_page.dart';
import 'package:sirkular/features/inventory/data/inventory_data.dart';
import 'package:sirkular/features/inventory/data/recipe_data.dart';
import 'package:sirkular/features/inventory/presentation/inventory_page.dart';
import 'package:sirkular/features/inventory/presentation/mix_match_pages.dart';

const _user = User(id: 1, name: 'Kopi Senja', email: 'kopi@senja.id');

Future<void> _pumpPhone(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: home));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('inventory page lays out and filters by search', (tester) async {
    await _pumpPhone(tester, const InventoryPage());

    expect(tester.takeException(), isNull);
    expect(find.text('Roti Tawar Sisa'), findsOneWidget);
    expect(find.text('Buat Resep AI'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'tepung');
    await tester.pump();

    expect(find.text('Tepung Terigu 1kg'), findsOneWidget);
    expect(find.text('Roti Tawar Sisa'), findsNothing);
  });

  testWidgets('ticking a product updates the AI button count', (tester) async {
    await _pumpPhone(tester, const InventoryPage());

    final card = find
        .ancestor(
          of: find.text('Roti Tawar Sisa'),
          matching: find.byType(AnimatedContainer),
        )
        .first;
    final checkbox =
        find.descendant(of: card, matching: find.byType(GestureDetector)).first;
    await tester.tap(checkbox);
    await tester.pump();
    expect(find.text('Buat Resep AI'), findsNothing);
    expect(find.text('Buat Resep AI (1)'), findsOneWidget);
  });

  testWidgets('tapping a card opens the quick restock sheet', (tester) async {
    await _pumpPhone(tester, const InventoryPage());

    await tester.tap(find.text('Roti Tawar Sisa'));
    await tester.pumpAndSettle();
    expect(find.text('Restok produk'), findsOneWidget);
    expect(find.text('Simpan stok'), findsOneWidget);
  });

  testWidgets('dashboard shows the insight pill and no rules card',
      (tester) async {
    await _pumpPhone(tester, const HomePage(user: _user));

    expect(find.text('3 AI Alerts'), findsOneWidget);
    expect(find.text('Aturan Saya'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('insights page lists the cards', (tester) async {
    await _pumpPhone(tester, const InsightsPage());

    expect(tester.takeException(), isNull);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Roti tawar mendekati kedaluwarsa'), findsOneWidget);
  });

  testWidgets('platform analytics page renders for Tokopedia', (tester) async {
    await _pumpPhone(
        tester, const PlatformAnalyticsPage(data: PlatformData.tokopedia));
    await tester.dragUntilVisible(
      find.text('Pengaturan Tokopedia'),
      find.byType(ListView),
      const Offset(0, -300),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Auto-reply chat'), findsOneWidget);
  });

  testWidgets('idea results and recipe detail render', (tester) async {
    await _pumpPhone(
      tester,
      MixMatchResultsPage(items: InventoryData.items.take(2).toList()),
    );

    expect(tester.takeException(), isNull);
    expect(find.text(RecipeData.ideas.first.name), findsOneWidget);

    await tester.tap(find.text(RecipeData.ideas.first.name));
    await tester.pumpAndSettle();
    expect(find.text('Simpan ke Inventory & Siap Jual'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

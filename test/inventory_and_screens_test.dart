import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sirkular/features/dashboard/data/dashboard_service.dart';
import 'package:sirkular/features/dashboard/presentation/insights_page.dart';
import 'package:sirkular/features/dashboard/presentation/platform_analytics_page.dart';
import 'package:sirkular/features/inventory/data/recipe_repository.dart';
import 'package:sirkular/features/inventory/presentation/inventory_page.dart';
import 'package:sirkular/features/inventory/presentation/mix_match_pages.dart';

import 'support/seeded_db.dart';

Future<void> _pumpPhone(
  WidgetTester tester,
  Widget home, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MaterialApp(theme: testTheme(), home: home));
  await settle(tester);
}

void main() {
  testWidgets('inventory lists saved products and filters by search',
      (tester) async {
    final user = await openSeededTestDb(tester);
    await _pumpPhone(tester, InventoryPage(userId: user.id));

    expect(tester.takeException(), isNull);
    expect(find.text('Roti Tawar Sisa'), findsOneWidget);
    expect(find.text('Buat Resep AI'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'tepung');
    await settle(tester);

    expect(find.text('Tepung Terigu 1kg'), findsOneWidget);
    expect(find.text('Roti Tawar Sisa'), findsNothing);
  });

  testWidgets('ticking a product updates the AI button count', (tester) async {
    final user = await openSeededTestDb(tester);
    await _pumpPhone(tester, InventoryPage(userId: user.id));

    final card = find
        .ancestor(
          of: find.text('Crumble Roti'),
          matching: find.byType(AnimatedContainer),
        )
        .first;
    final checkbox =
        find.descendant(of: card, matching: find.byType(GestureDetector)).first;
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await settle(tester);

    expect(find.text('Buat Resep AI (1)'), findsOneWidget);
  });

  testWidgets('tapping a card opens the quick restock sheet', (tester) async {
    final user = await openSeededTestDb(tester);
    await _pumpPhone(tester, InventoryPage(userId: user.id));

    await tester.ensureVisible(find.text('Crumble Roti'));
    await tester.tap(find.text('Crumble Roti'));
    await tester.pumpAndSettle();
    expect(find.text('Restok produk'), findsOneWidget);
    expect(find.text('Simpan stok'), findsOneWidget);
  });

  testWidgets('insights page shows the saved insights', (tester) async {
    final user = await openSeededTestDb(tester);
    await _pumpPhone(tester, InsightsPage(userId: user.id));

    expect(tester.takeException(), isNull);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Roti tawar mendekati kedaluwarsa'), findsOneWidget);
  });

  testWidgets('platform analytics loads Tokopedia from the database',
      (tester) async {
    final user = await openSeededTestDb(tester);
    await _pumpPhone(
      tester,
      PlatformAnalyticsPage(userId: user.id, platformKey: 'tokopedia'),
    );
    expect(find.text('Tokopedia Analytics'), findsOneWidget);
    expect(find.text('3,8%'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Pengaturan Tokopedia'),
      find.byType(ListView),
      const Offset(0, -300),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Auto-reply chat'), findsOneWidget);
  });

  testWidgets('saved recipe ideas render and open the detail', (tester) async {
    final user = await openSeededTestDb(tester);
    final recipes =
        await tester.runAsync(() => RecipeRepository().recipes(user.id));
    final ids = [for (final r in recipes!) r.id];

    await _pumpPhone(
      tester,
      size: const Size(390, 1600),
      MixMatchResultsPage(
        userId: user.id,
        recipeIds: ids,
        sourceNames: const ['Crumble Roti', 'Susu UHT 1L'],
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Pudding Roti'), findsOneWidget);

    await tester.tap(
      find
          .ancestor(
            of: find.text('Pudding Roti'),
            matching: find.byType(InkWell),
          )
          .first,
    );
    await settle(tester);
    expect(find.text('Simpan ke Inventory & Siap Jual'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('platform copy and totals come from the database', () async {
    expect(platformName('tokopedia'), 'Tokopedia');
    expect(platformName('shopee'), 'Shopee');
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sirkular/core/theme/app_theme.dart';
import 'package:sirkular/features/auth/data/user_repository.dart';
import 'package:sirkular/features/dashboard/presentation/home_page.dart';
import 'package:sirkular/features/inventory/presentation/inventory_page.dart';

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

  testWidgets('toggling a rule updates the active count', (tester) async {
    await _pumpPhone(tester, const HomePage(user: _user));

    await tester.dragUntilVisible(
      find.text('Aturan Saya'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    expect(find.text('3 aktif'), findsOneWidget);

    await tester.ensureVisible(find.byType(Switch).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).first);
    await tester.pump();

    expect(find.text('2 aktif'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

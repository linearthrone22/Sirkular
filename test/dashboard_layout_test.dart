import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sirkular/features/dashboard/presentation/home_page.dart';

import 'support/seeded_db.dart';

Future<void> _pumpAt(WidgetTester tester, Size size, Widget home) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MaterialApp(theme: testTheme(), home: home));
  await settle(tester);
}

void main() {
  testWidgets('web dashboard shows Johanes data without overflow',
      (tester) async {
    final user = await openSeededTestDb(tester);
    await _pumpAt(tester, const Size(1366, 900), HomePage(user: user));

    expect(tester.takeException(), isNull);
    expect(find.text('Sirkular'), findsOneWidget);
    expect(find.text('Generate AI R&D'), findsOneWidget);
    expect(find.text('Live Sync Orders'), findsOneWidget);
    expect(find.text('Roti tawar mendekati kedaluwarsa'), findsOneWidget);
  });

  testWidgets('mobile dashboard shows Johanes data without overflow',
      (tester) async {
    final user = await openSeededTestDb(tester);
    await _pumpAt(tester, const Size(390, 844), HomePage(user: user));

    expect(tester.takeException(), isNull);
    expect(find.text('Halo, Johanes'), findsOneWidget);
    expect(find.text('2 AI Alerts'), findsOneWidget);
    expect(find.text('Rp 23.876.000'), findsOneWidget);
  });
}

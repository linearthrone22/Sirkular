import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sirkular/core/theme/app_theme.dart';
import 'package:sirkular/features/auth/data/user_repository.dart';
import 'package:sirkular/features/dashboard/presentation/home_page.dart';

const _user = User(id: 1, name: 'Kopi Senja', email: 'kopi@senja.id');

Future<void> _pumpAt(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: const HomePage(user: _user),
    ),
  );
  // Charts animate on entry; advance past them instead of settling forever.
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  testWidgets('web dashboard lays out without overflow', (tester) async {
    await _pumpAt(tester, const Size(1366, 900));

    expect(tester.takeException(), isNull);
    expect(find.text('Sirkular'), findsOneWidget);
    expect(find.text('Generate AI R&D'), findsOneWidget);
    expect(find.text('Live Sync Orders'), findsOneWidget);
  });

  testWidgets('mobile dashboard lays out without overflow', (tester) async {
    await _pumpAt(tester, const Size(390, 844));

    expect(tester.takeException(), isNull);
    expect(find.text('Halo, Kopi'), findsOneWidget);
    expect(find.text('3 AI Alerts'), findsOneWidget);
  });
}

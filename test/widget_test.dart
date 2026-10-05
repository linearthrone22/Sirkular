import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sirkular/main.dart';

void main() {
  testWidgets('login screen shows the form and the signup tab', (tester) async {
    await tester.pumpWidget(const SirkularApp());

    expect(find.text('Sirkular'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.text('Signup'), findsOneWidget);
  });
}

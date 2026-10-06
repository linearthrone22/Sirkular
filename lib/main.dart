import 'package:flutter/material.dart';

import 'core/database/dummy_seed.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Writes the demo account and its data on first launch only.
  await DummySeed().ensureAllSeeded();
  runApp(const SirkularApp());
}

class SirkularApp extends StatelessWidget {
  const SirkularApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sirkular',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const LoginPage(),
    );
  }
}

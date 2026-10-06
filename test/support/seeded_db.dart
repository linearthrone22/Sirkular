import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:sirkular/core/database/app_database.dart';
import 'package:sirkular/core/theme/app_colors.dart';
import 'package:sirkular/core/database/dummy_seed.dart';
import 'package:sirkular/features/auth/data/user_repository.dart';

/// Points the app at a fresh in-memory database, seeded with Johanes's data,
/// and returns Johanes.
Future<User> openSeededTestDb(WidgetTester tester) async {
  return (await tester.runAsync(() async {
    AppDatabase.instance = AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    await DummySeed().ensureSeeded();
    return UserRepository().login(
      email: DummySeed.email,
      password: DummySeed.password,
    );
  }))!;
}

/// Lets real database futures finish: pumps until no loading spinner is left
/// (or a time limit is reached), so screens that read SQLite have data.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 400; i++) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump(const Duration(milliseconds: 10));
    // Wait a few rounds first so a page pushed just now has time to load.
    if (i > 10 && !tester.any(find.byType(CircularProgressIndicator))) break;
  }
  // Let the last frame's animations and rebuilds finish.
  await tester.pump(const Duration(milliseconds: 500));
}

/// Tests run without network, and the app theme loads Poppins from Google
/// Fonts. Tests use a plain theme with the same background instead.
ThemeData testTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
  );
}

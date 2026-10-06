import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:sirkular/core/database/app_database.dart';
import 'package:sirkular/core/database/dummy_seed.dart';
import 'package:sirkular/features/auth/data/user_repository.dart';
import 'package:sirkular/features/inventory/data/inventory_repository.dart';

void main() {
  test('an existing johanes account keeps its password and gets the data',
      () async {
    final db = AppDatabase.open(
        factory: databaseFactoryFfi, path: inMemoryDatabasePath);
    addTearDown(db.close);

    // Johanes signed up in the app before the seed existed.
    await UserRepository(database: db).register(
      name: 'Johanes',
      email: DummySeed.email,
      password: 'my-own-pass',
    );

    await DummySeed(database: db).ensureSeeded();
    await DummySeed(database: db).ensureSeeded();

    final user = await UserRepository(database: db).login(
      email: DummySeed.email,
      password: 'my-own-pass',
    );
    final items = await InventoryRepository(database: db).items(user.id);
    expect(items, hasLength(8));
  });

  test('every demo account is created with its data', () async {
    final db = AppDatabase.open(
        factory: databaseFactoryFfi, path: inMemoryDatabasePath);
    addTearDown(db.close);

    await DummySeed(database: db).ensureAllSeeded();

    for (final account in DummySeed.accounts) {
      final user = await UserRepository(database: db).login(
        email: account.email,
        password: account.password,
      );
      final items = await InventoryRepository(database: db).items(user.id);
      expect(items, hasLength(8), reason: account.email);
    }
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Singleton Riverpod provider for the Drift [AppDatabase].
///
/// Override this provider in tests to supply an in-memory database:
/// ```dart
/// databaseProvider.overrideWithValue(
///   AppDatabase.forTesting(NativeDatabase.memory()),
/// )
/// ```
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

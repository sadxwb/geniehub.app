import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:shopping/shopping.dart';

/// Builds Provider overrides that wire cross-module dependencies.
///
/// Called once in [main] and passed to the root [ProviderScope].
// ignore: strict_top_level_inference
buildAppProviderOverrides(Talker talker) {
  final db = AppDatabase();
  final shoppingRepo = ShoppingRepository(db);
  final bridge = ShoppingBridgeImpl(shoppingRepo);

  return [
    databaseProvider.overrideWithValue(db),
    shoppingBridgeProvider.overrideWithValue(bridge),
    talkerProvider.overrideWithValue(talker),
  ];
}

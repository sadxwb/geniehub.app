import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geniehub_core/geniehub_core.dart';
import 'package:geniehub_shopping/geniehub_shopping.dart';

/// Builds Provider overrides that wire cross-module dependencies.
///
/// Called once in [main] and passed to the root [ProviderScope].
// ignore: strict_top_level_inference
final appProviderOverrides = _buildOverrides();

// ignore: strict_top_level_inference
_buildOverrides() {
  final db = AppDatabase();
  final shoppingRepo = ShoppingRepository(db);
  final bridge = ShoppingBridgeImpl(shoppingRepo);

  return [
    databaseProvider.overrideWithValue(db),
    shoppingBridgeProvider.overrideWithValue(bridge),
  ];
}

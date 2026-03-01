import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shopping_bridge.dart';

/// Provides the [ShoppingBridge] implementation.
///
/// The shopping feature module overrides this provider at app startup with its
/// concrete implementation. Until then, any call will throw
/// [UnimplementedError] to surface wiring issues early during development.
final shoppingBridgeProvider = Provider<ShoppingBridge>((ref) {
  return _UnimplementedShoppingBridge();
});

class _UnimplementedShoppingBridge implements ShoppingBridge {
  Never _throw() => throw UnimplementedError(
        'ShoppingBridge has not been provided. '
        'Override shoppingBridgeProvider in main().',
      );

  @override
  Future<List<ShoppingListInfo>> getShoppingLists() => _throw();

  @override
  Future<String> createList(String name) => _throw();

  @override
  Future<void> addItemsToList(
          String listId, List<BridgeShoppingItem> items) =>
      _throw();

  @override
  Stream<List<ShoppingListInfo>> watchActiveLists() => _throw();

  @override
  Stream<List<BridgeShoppingItem>> watchItems(String listId) => _throw();

  @override
  Future<void> toggleItem(String itemId, bool isChecked) => _throw();

  @override
  Future<void> addItem(String listId, String name) => _throw();
}

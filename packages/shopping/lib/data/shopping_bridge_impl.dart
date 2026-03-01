import 'package:core/core.dart';

import 'shopping_repository.dart';

/// Implementation of [ShoppingBridge] from core.
///
/// This allows other modules to access shopping data through the
/// bridge abstraction without depending on the full shopping module.
class ShoppingBridgeImpl implements ShoppingBridge {
  ShoppingBridgeImpl(this._repository);

  final ShoppingRepository _repository;

  // --- Futures (used by recipe's "Add to Shopping List" dialog) ---

  @override
  Future<List<ShoppingListInfo>> getShoppingLists() async {
    // Get the first emission from the active-lists stream.
    final lists = await _repository.watchActiveLists().first;
    return lists
        .map((list) => ShoppingListInfo(id: list.id, name: list.name))
        .toList();
  }

  @override
  Future<String> createList(String name) async {
    final list = await _repository.createList(name);
    return list.id;
  }

  @override
  Future<void> addItemsToList(
      String listId, List<BridgeShoppingItem> items) async {
    for (final item in items) {
      await _repository.addItem(
        listId,
        item.name,
        quantity: item.quantity,
        unit: item.unit,
        category: item.category,
      );
    }
  }

  // --- Streams (used by the dashboard widget) ---

  @override
  Stream<List<ShoppingListInfo>> watchActiveLists() {
    return _repository.watchActiveLists().map(
          (lists) => lists
              .map(
                (list) => ShoppingListInfo(
                  id: list.id,
                  name: list.name,
                ),
              )
              .toList(),
        );
  }

  @override
  Stream<List<BridgeShoppingItem>> watchItems(String listId) {
    return _repository.watchItems(listId).map(
          (items) => items
              .map(
                (item) => BridgeShoppingItem(
                  name: item.name,
                  quantity: item.quantity,
                  unit: item.unit,
                  category: item.category,
                ),
              )
              .toList(),
        );
  }

  // --- Mutations ---

  @override
  Future<void> toggleItem(String itemId, bool isChecked) {
    return _repository.toggleItemChecked(itemId, isChecked);
  }

  @override
  Future<void> addItem(String listId, String name) {
    return _repository.addItem(listId, name);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geniehub_core/geniehub_core.dart';

import '../data/shopping_bridge_impl.dart';
import '../data/shopping_repository.dart';

/// Provides the [ShoppingRepository] backed by the app database.
final shoppingRepositoryProvider = Provider<ShoppingRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ShoppingRepository(db);
});

/// Watches all active (non-archived) shopping lists.
final shoppingListsProvider = StreamProvider<List<ShoppingList>>((ref) {
  final repo = ref.watch(shoppingRepositoryProvider);
  return repo.watchActiveLists();
});

/// Watches all shopping lists including archived ones.
final allShoppingListsProvider = StreamProvider<List<ShoppingList>>((ref) {
  final repo = ref.watch(shoppingRepositoryProvider);
  return repo.watchAllLists();
});

/// Fetches a single shopping list by [id].
final shoppingListDetailProvider =
    FutureProvider.family<ShoppingList?, String>((ref, id) {
  final repo = ref.watch(shoppingRepositoryProvider);
  return repo.getList(id);
});

/// Watches all items for a given [listId].
final shoppingItemsProvider =
    StreamProvider.family<List<ShoppingItem>, String>((ref, listId) {
  final repo = ref.watch(shoppingRepositoryProvider);
  return repo.watchItems(listId);
});

/// Provides the [ShoppingBridgeImpl] for cross-module access.
final shoppingBridgeImplProvider = Provider<ShoppingBridgeImpl>((ref) {
  final repo = ref.watch(shoppingRepositoryProvider);
  return ShoppingBridgeImpl(repo);
});

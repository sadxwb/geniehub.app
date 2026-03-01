import 'package:drift/drift.dart';
import 'package:geniehub_core/geniehub_core.dart';
import 'package:uuid/uuid.dart';

/// Repository for shopping list CRUD operations using Drift.
class ShoppingRepository {
  ShoppingRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  // ---------------------------------------------------------------------------
  // Lists
  // ---------------------------------------------------------------------------

  /// Watch all shopping lists ordered by most recently updated.
  Stream<List<ShoppingList>> watchAllLists() {
    return (_db.select(_db.shoppingLists)
          ..orderBy([
            (t) => OrderingTerm.desc(t.updatedAt),
          ]))
        .watch();
  }

  /// Watch only non-archived shopping lists.
  Stream<List<ShoppingList>> watchActiveLists() {
    return (_db.select(_db.shoppingLists)
          ..where((t) => t.isArchived.equals(false))
          ..orderBy([
            (t) => OrderingTerm.desc(t.updatedAt),
          ]))
        .watch();
  }

  /// Get a single shopping list by [id].
  Future<ShoppingList?> getList(String id) {
    return (_db.select(_db.shoppingLists)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Create a new shopping list with the given [name].
  Future<ShoppingList> createList(String name) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    await _db.into(_db.shoppingLists).insert(
          ShoppingListsCompanion.insert(
            id: id,
            name: name,
            createdAt: now,
            updatedAt: now,
            isArchived: Value(false),
          ),
        );

    // Return the newly created list.
    final created = await getList(id);
    return created!;
  }

  /// Update an existing shopping list.
  Future<void> updateList(ShoppingList list) async {
    await (_db.update(_db.shoppingLists)
          ..where((t) => t.id.equals(list.id)))
        .write(
      ShoppingListsCompanion(
        name: Value(list.name),
        updatedAt: Value(DateTime.now()),
        isArchived: Value(list.isArchived),
      ),
    );
  }

  /// Archive a shopping list by [id].
  Future<void> archiveList(String id) async {
    await (_db.update(_db.shoppingLists)
          ..where((t) => t.id.equals(id)))
        .write(
      ShoppingListsCompanion(
        isArchived: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Delete a shopping list and all its items by [id].
  Future<void> deleteList(String id) async {
    // Delete items first.
    await (_db.delete(_db.shoppingItems)
          ..where((t) => t.listId.equals(id)))
        .go();

    await (_db.delete(_db.shoppingLists)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  // ---------------------------------------------------------------------------
  // Items
  // ---------------------------------------------------------------------------

  /// Watch all items for a given [listId], ordered by sort order.
  Stream<List<ShoppingItem>> watchItems(String listId) {
    return (_db.select(_db.shoppingItems)
          ..where((t) => t.listId.equals(listId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
          ]))
        .watch();
  }

  /// Add a new item to a shopping list.
  Future<ShoppingItem> addItem(
    String listId,
    String name, {
    double? quantity,
    String? unit,
    String? category,
  }) async {
    final id = _uuid.v4();

    // Determine next sort order.
    final existing = await (_db.select(_db.shoppingItems)
          ..where((t) => t.listId.equals(listId))
          ..orderBy([(t) => OrderingTerm.desc(t.sortOrder)])
          ..limit(1))
        .getSingleOrNull();

    final nextOrder = (existing?.sortOrder ?? -1) + 1;

    await _db.into(_db.shoppingItems).insert(
          ShoppingItemsCompanion.insert(
            id: id,
            listId: listId,
            name: name,
            quantity: Value(quantity),
            unit: Value(unit),
            category: Value(category),
            isChecked: Value(false),
            sortOrder: Value(nextOrder),
          ),
        );

    // Touch the parent list's updatedAt.
    await (_db.update(_db.shoppingLists)
          ..where((t) => t.id.equals(listId)))
        .write(
      ShoppingListsCompanion(updatedAt: Value(DateTime.now())),
    );

    final created = await (_db.select(_db.shoppingItems)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return created!;
  }

  /// Update an existing shopping item.
  Future<void> updateItem(ShoppingItem item) async {
    await (_db.update(_db.shoppingItems)
          ..where((t) => t.id.equals(item.id)))
        .write(
      ShoppingItemsCompanion(
        name: Value(item.name),
        quantity: Value(item.quantity),
        unit: Value(item.unit),
        category: Value(item.category),
        isChecked: Value(item.isChecked),
        sortOrder: Value(item.sortOrder),
      ),
    );
  }

  /// Toggle the checked state of a single item.
  Future<void> toggleItemChecked(String itemId, bool isChecked) async {
    await (_db.update(_db.shoppingItems)
          ..where((t) => t.id.equals(itemId)))
        .write(
      ShoppingItemsCompanion(isChecked: Value(isChecked)),
    );
  }

  /// Delete a single shopping item by [itemId].
  Future<void> deleteItem(String itemId) async {
    await (_db.delete(_db.shoppingItems)
          ..where((t) => t.id.equals(itemId)))
        .go();
  }

  /// Uncheck all items in a shopping list.
  Future<void> uncheckAllItems(String listId) async {
    await (_db.update(_db.shoppingItems)
          ..where((t) => t.listId.equals(listId)))
        .write(
      const ShoppingItemsCompanion(isChecked: Value(false)),
    );
  }
}

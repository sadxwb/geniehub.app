/// Lightweight info about a shopping list (used across module boundaries).
class ShoppingListInfo {
  const ShoppingListInfo({required this.id, required this.name});

  final String id;
  final String name;
}

/// A single shopping item used across module boundaries.
class BridgeShoppingItem {
  const BridgeShoppingItem({
    required this.name,
    this.quantity,
    this.unit,
    this.category,
  });

  final String name;
  final double? quantity;
  final String? unit;
  final String? category;
}

/// Abstract bridge that the **shopping** feature module implements and the
/// **recipe** / **meal-plan** modules consume.
///
/// This decouples modules so that recipe code can add ingredients to the
/// shopping list without importing the shopping feature directly.
abstract class ShoppingBridge {
  // --- Futures (used by recipe's "Add to Shopping List" dialog) ---

  /// Returns all non-archived shopping lists.
  Future<List<ShoppingListInfo>> getShoppingLists();

  /// Creates a new shopping list and returns its ID.
  Future<String> createList(String name);

  /// Adds a batch of items to the given shopping list.
  Future<void> addItemsToList(String listId, List<BridgeShoppingItem> items);

  // --- Streams (used by the dashboard widget) ---

  /// Watches the active (non-archived) shopping lists.
  Stream<List<ShoppingListInfo>> watchActiveLists();

  /// Watches items in a specific list.
  Stream<List<BridgeShoppingItem>> watchItems(String listId);

  // --- Mutations (used by shopping mode / dashboard) ---

  /// Toggles the checked state of a single item.
  Future<void> toggleItem(String itemId, bool isChecked);

  /// Adds a single item to a list by name.
  Future<void> addItem(String listId, String name);
}

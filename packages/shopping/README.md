# shopping

Shopping list feature module for GenieHub.

It provides shopping list CRUD, list detail and shopping mode screens,
repository/providers, and the concrete `ShoppingBridge` implementation consumed
by other modules.

## Responsibilities

- Shopping list and shopping item data access (`ShoppingRepository`)
- UI screens: list overview, list detail, shopping mode
- Feature widgets and dialogs for list/item operations
- Bridge implementation (`ShoppingBridgeImpl`) for cross-module usage

## Dependency rule

`shopping` depends on `core` only.

## Main exports

```dart
import 'package:shopping/shopping.dart';
```

Notable exports include:

- `ShoppingRepository`
- `shoppingRepositoryProvider`, `shoppingListsProvider`, `shoppingItemsProvider`
- `ShoppingBridgeImpl`
- `ShoppingListsScreen`, `ShoppingListDetailScreen`, `ShoppingModeScreen`

## Usage

Watch active shopping lists:

```dart
final listsAsync = ref.watch(shoppingListsProvider);
```

App-level bridge wiring (done in root app provider overrides):

```dart
final shoppingRepo = ShoppingRepository(db);
final bridge = ShoppingBridgeImpl(shoppingRepo);

return [
  shoppingBridgeProvider.overrideWithValue(bridge),
];
```

## Development notes

- Keep navigation callback-based in screens (feature packages must not import
  `go_router`).
- Use UUID text IDs and Drift companions for inserts/updates.

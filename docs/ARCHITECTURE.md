# Architecture

## System Overview

GenieHub is a mono-repo Flutter application composed of a thin app shell and 4 feature packages. The app shell handles routing and layout; feature packages are self-contained modules that expose screens, providers, and dashboard widgets.

```text
┌──────────────────────────────────────────────────┐
│                  Main App Shell                  │
│  (lib/ — router, sidebar, provider overrides)    │
├──────────┬───────────┬───────────┬───────────────┤
│Dashboard │ Shopping  │  Recipe   │  (Future      │
│ Module   │  Module   │  Module   │   Modules)    │
├──────────┴───────────┴───────────┴───────────────┤
│                  geniehub_core                   │
│    (theme, auth, DB, bridge, subscription)       │
└──────────────────────────────────────────────────┘
```

## Package Dependency Graph

```text
geniehub (app shell)
├── geniehub_dashboard
│   ├── geniehub_shopping
│   │   └── geniehub_core
│   └── geniehub_recipe
│       └── geniehub_core
└── geniehub_core
```

Rules:

- Core has zero internal dependencies
- Feature modules depend only on core (never on each other)
- Dashboard depends on core + all feature modules (it composes their widgets)
- The app shell depends on everything

## Data Layer

### Local Database (Drift / SQLite)

A single `AppDatabase` instance is created in the app shell and shared via Riverpod provider override. All 4 feature modules receive the same database instance.

```text
┌─────────────────────────────────────┐
│           AppDatabase               │
├─────────────────────────────────────┤
│ ShoppingLists  │ ShoppingItems      │
│ Recipes        │ Ingredients        │
│ RecipeSteps    │ MealPlans          │
└─────────────────────────────────────┘
```

All tables use TEXT primary keys (UUIDs) to support eventual sync with Firestore, where document IDs are strings.

#### Entity Relationship Diagram

```text
ShoppingLists 1──* ShoppingItems
    (id, name, createdAt, updatedAt, isArchived)
                    (id, listId, name, quantity, unit, category, isChecked, sortOrder)

Recipes 1──* Ingredients
        1──* RecipeSteps
    (id, title, description, servings, prepTimeMinutes, cookTimeMinutes, imageUrl, createdAt, updatedAt)
                (id, recipeId, name, quantity, unit, isOptional, sortOrder)
                (id, recipeId, stepNumber, instruction)

MealPlans
    (id, date, mealType, recipeId?, customMealName?, notes?)
```

### Repository Pattern

Each feature module wraps database queries in a repository class:

```dart
class ShoppingRepository {
  ShoppingRepository(this._db);
  final AppDatabase _db;

  Stream<List<ShoppingList>> watchAllLists() { ... }
  Future<ShoppingList> createList(String name) { ... }
  // ...
}
```

Repositories are created via Riverpod providers and receive the database from the `databaseProvider`:

```dart
final shoppingRepositoryProvider = Provider<ShoppingRepository>((ref) {
  return ShoppingRepository(ref.watch(databaseProvider));
});
```

### Planned: Tier-Aware Data Routing

When Firebase is integrated, repositories will route to different data sources based on subscription tier:

```text
┌─────────────┐
│  Repository  │
├─────────────┤
│ Tier Router  │  ← Checks UserTier
├──────┬──────┤
│Local │Remote│  ← Drift or Firestore
└──────┴──────┘
```

- `UserTier.free` → Local Drift only
- `UserTier.plus+` → Firestore with local cache

## Logging Layer

### Talker Framework

GenieHub centralizes all error, network, AI, and debug log outputs using **Talker** via `talker_flutter` and `talker_riverpod_logger`.

1. **Providers Hook**: Changes crossing Riverpod state propagate implicitly given our `ProviderScope`'s setup.
2. **Crash Capturing**: Unhandled global exceptions in Flutter (`FlutterError.onError`) and Dart background routines (`PlatformDispatcher.instance.onError`) are trapped to Talker seamlessly.
3. **Local References**: Downstream repositories query `ref.watch(talkerProvider).info(...)` to manually log AI generative flows.

## State Management

### Riverpod Provider Types

| Provider Type | Use Case | Example |
| --- | --- | --- |
| `Provider` | Singleton services | `databaseProvider`, `shoppingRepositoryProvider` |
| `StateProvider` | Simple mutable state | `authProvider` (current user) |
| `StreamProvider` | Reactive DB queries | `shoppingListsProvider` (watches all lists) |
| `FutureProvider` | One-shot async | `shoppingListDetailProvider` (fetch single list) |
| `FutureProvider.family` | Parameterized async | `shoppingItemsProvider(listId)` |

### Provider Wiring

Provider overrides are defined in `lib/providers.dart` and applied in `main.dart`:

```dart
// providers.dart
final appProviderOverrides = <Override>[
  databaseProvider.overrideWithValue(db),
  shoppingBridgeProvider.overrideWithValue(bridgeImpl),
];

// main.dart
ProviderScope(
  overrides: appProviderOverrides,
  child: const GenieHubApp(),
)
```

## Navigation

### GoRouter with ShellRoute

The sidebar layout is implemented as a `ShellRoute`:

```dart
ShellRoute(
  builder: (context, state, child) => SidebarLayout(child: child),
  routes: [
    GoRoute(path: '/', ...),          // Dashboard
    GoRoute(path: '/shopping', ...),   // Shopping Lists
    GoRoute(path: '/recipes', ...),    // Recipes
    GoRoute(path: '/meal-plan', ...),  // Meal Planning
    GoRoute(path: '/ai-recipe', ...),  // AI Recipe Generation
  ],
)
```

### Callback-Based Screen Navigation

Feature modules never import `go_router`. Instead, screens accept callback functions:

```dart
// In the package
class RecipesScreen extends ConsumerStatefulWidget {
  final void Function(String recipeId)? onRecipeTap;
  final VoidCallback? onAddRecipe;
}

// In the router
GoRoute(
  path: '/recipes',
  builder: (context, state) => RecipesScreen(
    onRecipeTap: (id) => context.go('/recipes/$id'),
    onAddRecipe: () => context.go('/recipes/new'),
  ),
)
```

This keeps packages decoupled from the routing library and makes screens reusable.

### Responsive Sidebar

`SidebarLayout` adapts to screen width:

- **>= 600dp**: `NavigationRail` (persistent side rail)
- **< 600dp**: `AppBar` + `NavigationDrawer` (hamburger menu)

## Cross-Module Communication

### The Bridge Pattern

Feature modules cannot depend on each other directly. When module A needs to call module B, the pattern is:

1. **Define interface** in `geniehub_core` (abstract class + DTOs)
2. **Implement** in the source module (module B)
3. **Consume** via provider in the target module (module A)
4. **Wire** in the app shell via provider override

```text
geniehub_core:     abstract ShoppingBridge { ... }
                   shoppingBridgeProvider → UnimplementedShoppingBridge

geniehub_shopping: class ShoppingBridgeImpl implements ShoppingBridge { ... }

geniehub_recipe:   ref.watch(shoppingBridgeProvider).getShoppingLists()

app shell:         shoppingBridgeProvider.overrideWithValue(bridgeImpl)
```

The `ShoppingBridge` interface provides:

- **Future-based methods** for the recipe module's "Add to Shopping List" dialog
- **Stream-based methods** for the dashboard's real-time shopping list widget
- **Mutation methods** for toggling items and adding single items

## Subscription & Feature Gating

### UserTier Enum

```dart
enum UserTier { free, plus, pro }
```

Extension helpers: `canSync`, `canShareFamily`, `canUseAI`, `hasAds`

### TierGate Widget

Wraps any widget tree to restrict access by tier:

```dart
TierGate(
  requiredTier: UserTier.pro,
  child: AiRecipeScreen(),
)
```

Shows an upgrade prompt when the user's tier is insufficient.

### AdWrapper Widget

Conditionally shows ads for free tier users:

```dart
AdWrapper(child: DashboardScreen())
```

## Theme

Material 3 with `colorSchemeSeed` based on teal. Two themes:

- `AppTheme.light` — Light mode
- `AppTheme.dark` — Dark mode

Custom colors in `AppColors` (primary teal, surfaces, cards).

## Future Architecture (Planned)

### Firebase Integration (Plus+)

```text
Firebase Auth ──→ AuthRepository ──→ authProvider
Firestore     ──→ RemoteDataSource ──→ Repository (tier-routed)
```

- Auth: Email/password, Google Sign-In, Apple Sign-In
- Firestore: Collections mirror local DB tables, scoped by family group
- Real-time sync between local Drift DB and Firestore

### Family Sharing (Plus+)

```text
/families/{familyId}/
  ├── members/{userId}     # permissions map
  ├── shopping_lists/      # shared shopping data
  ├── recipes/             # shared recipes
  └── meal_plans/          # shared meal plans
```

Each family member has granular permissions (e.g., shopping access but not recipe access).

### AI Recipe Generation (Pro)

- Gemini via Firebase Vertex AI
- Generate recipes from text prompts
- Extract ingredients and auto-add to shopping list via the bridge
- UI exists, gated behind `TierGate(requiredTier: UserTier.pro)`

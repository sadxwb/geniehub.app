# AGENTS.md — Coding Conventions for AI Agents

This file describes the conventions, patterns, and rules that AI coding agents must follow when working on the GenieHub codebase.

## Project Overview

GenieHub is a modular Flutter mono-repo app with 4 packages under `packages/` and the main app shell at the project root (`lib/`). It uses Riverpod for state management, Drift for SQLite, and GoRouter for navigation.

## Language & Framework

- **Dart** (SDK ^3.11.0) with **Flutter**
- Target platforms: iOS, Android, Web
- Material 3 design system

## Package Structure

```text
geniehub.app/            # Main app (pubspec.yaml is both workspace root and app)
├── lib/                 # App shell: main.dart, router, sidebar, providers
├── packages/
│   ├── core/   # Shared foundation (theme, auth, DB, bridge, widgets)
│   ├── shopping/  # Shopping lists feature module
│   ├── meal_plan/    # Recipes & meal planning feature module
│   └── dashboard/ # Dashboard composing other modules
```

### Dependency Rules

- `core` depends on NO other internal packages
- `shopping` depends on `core` only
- `meal_plan` depends on `core` only (NOT shopping)
- `dashboard` depends on `core`, `shopping`, `meal_plan`
- The root app depends on all 4 packages

**Never** create circular dependencies between packages. If a feature module needs to call another module, use the Bridge pattern (see below).

## State Management — Riverpod

- Use `flutter_riverpod` ^2.6.1 with **manual providers** (no code generation, no `riverpod_annotation`)
- Provider types used: `Provider`, `StateProvider`, `FutureProvider`, `StreamProvider`, `StateNotifierProvider`
- Use `.family` modifier for parameterized providers
- Widgets extend `ConsumerWidget` or `ConsumerStatefulWidget`
- Access providers via `ref.watch()` in build methods and `ref.read()` in callbacks
- Provider overrides are set in `lib/providers.dart` and applied in `main.dart`'s `ProviderScope`

## Database — Drift

- Single `AppDatabase` in `core` shared by all modules
- All tables use **TEXT primary keys** (UUIDs generated via `package:uuid`)
- After changing table definitions in `app_database.dart`, regenerate with:

```bash
  melos build_runner
```

- Generated files (`*.g.dart`) are committed and excluded from lint via `analysis_options.yaml`
- Use `Companion.insert()` for inserts, `Companion()` with `Value()` wrappers for updates
- Foreign keys use `.references(OtherTable, #id)` syntax

## Navigation — GoRouter

- GoRouter is ONLY used in the main app shell (`lib/router.dart`)
- Feature packages must NEVER import `go_router`
- Screens accept **callback props** for navigation:

```dart
  class RecipesScreen extends ConsumerStatefulWidget {
    final void Function(String recipeId)? onRecipeTap;
    final VoidCallback? onAddRecipe;
    // ...
  }
```

- The router wires callbacks to `context.go()` / `context.push()` calls
- Layout uses `ShellRoute` with `SidebarLayout` as the shell builder

## Cross-Module Communication — Shopping Bridge

The `ShoppingBridge` abstract class in `core` defines the contract:

```dart
abstract class ShoppingBridge {
  Future<List<ShoppingListInfo>> getShoppingLists();
  Future<String> createList(String name);
  Future<void> addItemsToList(String listId, List<BridgeShoppingItem> items);
  Stream<List<ShoppingListInfo>> watchActiveLists();
  Stream<List<BridgeShoppingItem>> watchItems(String listId);
  Future<void> toggleItem(String itemId, bool isChecked);
  Future<void> addItem(String listId, String name);
}
```

- `shopping` provides `ShoppingBridgeImpl`
- `meal_plan` consumes the bridge via `shoppingBridgeProvider` (from core)
- The bridge is wired via provider override in `lib/providers.dart`
- When adding new cross-module communication, follow this same pattern: define interface in core, implement in source module, consume via provider in target module

## Subscription Tiers

```dart
enum UserTier { free, plus, pro }
```

- `free` — Local SQLite only, ads shown
- `plus` — Firebase sync, family sharing (up to 5 members)
- `pro` — All of Plus + AI features (Gemini recipe generation)

Gate features using the `TierGate` widget:

```dart
TierGate(
  requiredTier: UserTier.pro,
  child: AiRecipeScreen(),
)
```

## Coding Style

### General

- No `library` directives (suppress `unnecessary_library_name` info)
- Barrel exports via `lib/package_name.dart` using `export 'src/...'` or `export 'subdir/...'` pattern
- Prefer `const` constructors wherever possible
- Use trailing commas for multi-line parameter lists
- Use `super.key` in constructors (not `Key? key`)

### Logging

- Use `talker_flutter` and `talker_riverpod_logger` for all app-level logging instead of `print` or `debugPrint`.
- The `Talker` instance is globally provided via `talkerProvider` in `core`.
- Riverpod state events are automatically logged via `TalkerRiverpodObserver` configured in `main.dart`.
- Uncaught exceptions and framework errors are automatically routed to Talker.
- For specific logic, access Talker via Riverpod: `ref.read(talkerProvider).info('Some event');`

### Widget Conventions

- Extend `ConsumerWidget` for stateless widgets that use Riverpod
- Extend `ConsumerStatefulWidget` for stateful widgets that use Riverpod
- Use `StatelessWidget` / `StatefulWidget` only if no Riverpod access needed
- Private helper widgets use underscore prefix: `class _QuickActionChip extends StatelessWidget`
- Use `AsyncValue.when(data:, loading:, error:)` for stream/future provider UI

### Repository Pattern

- Repositories take `AppDatabase` in constructor
- Use `_uuid.v4()` for new entity IDs (static const `_uuid = Uuid()`)
- Streams for watch operations, Futures for CRUD operations
- Touch `updatedAt` on parent entities when child entities change

### File Organization

Each feature package follows this layout:

```text
lib/
├── package_name.dart       # Barrel export
├── data/                   # Repository classes
├── providers/              # Riverpod providers
├── screens/                # Full-page widgets
├── widgets/                # Reusable sub-widgets
└── dashboard/              # Dashboard widget for the home screen
```

### Naming

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Providers: `camelCaseProvider` (e.g., `shoppingRepositoryProvider`)
- Database tables: `PascalCase` Dart classes mapping to `snake_case` SQL tables (Drift convention)
- Screen widgets: `*Screen` suffix (e.g., `RecipesScreen`)
- Dashboard widgets: `*DashboardWidget` suffix

## Testing

- Test files go in `test/` within each package
- Run all tests: `melos test` or `flutter test`
- Widget tests use `flutter_test`
- The `AppDatabase.forTesting()` constructor accepts a custom executor for in-memory testing

## Build & Verify Checklist

1. `flutter pub get` — resolve dependencies across workspace
2. `melos build_runner` — generate Drift code in packages that need it
3. `melos analyze` — must produce zero errors and zero warnings
4. `melos test` — all tests pass
5. `flutter run` — app launches with sidebar navigation

## Things to Avoid

- Do not import `go_router` in any package — navigation is callback-based
- Do not use `int` auto-increment IDs — all PKs are TEXT UUIDs
- Do not create direct dependencies between feature modules (shopping ↔ recipe) — use the bridge
- Do not use Riverpod code generation (`riverpod_annotation`, `@riverpod`) — use manual providers
- Do not add `library` directives to new files
- Do not modify generated `*.g.dart` files — regenerate via build_runner
- Do not hardcode tier checks — use `TierGate` widget or `UserTierX` extension helpers

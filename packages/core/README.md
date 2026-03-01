# core

Shared foundation package for GenieHub. This package owns common domain models,
theme, database, auth/subscription primitives, app-level logging providers, and
cross-module bridge interfaces.

## Responsibilities

- Drift database (`AppDatabase`) and `databaseProvider`
- Theme tokens and app theme (`AppColors`, `appTheme`)
- Auth and subscription models/providers (`UserTier`, `TierGate`, ads)
- Shared utility widgets (`LoadingWidget`, `AppErrorWidget`)
- Cross-module contracts (for example `ShoppingBridge`)
- Logging providers (`talkerProvider`) used across packages

## Dependency rule

`core` must not depend on other internal packages.

## Main exports

Import from the barrel:

```dart
import 'package:core/core.dart';
```

Notable exports include:

- `AppDatabase`, `databaseProvider`
- `ShoppingBridge`, `shoppingBridgeProvider`
- `UserTier`, `TierGate`
- `talkerProvider`

## Usage

Read shared providers in feature modules:

```dart
final db = ref.watch(databaseProvider);
final bridge = ref.read(shoppingBridgeProvider);
```

Gate a Pro-only screen:

```dart
TierGate(
  requiredTier: UserTier.pro,
  child: const AiRecipeScreen(),
)
```

## Development notes

- Use manual Riverpod providers (no code generation).
- After modifying Drift table definitions, regenerate with:

```bash
melos build_runner
```

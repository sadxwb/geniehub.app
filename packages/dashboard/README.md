# dashboard

Dashboard composition module for GenieHub.

This package builds the home/dashboard experience by composing widgets from
`core`, `shopping`, and `meal_plan`, and managing dashboard-specific UI state
such as collapsed sections.

## Responsibilities

- Top-level dashboard screen UI
- Dashboard container widgets and layout helpers
- Dashboard state providers (for example section collapse state)

## Dependency rule

`dashboard` may depend on `core`, `shopping`, and `meal_plan`.

## Main exports

```dart
import 'package:dashboard/dashboard.dart';
```

Notable exports include:

- `DashboardScreen`
- `collapsedSectionsProvider`
- `DashboardWidgetContainer`

## Usage

Read dashboard collapsed-section state:

```dart
final collapsed = ref.watch(collapsedSectionsProvider);
```

Toggle a section in callbacks:

```dart
ref.read(collapsedSectionsProvider.notifier).toggle('shopping');
```

## Development notes

- Keep this package focused on composition/orchestration, not duplicated
  business logic from feature modules.

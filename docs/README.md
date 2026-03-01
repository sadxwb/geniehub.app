# GenieHub

A modular Flutter app that bundles family-focused mini-apps — shopping lists, recipes, and meal planning — into a single hub with a sidebar layout.

## Features

- **Dashboard** — Home screen aggregating widgets from all mini-apps (upcoming meals, active shopping lists, quick actions)
- **Shopping Lists** — Multiple lists (grocery, gifts, etc.), items with quantity/unit/category, shopping mode to cross off items
- **Recipes** — Full recipe management with ingredients, step-by-step instructions, prep/cook times
- **Meal Planning** — Assign recipes to days and meal types (breakfast, lunch, dinner, snack)
- **AI Recipe Generation** — Generate recipes from prompts via Gemini (Pro only, stubbed)
- **Cross-module integration** — Add recipe ingredients directly to a shopping list via the Shopping Bridge

## Subscription Tiers

| Feature | Free | Plus | Pro |
| --- | --- | --- | --- |
| Local SQLite storage | Yes | Yes | Yes |
| Ads | Yes | No | No |
| Firebase sync | No | Yes | Yes |
| Family sharing (up to 5) | No | Yes | Yes |
| AI recipe generation | No | No | Yes |

## Tech Stack

| Component | Technology |
| --- | --- |
| Framework | Flutter (Dart SDK ^3.11.0) |
| State Management | Riverpod (flutter_riverpod ^2.6.1) |
| Local Database | Drift ^2.22.1 (SQLite) |
| Navigation | GoRouter ^14.8.1 with ShellRoute |
| Cloud (planned) | Firebase Auth, Firestore, Vertex AI |
| Mono-repo | Melos + Flutter workspace |

## Project Structure

```text
geniehub.app/
├── lib/                         # Main app shell
│   ├── main.dart                # Entry point, ProviderScope
│   ├── app.dart                 # MaterialApp.router
│   ├── router.dart              # GoRouter with all routes
│   ├── sidebar.dart             # Responsive sidebar/drawer
│   └── providers.dart           # App-level provider overrides
├── packages/
│   ├── geniehub_core/           # Shared: theme, auth, DB, bridge, widgets
│   ├── geniehub_shopping/       # Shopping lists module
│   ├── geniehub_recipe/         # Recipes & meal planning module
│   └── geniehub_dashboard/      # Dashboard that composes other modules
├── android/ ios/ web/           # Platform folders
├── pubspec.yaml                 # Workspace root + app dependencies
└── melos.yaml                   # Mono-repo scripts
```

## Getting Started

### Prerequisites

- Flutter SDK (channel stable, Dart ^3.11.0)
- Melos (`dart pub global activate melos`)

### Setup

```bash
# Clone the repo
git clone <repo-url> geniehub.app
cd geniehub.app

# Install dependencies
flutter pub get

# Generate Drift database code
melos build_runner

# Run the app
flutter run
```

### Melos Commands

```bash
melos analyze       # Run dart analyze in all packages
melos build_runner  # Run build_runner in packages that need it
melos test          # Run tests across all packages
melos clean         # Clean all packages
```

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed technical documentation.

### Key Patterns

- **Repository pattern** — Each module has a repository wrapping Drift queries, with planned tier-aware routing to Firestore
- **Shopping Bridge** — Abstract interface in `geniehub_core`, implemented by the shopping module, consumed by the recipe module. Enables cross-module communication without direct package dependencies
- **Callback-based navigation** — Feature modules use callback props (e.g., `onRecipeTap`, `onListTap`) instead of importing GoRouter. The main app's `router.dart` wires these to actual navigation
- **Provider overrides** — The database, repository, and bridge are wired via Riverpod provider overrides in `main.dart`

### Database Schema

6 tables using Drift with UUID text primary keys:

| Table | Purpose |
| --- | --- |
| `ShoppingLists` | Shopping list containers |
| `ShoppingItems` | Items within lists (FK → ShoppingLists) |
| `Recipes` | Saved recipes |
| `Ingredients` | Recipe ingredients (FK → Recipes) |
| `RecipeSteps` | Step-by-step instructions (FK → Recipes) |
| `MealPlans` | Date + meal type → recipe mappings |

## What's Implemented vs Stubbed

### Implemented (working with local SQLite)

- Full shopping list CRUD with shopping mode
- Full recipe CRUD with ingredients and steps
- Meal plan calendar with recipe assignment
- Dashboard with widgets from all modules
- Responsive sidebar layout (NavigationRail on wide, Drawer on narrow)
- Tier gating UI (`TierGate`, `AdWrapper` widgets)
- Cross-module "Add to Shopping List" from recipes

### Stubbed (TODO)

- Firebase Auth (email, Google, Apple sign-in)
- Firestore sync for Plus+
- Family sharing and member permissions
- Gemini AI recipe generation (UI exists, gated behind Pro)
- AdMob banner/interstitial ads
- Push notifications

## License

Private — all rights reserved.

# meal_plan

Recipes and meal-planning feature module for GenieHub.

It manages recipe entities, ingredients/steps, meal slots, and AI recipe
entry points. It can send ingredients to shopping lists through the
`ShoppingBridge` interface from `core`.

## Responsibilities

- Recipe and meal-plan data access (`RecipeRepository`, `MealPlanRepository`)
- Riverpod providers for recipe/meal-plan queries and updates
- Screens for recipes, recipe detail/edit, meal plan, AI recipe
- Widgets such as `RecipeCard`, `MealSlotWidget`, and ingredient utilities
- Shopping bridge consumption in add-to-list flows

## Dependency rule

`meal_plan` depends on `core` only (no direct dependency on `shopping`).

## Main exports

```dart
import 'package:meal_plan/meal_plan.dart';
```

Notable exports include:

- `RecipeRepository`, `MealPlanRepository`
- `allRecipesProvider`, `recipeDetailProvider`, `recipeIngredientsProvider`
- `RecipesScreen`, `RecipeDetailScreen`, `MealPlanScreen`, `AiRecipeScreen`
- `AddToShoppingListDialog`

## Usage

Watch recipes in a widget:

```dart
final recipesAsync = ref.watch(allRecipesProvider);
```

Access shopping integration through the bridge abstraction:

```dart
final bridge = ref.read(shoppingBridgeProvider);
await bridge.addItemsToList(listId, items);
```

## Development notes

- Keep cross-module integration behind bridge interfaces from `core`.
- Keep navigation callback-based in feature screens (no `go_router` imports).

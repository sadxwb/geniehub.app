import 'package:go_router/go_router.dart';
import 'package:geniehub_dashboard/geniehub_dashboard.dart';
import 'package:geniehub_shopping/geniehub_shopping.dart';
import 'package:geniehub_recipe/geniehub_recipe.dart';

import 'sidebar.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => SidebarLayout(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => DashboardScreen(
            onNavigateToShopping: () => context.go('/shopping'),
            onNavigateToShoppingList: (id) => context.go('/shopping/$id'),
            onNavigateToShoppingMode: (id) => context.go('/shopping/$id/shop'),
            onNavigateToMealPlan: () => context.go('/meal-plan'),
            onNavigateToAddRecipe: () => context.go('/recipes/new'),
            onNavigateToRecipes: () => context.go('/recipes'),
            onNavigateToAiRecipe: () => context.go('/ai-recipe'),
          ),
        ),
        GoRoute(
          path: '/shopping',
          builder: (context, state) => ShoppingListsScreen(
            onListTap: (id) => context.go('/shopping/$id'),
            onStartShopping: (id) => context.go('/shopping/$id/shop'),
          ),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return ShoppingListDetailScreen(
                  listId: id,
                  onStartShopping: () => context.go('/shopping/$id/shop'),
                  onNavigateBack: () => context.go('/shopping'),
                );
              },
              routes: [
                GoRoute(
                  path: 'shop',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return ShoppingModeScreen(
                      listId: id,
                      onDone: () => context.go('/shopping/$id'),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/recipes',
          builder: (context, state) => RecipesScreen(
            onRecipeTap: (id) => context.go('/recipes/$id'),
            onAddRecipe: () => context.go('/recipes/new'),
            onAiRecipeTap: () => context.go('/ai-recipe'),
          ),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) => RecipeEditScreen(
                onSaved: (id) => context.go('/recipes/$id'),
                onBack: () => context.go('/recipes'),
              ),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return RecipeDetailScreen(
                  recipeId: id,
                  onEdit: () => context.go('/recipes/$id/edit'),
                  onBack: () => context.go('/recipes'),
                );
              },
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return RecipeEditScreen(
                      recipeId: id,
                      onSaved: (_) => context.go('/recipes/$id'),
                      onBack: () => context.go('/recipes/$id'),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/meal-plan',
          builder: (context, state) => MealPlanScreen(
            onRecipeTap: (id) => context.go('/recipes/$id'),
          ),
        ),
        GoRoute(
          path: '/ai-recipe',
          builder: (context, state) => AiRecipeScreen(
            onRecipeCreated: (id) => context.go('/recipes/$id'),
            onBack: () => context.go('/recipes'),
          ),
        ),
      ],
    ),
  ],
);

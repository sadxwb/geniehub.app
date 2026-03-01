import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geniehub_core/geniehub_core.dart';

import '../data/recipe_repository.dart';

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return RecipeRepository(db);
});

final allRecipesProvider = StreamProvider<List<Recipe>>((ref) {
  final repo = ref.watch(recipeRepositoryProvider);
  return repo.watchAllRecipes();
});

final recipeDetailProvider =
    FutureProvider.family<Recipe?, String>((ref, id) {
  final repo = ref.watch(recipeRepositoryProvider);
  return repo.getRecipe(id);
});

final recipeIngredientsProvider =
    StreamProvider.family<List<Ingredient>, String>((ref, recipeId) {
  final repo = ref.watch(recipeRepositoryProvider);
  return repo.watchIngredients(recipeId);
});

final recipeStepsProvider =
    StreamProvider.family<List<RecipeStep>, String>((ref, recipeId) {
  final repo = ref.watch(recipeRepositoryProvider);
  return repo.watchSteps(recipeId);
});

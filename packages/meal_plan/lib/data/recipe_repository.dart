import 'package:drift/drift.dart';
import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

class RecipeRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  RecipeRepository(this._db);

  // ---------------------------------------------------------------------------
  // Recipes
  // ---------------------------------------------------------------------------

  Stream<List<Recipe>> watchAllRecipes() {
    return (_db.select(_db.recipes)
          ..orderBy([
            (t) => OrderingTerm.desc(t.updatedAt),
          ]))
        .watch();
  }

  Future<Recipe?> getRecipe(String id) {
    return (_db.select(_db.recipes)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<Recipe> createRecipe({
    required String title,
    String? description,
    int servings = 4,
    int? prepTime,
    int? cookTime,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final companion = RecipesCompanion.insert(
      id: id,
      title: title,
      description: Value(description),
      servings: Value(servings),
      prepTimeMinutes: Value(prepTime),
      cookTimeMinutes: Value(cookTime),
      createdAt: now,
      updatedAt: now,
    );
    await _db.into(_db.recipes).insert(companion);
    final recipe = await getRecipe(id);
    return recipe!;
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await (_db.update(_db.recipes)..where((t) => t.id.equals(recipe.id)))
        .write(RecipesCompanion(
      title: Value(recipe.title),
      description: Value(recipe.description),
      servings: Value(recipe.servings),
      prepTimeMinutes: Value(recipe.prepTimeMinutes),
      cookTimeMinutes: Value(recipe.cookTimeMinutes),
      imageUrl: Value(recipe.imageUrl),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> deleteRecipe(String id) async {
    await (_db.delete(_db.ingredients)
          ..where((t) => t.recipeId.equals(id)))
        .go();
    await (_db.delete(_db.recipeSteps)
          ..where((t) => t.recipeId.equals(id)))
        .go();
    await (_db.delete(_db.recipes)..where((t) => t.id.equals(id))).go();
  }

  // ---------------------------------------------------------------------------
  // Ingredients
  // ---------------------------------------------------------------------------

  Stream<List<Ingredient>> watchIngredients(String recipeId) {
    return (_db.select(_db.ingredients)
          ..where((t) => t.recipeId.equals(recipeId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  Future<Ingredient> addIngredient(
    String recipeId, {
    required String name,
    double? quantity,
    String? unit,
    bool isOptional = false,
  }) async {
    final id = _uuid.v4();

    // Determine next sort order.
    final existing = await (_db.select(_db.ingredients)
          ..where((t) => t.recipeId.equals(recipeId)))
        .get();
    final nextSort =
        existing.isEmpty ? 0 : existing.map((e) => e.sortOrder).reduce((a, b) => a > b ? a : b) + 1;

    final companion = IngredientsCompanion.insert(
      id: id,
      recipeId: recipeId,
      name: name,
      quantity: Value(quantity),
      unit: Value(unit),
      isOptional: Value(isOptional),
      sortOrder: Value(nextSort),
    );
    await _db.into(_db.ingredients).insert(companion);
    final ingredient = await (_db.select(_db.ingredients)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    return ingredient;
  }

  Future<void> updateIngredient(Ingredient ingredient) async {
    await (_db.update(_db.ingredients)
          ..where((t) => t.id.equals(ingredient.id)))
        .write(IngredientsCompanion(
      name: Value(ingredient.name),
      quantity: Value(ingredient.quantity),
      unit: Value(ingredient.unit),
      isOptional: Value(ingredient.isOptional),
      sortOrder: Value(ingredient.sortOrder),
    ));
  }

  Future<void> deleteIngredient(String id) async {
    await (_db.delete(_db.ingredients)..where((t) => t.id.equals(id))).go();
  }

  // ---------------------------------------------------------------------------
  // Steps
  // ---------------------------------------------------------------------------

  Stream<List<RecipeStep>> watchSteps(String recipeId) {
    return (_db.select(_db.recipeSteps)
          ..where((t) => t.recipeId.equals(recipeId))
          ..orderBy([(t) => OrderingTerm.asc(t.stepNumber)]))
        .watch();
  }

  Future<RecipeStep> addStep(
    String recipeId,
    int stepNumber,
    String instruction,
  ) async {
    final id = _uuid.v4();
    final companion = RecipeStepsCompanion.insert(
      id: id,
      recipeId: recipeId,
      stepNumber: stepNumber,
      instruction: instruction,
    );
    await _db.into(_db.recipeSteps).insert(companion);
    final step = await (_db.select(_db.recipeSteps)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    return step;
  }

  Future<void> updateStep(RecipeStep step) async {
    await (_db.update(_db.recipeSteps)..where((t) => t.id.equals(step.id)))
        .write(RecipeStepsCompanion(
      stepNumber: Value(step.stepNumber),
      instruction: Value(step.instruction),
    ));
  }

  Future<void> deleteStep(String id) async {
    await (_db.delete(_db.recipeSteps)..where((t) => t.id.equals(id))).go();
  }
}

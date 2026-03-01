import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Table definitions — TEXT primary keys (UUIDs) used throughout.
// ---------------------------------------------------------------------------

/// Shopping lists (e.g. "Grocery", "Party", "Gifts").
class ShoppingLists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isArchived =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Individual items within a shopping list.
class ShoppingItems extends Table {
  TextColumn get id => text()();
  TextColumn get listId => text().references(ShoppingLists, #id)();
  TextColumn get name => text()();
  RealColumn get quantity => real().nullable()();
  TextColumn get unit => text().nullable()();
  TextColumn get category => text().nullable()();
  BoolColumn get isChecked =>
      boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Recipes saved by the user.
class Recipes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  IntColumn get servings => integer().withDefault(const Constant(4))();
  IntColumn get prepTimeMinutes => integer().nullable()();
  IntColumn get cookTimeMinutes => integer().nullable()();
  TextColumn get imageUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Ingredients belonging to a recipe.
class Ingredients extends Table {
  TextColumn get id => text()();
  TextColumn get recipeId => text().references(Recipes, #id)();
  TextColumn get name => text()();
  RealColumn get quantity => real().nullable()();
  TextColumn get unit => text().nullable()();
  BoolColumn get isOptional =>
      boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Step-by-step instructions for a recipe.
class RecipeSteps extends Table {
  TextColumn get id => text()();
  TextColumn get recipeId => text().references(Recipes, #id)();
  IntColumn get stepNumber => integer()();
  TextColumn get instruction => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Meal-plan entries mapping a recipe (or custom meal) to a date + meal type.
class MealPlans extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get mealType => text()(); // breakfast, lunch, dinner, snack
  TextColumn get recipeId => text().nullable()();
  TextColumn get customMealName => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [
  ShoppingLists,
  ShoppingItems,
  Recipes,
  Ingredients,
  RecipeSteps,
  MealPlans,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Accepts an explicit [QueryExecutor] — handy for testing with an
  /// in-memory database.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;
}

/// Opens (or creates) the SQLite file in the app's documents directory.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'geniehub.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

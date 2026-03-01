import 'package:drift/drift.dart';
import 'package:core/core.dart';
import 'package:uuid/uuid.dart';

class MealPlanRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  MealPlanRepository(this._db);

  Stream<List<MealPlan>> watchMealPlans(DateTime start, DateTime end) {
    return (_db.select(_db.mealPlans)
          ..where((t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerOrEqualValue(end))
          ..orderBy([
            (t) => OrderingTerm.asc(t.date),
            (t) => OrderingTerm.asc(t.mealType),
          ]))
        .watch();
  }

  Future<List<MealPlan>> getMealPlansForDate(DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return (_db.select(_db.mealPlans)
          ..where(
              (t) => t.date.isBiggerOrEqualValue(dayStart) & t.date.isSmallerThanValue(dayEnd))
          ..orderBy([(t) => OrderingTerm.asc(t.mealType)]))
        .get();
  }

  Future<MealPlan> createMealPlan({
    required DateTime date,
    required String mealType,
    String? recipeId,
    String? customMealName,
    String? notes,
  }) async {
    final id = _uuid.v4();
    final companion = MealPlansCompanion.insert(
      id: id,
      date: date,
      mealType: mealType,
      recipeId: Value(recipeId),
      customMealName: Value(customMealName),
      notes: Value(notes),
    );
    await _db.into(_db.mealPlans).insert(companion);
    final plan = await (_db.select(_db.mealPlans)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    return plan;
  }

  Future<void> updateMealPlan(MealPlan plan) async {
    await (_db.update(_db.mealPlans)..where((t) => t.id.equals(plan.id)))
        .write(MealPlansCompanion(
      date: Value(plan.date),
      mealType: Value(plan.mealType),
      recipeId: Value(plan.recipeId),
      customMealName: Value(plan.customMealName),
      notes: Value(plan.notes),
    ));
  }

  Future<void> deleteMealPlan(String id) async {
    await (_db.delete(_db.mealPlans)..where((t) => t.id.equals(id))).go();
  }
}

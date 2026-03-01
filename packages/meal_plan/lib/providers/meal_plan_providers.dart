import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';

import '../data/meal_plan_repository.dart';

final mealPlanRepositoryProvider = Provider<MealPlanRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return MealPlanRepository(db);
});

/// Notifier that holds the currently selected date for the meal planner.
class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void select(DateTime date) => state = date;
}

final selectedDateProvider =
    NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

/// Returns the Monday of the week that contains [date].
DateTime _startOfWeek(DateTime date) {
  final weekday = date.weekday; // Monday = 1
  return DateTime(date.year, date.month, date.day)
      .subtract(Duration(days: weekday - 1));
}

final weeklyMealPlanProvider = StreamProvider<List<MealPlan>>((ref) {
  final repo = ref.watch(mealPlanRepositoryProvider);
  final selected = ref.watch(selectedDateProvider);
  final start = _startOfWeek(selected);
  final end = start.add(const Duration(days: 7));
  return repo.watchMealPlans(start, end);
});

final mealPlanForDateProvider =
    FutureProvider.family<List<MealPlan>, DateTime>((ref, date) {
  final repo = ref.watch(mealPlanRepositoryProvider);
  return repo.getMealPlansForDate(date);
});

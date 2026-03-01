import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geniehub_core/geniehub_core.dart';
import 'package:intl/intl.dart';

import '../providers/meal_plan_providers.dart';
import '../providers/recipe_providers.dart';

class MealPlanDashboardWidget extends ConsumerWidget {
  final VoidCallback? onTap;

  const MealPlanDashboardWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final todayPlansAsync = ref.watch(mealPlanForDateProvider(today));
    final tomorrowPlansAsync = ref.watch(mealPlanForDateProvider(tomorrow));
    final recipesAsync = ref.watch(allRecipesProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month,
                      size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Meal Plan',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 12),
              // Today
              _DaySection(
                label: 'Today',
                date: today,
                plansAsync: todayPlansAsync,
                recipesAsync: recipesAsync,
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              // Tomorrow
              _DaySection(
                label: 'Tomorrow',
                date: tomorrow,
                plansAsync: tomorrowPlansAsync,
                recipesAsync: recipesAsync,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final String label;
  final DateTime date;
  final AsyncValue<List<MealPlan>> plansAsync;
  final AsyncValue<List<Recipe>> recipesAsync;

  const _DaySection({
    required this.label,
    required this.date,
    required this.plansAsync,
    required this.recipesAsync,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label, ${DateFormat.MMMd().format(date)}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        plansAsync.when(
          loading: () => const SizedBox(
            height: 24,
            child: Center(child: LinearProgressIndicator()),
          ),
          error: (_, __) => Text(
            'Failed to load',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          data: (plans) {
            if (plans.isEmpty) {
              return Text(
                'No meals planned',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              );
            }

            final recipes = recipesAsync.value ?? <Recipe>[];
            final recipeMap = {for (final r in recipes) r.id: r};

            return Column(
              children: plans.map((plan) {
                final mealLabel = _capitalizeFirst(plan.mealType);
                final name = plan.customMealName ??
                    (plan.recipeId != null
                        ? recipeMap[plan.recipeId]?.title
                        : null) ??
                    'Unnamed meal';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 72,
                        child: Text(
                          mealLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          name,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  String _capitalizeFirst(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

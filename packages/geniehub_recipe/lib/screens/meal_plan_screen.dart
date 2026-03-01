import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geniehub_core/geniehub_core.dart';
import 'package:intl/intl.dart';

import '../providers/meal_plan_providers.dart';
import '../providers/recipe_providers.dart';
import '../widgets/meal_slot_widget.dart';

class MealPlanScreen extends ConsumerWidget {
  final void Function(String recipeId)? onRecipeTap;

  const MealPlanScreen({super.key, this.onRecipeTap});

  static const _mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedDate = ref.watch(selectedDateProvider);
    final weekStart = _startOfWeek(selectedDate);
    final mealPlansAsync = ref.watch(weeklyMealPlanProvider);
    final recipesAsync = ref.watch(allRecipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
      ),
      body: Column(
        children: [
          // Week navigation header
          _WeekNavigator(
            weekStart: weekStart,
            onPreviousWeek: () {
              ref.read(selectedDateProvider.notifier).select(
                  selectedDate.subtract(const Duration(days: 7)));
            },
            onNextWeek: () {
              ref.read(selectedDateProvider.notifier).select(
                  selectedDate.add(const Duration(days: 7)));
            },
            onToday: () {
              final now = DateTime.now();
              ref.read(selectedDateProvider.notifier).select(
                  DateTime(now.year, now.month, now.day));
            },
          ),
          // Day tabs
          _DayTabBar(
            weekStart: weekStart,
            selectedDate: selectedDate,
            onDaySelected: (date) {
              ref.read(selectedDateProvider.notifier).select(date);
            },
          ),
          const Divider(height: 1),
          // Meal slots for selected day
          Expanded(
            child: mealPlansAsync.when(
              loading: () => const Center(child: LoadingWidget()),
              error: (err, _) =>
                  Center(child: AppErrorWidget(message: err.toString())),
              data: (allPlans) {
                final dayStart = DateTime(
                    selectedDate.year, selectedDate.month, selectedDate.day);
                final dayEnd = dayStart.add(const Duration(days: 1));
                final dayPlans = allPlans
                    .where((p) =>
                        !p.date.isBefore(dayStart) && p.date.isBefore(dayEnd))
                    .toList();

                final recipes = recipesAsync.value ?? <Recipe>[];
                final recipeMap = {for (final r in recipes) r.id: r};

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      DateFormat.yMMMMEEEEd().format(selectedDate),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final mealType in _mealTypes) ...[
                      _buildMealSlot(
                        context,
                        ref,
                        mealType: mealType,
                        plan: dayPlans.cast<MealPlan?>().firstWhere(
                              (p) => p!.mealType == mealType,
                              orElse: () => null,
                            ),
                        recipeMap: recipeMap,
                        date: selectedDate,
                        recipes: recipes,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSlot(
    BuildContext context,
    WidgetRef ref, {
    required String mealType,
    required MealPlan? plan,
    required Map<String, Recipe> recipeMap,
    required DateTime date,
    required List<Recipe> recipes,
  }) {
    final recipeName =
        plan?.recipeId != null ? recipeMap[plan!.recipeId]?.title : null;

    return MealSlotWidget(
      mealType: mealType,
      mealPlan: plan,
      recipeName: recipeName,
      onTap: () => _showAssignDialog(
        context,
        ref,
        mealType: mealType,
        date: date,
        existingPlan: plan,
        recipes: recipes,
      ),
      onDelete: plan != null
          ? () async {
              final repo = ref.read(mealPlanRepositoryProvider);
              await repo.deleteMealPlan(plan.id);
            }
          : null,
    );
  }

  Future<void> _showAssignDialog(
    BuildContext context,
    WidgetRef ref, {
    required String mealType,
    required DateTime date,
    required MealPlan? existingPlan,
    required List<Recipe> recipes,
  }) async {
    final result = await showDialog<_MealAssignment>(
      context: context,
      builder: (ctx) => _MealAssignDialog(
        mealType: mealType,
        recipes: recipes,
        currentRecipeId: existingPlan?.recipeId,
        currentCustomName: existingPlan?.customMealName,
      ),
    );

    if (result == null) return;

    final repo = ref.read(mealPlanRepositoryProvider);

    if (existingPlan != null) {
      await repo.deleteMealPlan(existingPlan.id);
    }

    await repo.createMealPlan(
      date: date,
      mealType: mealType,
      recipeId: result.recipeId,
      customMealName: result.customName,
    );
  }

  DateTime _startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: weekday - 1));
  }
}

// ---------------------------------------------------------------------------
// Week navigator
// ---------------------------------------------------------------------------

class _WeekNavigator extends StatelessWidget {
  final DateTime weekStart;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onToday;

  const _WeekNavigator({
    required this.weekStart,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekEnd = weekStart.add(const Duration(days: 6));
    final label =
        '${DateFormat.MMMd().format(weekStart)} - ${DateFormat.MMMd().format(weekEnd)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPreviousWeek,
          ),
          Expanded(
            child: Center(
              child: Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: onToday,
            child: const Text('Today'),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNextWeek,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Day tab bar
// ---------------------------------------------------------------------------

class _DayTabBar extends StatelessWidget {
  final DateTime weekStart;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDaySelected;

  const _DayTabBar({
    required this.weekStart,
    required this.selectedDate,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();

    return SizedBox(
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = weekStart.add(Duration(days: index));
          final isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;
          final isToday = date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Material(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onDaySelected(date),
                child: Container(
                  width: 48,
                  alignment: Alignment.center,
                  decoration: isToday && !isSelected
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 1.5,
                          ),
                        )
                      : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat.E().format(date).substring(0, 2),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${date.day}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Meal assignment dialog
// ---------------------------------------------------------------------------

class _MealAssignment {
  final String? recipeId;
  final String? customName;

  _MealAssignment({this.recipeId, this.customName});
}

class _MealAssignDialog extends StatefulWidget {
  final String mealType;
  final List<Recipe> recipes;
  final String? currentRecipeId;
  final String? currentCustomName;

  const _MealAssignDialog({
    required this.mealType,
    required this.recipes,
    this.currentRecipeId,
    this.currentCustomName,
  });

  @override
  State<_MealAssignDialog> createState() => _MealAssignDialogState();
}

class _MealAssignDialogState extends State<_MealAssignDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String? _selectedRecipeId;
  final _customNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedRecipeId = widget.currentRecipeId;
    _customNameController.text = widget.currentCustomName ?? '';

    // Start on the custom tab if there is a custom meal name.
    if (widget.currentCustomName != null &&
        widget.currentCustomName!.isNotEmpty) {
      _tabController.index = 1;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customNameController.dispose();
    super.dispose();
  }

  String _capitalizeFirst(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('${_capitalizeFirst(widget.mealType)} Plan'),
      contentPadding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Pick a Recipe'),
                Tab(text: 'Custom'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Recipe picker tab
                  widget.recipes.isEmpty
                      ? Center(
                          child: Text(
                            'No recipes yet.\nCreate one first!',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: widget.recipes.length,
                          itemBuilder: (context, index) {
                            final recipe = widget.recipes[index];
                            final isSelected =
                                recipe.id == _selectedRecipeId;
                            return ListTile(
                              title: Text(recipe.title),
                              subtitle: recipe.description != null
                                  ? Text(
                                      recipe.description!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : null,
                              trailing: isSelected
                                  ? Icon(Icons.check_circle,
                                      color: theme.colorScheme.primary)
                                  : null,
                              selected: isSelected,
                              onTap: () {
                                setState(() {
                                  _selectedRecipeId = recipe.id;
                                });
                              },
                            );
                          },
                        ),
                  // Custom meal tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _customNameController,
                      decoration: const InputDecoration(
                        labelText: 'Meal name',
                        hintText: 'e.g., Leftover pasta',
                        border: OutlineInputBorder(),
                      ),
                      autofocus: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_tabController.index == 0 && _selectedRecipeId != null) {
              Navigator.of(context).pop(
                  _MealAssignment(recipeId: _selectedRecipeId));
            } else if (_tabController.index == 1 &&
                _customNameController.text.trim().isNotEmpty) {
              Navigator.of(context).pop(_MealAssignment(
                  customName: _customNameController.text.trim()));
            }
          },
          child: const Text('Assign'),
        ),
      ],
    );
  }
}

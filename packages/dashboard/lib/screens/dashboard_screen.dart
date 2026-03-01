import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:shopping/shopping.dart';
import 'package:meal_plan/meal_plan.dart';

import '../widgets/dashboard_widget_container.dart';

/// The home screen that aggregates widgets from all feature modules.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    super.key,
    this.onNavigateToShopping,
    this.onNavigateToShoppingList,
    this.onNavigateToShoppingMode,
    this.onNavigateToMealPlan,
    this.onNavigateToAddRecipe,
    this.onNavigateToRecipes,
    this.onNavigateToAiRecipe,
  });

  final VoidCallback? onNavigateToShopping;
  final ValueChanged<String>? onNavigateToShoppingList;
  final ValueChanged<String>? onNavigateToShoppingMode;
  final VoidCallback? onNavigateToMealPlan;
  final VoidCallback? onNavigateToAddRecipe;
  final VoidCallback? onNavigateToRecipes;
  final VoidCallback? onNavigateToAiRecipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(user.displayName),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formattedDate(DateTime.now()),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Shopping dashboard widget
              ShoppingDashboardWidget(
                onViewAllLists: onNavigateToShopping,
                onListTap: onNavigateToShoppingList,
                onStartShopping: onNavigateToShoppingMode,
              ),

              // Meal plan dashboard widget
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: MealPlanDashboardWidget(
                  onTap: onNavigateToMealPlan,
                ),
              ),

              // Quick actions
              DashboardWidgetContainer(
                title: 'Quick Actions',
                icon: Icons.bolt,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _QuickActionChip(
                      icon: Icons.add,
                      label: 'Add Recipe',
                      onTap: onNavigateToAddRecipe,
                    ),
                    _QuickActionChip(
                      icon: Icons.shopping_cart_outlined,
                      label: 'Shopping',
                      onTap: onNavigateToShopping,
                    ),
                    _QuickActionChip(
                      icon: Icons.calendar_month,
                      label: 'Plan Meals',
                      onTap: onNavigateToMealPlan,
                    ),
                    _QuickActionChip(
                      icon: Icons.restaurant_menu,
                      label: 'Recipes',
                      onTap: onNavigateToRecipes,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting(String? name) {
    final hour = DateTime.now().hour;
    final prefix = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    if (name != null && name.isNotEmpty) {
      final firstName = name.split(' ').first;
      return '$prefix, $firstName';
    }
    return prefix;
  }

  String _formattedDate(DateTime date) {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return '$weekday, $month ${date.day}';
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

import 'package:flutter/material.dart';

/// Grid of feature shortcuts for the "Apps" bottom nav tab.
class AppsScreen extends StatelessWidget {
  const AppsScreen({
    super.key,
    this.onNavigateToShopping,
    this.onNavigateToRecipes,
    this.onNavigateToMealPlan,
    this.onNavigateToAiRecipe,
  });

  final VoidCallback? onNavigateToShopping;
  final VoidCallback? onNavigateToRecipes;
  final VoidCallback? onNavigateToMealPlan;
  final VoidCallback? onNavigateToAiRecipe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apps',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _AppTile(
                    icon: Icons.shopping_cart,
                    label: 'Shopping',
                    color: theme.colorScheme.primary,
                    onTap: onNavigateToShopping,
                  ),
                  _AppTile(
                    icon: Icons.calendar_month,
                    label: 'Meal Plan',
                    color: theme.colorScheme.tertiary,
                    onTap: onNavigateToMealPlan,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppTile extends StatelessWidget {
  const _AppTile({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

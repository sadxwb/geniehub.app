import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geniehub_core/geniehub_core.dart';

import '../providers/recipe_providers.dart';
import '../widgets/ingredient_list.dart';
import '../widgets/add_to_shopping_list_dialog.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final String recipeId;
  final VoidCallback? onEdit;
  final VoidCallback? onBack;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
    this.onEdit,
    this.onBack,
  });

  @override
  ConsumerState<RecipeDetailScreen> createState() =>
      _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  final Set<String> _checkedIngredients = {};

  String _formatTime(int? minutes) {
    if (minutes == null) return '';
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    if (remaining == 0) return '$hours hr';
    return '$hours hr $remaining min';
  }

  void _showAddToShoppingListDialog() {
    showDialog<bool>(
      context: context,
      builder: (_) => AddToShoppingListDialog(recipeId: widget.recipeId),
    ).then((added) {
      if (added == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingredients added to shopping list!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipeAsync = ref.watch(recipeDetailProvider(widget.recipeId));
    final ingredientsAsync =
        ref.watch(recipeIngredientsProvider(widget.recipeId));
    final stepsAsync = ref.watch(recipeStepsProvider(widget.recipeId));

    return Scaffold(
      appBar: AppBar(
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Recipe',
            onPressed: widget.onEdit,
          ),
        ],
      ),
      body: recipeAsync.when(
        loading: () => const Center(child: LoadingWidget()),
        error: (err, _) => Center(
          child: AppErrorWidget(message: err.toString()),
        ),
        data: (recipe) {
          if (recipe == null) {
            return const Center(
              child: Text('Recipe not found.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header image
                if (recipe.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        recipe.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.restaurant,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Title
                Text(
                  recipe.title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Description
                if (recipe.description != null &&
                    recipe.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    recipe.description!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Meta info chips
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.people_outlined,
                      label: '${recipe.servings} servings',
                    ),
                    if (recipe.prepTimeMinutes != null)
                      _InfoChip(
                        icon: Icons.timer_outlined,
                        label: 'Prep: ${_formatTime(recipe.prepTimeMinutes)}',
                      ),
                    if (recipe.cookTimeMinutes != null)
                      _InfoChip(
                        icon: Icons.local_fire_department_outlined,
                        label: 'Cook: ${_formatTime(recipe.cookTimeMinutes)}',
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Ingredients section
                Row(
                  children: [
                    Text(
                      'Ingredients',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _showAddToShoppingListDialog,
                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                      label: const Text('Add to List'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ingredientsAsync.when(
                  loading: () => const LoadingWidget(),
                  error: (err, _) =>
                      AppErrorWidget(message: err.toString()),
                  data: (ingredients) => IngredientList(
                    ingredients: ingredients,
                    showCheckboxes: true,
                    checkedIds: _checkedIngredients,
                    onToggle: (id) {
                      setState(() {
                        if (_checkedIngredients.contains(id)) {
                          _checkedIngredients.remove(id);
                        } else {
                          _checkedIngredients.add(id);
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Steps section
                Text(
                  'Instructions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                stepsAsync.when(
                  loading: () => const LoadingWidget(),
                  error: (err, _) =>
                      AppErrorWidget(message: err.toString()),
                  data: (steps) {
                    if (steps.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No instructions added yet.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: steps.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final step = steps[index];
                        return _StepTile(
                          stepNumber: step.stepNumber,
                          instruction: step.instruction,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final int stepNumber;
  final String instruction;

  const _StepTile({required this.stepNumber, required this.instruction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$stepNumber',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              instruction,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }
}

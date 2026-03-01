import 'package:flutter/material.dart';
import 'package:core/core.dart';

class MealSlotWidget extends StatelessWidget {
  final String mealType;
  final MealPlan? mealPlan;
  final String? recipeName;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const MealSlotWidget({
    super.key,
    required this.mealType,
    this.mealPlan,
    this.recipeName,
    this.onTap,
    this.onDelete,
  });

  IconData _iconForMealType(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie_outlined;
      default:
        return Icons.restaurant;
    }
  }

  String _labelForMealType(String type) {
    if (type.isEmpty) return type;
    return type[0].toUpperCase() + type.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasContent = mealPlan != null;
    final displayName = mealPlan?.customMealName ?? recipeName;

    return Card(
      elevation: hasContent ? 1 : 0,
      color: hasContent
          ? theme.colorScheme.surfaceContainerLow
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                _iconForMealType(mealType),
                size: 20,
                color: hasContent
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _labelForMealType(mealType),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName ?? 'Tap to plan',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: hasContent
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                        fontStyle:
                            hasContent ? FontStyle.normal : FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (hasContent && onDelete != null)
                IconButton(
                  icon: Icon(Icons.close,
                      size: 18, color: theme.colorScheme.onSurfaceVariant),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

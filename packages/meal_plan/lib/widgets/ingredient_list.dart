import 'package:flutter/material.dart';
import 'package:core/core.dart';

class IngredientList extends StatelessWidget {
  final List<Ingredient> ingredients;
  final bool showCheckboxes;
  final Set<String>? checkedIds;
  final ValueChanged<String>? onToggle;

  const IngredientList({
    super.key,
    required this.ingredients,
    this.showCheckboxes = false,
    this.checkedIds,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (ingredients.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No ingredients added yet.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        final isChecked = checkedIds?.contains(ingredient.id) ?? false;

        final quantityText = _formatQuantity(ingredient);
        final displayText = quantityText.isNotEmpty
            ? '$quantityText ${ingredient.name}'
            : ingredient.name;

        if (showCheckboxes) {
          return CheckboxListTile(
            value: isChecked,
            onChanged: (_) => onToggle?.call(ingredient.id),
            title: Text(
              displayText,
              style: theme.textTheme.bodyMedium?.copyWith(
                decoration: isChecked ? TextDecoration.lineThrough : null,
                color: isChecked
                    ? theme.colorScheme.onSurfaceVariant
                    : null,
              ),
            ),
            subtitle: ingredient.isOptional
                ? Text(
                    'Optional',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : null,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
          );
        }

        return ListTile(
          leading: const Icon(Icons.fiber_manual_record, size: 8),
          title: Text(displayText, style: theme.textTheme.bodyMedium),
          subtitle: ingredient.isOptional
              ? Text(
                  'Optional',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                )
              : null,
          dense: true,
          visualDensity: VisualDensity.compact,
        );
      },
    );
  }

  String _formatQuantity(Ingredient ingredient) {
    final parts = <String>[];
    if (ingredient.quantity != null) {
      final q = ingredient.quantity!;
      // Display as integer if it has no fractional part.
      if (q == q.roundToDouble() && q == q.toInt().toDouble()) {
        parts.add(q.toInt().toString());
      } else {
        parts.add(q.toString());
      }
    }
    if (ingredient.unit != null && ingredient.unit!.isNotEmpty) {
      parts.add(ingredient.unit!);
    }
    return parts.join(' ');
  }
}

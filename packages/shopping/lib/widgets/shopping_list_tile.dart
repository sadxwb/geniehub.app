import 'package:flutter/material.dart';
import 'package:core/core.dart';

/// A Material card showing a shopping list summary in the lists overview.
class ShoppingListTile extends StatelessWidget {
  const ShoppingListTile({
    super.key,
    required this.list,
    required this.totalItems,
    required this.checkedItems,
    this.onTap,
    this.onStartShopping,
  });

  /// The shopping list to display.
  final ShoppingList list;

  /// Total number of items in the list.
  final int totalItems;

  /// Number of checked-off items.
  final int checkedItems;

  /// Called when the card is tapped (navigate to detail).
  final VoidCallback? onTap;

  /// Called when the "Start Shopping" button is pressed.
  final VoidCallback? onStartShopping;

  double get _progress =>
      totalItems > 0 ? checkedItems / totalItems : 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      list.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (list.isArchived)
                    Chip(
                      label: const Text('Archived'),
                      visualDensity: VisualDensity.compact,
                      labelStyle: theme.textTheme.labelSmall,
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Item count
              Text(
                totalItems == 0
                    ? 'No items'
                    : '$checkedItems of $totalItems items checked',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 6,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _progress >= 1.0
                        ? colorScheme.tertiary
                        : colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Action row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (totalItems > 0 && onStartShopping != null)
                    FilledButton.tonalIcon(
                      onPressed: onStartShopping,
                      icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                      label: const Text('Start Shopping'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

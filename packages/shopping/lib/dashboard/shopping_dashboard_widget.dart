import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';

import '../providers/shopping_providers.dart';

/// A card widget for the app dashboard showing the most recent
/// non-archived shopping list with progress and quick actions.
class ShoppingDashboardWidget extends ConsumerWidget {
  const ShoppingDashboardWidget({
    super.key,
    this.onViewAllLists,
    this.onStartShopping,
    this.onListTap,
  });

  /// Called when the user taps "View All Lists".
  final VoidCallback? onViewAllLists;

  /// Called when the user taps "Start Shopping" for a specific list.
  /// Receives the list ID.
  final ValueChanged<String>? onStartShopping;

  /// Called when the user taps on the list name/card.
  /// Receives the list ID.
  final ValueChanged<String>? onListTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(shoppingListsProvider);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Shopping',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (onViewAllLists != null)
                  TextButton(
                    onPressed: onViewAllLists,
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Content
            listsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: LoadingWidget()),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Unable to load shopping lists',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
              data: (lists) {
                if (lists.isEmpty) {
                  return _buildEmptyState(context);
                }

                // Show the most recently updated list.
                final recentList = lists.first;
                return _ShoppingDashboardListPreview(
                  list: recentList,
                  onTap: onListTap != null
                      ? () => onListTap!(recentList.id)
                      : null,
                  onStartShopping: onStartShopping != null
                      ? () => onStartShopping!(recentList.id)
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          'No active shopping lists',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Internal widget that watches item counts for the preview list.
class _ShoppingDashboardListPreview extends ConsumerWidget {
  const _ShoppingDashboardListPreview({
    required this.list,
    this.onTap,
    this.onStartShopping,
  });

  final ShoppingList list;
  final VoidCallback? onTap;
  final VoidCallback? onStartShopping;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(shoppingItemsProvider(list.id));
    final theme = Theme.of(context);

    return itemsAsync.when(
      loading: () => const SizedBox(
        height: 48,
        child: Center(child: LoadingWidget()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        final total = items.length;
        final checked = items.where((i) => i.isChecked).length;
        final remaining = total - checked;
        final progress = total > 0 ? checked / total : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // List name
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        list.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Progress
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 1.0
                            ? theme.colorScheme.tertiary
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  total == 0
                      ? 'Empty'
                      : remaining == 0
                          ? 'All done!'
                          : '$remaining left',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Start Shopping button
            if (total > 0 && onStartShopping != null)
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: onStartShopping,
                  icon:
                      const Icon(Icons.shopping_cart_outlined, size: 18),
                  label: Text(
                    progress >= 1.0 ? 'Shopping Complete' : 'Start Shopping',
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

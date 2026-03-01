import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geniehub_core/geniehub_core.dart';

import '../providers/shopping_providers.dart';
import '../widgets/shopping_item_tile.dart';

/// Full-screen shopping mode experience.
///
/// Shows large, easy-to-tap items. Checked items move to the bottom
/// with strikethrough. Displays progress at the top.
class ShoppingModeScreen extends ConsumerWidget {
  const ShoppingModeScreen({
    super.key,
    required this.listId,
    this.onDone,
  });

  /// The ID of the shopping list.
  final String listId;

  /// Called when the user taps "Done Shopping".
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(shoppingListDetailProvider(listId));
    final itemsAsync = ref.watch(shoppingItemsProvider(listId));
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        scaffoldBackgroundColor: theme.brightness == Brightness.dark
            ? const Color(0xFF0D1117)
            : const Color(0xFF1B2838),
        appBarTheme: theme.appBarTheme.copyWith(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: listAsync.when(
            loading: () => const Text('Shopping'),
            error: (_, __) => const Text('Shopping'),
            data: (list) =>
                Text(list?.name ?? 'Shopping', style: const TextStyle(color: Colors.white)),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: onDone ?? () => Navigator.of(context).maybePop(),
          ),
          actions: [
            TextButton(
              onPressed: onDone ?? () => Navigator.of(context).maybePop(),
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: itemsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          error: (error, stack) => Center(
            child: Text(
              'Failed to load items',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
          data: (items) => _ShoppingModeBody(
            items: items,
            listId: listId,
          ),
        ),
      ),
    );
  }
}

class _ShoppingModeBody extends ConsumerWidget {
  const _ShoppingModeBody({
    required this.items,
    required this.listId,
  });

  final List<ShoppingItem> items;
  final String listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No items in this list',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
        ),
      );
    }

    final unchecked = items.where((i) => !i.isChecked).toList();
    final checked = items.where((i) => i.isChecked).toList();
    final total = items.length;
    final checkedCount = checked.length;
    final progress = total > 0 ? checkedCount / total : 0.0;

    return Column(
      children: [
        // Progress header
        Container(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: Column(
            children: [
              Text(
                '$checkedCount of $total items',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0 ? Colors.greenAccent : Colors.blueAccent,
                  ),
                ),
              ),
              if (progress >= 1.0) ...[
                const SizedBox(height: 12),
                Text(
                  'All done!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ],
          ),
        ),

        // Items list
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              // Unchecked items first.
              ...unchecked.map(
                (item) => _buildShoppingItem(context, ref, item),
              ),

              // Divider between unchecked and checked.
              if (unchecked.isNotEmpty && checked.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Divider(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),

              // Checked items.
              if (checked.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
                  child: Text(
                    'Checked off',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                  ),
                ),
              ...checked.map(
                (item) => _buildShoppingItem(context, ref, item),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShoppingItem(
    BuildContext context,
    WidgetRef ref,
    ShoppingItem item,
  ) {
    return Material(
      color: Colors.transparent,
      child: Theme(
        data: Theme.of(context).copyWith(
          checkboxTheme: CheckboxThemeData(
            checkColor: WidgetStateProperty.all(Colors.white),
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.blueAccent;
              }
              return Colors.white.withValues(alpha: 0.3);
            }),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          listTileTheme: ListTileThemeData(
            textColor: item.isChecked
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.white,
          ),
        ),
        child: ShoppingItemTile(
          item: item,
          shoppingMode: true,
          onToggle: (checked) {
            final repo = ref.read(shoppingRepositoryProvider);
            repo.toggleItemChecked(item.id, checked);
          },
        ),
      ),
    );
  }
}

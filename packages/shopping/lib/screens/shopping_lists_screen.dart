import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';

import '../providers/shopping_providers.dart';
import '../widgets/add_list_dialog.dart';
import '../widgets/shopping_list_tile.dart';

/// Screen showing all active shopping lists as cards.
class ShoppingListsScreen extends ConsumerWidget {
  const ShoppingListsScreen({
    super.key,
    this.onListTap,
    this.onStartShopping,
  });

  /// Called when a list card is tapped. Receives the list ID.
  final ValueChanged<String>? onListTap;

  /// Called when the "Start Shopping" button on a card is pressed.
  /// Receives the list ID.
  final ValueChanged<String>? onStartShopping;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(shoppingListsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Lists'),
      ),
      body: listsAsync.when(
        loading: () => const Center(child: LoadingWidget()),
        error: (error, stack) => Center(
          child: AppErrorWidget(
            message: 'Failed to load shopping lists',
            onRetry: () => ref.invalidate(shoppingListsProvider),
          ),
        ),
        data: (lists) {
          if (lists.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No shopping lists yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to create one',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final list = lists[index];
              return _ShoppingListCard(
                list: list,
                onTap: onListTap != null ? () => onListTap!(list.id) : null,
                onStartShopping: onStartShopping != null
                    ? () => onStartShopping!(list.id)
                    : null,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createList(context, ref),
        tooltip: 'Create new list',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _createList(BuildContext context, WidgetRef ref) async {
    final name = await AddListDialog.show(context);
    if (name == null || name.isEmpty) return;

    final repo = ref.read(shoppingRepositoryProvider);
    final newList = await repo.createList(name);

    if (context.mounted && onListTap != null) {
      onListTap!(newList.id);
    }
  }
}

/// Internal widget that watches item counts for a specific list.
class _ShoppingListCard extends ConsumerWidget {
  const _ShoppingListCard({
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

    return itemsAsync.when(
      loading: () => ShoppingListTile(
        list: list,
        totalItems: 0,
        checkedItems: 0,
        onTap: onTap,
        onStartShopping: onStartShopping,
      ),
      error: (_, __) => ShoppingListTile(
        list: list,
        totalItems: 0,
        checkedItems: 0,
        onTap: onTap,
        onStartShopping: onStartShopping,
      ),
      data: (items) {
        final total = items.length;
        final checked = items.where((i) => i.isChecked).length;
        return ShoppingListTile(
          list: list,
          totalItems: total,
          checkedItems: checked,
          onTap: onTap,
          onStartShopping: onStartShopping,
        );
      },
    );
  }
}

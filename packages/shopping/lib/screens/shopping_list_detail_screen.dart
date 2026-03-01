import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';

import '../providers/shopping_providers.dart';
import '../widgets/add_item_dialog.dart';
import '../widgets/shopping_item_tile.dart';

/// Screen for viewing and editing a single shopping list.
class ShoppingListDetailScreen extends ConsumerStatefulWidget {
  const ShoppingListDetailScreen({
    super.key,
    required this.listId,
    this.onStartShopping,
    this.onNavigateBack,
  });

  /// The ID of the shopping list to display.
  final String listId;

  /// Called when the user wants to enter shopping mode.
  final VoidCallback? onStartShopping;

  /// Called when the user navigates back (e.g. after deleting the list).
  final VoidCallback? onNavigateBack;

  @override
  ConsumerState<ShoppingListDetailScreen> createState() =>
      _ShoppingListDetailScreenState();
}

class _ShoppingListDetailScreenState
    extends ConsumerState<ShoppingListDetailScreen> {
  bool _isEditingName = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(shoppingListDetailProvider(widget.listId));
    final itemsAsync = ref.watch(shoppingItemsProvider(widget.listId));

    return listAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: LoadingWidget()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: AppErrorWidget(
            message: 'Failed to load shopping list',
            onRetry: () =>
                ref.invalidate(shoppingListDetailProvider(widget.listId)),
          ),
        ),
      ),
      data: (list) {
        if (list == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Shopping list not found')),
          );
        }

        return Scaffold(
          appBar: _buildAppBar(context, list),
          body: _buildBody(context, itemsAsync),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addItem(context),
            tooltip: 'Add item',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ShoppingList list) {
    if (_isEditingName) {
      return AppBar(
        title: TextField(
          controller: _nameController,
          autofocus: true,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'List name',
          ),
          onSubmitted: (value) => _saveName(list, value),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => _saveName(list, _nameController.text),
          ),
        ],
      );
    }

    return AppBar(
      title: GestureDetector(
        onTap: () {
          _nameController.text = list.name;
          setState(() => _isEditingName = true);
        },
        child: Text(list.name),
      ),
      actions: [
        if (widget.onStartShopping != null)
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Start shopping',
            onPressed: widget.onStartShopping,
          ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, list),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'uncheck_all',
              child: ListTile(
                leading: Icon(Icons.check_box_outline_blank),
                title: Text('Uncheck All'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'archive',
              child: ListTile(
                leading: Icon(Icons.archive_outlined),
                title: Text('Archive List'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text('Delete List',
                    style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncValue<List<ShoppingItem>> itemsAsync,
  ) {
    return itemsAsync.when(
      loading: () => const Center(child: LoadingWidget()),
      error: (error, stack) => Center(
        child: AppErrorWidget(
          message: 'Failed to load items',
          onRetry: () =>
              ref.invalidate(shoppingItemsProvider(widget.listId)),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.playlist_add,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No items yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add items',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          );
        }

        // Group items by category.
        final grouped = _groupByCategory(items);

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 88),
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final entry = grouped[index];
            return _buildCategorySection(context, entry.key, entry.value);
          },
        );
      },
    );
  }

  List<MapEntry<String?, List<ShoppingItem>>> _groupByCategory(
    List<ShoppingItem> items,
  ) {
    final map = <String?, List<ShoppingItem>>{};
    for (final item in items) {
      final category = item.category;
      map.putIfAbsent(category, () => []).add(item);
    }

    // Sort: uncategorized last, others alphabetically.
    final entries = map.entries.toList()
      ..sort((a, b) {
        if (a.key == null && b.key == null) return 0;
        if (a.key == null) return 1;
        if (b.key == null) return -1;
        return a.key!.compareTo(b.key!);
      });

    return entries;
  }

  Widget _buildCategorySection(
    BuildContext context,
    String? category,
    List<ShoppingItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (category != null && category.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              category,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ...items.map(
          (item) => ShoppingItemTile(
            item: item,
            onToggle: (checked) => _toggleItem(item.id, checked),
            onTap: () => _editItem(context, item),
            onDismissed: () => _deleteItem(item.id),
          ),
        ),
      ],
    );
  }

  Future<void> _saveName(ShoppingList list, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      setState(() => _isEditingName = false);
      return;
    }

    final repo = ref.read(shoppingRepositoryProvider);
    // Drift data classes are immutable; we create a copy via the copyWith
    // or reconstruct by hand. Since generated Drift data classes typically
    // include copyWith, we use it.  If not available we'd need the companion.
    // For safety, re-fetch and update:
    final current = await repo.getList(list.id);
    if (current != null) {
      await repo.updateList(ShoppingList(
        id: current.id,
        name: trimmed,
        createdAt: current.createdAt,
        updatedAt: DateTime.now(),
        isArchived: current.isArchived,
      ));
    }

    ref.invalidate(shoppingListDetailProvider(widget.listId));
    if (mounted) setState(() => _isEditingName = false);
  }

  Future<void> _addItem(BuildContext context) async {
    final result = await AddItemDialog.show(context);
    if (result == null) return;

    final repo = ref.read(shoppingRepositoryProvider);
    await repo.addItem(
      widget.listId,
      result['name'] as String,
      quantity: result['quantity'] as double?,
      unit: result['unit'] as String?,
      category: result['category'] as String?,
    );
  }

  Future<void> _editItem(BuildContext context, ShoppingItem item) async {
    final result = await _showEditItemDialog(context, item);
    if (result == null) return;

    final repo = ref.read(shoppingRepositoryProvider);
    await repo.updateItem(ShoppingItem(
      id: item.id,
      listId: item.listId,
      name: result['name'] as String,
      quantity: result['quantity'] as double?,
      unit: result['unit'] as String?,
      category: result['category'] as String?,
      isChecked: item.isChecked,
      sortOrder: item.sortOrder,
    ));
  }

  Future<Map<String, dynamic>?> _showEditItemDialog(
    BuildContext context,
    ShoppingItem item,
  ) {
    final nameController = TextEditingController(text: item.name);
    final quantityController = TextEditingController(
      text: item.quantity?.toString() ?? '',
    );
    final unitController = TextEditingController(text: item.unit ?? '');
    final categoryController =
        TextEditingController(text: item.category ?? '');
    final formKey = GlobalKey<FormState>();

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Item'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item name',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an item name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: unitController,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final quantity = quantityController.text.trim().isNotEmpty
                  ? double.tryParse(quantityController.text.trim())
                  : null;
              Navigator.of(ctx).pop({
                'name': nameController.text.trim(),
                'quantity': quantity,
                'unit': unitController.text.trim().isNotEmpty
                    ? unitController.text.trim()
                    : null,
                'category': categoryController.text.trim().isNotEmpty
                    ? categoryController.text.trim()
                    : null,
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _toggleItem(String itemId, bool isChecked) {
    final repo = ref.read(shoppingRepositoryProvider);
    repo.toggleItemChecked(itemId, isChecked);
  }

  void _deleteItem(String itemId) {
    final repo = ref.read(shoppingRepositoryProvider);
    repo.deleteItem(itemId);
  }

  Future<void> _handleMenuAction(String action, ShoppingList list) async {
    final repo = ref.read(shoppingRepositoryProvider);

    switch (action) {
      case 'uncheck_all':
        await repo.uncheckAllItems(widget.listId);
      case 'archive':
        await repo.archiveList(widget.listId);
        if (mounted) widget.onNavigateBack?.call();
      case 'delete':
        final confirmed = await _confirmDelete(context);
        if (confirmed && mounted) {
          await repo.deleteList(widget.listId);
          widget.onNavigateBack?.call();
        }
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete List'),
            content: const Text(
              'Are you sure you want to delete this shopping list and all its items? '
              'This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

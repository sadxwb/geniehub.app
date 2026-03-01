import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';

import '../providers/recipe_providers.dart';
import 'ingredient_list.dart';

class AddToShoppingListDialog extends ConsumerStatefulWidget {
  final String recipeId;

  const AddToShoppingListDialog({
    super.key,
    required this.recipeId,
  });

  @override
  ConsumerState<AddToShoppingListDialog> createState() =>
      _AddToShoppingListDialogState();
}

class _AddToShoppingListDialogState
    extends ConsumerState<AddToShoppingListDialog> {
  final Set<String> _selectedIngredientIds = {};
  String? _selectedListId;
  bool _isCreatingNewList = false;
  final _newListNameController = TextEditingController();
  bool _isSubmitting = false;
  List<ShoppingListInfo>? _shoppingLists;
  bool _loadingLists = true;

  @override
  void initState() {
    super.initState();
    _loadShoppingLists();
  }

  @override
  void dispose() {
    _newListNameController.dispose();
    super.dispose();
  }

  Future<void> _loadShoppingLists() async {
    final bridge = ref.read(shoppingBridgeProvider);
    try {
      final lists = await bridge.getShoppingLists();
      if (mounted) {
        setState(() {
          _shoppingLists = lists;
          _loadingLists = false;
          if (lists.isNotEmpty) {
            _selectedListId = lists.first.id;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _shoppingLists = [];
          _loadingLists = false;
        });
      }
    }
  }

  void _toggleAll(List<Ingredient> ingredients) {
    setState(() {
      if (_selectedIngredientIds.length == ingredients.length) {
        _selectedIngredientIds.clear();
      } else {
        _selectedIngredientIds
          ..clear()
          ..addAll(ingredients.map((i) => i.id));
      }
    });
  }

  Future<void> _submit(List<Ingredient> ingredients) async {
    if (_selectedIngredientIds.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final bridge = ref.read(shoppingBridgeProvider);

      String listId;
      if (_isCreatingNewList) {
        final name = _newListNameController.text.trim();
        if (name.isEmpty) {
          setState(() => _isSubmitting = false);
          return;
        }
        listId = await bridge.createList(name);
      } else if (_selectedListId != null) {
        listId = _selectedListId!;
      } else {
        setState(() => _isSubmitting = false);
        return;
      }

      final selectedIngredients = ingredients
          .where((i) => _selectedIngredientIds.contains(i.id))
          .toList();

      final items = selectedIngredients
          .map((i) => BridgeShoppingItem(
                name: i.name,
                quantity: i.quantity,
                unit: i.unit,
              ))
          .toList();

      await bridge.addItemsToList(listId, items);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add items: $e')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ingredientsAsync = ref.watch(recipeIngredientsProvider(widget.recipeId));

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ingredientsAsync.when(
            loading: () => const Center(child: LoadingWidget()),
            error: (err, _) => AppErrorWidget(message: err.toString()),
            data: (ingredients) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add to Shopping List',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                // Select/Deselect all
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _toggleAll(ingredients),
                      child: Text(
                        _selectedIngredientIds.length == ingredients.length
                            ? 'Deselect All'
                            : 'Select All',
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_selectedIngredientIds.length} selected',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Ingredients with checkboxes
                Flexible(
                  child: SingleChildScrollView(
                    child: IngredientList(
                      ingredients: ingredients,
                      showCheckboxes: true,
                      checkedIds: _selectedIngredientIds,
                      onToggle: (id) {
                        setState(() {
                          if (_selectedIngredientIds.contains(id)) {
                            _selectedIngredientIds.remove(id);
                          } else {
                            _selectedIngredientIds.add(id);
                          }
                        });
                      },
                    ),
                  ),
                ),
                const Divider(),
                // Shopping list selection
                if (_loadingLists)
                  const Center(child: LoadingWidget())
                else ...[
                  Text(
                    'Choose a Shopping List',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  if (_shoppingLists != null && _shoppingLists!.isNotEmpty && !_isCreatingNewList)
                    DropdownButtonFormField<String>(
                      value: _selectedListId,
                      items: _shoppingLists!
                          .map((list) => DropdownMenuItem(
                                value: list.id,
                                child: Text(list.name),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedListId = val),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  if (_isCreatingNewList)
                    TextField(
                      controller: _newListNameController,
                      decoration: const InputDecoration(
                        labelText: 'New list name',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      autofocus: true,
                    ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _isCreatingNewList = !_isCreatingNewList;
                        });
                      },
                      icon: Icon(_isCreatingNewList
                          ? Icons.list
                          : Icons.add),
                      label: Text(_isCreatingNewList
                          ? 'Use existing list'
                          : 'Create new list'),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _isSubmitting ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _isSubmitting || _selectedIngredientIds.isEmpty
                          ? null
                          : () => _submit(ingredients),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Add Items'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

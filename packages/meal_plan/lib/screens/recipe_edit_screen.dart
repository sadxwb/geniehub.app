import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';

import '../data/recipe_repository.dart';
import '../providers/recipe_providers.dart';

class RecipeEditScreen extends ConsumerStatefulWidget {
  /// If non-null, we are editing an existing recipe.
  final String? recipeId;
  final void Function(String recipeId)? onSaved;
  final VoidCallback? onBack;

  const RecipeEditScreen({
    super.key,
    this.recipeId,
    this.onSaved,
    this.onBack,
  });

  @override
  ConsumerState<RecipeEditScreen> createState() => _RecipeEditScreenState();
}

class _RecipeEditScreenState extends ConsumerState<RecipeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _servingsController = TextEditingController(text: '4');
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();

  List<_IngredientEntry> _ingredients = [];
  List<_StepEntry> _steps = [];

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.recipeId != null;
    if (_isEditing) {
      _loadRecipe();
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _servingsController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    for (final entry in _ingredients) {
      entry.dispose();
    }
    for (final entry in _steps) {
      entry.dispose();
    }
    super.dispose();
  }

  Future<void> _loadRecipe() async {
    final repo = ref.read(recipeRepositoryProvider);
    final recipe = await repo.getRecipe(widget.recipeId!);
    if (recipe == null || !mounted) return;

    _titleController.text = recipe.title;
    _descriptionController.text = recipe.description ?? '';
    _servingsController.text = recipe.servings.toString();
    _prepTimeController.text =
        recipe.prepTimeMinutes?.toString() ?? '';
    _cookTimeController.text =
        recipe.cookTimeMinutes?.toString() ?? '';

    // Load ingredients
    final ingredients =
        await (_ingredientsFuture(repo, widget.recipeId!));
    _ingredients = ingredients
        .map((i) => _IngredientEntry.fromIngredient(i))
        .toList();

    // Load steps
    final steps = await _stepsFuture(repo, widget.recipeId!);
    _steps = steps.map((s) => _StepEntry.fromStep(s)).toList();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<List<Ingredient>> _ingredientsFuture(
      RecipeRepository repo, String recipeId) {
    return repo.watchIngredients(recipeId).first;
  }

  Future<List<RecipeStep>> _stepsFuture(
      RecipeRepository repo, String recipeId) {
    return repo.watchSteps(recipeId).first;
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(_IngredientEntry());
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients[index].dispose();
      _ingredients.removeAt(index);
    });
  }

  void _reorderIngredients(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _ingredients.removeAt(oldIndex);
      _ingredients.insert(newIndex, item);
    });
  }

  void _addStep() {
    setState(() {
      _steps.add(_StepEntry());
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps[index].dispose();
      _steps.removeAt(index);
    });
  }

  void _reorderSteps(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _steps.removeAt(oldIndex);
      _steps.insert(newIndex, item);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(recipeRepositoryProvider);
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final servings =
          int.tryParse(_servingsController.text.trim()) ?? 4;
      final prepTime =
          int.tryParse(_prepTimeController.text.trim());
      final cookTime =
          int.tryParse(_cookTimeController.text.trim());

      String recipeId;

      if (_isEditing) {
        recipeId = widget.recipeId!;
        final existing = await repo.getRecipe(recipeId);
        if (existing == null) return;

        await repo.updateRecipe(Recipe(
          id: recipeId,
          title: title,
          description: description.isEmpty ? null : description,
          servings: servings,
          prepTimeMinutes: prepTime,
          cookTimeMinutes: cookTime,
          imageUrl: existing.imageUrl,
          createdAt: existing.createdAt,
          updatedAt: DateTime.now(),
        ));

        // Delete existing ingredients and steps, then re-create.
        final existingIngredients =
            await repo.watchIngredients(recipeId).first;
        for (final ing in existingIngredients) {
          await repo.deleteIngredient(ing.id);
        }
        final existingSteps = await repo.watchSteps(recipeId).first;
        for (final step in existingSteps) {
          await repo.deleteStep(step.id);
        }
      } else {
        final recipe = await repo.createRecipe(
          title: title,
          description: description.isEmpty ? null : description,
          servings: servings,
          prepTime: prepTime,
          cookTime: cookTime,
        );
        recipeId = recipe.id;
      }

      // Add ingredients
      for (var i = 0; i < _ingredients.length; i++) {
        final entry = _ingredients[i];
        final name = entry.nameController.text.trim();
        if (name.isEmpty) continue;
        await repo.addIngredient(
          recipeId,
          name: name,
          quantity:
              double.tryParse(entry.quantityController.text.trim()),
          unit: entry.unitController.text.trim().isEmpty
              ? null
              : entry.unitController.text.trim(),
          isOptional: entry.isOptional,
        );
      }

      // Add steps
      for (var i = 0; i < _steps.length; i++) {
        final entry = _steps[i];
        final instruction = entry.instructionController.text.trim();
        if (instruction.isEmpty) continue;
        await repo.addStep(recipeId, i + 1, instruction);
      }

      if (mounted) {
        widget.onSaved?.call(recipeId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save recipe: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: widget.onBack != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: widget.onBack,
                )
              : null,
          title: Text(_isEditing ? 'Edit Recipe' : 'New Recipe'),
        ),
        body: const Center(child: LoadingWidget()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onBack,
              )
            : null,
        title: Text(_isEditing ? 'Edit Recipe' : 'New Recipe'),
        actions: [
          FilledButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Recipe Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Servings, Prep time, Cook time row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _servingsController,
                      decoration: const InputDecoration(
                        labelText: 'Servings',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _prepTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Prep (min)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cookTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Cook (min)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Ingredients section
              Row(
                children: [
                  Text(
                    'Ingredients',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _addIngredient,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _ingredients.length,
                onReorder: _reorderIngredients,
                itemBuilder: (context, index) {
                  final entry = _ingredients[index];
                  return _IngredientRow(
                    key: entry.key,
                    entry: entry,
                    onRemove: () => _removeIngredient(index),
                    onOptionalChanged: (val) {
                      setState(() => entry.isOptional = val);
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              // Steps section
              Row(
                children: [
                  Text(
                    'Instructions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _addStep,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _steps.length,
                onReorder: _reorderSteps,
                itemBuilder: (context, index) {
                  final entry = _steps[index];
                  return _StepRow(
                    key: entry.key,
                    stepNumber: index + 1,
                    entry: entry,
                    onRemove: () => _removeStep(index),
                  );
                },
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper models
// ---------------------------------------------------------------------------

class _IngredientEntry {
  final GlobalKey key = GlobalKey();
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController unitController;
  bool isOptional;
  final String? existingId;

  _IngredientEntry({
    String name = '',
    String quantity = '',
    String unit = '',
    this.isOptional = false,
    this.existingId,
  })  : nameController = TextEditingController(text: name),
        quantityController = TextEditingController(text: quantity),
        unitController = TextEditingController(text: unit);

  factory _IngredientEntry.fromIngredient(Ingredient ingredient) {
    return _IngredientEntry(
      name: ingredient.name,
      quantity: ingredient.quantity != null
          ? (ingredient.quantity == ingredient.quantity!.roundToDouble()
              ? ingredient.quantity!.toInt().toString()
              : ingredient.quantity.toString())
          : '',
      unit: ingredient.unit ?? '',
      isOptional: ingredient.isOptional,
      existingId: ingredient.id,
    );
  }

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
  }
}

class _StepEntry {
  final GlobalKey key = GlobalKey();
  final TextEditingController instructionController;
  final String? existingId;

  _StepEntry({String instruction = '', this.existingId})
      : instructionController =
            TextEditingController(text: instruction);

  factory _StepEntry.fromStep(RecipeStep step) {
    return _StepEntry(
      instruction: step.instruction,
      existingId: step.id,
    );
  }

  void dispose() {
    instructionController.dispose();
  }
}

// ---------------------------------------------------------------------------
// Row widgets
// ---------------------------------------------------------------------------

class _IngredientRow extends StatelessWidget {
  final _IngredientEntry entry;
  final VoidCallback onRemove;
  final ValueChanged<bool> onOptionalChanged;

  const _IngredientRow({
    super.key,
    required this.entry,
    required this.onRemove,
    required this.onOptionalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.drag_handle, size: 20),
          const SizedBox(width: 4),
          SizedBox(
            width: 60,
            child: TextField(
              controller: entry.quantityController,
              decoration: const InputDecoration(
                hintText: 'Qty',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 60,
            child: TextField(
              controller: entry.unitController,
              decoration: const InputDecoration(
                hintText: 'Unit',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: entry.nameController,
              decoration: const InputDecoration(
                hintText: 'Ingredient name',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              ),
            ),
          ),
          Tooltip(
            message: 'Optional',
            child: Checkbox(
              value: entry.isOptional,
              onChanged: (val) => onOptionalChanged(val ?? false),
              visualDensity: VisualDensity.compact,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int stepNumber;
  final _StepEntry entry;
  final VoidCallback onRemove;

  const _StepRow({
    super.key,
    required this.stepNumber,
    required this.entry,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.drag_handle, size: 20),
          const SizedBox(width: 4),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$stepNumber',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: entry.instructionController,
              decoration: const InputDecoration(
                hintText: 'Describe this step...',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              maxLines: 3,
              minLines: 1,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

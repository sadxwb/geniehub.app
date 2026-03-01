import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';

class AiRecipeScreen extends ConsumerStatefulWidget {
  final void Function(String recipeId)? onRecipeCreated;
  final VoidCallback? onBack;

  const AiRecipeScreen({
    super.key,
    this.onRecipeCreated,
    this.onBack,
  });

  @override
  ConsumerState<AiRecipeScreen> createState() => _AiRecipeScreenState();
}

class _AiRecipeScreenState extends ConsumerState<AiRecipeScreen> {
  final _promptController = TextEditingController();
  bool _isGenerating = false;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _generate() {
    if (_promptController.text.trim().isEmpty) return;

    setState(() => _isGenerating = true);

    // Simulate a delay to show the placeholder experience.
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI recipe generation coming soon!'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TierGate(
      requiredTier: UserTier.pro,
      child: Scaffold(
        appBar: AppBar(
          leading: widget.onBack != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: widget.onBack,
                )
              : null,
          title: const Text('AI Recipe Generator'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header illustration / icon
              Icon(
                Icons.auto_awesome,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Generate a Recipe with AI',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Describe what kind of recipe you would like, and our AI will create one for you.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Prompt input
              TextField(
                controller: _promptController,
                decoration: InputDecoration(
                  labelText: 'What recipe would you like?',
                  hintText:
                      'e.g., A healthy chicken stir-fry with vegetables',
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                  suffixIcon: _promptController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _promptController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                maxLines: 4,
                minLines: 2,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),

              // Generate button
              FilledButton.icon(
                onPressed: _isGenerating ||
                        _promptController.text.trim().isEmpty
                    ? null
                    : _generate,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                    _isGenerating ? 'Generating...' : 'Generate Recipe'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 32),

              // Placeholder area
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.science_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'AI recipe generation coming soon',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This feature will use Gemini to generate complete recipes including ingredients, instructions, and nutritional information based on your description.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

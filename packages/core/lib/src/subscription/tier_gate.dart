import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'subscription_models.dart';
import 'subscription_provider.dart';

/// A widget that conditionally renders its [child] based on the user's tier.
///
/// If the user's tier is below [requiredTier], the [fallback] widget is shown
/// instead (defaults to a simple upgrade prompt).
class TierGate extends ConsumerWidget {
  const TierGate({
    super.key,
    required this.requiredTier,
    required this.child,
    this.fallback,
  });

  /// The minimum tier needed to see [child].
  final UserTier requiredTier;

  /// The widget to display when the user meets the tier requirement.
  final Widget child;

  /// An optional widget shown when the user does not meet the tier requirement.
  /// If omitted, a default upgrade prompt is rendered.
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTier = ref.watch(userTierProvider);

    if (currentTier.index >= requiredTier.index) {
      return child;
    }

    return fallback ?? _DefaultUpgradePrompt(requiredTier: requiredTier);
  }
}

class _DefaultUpgradePrompt extends StatelessWidget {
  const _DefaultUpgradePrompt({required this.requiredTier});

  final UserTier requiredTier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Upgrade to ${requiredTier.name} to unlock this feature',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                // TODO: Navigate to subscription / paywall screen.
              },
              child: const Text('View Plans'),
            ),
          ],
        ),
      ),
    );
  }
}

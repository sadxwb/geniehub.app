import 'package:flutter/material.dart';

/// Generic card wrapper for dashboard sections.
class DashboardWidgetContainer extends StatelessWidget {
  const DashboardWidgetContainer({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.onAction,
    this.actionLabel,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final VoidCallback? onAction;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (onAction != null && actionLabel != null)
                  TextButton(
                    onPressed: onAction,
                    child: Text(actionLabel!),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:geniehub_core/geniehub_core.dart';

/// A list tile for displaying a shopping item.
///
/// Used in both the list detail screen and the shopping mode screen.
class ShoppingItemTile extends StatelessWidget {
  const ShoppingItemTile({
    super.key,
    required this.item,
    this.onToggle,
    this.onTap,
    this.onDismissed,
    this.shoppingMode = false,
  });

  /// The shopping item to display.
  final ShoppingItem item;

  /// Called when the checkbox is toggled.
  final ValueChanged<bool>? onToggle;

  /// Called when the tile is tapped (e.g. to edit).
  final VoidCallback? onTap;

  /// Called when the tile is swiped to dismiss.
  final VoidCallback? onDismissed;

  /// Whether this tile is displayed in shopping mode (larger, bolder styling).
  final bool shoppingMode;

  String get _subtitle {
    final parts = <String>[];
    if (item.quantity != null) {
      // Show as integer if it's a whole number.
      final qty = item.quantity!;
      final qtyStr = qty == qty.roundToDouble()
          ? qty.toInt().toString()
          : qty.toStringAsFixed(1);
      parts.add(qtyStr);
    }
    if (item.unit != null && item.unit!.isNotEmpty) {
      parts.add(item.unit!);
    }
    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = shoppingMode
        ? theme.textTheme.titleLarge
        : theme.textTheme.bodyLarge;

    final tile = ListTile(
      contentPadding: shoppingMode
          ? const EdgeInsets.symmetric(horizontal: 24, vertical: 8)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Checkbox(
        value: item.isChecked,
        onChanged: onToggle != null
            ? (value) => onToggle!(value ?? false)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      title: Text(
        item.name,
        style: textStyle?.copyWith(
          decoration: item.isChecked ? TextDecoration.lineThrough : null,
          color: item.isChecked
              ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
              : null,
        ),
      ),
      subtitle: _subtitle.isNotEmpty
          ? Text(
              _subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: item.isChecked
                    ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                    : theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: item.category != null && item.category!.isNotEmpty
          ? Chip(
              label: Text(item.category!),
              visualDensity: VisualDensity.compact,
              labelStyle: theme.textTheme.labelSmall,
              padding: EdgeInsets.zero,
            )
          : null,
      onTap: onTap,
    );

    if (onDismissed != null) {
      return Dismissible(
        key: ValueKey(item.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismissed!(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          color: theme.colorScheme.error,
          child: Icon(
            Icons.delete_outline,
            color: theme.colorScheme.onError,
          ),
        ),
        child: tile,
      );
    }

    return tile;
  }
}

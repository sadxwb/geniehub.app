import 'package:flutter/material.dart';

/// A centered [CircularProgressIndicator] with an optional [message].
///
/// Used as a default loading state across all feature modules.
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.message});

  /// Optional text displayed below the spinner.
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator.adaptive(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

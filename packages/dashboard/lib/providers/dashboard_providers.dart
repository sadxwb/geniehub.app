import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier that tracks which dashboard sections are collapsed by the user.
class CollapsedSectionsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String section) {
    if (state.contains(section)) {
      state = {...state}..remove(section);
    } else {
      state = {...state, section};
    }
  }
}

final collapsedSectionsProvider =
    NotifierProvider<CollapsedSectionsNotifier, Set<String>>(
  CollapsedSectionsNotifier.new,
);

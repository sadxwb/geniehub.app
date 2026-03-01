import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_provider.dart';
import 'subscription_models.dart';

/// Derives the current [UserTier] from the authenticated user.
///
/// Automatically updates whenever [authProvider] changes.
final userTierProvider = Provider<UserTier>((ref) {
  final user = ref.watch(authProvider);
  return user.tier;
});

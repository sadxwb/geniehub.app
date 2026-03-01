import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_models.dart';
import 'auth_repository.dart';

/// Notifier that holds the current [AppUser].
///
/// Defaults to [AppUser.anonymous] (offline / free tier).
/// The host app can call [setUser] after authentication.
class AuthNotifier extends Notifier<AppUser> {
  @override
  AppUser build() => AppUser.anonymous;

  void setUser(AppUser user) => state = user;
}

/// Provides the current [AppUser].
final authProvider =
    NotifierProvider<AuthNotifier, AppUser>(AuthNotifier.new);

/// Provides an optional [AuthRepository].
///
/// This is `null` until the host app supplies a concrete implementation
/// via a provider override.
final authRepositoryProvider = Provider<AuthRepository?>((_) => null);

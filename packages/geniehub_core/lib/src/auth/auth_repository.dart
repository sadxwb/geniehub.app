import 'auth_models.dart';

/// Contract for authentication backends (Firebase, Supabase, etc.).
///
/// The main app provides a concrete implementation and overrides the
/// [authProvider] Riverpod provider at bootstrap time.
abstract class AuthRepository {
  /// A stream that emits whenever the auth state changes.
  Stream<AppUser> authStateChanges();

  /// Signs in with email and password.
  Future<AppUser> signInWithEmail(String email, String password);

  /// Creates a new account with email and password.
  Future<AppUser> signUpWithEmail(String email, String password);

  /// Signs in with Google.
  Future<AppUser> signInWithGoogle();

  /// Signs in with Apple.
  Future<AppUser> signInWithApple();

  /// Signs the current user out.
  Future<void> signOut();

  /// Deletes the current user's account.
  Future<void> deleteAccount();
}

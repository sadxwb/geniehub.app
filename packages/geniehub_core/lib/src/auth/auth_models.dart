import '../subscription/subscription_models.dart';

/// Immutable representation of the currently signed-in user.
///
/// When the user is not authenticated (offline / free tier), a default
/// anonymous instance is used -- see [AppUser.anonymous].
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.tier,
    this.photoUrl,
  });

  /// A default anonymous user used before any authentication takes place.
  static const anonymous = AppUser(
    uid: '',
    email: '',
    displayName: 'Guest',
    tier: UserTier.free,
  );

  final String uid;
  final String email;
  final String displayName;
  final UserTier tier;
  final String? photoUrl;

  /// Whether this represents an unauthenticated / offline user.
  bool get isAnonymous => uid.isEmpty;

  /// Returns a copy of this user with the given fields replaced.
  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    UserTier? tier,
    String? photoUrl,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      tier: tier ?? this.tier,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          displayName == other.displayName &&
          tier == other.tier &&
          photoUrl == other.photoUrl;

  @override
  int get hashCode => Object.hash(uid, email, displayName, tier, photoUrl);

  @override
  String toString() =>
      'AppUser(uid: $uid, displayName: $displayName, tier: $tier)';
}

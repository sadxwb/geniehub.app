/// The user's subscription tier.
enum UserTier {
  free,
  plus,
  pro,
}

extension UserTierX on UserTier {
  bool get canSync => this != UserTier.free;

  bool get canShareFamily => this != UserTier.free;

  bool get canUseAI => this == UserTier.pro;

  bool get hasAds => this == UserTier.free;
}

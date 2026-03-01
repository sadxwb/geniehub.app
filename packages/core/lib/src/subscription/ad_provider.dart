import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';
import 'subscription_models.dart';
import 'subscription_provider.dart';

/// Notifier that manages loading and providing an [InterstitialAd].
///
/// Returns `null` if the user is on a paid tier or the ad hasn't loaded yet.
/// After showing the ad, call `ref.invalidate(interstitialAdProvider)` to
/// trigger loading the next one.
class InterstitialAdNotifier extends Notifier<InterstitialAd?> {
  @override
  InterstitialAd? build() {
    final tier = ref.watch(userTierProvider);
    if (!tier.hasAds) return null;

    _loadAd();
    return null;
  }

  void _loadAd() {
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              ref.invalidateSelf();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              ref.invalidateSelf();
            },
          );
          state = ad;
        },
        onAdFailedToLoad: (_) {
          // Silently ignore — will retry on next invalidation.
        },
      ),
    );
  }
}

final interstitialAdProvider =
    NotifierProvider<InterstitialAdNotifier, InterstitialAd?>(
  InterstitialAdNotifier.new,
);

/// Helper to show an interstitial ad if one is loaded.
///
/// Usage in a callback:
/// ```dart
/// showInterstitialAd(ref);
/// ```
void showInterstitialAd(WidgetRef ref) {
  final ad = ref.read(interstitialAdProvider);
  if (ad != null) {
    ad.show();
  }
}

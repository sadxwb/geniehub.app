import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';
import 'subscription_models.dart';
import 'subscription_provider.dart';

/// Wraps its [child] with an AdMob banner when the user is on the free tier.
///
/// On paid tiers the [child] is rendered directly with no overhead.
class AdWrapper extends ConsumerWidget {
  const AdWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(userTierProvider);

    if (!tier.hasAds) {
      return child;
    }

    return Column(
      children: [
        Expanded(child: child),
        const _AdMobBanner(),
      ],
    );
  }
}

/// Displays a real AdMob banner ad.
class _AdMobBanner extends StatefulWidget {
  const _AdMobBanner();

  @override
  State<_AdMobBanner> createState() => _AdMobBannerState();
}

class _AdMobBannerState extends State<_AdMobBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null) {
      _loadAd();
    }
  }

  void _loadAd() {
    final adWidth = MediaQuery.of(context).size.width.truncate();

    _bannerAd = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      size: AdSize.getInlineAdaptiveBannerAdSize(adWidth, 60),
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      // Reserve space while ad is loading to avoid layout jumps.
      return const SizedBox(height: 60);
    }

    return SizedBox(
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

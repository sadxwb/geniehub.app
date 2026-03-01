import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized AdMob configuration for the GenieHub app.
///
/// Ad unit IDs are loaded from the `.env` file via `flutter_dotenv`.
/// The AdMob app ID is configured natively in `AndroidManifest.xml`
/// and `Info.plist` (required by the SDK before Dart code runs).
abstract final class AdConfig {
  /// Banner ad unit ID.
  static String get bannerAdUnitId =>
      dotenv.env['ADMOB_BANNER_AD_UNIT_ID'] ?? '';

  /// Interstitial ad unit ID.
  static String get interstitialAdUnitId =>
      dotenv.env['ADMOB_INTERSTITIAL_AD_UNIT_ID'] ?? '';
}

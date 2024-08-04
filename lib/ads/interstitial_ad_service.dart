import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:loggy/loggy.dart';

class InterstitialAdService with UiLoggy {
  InterstitialAd? _interstitialAd;

  // TODO: replace this test ad unit with your own ad unit.
  final adUnitId = 'ca-app-pub-3940256099942544/1033173712';

  void loadAd() {
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              loggy.error('InterstitialAd failed to show full screen content: $err');
              ad.dispose();
            },
            onAdDismissedFullScreenContent: (ad) {
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
              ad.dispose();
            },
          );

          loggy.info('$ad loaded.');

          _interstitialAd = ad;
          _interstitialAd?.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          loggy.error('InterstitialAd failed to load: $error');
        },
      ),
    );
  }
}

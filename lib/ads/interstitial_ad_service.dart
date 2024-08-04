import 'dart:io';

import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:loggy/loggy.dart';

class InterstitialAdService with UiLoggy {
  InterstitialAd? _interstitialAd;

  void loadAd() {
    // TODO: replace this test ad unit with your own ad unit.
    // Sample adUnitId: ca-app-pub-3940256099942544/1033173712
    const adUnitId = String.fromEnvironment('AD_UNIT_ID');
    if (adUnitId.isEmpty) {
      loggy.error("Failed to load AD_UNIT_ID!");
      exit(1);
    }

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

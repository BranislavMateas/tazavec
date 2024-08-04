import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:loggy/loggy.dart';
import 'package:tazavec/app.dart';

const String appTitle = "Tazavec";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(MobileAds.instance.initialize());

  Loggy.initLoggy();

  runApp(const App());
}

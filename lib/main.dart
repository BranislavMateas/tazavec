import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loggy/loggy.dart';
import 'package:tazavec/app.dart';

const String appTitle = "Tazavec";

void main() {
  Loggy.initLoggy();

  runApp(const App());
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:geniehub_core/geniehub_core.dart'; // Add this line

import 'app.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final talker = TalkerFlutter.init(
    settings: TalkerSettings(
      useConsoleLogs: true,
      useHistory: true,
    ),
  );

  FlutterError.onError = (details) {
    talker.handle(details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    talker.handle(error, stack);
    return true;
  };

  talker.info('Initializing application...');

  await dotenv.load();
  MobileAds.instance.initialize();

  runApp(
    ProviderScope(
      overrides: buildAppProviderOverrides(talker),
      observers: [TalkerRiverpodObserver(talker: talker)],
      child: const GenieHubApp(),
    ),
  );
}
